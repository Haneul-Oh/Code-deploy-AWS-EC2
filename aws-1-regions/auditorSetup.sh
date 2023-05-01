#!/bin/bash

new_auditors=()
curPATH=$(pwd)

# AUDITOR_REGION="seo"
# file="${curPATH}/new_auditor_ip_seo.txt"
# while IFS= read -r line; do
#     new_auditors+=(${line})
#     # ssh-keygen -f "/home/hanuri/.ssh/known_hosts" -R "${line}"
# done < $file

# AUDITOR_REGION="vir"
# file="${curPATH}/new_auditor_ip_vir.txt"
# while IFS= read -r line; do
#     new_auditors+=(${line})
#     # IP=${line}
#     # ssh-keygen -f "/home/hanuri/.ssh/known_hosts" -R "${IP}"
# done < $file

AUDITOR_REGION="fra"
file="${curPATH}/new_auditor_ip_fra.txt"
while IFS= read -r line; do
    new_auditors+=(${line})
    # IP=${line}
    # ssh-keygen -f "/home/hanuri/.ssh/known_hosts" -R "${IP}"
done < $file



sizeAuditor_seo=${#new_auditors[@]}


for ip in ${new_auditors[@]}; do
    echo ">> Copy Files at " ${ip}
    ./a-copy.sh copy ${ip} ${AUDITOR_REGION}
done

for ip in ${new_auditors[@]}; do
    echo ">> Setup at " ${ip}
    ./a-copy.sh setup ${ip} ${AUDITOR_REGION}
done

# for (( i=0; i<${sizeAuditor_seo}; i++ )); do
#    ./a-copy.sh image ${new_auditors[i]} ${AUDITOR_REGION} ${i}
# done

#  for (( i=0; i<${sizeAuditor_seo}; i++ )); do
#      ./a-copy.sh basicImage ${new_auditors[i]} ${AUDITOR_REGION} ${i}
#  done