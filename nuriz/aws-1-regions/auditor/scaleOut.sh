#!/bin/bash

curPATH=$(pwd)

## Extract IPs
BSP=$(cat ${curPATH}/bsp_ip_seo.txt |tail -1)
auditors_seo=()
auditors_vir=()
auditors_fra=()
client_seo=()

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
    client_seo+=(${line})
done < $file

sizeAuditor_seo=${#auditors_seo[@]}
sizeAuditor_vir=${#auditors_vir[@]}
sizeAuditor_fra=${#auditors_fra[@]}
sizeAuditor_total=$((${sizeAuditor_seo}+${sizeAuditor_vir}+${sizeAuditor_fra}))
size_f=$((${sizeAuditor_total}/3))
sizeClient=${#client_seo[@]}

cd "${curPATH}/auditor/config"
rm -rf "./auditchain_dis_"*

committee_list="auditor0:8000"
nodeIP_list="${auditors_seo[0]}"
for (( i=1; i <${sizeAuditor_total}; i++ )); do
    new="auditor${i}:8000"
    committee_list="${committee_list},${new}"
done

nodeIP_list="${auditors_seo[0]}"
for (( i=1; i <${sizeAuditor_seo}; i++ )); do
    new="${auditors_seo[i]}"
    nodeIP_list="${nodeIP_list},${new}"
done
for (( i=0; i <${sizeAuditor_vir}; i++ )); do
    new="${auditors_vir[i]}"
    nodeIP_list="${nodeIP_list},${new}"
done
for (( i=0; i <${sizeAuditor_fra}; i++ )); do
    new="${auditors_fra[i]}"
    nodeIP_list="${nodeIP_list},${new}"
done
# echo ${nodeIP_list}

## Edit BSP IP of Extra host field
fname="./auditchain_dis.yaml"
BSP=$(cat ${curPATH}/bsp_ip_seo.txt |tail -1)
col=$(grep -n "extra_hosts:" ./${fname} | cut -d':' -f1)
sed -i "$((${col}+1))s/.*/      - \"orderer.example.com:${BSP}\"/g" ${fname}
sed -i "$((${col}+2))s/.*/      - \"orderer2.example.com:${BSP}\"/g" ${fname}
sed -i "$((${col}+3))s/.*/      - \"bsp1.executor.edgechain0:${BSP}\"/g" ${fname}
sed -i "$((${col}+4))s/.*/      - \"peer0.org1.example.com:${BSP}\"/g" ${fname}

## Edit Client IP of Extra host field
for (( i=0; i <${sizeClient}; i++ )); do
    sed -i "$((${col}+5+${i}))s/.*/      - \"aggregator$((${i}+1)).edgechain0.com:${client_seo[i]}\"/g" ${fname}
done


## Replicate Config File
for (( i=0; i <${sizeAuditor_seo}; i++ ))
do
    fname="./auditchain_dis_seo_${i}.yaml"
    cp "./auditchain_dis.yaml" ${fname}
    sed -i "15s/.*/  auditor${i}:/g" ${fname}
    sed -i "16s/.*/    container_name: auditor${i}/g" ${fname}
    sed -i "42s/.*/      - CORE_OPERATIONS_LISTENADDRESS=auditor${i}:9443/g" ${fname}
    sed -i "48s/.*/      - EDGECHAIN_NODE_NAME=auditor$((${i}+1)).edgechain0.com/g" ${fname}
    sed -i "52s/.*/      - AUDITOR_ADDRESS=auditor$((${i}+1)).edgechain0.com:10000/g" ${fname}
    sed -i "53s/.*/      - SECONDARY_ADDRESS=auditor${i}:8000/g" ${fname}
    sed -i "54s/.*/      - CHANGER_ADDRESS=auditor${i}:8001/g" ${fname}
    sed -i "55s/.*/      - SECONDARY_ADDRESS_LIST=${committee_list}/g" ${fname}
    sed -i "64s/.*/      - NUM_AUDITORS=${sizeAuditor_total}/g" ${fname}
    sed -i "68s/.*/      - COMMITTEESIZE=${sizeAuditor_total}/g" ${fname}
    sed -i "65s/.*/      - NUM_QUORUM=$((${size_f}*2+1))/g" ${fname}
    sed -i "72s/.*/      - NODE_IP=${auditors_seo[i]}/g" ${fname}
    sed -i "74s/.*/      - NODE_IP_LIST=${nodeIP_list}/g" ${fname}

    col=$(grep -n "aliases" ./${fname} | cut -d':' -f1)
    sed -i "$((${col}+1))s/.*/          - auditor$((${i}+1)).edgechain0.com/g" ${fname}
    sed -i "$((${col}+2))s/.*/          - changer$((${i}+1)).edgechain0.com/g" ${fname}
done
for (( i=0; i <${sizeAuditor_vir}; i++ ))
do
    fname="./auditchain_dis_vir_${i}.yaml"
    cp "./auditchain_dis.yaml" ${fname}
    j=$((${i}+${sizeAuditor_seo}))
    sed -i "15s/.*/  auditor${j}:/g" ${fname}
    sed -i "16s/.*/    container_name: auditor${j}/g" ${fname}
    sed -i "42s/.*/      - CORE_OPERATIONS_LISTENADDRESS=auditor${j}:9443/g" ${fname}
    sed -i "48s/.*/      - EDGECHAIN_NODE_NAME=auditor$((${j}+1)).edgechain0.com/g" ${fname}
    sed -i "52s/.*/      - AUDITOR_ADDRESS=auditor$((${j}+1)).edgechain0.com:10000/g" ${fname}
    sed -i "53s/.*/      - SECONDARY_ADDRESS=auditor${j}:8000/g" ${fname}
    sed -i "54s/.*/      - CHANGER_ADDRESS=auditor${j}:8001/g" ${fname}
    sed -i "55s/.*/      - SECONDARY_ADDRESS_LIST=${committee_list}/g" ${fname}
    sed -i "64s/.*/      - NUM_AUDITORS=${sizeAuditor_total}/g" ${fname}
    sed -i "68s/.*/      - COMMITTEESIZE=${sizeAuditor_total}/g" ${fname}
    sed -i "65s/.*/      - NUM_QUORUM=$((${size_f}*2+1))/g" ${fname}
    sed -i "72s/.*/      - NODE_IP=${auditors_vir[i]}/g" ${fname}
    sed -i "74s/.*/      - NODE_IP_LIST=${nodeIP_list}/g" ${fname}

    col=$(grep -n "aliases" ./${fname} | cut -d':' -f1)
    sed -i "$((${col}+1))s/.*/          - auditor$((${j}+1)).edgechain0.com/g" ${fname}
    sed -i "$((${col}+2))s/.*/          - changer$((${j}+1)).edgechain0.com/g" ${fname}
done
for (( i=0; i <${sizeAuditor_fra}; i++ ))
do
    fname="./auditchain_dis_fra_${i}.yaml"
    cp "./auditchain_dis.yaml" ${fname}
    j=$((${i}+${sizeAuditor_seo}+${sizeAuditor_vir}))
    sed -i "15s/.*/  auditor${j}:/g" ${fname}
    sed -i "16s/.*/    container_name: auditor${j}/g" ${fname}
    sed -i "42s/.*/      - CORE_OPERATIONS_LISTENADDRESS=auditor${j}:9443/g" ${fname}
    sed -i "48s/.*/      - EDGECHAIN_NODE_NAME=auditor$((${j}+1)).edgechain0.com/g" ${fname}
    sed -i "52s/.*/      - AUDITOR_ADDRESS=auditor$((${j}+1)).edgechain0.com:10000/g" ${fname}
    sed -i "53s/.*/      - SECONDARY_ADDRESS=auditor${j}:8000/g" ${fname}
    sed -i "54s/.*/      - CHANGER_ADDRESS=auditor${j}:8001/g" ${fname}
    sed -i "55s/.*/      - SECONDARY_ADDRESS_LIST=${committee_list}/g" ${fname}
    sed -i "64s/.*/      - NUM_AUDITORS=${sizeAuditor_total}/g" ${fname}
    sed -i "68s/.*/      - COMMITTEESIZE=${sizeAuditor_total}/g" ${fname}
    sed -i "65s/.*/      - NUM_QUORUM=$((${size_f}*2+1))/g" ${fname}
    sed -i "72s/.*/      - NODE_IP=${auditors_fra[i]}/g" ${fname}
    sed -i "74s/.*/      - NODE_IP_LIST=${nodeIP_list}/g" ${fname}

    col=$(grep -n "aliases" ./${fname} | cut -d':' -f1)
    sed -i "$((${col}+1))s/.*/          - auditor$((${j}+1)).edgechain0.com/g" ${fname}
    sed -i "$((${col}+2))s/.*/          - changer$((${j}+1)).edgechain0.com/g" ${fname}
done

