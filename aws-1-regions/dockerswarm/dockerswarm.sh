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

completion="This node joined a swarm as a manager."
dockerswarmresult=()

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


echo "## BSP's Docker Swarm: "${BSP}
ssh -i ${BSP_KEY} ubuntu@${BSP} "docker network rm edgechain0 mec"	
ssh -i ${BSP_KEY} ubuntu@${BSP} "docker swarm leave -f; docker swarm init --advertise-addr ${BSP} && docker swarm join-token manager && sudo docker network create --attachable --driver overlay edgechain0 && sudo docker network create --attachable --driver overlay mec"	
rm -rf ${curPATH}/dockerswarm/token.txt
ssh -i ${BSP_KEY} ubuntu@${BSP} "docker swarm join-token manager -q" >> ${curPATH}/dockerswarm/token.txt

file="${curPATH}/dockerswarm/token.txt"
token=$(cat ${curPATH}/dockerswarm/token.txt |tail -1)

function dockerSwarmAddManger {
    ip=$1
    keypath=$2

    result=$(ssh -i ${keypath} ubuntu@${ip} "docker swarm leave -f; docker swarm join --token ${token} ${BSP}:2377")
    if [[ "${result}" != *${completion}* ]]; then
        dockerswarmresult+=("aud-seo: ${ip}:")
    fi
}


for ip in ${auditors_seo[@]}; do
    echo "## Auditor-seo's Docker Swarm: "${ip}
	dockerSwarmAddManger ${ip} ${AUDITOR_SEO_KEY} &
done

for ip in ${auditors_vir[@]}; do
    echo "## Auditor-vir's Docker Swarm: "${ip}
	dockerSwarmAddManger ${ip} ${AUDITOR_VIR_KEY} &
done

for ip in ${auditors_fra[@]}; do
    echo "## Auditor-fra's Docker Swarm: "${ip}
	dockerSwarmAddManger ${ip} ${AUDITOR_FRA_KEY} &
done

for ip in ${clients_seo[@]}; do
    echo "## Client-seo's Docker Swarm: "${ip}
	dockerSwarmAddManger ${ip} ${CLIENT_KEY} &
done
sleep 30

a=($(docker node ls -q));echo ${#a[@]}

for v in ${dockerswarmresult[@]}; do
    echo "ERROR: ${v}: docker swarm leave -f; docker swarm join --token ${token} ${BSP}:2377"
done

