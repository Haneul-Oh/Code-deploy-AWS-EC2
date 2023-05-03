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
BSP_PRIVATE_IP="172.31.38.167"
auditors_seo=()
auditors_vir=()
auditors_fra=()
auditors_sin=()
auditors_cal=()
auditors_ire=()
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


echo "## BSP's Docker Swarm: "${BSP}
ssh -i ${BSP_KEY} ubuntu@${BSP} "docker network rm edgechain0 mec"	
ssh -i ${BSP_KEY} ubuntu@${BSP} "docker swarm leave -f; docker swarm init --advertise-addr ${BSP_PRIVATE_IP} && docker swarm join-token manager"
ssh -i ${BSP_KEY} ubuntu@${BSP} "sudo docker network create --attachable --scope=swarm --driver overlay edgechain0 && sudo docker network create --attachable --scope=swarm --driver overlay mec"	
rm -rf ${curPATH}/dockerswarm/ip.txt
ssh -i ${BSP_KEY} ubuntu@${BSP} "docker swarm join-token manager -q" >> ${curPATH}/dockerswarm/token.txt

file="${curPATH}/dockerswarm/token.txt"
token=$(cat ${curPATH}/dockerswarm/token.txt |tail -1)

function dockerSwarmAddManger {
    ip=$1
    keypath=$2

    result=$(ssh -i ${keypath} ubuntu@${ip} "docker swarm leave -f; docker swarm join --token ${token} ${BSP_PRIVATE_IP}:2377")
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
for ip in ${auditors_sin[@]}; do
    echo "## Auditor-sin's Docker Swarm: "${ip}
	dockerSwarmAddManger ${ip} ${AUDITOR_SIN_KEY} & 
done

for ip in ${auditors_cal[@]}; do
    echo "## Auditor-cal's Docker Swarm: "${ip}
	dockerSwarmAddManger ${ip} ${AUDITOR_CAL_KEY} & 
done

for ip in ${auditors_ire[@]}; do
    echo "## Auditor-ire's Docker Swarm: "${ip}
	dockerSwarmAddManger ${ip} ${AUDITOR_IRE_KEY} & 
done
for ip in ${clients_seo[@]}; do
    echo "## Client-seo's Docker Swarm: "${ip}
	dockerSwarmAddManger ${ip} ${CLIENT_KEY} & 
done
sleep 30

a=($(docker node ls -q));echo ${#a[@]}

for v in ${dockerswarmresult[@]}; do
    echo "ERROR: ${v}: docker swarm leave -f; docker swarm join --token ${token} ${BSP_PRIVATE_IP}:2377"
done

