#!/bin/bash

cmd=${1}
IP=${2}
REGION=${3}
args=${4}

curPATH=$(pwd)

CLIENT_SEO_KEY="~/keystore/hanuri_seoul_4.pem"

CLIENT_KEY=""
CLIENT_REGION=""

if [ "${REGION}" == "seo" ]
then
	CLIENT_KEY="${CLIENT_SEO_KEY}"
	CLIENT_REGION="seo"
fi
if [ "${REGION}" == "vir" ]
then
	CLIENT_KEY="${CLIENT_VIR_KEY}"
	CLIENT_REGION="vir"
fi


# preliminary files
if [ ${cmd} == "copy" ]
then
	cd ${curPATH}
	scp -i ${CLIENT_KEY} ./dockerInstall.sh ./goInstall.sh ./go1.14.1.linux-amd64.tar.gz /home/hanuri/.profile ubuntu@${IP}:~/
fi
if [ ${cmd} == "setup" ]
then
	# echo "## INSTALL Doker "
	# ssh -i ${CLIENT_KEY} ubuntu@${IP} "./dockerInstall.sh"
	
	# install docker & docker-compose & go 
	echo "## INSTALL GO "
	ssh -i ${CLIENT_KEY} ubuntu@${IP} "sudo rm -rf go && ./goInstall.sh && source ~/.profile"

	# make 2022 dir 
	echo "## MAKE 2022 DIR & Unzip files"
	ssh -i ${CLIENT_KEY} ubuntu@${IP} "sudo rm -rf 2022 && mkdir 2022"	
	scp -i ${CLIENT_KEY} ${curPATH}/client/file/bsp.tar  ${curPATH}/client/file/tra.tar ubuntu@${IP}:~/2022/
	
	ssh -i ${CLIENT_KEY} ubuntu@${IP} "cd 2022; sudo rm -rf ./transaction_work && tar -xf tra.tar"
	ssh -i ${CLIENT_KEY} ubuntu@${IP} "cd 2022; sudo rm -rf ./bsp_210817_base && tar -xf bsp.tar"
	ssh -i ${CLIENT_KEY} ubuntu@${IP} "sudo rm -rf bsp.tar tra.tar"
fi

# Image load
if [ ${cmd} == "image" ]
then
	echo "## COPY IMAGE at" ${IP}
	cd ${curPATH}/client/image/
	ssh -i ${CLIENT_KEY} ubuntu@${IP} "rm -rf aggregator.tar caliper.tar"
	scp -i ${CLIENT_KEY} ./aggregator.tar ./caliper.tar ubuntu@${IP}:~/

	echo "## IMAGE LOAD at " ${IP}
	ssh -i ${CLIENT_KEY} ubuntu@${IP} "docker load -i aggregator.tar"
	ssh -i ${CLIENT_KEY} ubuntu@${IP} "docker load -i caliper.tar"
fi
if [ ${cmd} == "imageDownload" ]
then
	scp -i ${CLIENT_KEY} ./removeImage.sh ubuntu@${IP}:~/
	cd ${curPATH}/client/image/
	if [ ${args} -eq 0 ] 
	then 
		echo "## EXTRACT IMAGE"
		ssh hanuri@141.223.181.52 "rm -rf aggregator.tar && docker save -o aggregator.tar aggregator:latest"
		rm -rf ./aggregator.tar
		scp hanuri@141.223.181.52:/home/hanuri/aggregator.tar ./
	fi 

	echo "## COPY IMAGE"
	ssh -i ${CLIENT_KEY} ubuntu@${IP} "./removeImage.sh && rm -rf aggregator.tar caliper.tar"
	scp -i ${CLIENT_KEY} ./aggregator.tar ./caliper.tar ubuntu@${IP}:~/

	echo "## IMAGE LOAD..."
	ssh -i ${CLIENT_KEY} ubuntu@${IP} "docker load -i aggregator.tar"
	ssh -i ${CLIENT_KEY} ubuntu@${IP} "docker load -i caliper.tar"
fi

# Yaml file 
if [ ${cmd} == "yaml" ]
then
	cd ${curPATH}/client/config
	file="agg_${CLIENT_REGION}_${args}.yaml"
	# echo ${file}
    scp -i ${CLIENT_KEY} ./${file} ubuntu@${IP}:~/
    ssh -i ${CLIENT_KEY} ubuntu@${IP} "sudo mv -f $file ~/2022/bsp_210817_base/agg.yaml"

	file="docker-compose-minirun_${CLIENT_REGION}_${args}.yml"
	# echo ${file}
    scp -i ${CLIENT_KEY} ./${file} ubuntu@${IP}:~/
    ssh -i ${CLIENT_KEY} ubuntu@${IP} "sudo mv -f $file ~/2022/transaction_work/docker-compose-minirun.yml"

	file="config_client0_edgechain0.yaml"
    scp -i ${CLIENT_KEY} ./${file} ubuntu@${IP}:~/
    ssh -i ${CLIENT_KEY} ubuntu@${IP} "sudo mv -f $file ~/2022/transaction_work/caliper-workspace/benchmarks/miniRun/config_client0_edgechain0.yaml"
fi
# caliper code file 
if [ ${cmd} == "code" ]
then
	cd ${curPATH}/client/file/
	file="transaction.js"
	# if [ ${args} -eq 0 ] 
	# then 
	# 	echo "## COPY CODE"
	# 	rm -rf ./${file}
	# 	scp hanuri@141.223.181.52:/home/hanuri/2022/transaction_work/caliper-workspace/node_modules/fabric-network/lib/${file} ./
	# fi 
	
	# echo ${file}
    scp -i ${CLIENT_KEY} ./${file} ubuntu@${IP}:~/
    ssh -i ${CLIENT_KEY} ubuntu@${IP} "sudo mv -f $file ~/2022/transaction_work/caliper-workspace/node_modules/fabric-network/lib/${file}"
fi