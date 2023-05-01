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
sizeClient=${#client_seo[@]}


## Edit Client Config
cd "${curPATH}/client/config"
rm -rf "./agg_"*
rm -rf "./docker-compose-minirun_"*

intra_clients="client0.edgechain0.com"
for (( i=1; i <${sizeClient}; i++ ))
do
    new="client${i}.edgechain0.com"
    intra_clients="${intra_clients} ${new}"
done


## Edit BSP IP of Extra host field
BSP=$(cat ${curPATH}/bsp_ip_seo.txt |tail -1)
fname="agg.yaml"
sed -i "54s/.*/      - \"orderer.example.com:${BSP}\"/g" ${fname}
sed -i "55s/.*/      - \"orderer2.example.com:${BSP}\"/g" ${fname}
sed -i "56s/.*/      - \"bsp1.executor.edgechain0:${BSP}\"/g" ${fname}
sed -i "57s/.*/      - \"peer0.org1.example.com:${BSP}\"/g" ${fname}

fname="docker-compose-minirun.yml"
sed -i "58s/.*/      - \"orderer.example.com:${BSP}\"/g" ${fname}
sed -i "59s/.*/      - \"orderer2.example.com:${BSP}\"/g" ${fname}
sed -i "60s/.*/      - \"bsp1.executor.edgechain0:${BSP}\"/g" ${fname}
sed -i "61s/.*/      - \"peer0.org1.example.com:${BSP}\"/g" ${fname}


## Edit Auditor IP of Extra host field (docker-config, agg.yaml)
extra_host=()
for (( i=0; i <${sizeAuditor_seo}; i++ ))
do
    extra_host+=("auditor${i}:${auditors_seo[i]}")
done
for (( i=0; i <${sizeAuditor_vir}; i++ ))
do
    j=$((${i}+${sizeAuditor_seo}))
    extra_host+=("auditor${j}:${auditors_vir[i]}")
done
for (( i=0; i <${sizeAuditor_fra}; i++ ))
do
    j=$((${i}+${sizeAuditor_seo}+${sizeAuditor_vir}))
    extra_host+=("auditor${j}:${auditors_fra[i]}")
done

cli_docker_yaml="${curPATH}/client/config/docker-compose-minirun.yml"
cli_agg_yaml="${curPATH}/client/config/agg.yaml"
for (( i=0; i <${sizeAuditor_total}; i++ )); do
    sed -i "$((26+${i}))s/.*/      - \"${extra_host[i]}\"/g" ${cli_docker_yaml}
    sed -i "$((58+${i}))s/.*/      - \"${extra_host[i]}\"/g" ${cli_agg_yaml}
done 


## Replicate Client Config File
for (( i=0; i <${sizeClient}; i++ ))
do
    fname="./agg_seo_${i}.yaml"
    cp "./agg.yaml" ${fname}
    sed -i "16s/.*/  aggregator${i}.edgechain0.com:/g" ${fname}
    sed -i "17s/.*/    container_name: aggregator${i}.edgechain0.com/g" ${fname}
    sed -i "22s/.*/      - CORE_OPERATIONS_LISTENADDRESS=client${i}.edgechain0.com:9443/g" ${fname}
    sed -i "30s/.*/      - AGGREGATOR_ID=aggregator${i}.edgechain0.com/g" ${fname}
    sed -i "38s/.*/      - AGGREGATOR_NAME=edgechain::${i}/g" ${fname}
    sed -i "47s/.*/          - client${i}.edgechain0.com/g" ${fname}

    fname="./docker-compose-minirun_seo_${i}.yml"
    cp "./docker-compose-minirun.yml" ${fname}
    sed -i "12s/.*/  client${i}_edgechain0:/g" ${fname}
    sed -i "13s/.*/    container_name: client${i}_edgechain0/g" ${fname}
    sed -i "17s/.*/      - AGGREGATOR_NAME=aggregator${i}.edgechain0.com/g" ${fname}
    sed -i "18s/.*/      - AGGREGATOR_ADDRESS=aggregator${i}.edgechain0.com:30303/g" ${fname}
    sed -i "19s/.*/      - CLIENT_ID=client${i}.edgechain0.com/g" ${fname}
    sed -i "20s/.*/      - INTRA_CLIENTS=${intra_clients}/g" ${fname}
done


