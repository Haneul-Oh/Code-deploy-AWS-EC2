#!/bin/bash

new_clients=()
curPATH=$(pwd)

CLIENT_REGION="seo"
file="${curPATH}/new_client_ip_seo.txt"

while IFS= read -r line; do
    new_clients+=(${line})
done < $file

# BSP=$(cat ${curPATH}/bsp_ip_seo.txt |tail -1)
# token=$(cat ${curPATH}/dockerswarm/token.txt |tail -1)
# completion="This node joined a swarm as a manager."
# dockerswarmresult=()

for ip in ${new_clients[@]}; do
    echo ">> Copy Files at " ${ip}
    ./c-copy.sh copy ${ip} ${CLIENT_REGION}
done

for ip in ${new_clients[@]}; do
    echo ">> Setup at " ${ip}
    ./c-copy.sh setup ${ip} ${CLIENT_REGION}
done

for ip in ${new_clients[@]}; do
    ./c-copy.sh image ${ip} ${CLIENT_REGION}
done
