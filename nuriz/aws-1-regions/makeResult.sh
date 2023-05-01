#!/bin/bash

curPATH=$(pwd)

BSP_KEY="~/keystore/hanuri_seoul_4.pem"
AUDITOR_SEO_KEY="~/keystore/hanuri_seoul_4.pem"
AUDITOR_VIR_KEY="~/keystore/hanuri_virginia_4.pem"
AUDITOR_FRA_KEY="~/keystore/hanuri_ireland.pem"
CLIENT_KEY="~/keystore/hanuri_seoul_4.pem"

BSP=$(cat ${curPATH}/bsp_ip_seo.txt |tail -1)
auditors_seo=()
auditors_vir=()
auditors_fra=()
clients_seo=()

file="${curPATH}/auditor_ip_seo.txt"
while IFS= read -r line; do
    auditors_seo+=(${line})
done < $file
file="${curPATH}/auditor_ip_vir.txt"
while IFS= read -r line; do
    auditors_vir+=(${line})
done < $file
file="${curPATH}/auditor_ip_fra.txt"
while IFS= read -r line; do
    auditors_fra+=(${line})
done < $file
file="${curPATH}/client_ip_seo.txt"
while IFS= read -r line; do
    clients_seo+=(${line})
done < $file

sizeAuditor_seo=${#auditors_seo[@]}
sizeAuditor_vir=${#auditors_vir[@]}
sizeAuditor_fra=${#auditors_fra[@]}
sizeAuditor_total=$((${sizeAuditor_seo}+${sizeAuditor_vir}+${sizeAuditor_fra}))
sizeClient_seo=${#clients_seo[@]}

alpha=()
beta=()
phase1_latency=()
phase2_latency=()
tmp=()
BToC=()
hash_interval=() # start to receive the previous thing
block_interval=()
hash_boadcast=() # start to send point 
block_boadcast=()
tps=()
latency=()
sendrate=()
block_size=()
hash_size=()
block_send=()
pipeline_depth=()
commitWithQC=()
commitWithCo=()
from_block_send_to_aggregator=()
Throughput=()
Latency=()
SendRate=()
timerFromBSPToAgg=()
TimeFromTXReceiveToBlockDelivery=()


BlockReceive=()
HashReceive=()
CiCreate=()
PrepareStart=()
PrepareEnd=()
CommitStart=()
CommitEnd=()
PresistResult=()
commitWithPr=()




function readResults {
    fname=$1
    sub="sendPayment   | * | 0"

    while read line; do
        if [[ "${line}" == *${sub}* ]]; then
            arr=(${line})
            tps+=(${arr[17]})
            latency+=(${arr[15]})
            sendrate+=(${arr[9]})
            echo ${arr[17]}, ${arr[15]}, ${arr[9]}
            return 1
        fi
    done < ${fname} 
    return 0
}

# ok=1
for (( i=0; i<${sizeClient_seo}; i++ ))
do
    ok=1    
    fname="${curPATH}/log/client_${i}.txt"
    readResults ${fname}
    ok=$((${ok}*${?})) 
    if [ ${ok} -eq 0 ]; then
        printf "Fail to find Successful outcome in client log file.\n" 
        # exit 100
    fi
done

rm -rf ./log/*log*.txt
scp -i ${BSP_KEY} ubuntu@${BSP}:~/2022/bsp_210817_base/log/bsp-logs.txt ./log/bsp_log.txt
for (( i=0; i<${sizeClient_seo}; i++ )); do
    scp -i ${CLIENT_KEY} ubuntu@${clients_seo[i]}:~/2022/bsp_210817_base/log/agg_log.txt ./log/agg_log_${i}.txt &
done
for (( i=0; i<${sizeAuditor_seo}; i++ )); do
    scp -i ${AUDITOR_SEO_KEY} ubuntu@${auditors_seo[i]}:~/2022/auditchain/bsstore/demo/docker/log/test-logs.txt ./log/log_${i}.txt &
done
for (( i=0; i<${sizeAuditor_vir}; i++ )); do
    j=$((${i}+${sizeAuditor_seo}))
    scp -i ${AUDITOR_VIR_KEY} ubuntu@${auditors_vir[i]}:~/2022/auditchain/bsstore/demo/docker/log/test-logs.txt ./log/log_${j}.txt &
done
for (( i=0; i<${sizeAuditor_fra}; i++ )); do
    j=$((${i}+${sizeAuditor_seo}+${sizeAuditor_vir}))
    scp -i ${AUDITOR_FRA_KEY} ubuntu@${auditors_fra[i]}:~/2022/auditchain/bsstore/demo/docker/log/test-logs.txt ./log/log_${j}.txt &
done
sleep 5


function split {
    file="./log/log_${1}.txt"
    while IFS= read -r line; do
        strings=${line##*logger.go:30:}
        arr=($strings)
        
        case ${arr[0]} in
            Diff)
                alpha+=(${arr[1]})
                ;;
            Consensus)
                beta+=(${arr[1]})
                ;;
            Phase1)
                phase1_latency+=(${arr[1]})
                ;;
            Phase2)
                phase2_latency+=(${arr[1]})
                ;;
            HashRecvTimeInterval)
                hash_interval+=(${arr[1]})
                ;;
            BlockRecvTimeInterval)
                block_interval+=(${arr[1]})
                ;;
            HashBroadcast)
                hash_boadcast+=(${arr[1]})
                ;;
            BlockBroadcast) 
                block_boadcast+=(${arr[1]})
                ;;
            BlockGenration) 
                block_send+=(${arr[1]})
                ;;
            TimeFromBSPToCommit)
                BToC+=(${arr[1]})
                ;;
            BlockSize)
                block_size+=(${arr[1]})
                ;;
            PipelineDepth)
                pipeline_depth+=(${arr[1]})
                ;;
            CommitWithQC)
                commitWithQC+=(${arr[1]})
                ;;
            CommitWithCommit)
                commitWithCo+=(${arr[1]})
                ;;
            CommitWithPrepare)
                commitWithPr+=(${arr[1]})
                ;;
            BlockReceive)
                BlockReceive+=(${arr[1]})
                ;;
            HashReceive)
                HashReceive+=(${arr[1]})
                ;;
            CiCreate)
                CiCreate+=(${arr[1]})
                ;;
            PrepareStart)
                PrepareStart+=(${arr[1]})
                ;;
            PrepareEnd)
                PrepareEnd+=(${arr[1]})
                ;;
            CommitStart)
                CommitStart+=(${arr[1]})
                ;;
            CommitEnd)
                CommitEnd+=(${arr[1]})
                ;;
            PresistResult)
                PresistResult+=(${arr[1]})
                ;;
            esac
    done < $file
}

# split the data from log files
for (( i=0; i<${sizeAuditor_total}; i++ )); do
    split ${i}
done

function extractDataFromAggLogs {
    file="./log/agg_log_${1}.txt"
    while IFS= read -r line; do
        strings=${line##*logger.go:30:}
        arr=($strings)
    
        case ${arr[0]} in
            timerFromBSPToAgg)
                timerFromBSPToAgg+=(${arr[1]})
                ;;
            Throughput)
                Throughput+=(${arr[1]})
                ;;
            Latency)
                Latency+=(${arr[1]})
                ;;
            SendRate)
                SendRate+=(${arr[1]})
                ;;
            esac
    done < $file
}

# split the data from log files
for (( i=0; i<${sizeClient_seo}; i++ )); do
    extractDataFromAggLogs ${i}
done

function extractDataFromBSPLogs {
    file="./log/bsp_log.txt"
    while IFS= read -r line; do
        strings=${line##*logger.go:30:}
        arr=($strings)
    
        case ${arr[0]} in
            TimeFromTXReceiveToBlockDelivery)
                TimeFromTXReceiveToBlockDelivery+=(${arr[1]})
                ;;
            esac
    done < $file
}
extractDataFromBSPLogs


function avg_aud {
    arr=("${!1}")
    if [ ${#arr[@]} -gt 0 ]; then
    # if [ ${#arr[@]} -eq ${sizeAuditor_total} ]; then
        sum=0
        for v in ${arr[@]}; do
            sum=`echo "$sum + $v" | bc -l`
        done
        avg=`echo "$sum / ${#arr[@]}" | bc -l`
        printf "%0.2f " "$avg" >> ./log/result.txt
    else
        printf "0 " >> ./log/result.txt
    fi 
}
# function avg_aud {
#     arr=("${!1}")
#     # if [ ${#arr[@]} -gt 0 ]; then
#     if [ ${#arr[@]} -eq ${sizeAuditor_total} ]; then
#         sum=0
#         for v in ${arr[@]}; do
#             sum=`echo "$sum + $v" | bc -l`
#         done
#         avg=`echo "$sum / ${#arr[@]}" | bc -l`
#         printf "%0.2f " "$avg" >> ./log/result.txt
#     else
#         printf "0 " >> ./log/result.txt
#     fi 
# }
function avg {
    arr=("${!1}")
    if [ ${#arr[@]} -gt 0 ]; then
        sum=0
        for v in ${arr[@]}; do
            sum=`echo "$sum + $v" | bc -l`
        done
        avg=`echo "$sum / ${#arr[@]}" | bc -l`
        printf "%0.2f " "$avg" >> ./log/result.txt
    else
        printf "0 " >> ./log/result.txt
    fi 
}
function sum {
    arr=("${!1}")
    if [ ${#arr[@]} -gt 0 ]; then
        sum=0
        for v in ${arr[@]}; do
            sum=`echo "$sum + $v" | bc -l`
        done
        printf "%0.2f " "$sum" >> ./log/result.txt
    else
        printf "0 " >> ./log/result.txt
    fi 
}
function statist {
    avg_aud "block_send[@]" "bse"
    avg_aud "block_size[@]" "bsi"

    sum "tps[@]" "tps"
    avg "latency[@]" "lay"

    avg_aud "alpha[@]" "alp"
    avg_aud "beta[@]" "bet"
    avg_aud "phase1_latency[@]" "p1"
    avg_aud "hash_interval[@]" "h-r"
    avg_aud "block_interval[@]" "b-r"
    avg_aud "hash_boadcast[@]" "h-b"
    avg_aud "block_boadcast[@]" "b-b"

    sum "sendrate[@]" "sen"

    avg_aud "pipeline_depth[@]" "b-b"
    avg_aud "commitWithQC[@]" "b-b"
    avg_aud "commitWithCo[@]" "b-b"
    avg_aud "commitWithPr[@]" "b-b"
    
    avg_aud "phase2_latency[@]" "p2"
    avg "timerFromBSPToAgg[@]" "tmp3"

    avg "TimeFromTXReceiveToBlockDelivery[@]" "TimeFromTXReceiveToBlockDelivery"

    
    avg_aud "BlockReceive[@]" "b-b"
    avg_aud "HashReceive[@]" "b-b"
    avg_aud "CiCreate[@]" "b-b"
    avg_aud "PrepareStart[@]" "b-b"
    avg_aud "PrepareEnd[@]" "b-b"
    avg_aud "CommitStart[@]" "b-b"
    avg_aud "CommitEnd[@]" "b-b"
    avg_aud "PresistResult[@]" "b-b"

    echo "" >> ./log/result.txt
    echo $(tail -n 1 ./log/result.txt)
}

# statistics about datas 
statist

