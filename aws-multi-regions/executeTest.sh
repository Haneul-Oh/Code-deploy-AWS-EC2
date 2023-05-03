#!/bin/bash

curPATH=$(pwd)

BSP=$(cat ${curPATH}/bsp_ip_seo.txt |tail -1)
auditors_seo=()
auditors_vir=()
auditors_fra=()
auditors_sin=()
auditors_cal=()
auditors_ire=()
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
file="${curPATH}/auditor_ip_sin.txt"
while IFS= read -r line; do
    auditors_sin+=(${line})
done < $file
file="${curPATH}/auditor_ip_cal.txt"
while IFS= read -r line; do
    auditors_cal+=(${line})
done < $file
file="${curPATH}/auditor_ip_ire.txt"
while IFS= read -r line; do
    auditors_ire+=(${line})
done < $file
file="${curPATH}/client_ip_seo.txt"
while IFS= read -r line; do
    clients_seo+=(${line})
done < $file

sizeAuditor_seo=${#auditors_seo[@]}
sizeAuditor_vir=${#auditors_vir[@]}
sizeAuditor_fra=${#auditors_fra[@]}
sizeAuditor_sin=${#auditors_sin[@]}
sizeAuditor_cal=${#auditors_cal[@]}
sizeAuditor_ire=${#auditors_ire[@]}
sizeAuditor_total=$((${sizeAuditor_seo}+${sizeAuditor_vir}+${sizeAuditor_fra}+${sizeAuditor_sin}+${sizeAuditor_cal}+${sizeAuditor_ire}))
sizeClient_seo=${#clients_seo[@]}

## Additionally, Install docker and docker-compoase && Set docker swarm 
## seoul BSP 
## docker swarm leave -f && docker swarm init && docker swarm join-ireen manager && sudo docker network create --attachable --driver overlay edgechain0 && sudo docker network create --attachable --driver overlay mec

## docker swarm init --advertise-addr 3.37.181.153 && docker swarm join-ireen manager && sudo docker network create --attachable --driver overlay edgechain0 && sudo docker network create --attachable --driver overlay mec
## docker swarm leave -f && docker swarm join --ireen SWMTKN-1-61gxgv39asnvrpuzw2ylwmbl6scz9mh9ujpm7woooueo6rd70w-6418fhpmn4uxl58c0g7ghr3fy 3.37.181.153:2377
## Virginia BSP 
## docker swarm leave -f &&  docker swarm join --ireen SWMTKN-1-2bq7o9t4sul0wb2xea8bbs06uge7wp9ukufzkoztmwss2cwum2-1pkgku0d30lud886emvsfi85q 52.21.8.83:2377

## COPY YAML FILE 
function copyClientYaml {
    # ${curPATH}/client/scaleOut.sh
    for (( i=0; i<${sizeClient_seo}; i++ ))
    do
        # echo ">> COPY CLIENT YAML FILE to " ${clients_seo[i]}
        ./c-copy.sh yaml ${clients_seo[i]} "seo" ${i} &
    done
}
function copyAuditorYaml {
    # ${curPATH}/auditor/scaleOut.sh
    for (( i=0; i<${sizeAuditor_seo}; i++ )); do
        ./a-copy.sh yaml ${auditors_seo[i]} "seo" ${i} &
    done
    for (( i=0; i<${sizeAuditor_vir}; i++ )); do
        ./a-copy.sh yaml ${auditors_vir[i]} "vir" ${i} &
    done
    for (( i=0; i<${sizeAuditor_fra}; i++ )); do
        ./a-copy.sh yaml ${auditors_fra[i]} "fra" ${i} &
    done
    for (( i=0; i<${sizeAuditor_sin}; i++ )); do
        ./a-copy.sh yaml ${auditors_sin[i]} "sin" ${i} &
    done
    for (( i=0; i<${sizeAuditor_cal}; i++ )); do
        ./a-copy.sh yaml ${auditors_cal[i]} "cal" ${i} &
    done
    for (( i=0; i<${sizeAuditor_ire}; i++ )); do
        ./a-copy.sh yaml ${auditors_ire[i]} "ire" ${i} &
    done
}
function copyBSPYaml {
    # ${curPATH}/bsp/scaleOut.sh
    ./b-copy.sh yaml ${BSP} $REGIONS &
}

## COPY IMAGE FILE 
function copyClientImage {
    for (( i=0; i<${sizeClient_seo}; i++ ))
    do
        echo ">> COPY CLIENT IMAGE FILE to " ${clients_seo[i]} ${i}
        ./c-copy.sh imageDownload ${clients_seo[i]} "seo" ${i}
    done
}
function copyAuditorImage {
    for (( i=0; i<${sizeAuditor_seo}; i++ )); do
        echo ">> COPY AUDITOR IMAGE FILE to " ${auditors_seo[i]} ${i}
        ./a-copy.sh image ${auditors_seo[i]} "seo" ${i}
    done
    for (( i=0; i<${sizeAuditor_vir}; i++ )); do
        echo ">> COPY AUDITOR IMAGE FILE to " ${auditors_vir[i]} ${i}
        ./a-copy.sh image ${auditors_vir[i]} "vir" ${i}
    done
    for (( i=0; i<${sizeAuditor_fra}; i++ )); do
        echo ">> COPY AUDITOR IMAGE FILE to " ${auditors_fra[i]} ${i}
        ./a-copy.sh image ${auditors_fra[i]} "fra" ${i}
    done
    for (( i=0; i<${sizeAuditor_sin}; i++ )); do
        echo ">> COPY AUDITOR IMAGE FILE to " ${auditors_sin[i]} ${i}
        ./a-copy.sh image ${auditors_sin[i]} "sin" ${i}
    done
    for (( i=0; i<${sizeAuditor_cal}; i++ )); do
        echo ">> COPY AUDITOR IMAGE FILE to " ${auditors_cal[i]} ${i}
        ./a-copy.sh image ${auditors_cal[i]} "cal" ${i}
    done
    for (( i=0; i<${sizeAuditor_ire}; i++ )); do
        echo ">> COPY AUDITOR IMAGE FILE to " ${auditors_ire[i]} ${i}
        ./a-copy.sh image ${auditors_ire[i]} "ire" ${i}
    done
}

function copyBSPImage {
    ./b-copy.sh image ${BSP} $REGIONS
}

## COPY Code FILE 
function copyClientCode {
    for (( i=0; i<${sizeClient_seo}; i++ )); do
        ./c-copy.sh code ${clients_seo[i]} "seo" ${i} &
    done
}

# CHANGE PARAMETER of Config FIle 
function changeParameters {

    declare -a fields=("$1:$2" "$3:$4" "$5:$6" "$7:$8" "$9:${10}" "${11}:${12}" "${13}:${14}")
    bsp_file="${curPATH}/bsp/config/edgechain0_seo_.yaml" 
    aud_file="${curPATH}/auditor/config/auditchain_dis.yaml"
    cli_file="${curPATH}/client/config/config_client0_edgechain0.yaml"
    agg_file="${curPATH}/client/config/agg.yaml"
    sendrate=""

    printf "\n... >> TEST >> [#auditor: %d] " "${sizeAuditor_total}" >> ./log/result.txt
    for pair in ${fields[@]}; do
        key="${pair%%:*}"
        value="${pair##*:}"
        if [ $key == "-pipelining" ]; then 
            str="      - PIPELINING_OPTION=${value}"
            sed -i "61s/.*/${str}/g" ${aud_file}
            printf "pipelining %d " "${value}" >> ./log/result.txt

        elif [ $key == "-overlapping" ]; then 
            str="      - OVERLAPPING_OPTION=${value}"
            sed -i "60s/.*/${str}/g" ${bsp_file}
            sed -i "60s/.*/${str}/g" ${aud_file}
            printf "overlapping %d " "${value}" >> ./log/result.txt

        elif [ $key == "-client" ]; then 
            str="      - NUM_CLIENTS=${value}"
            sed -i "59s/.*/${str}/g" ${bsp_file}
            sed -i "59s/.*/${str}/g" ${aud_file}
            printf "client %d " "${value}" >> ./log/result.txt

        elif [ $key == "-sendrate" ]; then 
            str="    tps: ${value}"
            sed -i "10s/.*/${str}/g" ${cli_file}
            printf "sendrate %d " "${value}" >> ./log/result.txt
            sendrate=${value}

        elif [ $key == "-batchsize" ]; then 
            str="      - BATCH_SIZE=${value}"
            sed -i "56s/.*/${str}/g" ${bsp_file}
            sed -i "56s/.*/${str}/g" ${aud_file}
            printf "!!batchsize!! %d " "${value}" >> ./log/result.txt

        elif [ $key == "-accounts" ]; then 
            str="      - TX_NUMBERS_ROUND1=${value}"
            echo ${str}
            sed -i "57s/.*/${str}/g" ${bsp_file}
            sed -i "57s/.*/${str}/g" ${aud_file}
            sed -i "36s/.*/${str}/g" ${agg_file}
            str="  accounts: ${value}"
            sed -i "13s/.*/${str}/g" ${cli_file}
            str="    txNumber: ${value}"
            sed -i "22s/.*/${str}/g" ${cli_file}
            printf "accounts %d " "${value}" >> ./log/result.txt
            
        # elif [ $key == "-txNumber" ]; then 
        #     str="      - TOTALTX=${value}"
        #     sed -i "68s/.*/${str}/g" ${aud_file}
        #     str="    txNumber: ${value}"
        #     sed -i "28s/.*/${str}/g" ${cli_file}
        #     str="      - TX_NUMBERS_ROUND2=${value}"
        #     sed -i "37s/.*/${str}/g" ${agg_file}
        #     printf "txNumber %d " "${value}" >> ./log/result.txt

        elif [ $key == "-txDuration" ]; then 
            txNumber=$((${sendrate}*${value}))
            str="      - TX_NUMBERS_ROUND2=${txNumber}"
            echo ${str}
            sed -i "58s/.*/${str}/g" ${bsp_file}
            sed -i "58s/.*/${str}/g" ${aud_file}
            sed -i "37s/.*/${str}/g" ${agg_file}
            str="    txNumber: ${txNumber}"
            sed -i "28s/.*/${str}/g" ${cli_file}
            printf "txNumber %d " "${txNumber}" >> ./log/result.txt

        # elif [ $key == "-interval" ]; then 
        #     str="      - ESTIMATION_BEFORE_INTERVAL=${value%%,*}"
        #     sed -i "57s/.*/${str}/g" ${aud_file}
        #     str="      - ESTIMATION_INTERVAL=${value##*,}"
        #     sed -i "58s/.*/${str}/g" ${aud_file}
        #     printf "interval (%s) " "${value}" >> ./log/result.txt

        # elif [ $key == "-endHeight" ]; then 
        #     str="      - END_HEIGHT=${value}"
        #     sed -i "70s/.*/${str}/g" ${aud_file}
        fi
    done
    printf "\n" >> ./log/result.txt

    copyClientYaml
    copyBSPYaml
    copyAuditorYaml
    sleep 20
}



# interval_batchsize="30s,1m20s" # 2 seoul & 2 virginia
# interval_batchsize="10s,30s" # all seoul 
# interval_sendrate=([500]="3m30s,4m30s" [1000]="3m30s,4m30s" [1500]="3m30s,4m30s" [2000]="3m30s,4m30s" [2500]="3m30s,4m30s" [3000]="3m30s,4m30s")
# endHeight_sendrate=([500]=368 [1000]=3 [1500]=3 [2000]=3 [2500]=3 [3000]=3)

function execute_batchsize {
    batchsize=${10}
    # interval=${interval_batchsize}
    echo ">> EXECUTION execute_batchsize TEST with" ${batchsize} "batchsize"
    changeParameters -pipelining ${2} -overlapping ${4} -client ${6} -sendrate ${8} -batchsize ${batchsize} -accounts ${12} -txDuration ${14}
    ./runNode.sh 111 ${16}
}

# copyClientYaml
# copyBSPYaml
# copyAuditorImage
# copyClientImage
# copyBSPImage

# copyAuditorImage


for i in 400 ; do
    execute_batchsize -pipelining 1 -overlapping 0 -client ${sizeClient_seo} -sendrate ${i} -batchsize 100 -accounts $((${i}*30)) -txDuration 60 -counts 1
done 
