#!/bin/bash

curPATH=$(pwd)

## Extract IPs
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
sizeClient=${#clients_seo[@]}

cd "${curPATH}/bsp/config"
j=0
for (( i=0; i<${sizeAuditor_seo}; i++ )); do
    extra_host+=("auditor${j}:${auditors_seo[i]}")
    j=$(($j+1))
done
for (( i=0; i<${sizeAuditor_vir}; i++ )); do
    extra_host+=("auditor${j}:${auditors_vir[i]}")
    j=$(($j+1))
done
for (( i=0; i<${sizeAuditor_fra}; i++ )); do
    extra_host+=("auditor${j}:${auditors_fra[i]}")
    j=$(($j+1))
done
for (( i=0; i<${sizeAuditor_sin}; i++ )); do
    extra_host+=("auditor${j}:${auditors_sin[i]}")
    j=$(($j+1))
done
for (( i=0; i<${sizeAuditor_cal}; i++ )); do
    extra_host+=("auditor${j}:${auditors_cal[i]}")
    j=$(($j+1))
done
for (( i=0; i<${sizeAuditor_ire}; i++ )); do
    extra_host+=("auditor${j}:${auditors_ire[i]}")
    j=$(($j+1))
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
    sed -i "$((${col}+1+${i}))s/.*/      - \"client${i}_edgechain0:${clients_seo[i]}\"/g" ${fname}
done