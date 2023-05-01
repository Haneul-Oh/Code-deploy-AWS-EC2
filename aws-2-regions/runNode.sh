#!/bin/bash

curPATH=$(pwd)

BSP_REGION=${REGION:0:1}
AUDITOR_REGION=${REGION:1:1}
CLIENT_REGION=${REGION:2:1}

args=${1}
args_1=${args:0:1}
args_2=${args:1:1}
args_3=${args:2:1}
counts=${2}

BSP_KEY="~/keystore/hanuri_seoul_4.pem"
AUDITOR_SEO_KEY="~/keystore/hanuri_seoul_4.pem"
AUDITOR_VIR_KEY="~/keystore/hanuri_virginia_4.pem"
AUDITOR_FRA_KEY="~/keystore/hanuri_frankfrut_4.pem"
AUDITOR_SIN_KEY="~/keystore/hanuri_singapore.pem"
AUDITOR_CAL_KEY="~/keystore/hanuri_califonia.pem"
AUDITOR_IRE_KEY="~/keystore/hanuri_ireland.pem"
CLIENT_KEY="~/keystore/hanuri_seoul_4.pem"

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

function run {

   # PRUNE Client 
   for ip in ${clients_seo[@]}; do
      ssh -i ${CLIENT_KEY} ubuntu@${ip} "~/2022/bsp_210817_base/edgechain_prune.sh" &
      ssh -i ${CLIENT_KEY} ubuntu@${ip} "sudo rm -rf ~/2022/bsp_210817_base/log/*.txt && sudo rm -rf ~/2022/transaction_work/caliper-workspace/caliper.log" &
   done

   # PRUNE BSP 
   ssh -i ${BSP_KEY} ubuntu@${BSP} "~/2022/bsp_210817_base/edgechain_prune.sh; sudo rm -rf ./2022/bsp_210817_base/log/*.txt" & 

   # PRUNE Auditor
   for ip in ${auditors_seo[@]}; do
      ssh -i ${AUDITOR_SEO_KEY} ubuntu@${ip} "./2022/auditchain/bsstore/demo/docker/auditchain_prune.sh; sudo rm -rf ./2022/auditchain/bsstore/demo/docker/log/*.txt" & 
   done
   for ip in ${auditors_vir[@]}; do
      ssh -i ${AUDITOR_VIR_KEY} ubuntu@${ip} "./2022/auditchain/bsstore/demo/docker/auditchain_prune.sh; sudo rm -rf ./2022/auditchain/bsstore/demo/docker/log/*.txt" & 
   done
   for ip in ${auditors_fra[@]}; do
      ssh -i ${AUDITOR_FRA_KEY} ubuntu@${ip} "./2022/auditchain/bsstore/demo/docker/auditchain_prune.sh; sudo rm -rf ./2022/auditchain/bsstore/demo/docker/log/*.txt" & 
   done
   for ip in ${auditors_sin[@]}; do
      ssh -i ${AUDITOR_SIN_KEY} ubuntu@${ip} "./2022/auditchain/bsstore/demo/docker/auditchain_prune.sh; sudo rm -rf ./2022/auditchain/bsstore/demo/docker/log/*.txt" & 
   done
   for ip in ${auditors_cal[@]}; do
      ssh -i ${AUDITOR_CAL_KEY} ubuntu@${ip} "./2022/auditchain/bsstore/demo/docker/auditchain_prune.sh; sudo rm -rf ./2022/auditchain/bsstore/demo/docker/log/*.txt" & 
   done
   for ip in ${auditors_ire[@]}; do
      ssh -i ${AUDITOR_IRE_KEY} ubuntu@${ip} "./2022/auditchain/bsstore/demo/docker/auditchain_prune.sh; sudo rm -rf ./2022/auditchain/bsstore/demo/docker/log/*.txt" & 
   done
   sleep 30
 

   # RUN BSP 
   if [ ${args_1} -eq 1 ]
   then
      echo "## START BSP"
      ssh -i ${BSP_KEY} ubuntu@${BSP} " cd ~/2022/bsp_210817_base; ./auditchain_rollback.sh"
      sleep 5
   fi

   # RUN Auditor
   if [ ${args_2} -eq 1 ]
   then
      echo "## START AUDITOR"
      rm -rf ./log/auditor_*.txt
      for ip in ${auditors_seo[@]}; do
         ssh -i ${AUDITOR_SEO_KEY} ubuntu@${ip} "cd 2022/auditchain/bsstore/demo/docker/; ./auditchain_rollback_dis.sh" &
      done
      for ip in ${auditors_vir[@]}; do
         ssh -i ${AUDITOR_VIR_KEY} ubuntu@${ip} "cd 2022/auditchain/bsstore/demo/docker/; ./auditchain_rollback_dis.sh" &
      done
      for ip in ${auditors_fra[@]}; do
         ssh -i ${AUDITOR_FRA_KEY} ubuntu@${ip} "cd 2022/auditchain/bsstore/demo/docker/; ./auditchain_rollback_dis.sh" &
      done
      for ip in ${auditors_sin[@]}; do
         ssh -i ${AUDITOR_SIN_KEY} ubuntu@${ip} "cd 2022/auditchain/bsstore/demo/docker/; ./auditchain_rollback_dis.sh" & 
      done
      for ip in ${auditors_cal[@]}; do
         ssh -i ${AUDITOR_CAL_KEY} ubuntu@${ip} "cd 2022/auditchain/bsstore/demo/docker/; ./auditchain_rollback_dis.sh" & 
      done
      for ip in ${auditors_ire[@]}; do
         ssh -i ${AUDITOR_IRE_KEY} ubuntu@${ip} "cd 2022/auditchain/bsstore/demo/docker/; ./auditchain_rollback_dis.sh" & 
      done
      sleep 50
   fi

   # RUN Client 
   if [ ${args_3} -eq 1 ]
   then
      echo "## START CLIENT"
      rm -rf ./log/client_*.txt
      for ip in ${clients_seo[@]}; do
         ssh -i ${CLIENT_KEY} ubuntu@${ip} "cd 2022/bsp_210817_base; ./agg.sh" &
      done
      sleep 15

      for (( i=0; i<${sizeClient_seo}; i++ )); do
         ssh -i ${CLIENT_KEY} ubuntu@${clients_seo[i]} "cd 2022/transaction_work; ./runmini.sh" > ./log/client_${i}.txt &
      done
      sleep 130 #sleep 840 # 14 * 60 in case of sendrate=500 
   fi

   return 1
}


for (( j=0; j <${counts}; j++ ))
do
   echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"  $j-th Running ...
   start_time=`date +%s`
   run
   end_time=`date +%s`
   echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"  execution time was `expr $end_time - $start_time` s.
   echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"  $j-th Resulting ...
   sleep 5
   ./makeResult.sh 
done

# echo ${checkContainerLives}
# checkContainerLives

# run