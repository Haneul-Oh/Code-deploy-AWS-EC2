#!/bin/bash

cmd=${1}
IP=${2}
# REGION=${3}
# args=${4}

curPATH=$(pwd)

BSP_KEY="~/keystore/hanuri_seoul_4.pem"
BSP_REGION="seo"

if [ ${cmd} == "copy" ]
then
	echo hi1
	scp -i ${BSP_KEY} ./dockerInstall.sh ./goInstall.sh ./go1.14.1.linux-amd64.tar.gz ./removeImage.sh /home/hanuri/.profile ubuntu@${IP}:~/

	# install docker & docker-compose & go 
	echo "## INSTALL GO "
	ssh -i ${BSP_KEY} ubuntu@${IP} "./goInstall.sh && source ~/.profile"

	# make 2022 dir 
	echo "## MAKE 2022 DIR"
	ssh -i ${BSP_KEY} ubuntu@${IP} "rm -rf 2022 && mkdir 2022"	
	scp -i ${BSP_KEY} ./bsp/file/bsp.tar  ubuntu@${IP}:~/2022/
	ssh -i ${BSP_KEY} ubuntu@${IP} "cd 2022; sudo rm -rf ./bsp_210817_base && tar -xf bsp.tar && rm -rf bsp.tar"
fi
if [ ${cmd} == "image" ]
then
	scp -i ${BSP_KEY} ./removeImage.sh ubuntu@${IP}:~/
	echo "## EXTRACT IMAGE"
	rm -rf ./bsp/image/peerd.tar && docker save -o ./bsp/image/peerd.tar peerd:latest
	rm -rf ./bsp/image/ordererd.tar && docker save -o ./bsp/image/ordererd.tar ordererd:latest

	echo "## COPY IMAGE"
	ssh -i ${BSP_KEY} ubuntu@${IP} "./removeImage.sh && rm -rf peerd.tar ordererd.tar"
	scp -i ${BSP_KEY} ./bsp/image/peerd.tar ./bsp/image/ordererd.tar ubuntu@${IP}:~/

	echo "Image load..."
	ssh -i ${BSP_KEY} ubuntu@${IP} "docker load -i peerd.tar; docker load -i ordererd.tar"
fi
if [ ${cmd} == "yaml" ]
then
	file="edgechain0_${BSP_REGION}_.yaml"
	cd ${curPATH}/bsp/config
    ssh -i ${BSP_KEY} ubuntu@${IP} "sudo rm -rf ~/$file"
    scp -i ${BSP_KEY} ./${file} ubuntu@${IP}:~/
    ssh -i ${BSP_KEY} ubuntu@${IP} "sudo mv -f $file ~/2022/bsp_210817_base/edgechain0.yaml"
fi