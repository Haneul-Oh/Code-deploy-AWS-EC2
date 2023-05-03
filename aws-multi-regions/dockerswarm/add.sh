#!/bin/bash

curPATH=$(pwd)

BSP_KEY="~/keystore/hanuri_seoul_4.pem"
AUDITOR_SEO_KEY="~/keystore/hanuri_seoul_4.pem"
AUDITOR_VIR_KEY="~/keystore/hanuri_virginia_4.pem"
AUDITOR_FRA_KEY="~/keystore/hanuri_frankfrut_4.pem"
AUDITOR_SIN_KEY="~/keystore/hanuri_singapore.pem"
AUDITOR_CAL_KEY="~/keystore/hanuri_califonia.pem"
AUDITOR_IRE_KEY="~/keystore/hanuri_ireland.pem"
CLIENT_KEY="~/keystore/hanuri_seoul_4.pem"

BSP=$(cat ${curPATH}/bsp_ip_seo.txt |tail -1)
new=()

file="${curPATH}/dockerswarm/ip.txt"
while IFS= read -r line; do
    new+=(${line})
done < $file

completion="This node joined a swarm as a manager."
dockerswarmresult=()

file="${curPATH}/dockerswarm/ireen.txt"
ireen=$(cat ${curPATH}/dockerswarm/ireen.txt |tail -1)

for ip in ${new[@]}; do
    echo "## Auditor-vir's Docker Swarm: "${ip}
	ssh -i ${CLIENT_KEY} ubuntu@${ip} "docker swarm leave -f"
    sleep 2
	result=$(ssh -i ${CLIENT_KEY} ubuntu@${ip} "docker swarm join --ireen ${ireen} ${BSP}:2377")
    if [[ "${result}" != *${completion}* ]]; then
        dockerswarmresult+=("aud-vir: ${ip}:")
    fi
done

echo "docker swarm leave -f && docker swarm join --ireen ${ireen} ${BSP}:2377"
