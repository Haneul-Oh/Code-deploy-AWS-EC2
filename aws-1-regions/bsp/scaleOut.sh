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

cd "${curPATH}/bsp/config"

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


## Edit Auditor IP of Extra host field
fname="edgechain0_seo_.yaml"
col=$(grep -n "# auditor ip" ./${fname} | cut -d':' -f1)
for (( i=0; i <${sizeAuditor_total}; i++ )); do
    sed -i "$((${col}+1+${i}))s/.*/      - \"${extra_host[i]}\"/g" ${fname}
done 


## Edit Client IP of Extra host field
col=$(grep -n "# client ip" ./${fname} | cut -d':' -f1)
for (( i=0; i <${sizeClient}; i++ )); do
    sed -i "$((${col}+1+${i}))s/.*/      - \"client${i}_edgechain0:${client_seo[i]}\"/g" ${fname}
done