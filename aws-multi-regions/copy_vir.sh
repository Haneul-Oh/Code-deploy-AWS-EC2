#!/bin/bash

cmd=${1}
IP=${2}
REGION=${3}
args=${4}

BSP_KEY="~/keystore/cloudvir.pem"
AUDITOR_KEY="~/keystore/cloudvir.pem"
CLIENT_KEY="~/keystore/cloudvir.pem"

BSP_REGION="vir"
AUDITOR_REGION="seo"
CLIENT_REGION="vir"


# preliminary files
if [ ${cmd} == "a-setup" ]
then
	scp -i ${AUDITOR_KEY} ./dockerInstall.sh ./easycompose.sh ./goInstall.sh ./go1.14.1.linux-amd64.tar.gz ubuntu@${IP}:~/

	# install docker & docker-compose & go 
	echo "## INSTALL GO "
	ssh -i ${AUDITOR_KEY} ubuntu@${IP} "./goInstall.sh"
	
	# Go path
	echo "## SETTING GO PATH"
	scp -i ${AUDITOR_KEY} /home/hanuri/.profile ubuntu@${IP}:~/
	ssh -i ${AUDITOR_KEY} ubuntu@${IP} "source ~/.profile"

	# make 2022 dir 
	echo "## MAKE 2022 DIR"
	ssh -i ${AUDITOR_KEY} ubuntu@${IP} "mkdir 2022"	
fi
if [ ${cmd} == "b-setup" ]
then
	scp -i ${BSP_KEY} ./dockerInstall.sh ./easycompose.sh ./goInstall.sh ./go1.14.1.linux-amd64.tar.gz ubuntu@${IP}:~/

	# install docker & docker-compose & go 
	echo "## INSTALL GO "
	ssh -i ${BSP_KEY} ubuntu@${BSP} "./goInstall.sh"
	
	# Go path
	echo "## SETTING GO PATH"
	scp -i ${BSP_KEY} /home/hanuri/.profile ubuntu@${BSP}:~/
	ssh -i ${BSP_KEY} ubuntu@${BSP} "source ~/.profile"

	# make 2022 dir 
	echo "## MAKE 2022 DIR"
	ssh -i ${BSP_KEY} ubuntu@${BSP} "mkdir 2022"	
fi
if [ ${cmd} == "c-setup" ]
then
	scp -i ${CLIENT_KEY} ./dockerInstall.sh ./easycompose.sh ./goInstall.sh ./go1.14.1.linux-amd64.tar.gz ubuntu@${client}:~/

	# install docker & docker-compose & go 
	echo "## INSTALL GO "
	ssh -i ${CLIENT_KEY} ubuntu@${client} "./goInstall.sh"
	
	# Go path
	echo "## SETTING GO PATH"
	scp -i ${CLIENT_KEY} /home/hanuri/.profile ubuntu@${client}:~/
	ssh -i ${CLIENT_KEY} ubuntu@${client} "source ~/.profile"

	# make 2022 dir 
	echo "## MAKE 2022 DIR"
	ssh -i ${CLIENT_KEY} ubuntu@${client} "mkdir 2022"	
fi

# Copy script files 
if [ ${cmd} == "a-files" ]
then
	scp -i ${AUDITOR_KEY} ./auditor/file/aud.tar  ubuntu@${IP}:~/2022/
	ssh -i ${AUDITOR_KEY} ubuntu@${IP} "cd 2022; sudo rm -rf ./auditchain && sudo tar -xvf aud.tar"
	ssh -i ${BSP_KEY} ubuntu@${IP} "sudo rm -rf aud.tar"
fi
if [ ${cmd} == "b-files" ]
then
	scp -i ${BSP_KEY} ./bsp/file/bsp.tar  ubuntu@${BSP}:~/2022/
	ssh -i ${BSP_KEY} ubuntu@${BSP} "cd 2022; sudo rm -rf ./bsp_210817_base && tar -xvf bsp.tar"
	ssh -i ${BSP_KEY} ubuntu@${BSP} "sudo rm -rf bsp.tar"
	
fi
if [ ${cmd} == "c-files" ]
then
	scp -i ${CLIENT_KEY} ./client/file/tra.tar ./bsp/file/bsp.tar  ubuntu@${client}:~/2022/
	ssh -i ${CLIENT_KEY} ubuntu@${client} "cd 2022; sudo rm -rf ./transaction_work && tar -xvf tra.tar"
	ssh -i ${CLIENT_KEY} ubuntu@${client} "cd 2022; sudo rm -rf ./bsp_210817_base && tar -xvf bsp.tar"
	ssh -i ${CLIENT_KEY} ubuntu@${client} "sudo rm -rf tra.tar bsp.tar"
fi

# Image load
if [ ${cmd} == "a-image" ]
then
	# if [ ${args} -eq 0 ] 
	# then 
	# 	echo "## EXTRACT IMAGE"
	# 	ssh hanuri@141.223.181.51 "rm -rf secondary.tar && docker save -o secondary.tar secondary:latest"
	# 	rm -rf ./auditor/image/secondary.tar
	# 	scp hanuri@141.223.181.51:/home/hanuri/secondary.tar ./auditor/image/
	# fi 
	
	echo "## COPY IMAGE"
	ssh -i ${AUDITOR_KEY} ubuntu@${IP} "rm -rf secondary.tar"
	scp -i ${AUDITOR_KEY} ./auditor/image/secondary.tar ubuntu@${IP}:~/

	echo "## IMAGE LOAD..."
	ssh -i ${AUDITOR_KEY} ubuntu@${IP} "docker load -i secondary.tar"
fi
if [ ${cmd} == "b-image" ]
then
	echo "## EXTRACT IMAGE"
	rm -rf ./bsp/image/peerd.tar && docker save -o ./bsp/image/peerd.tar peerd:latest
	rm -rf ./bsp/image/ordererd.tar && docker save -o ./bsp/image/ordererd.tar ordererd:latest

	echo "## COPY IMAGE"
	ssh -i ${BSP_KEY} ubuntu@${BSP} "rm -rf peerd.tar ordererd.tar"
	scp -i ${BSP_KEY} ./bsp/image/peerd.tar ./bsp/image/ordererd.tar ubuntu@${BSP}:~/

	echo "Image load..."
	ssh -i ${BSP_KEY} ubuntu@${BSP} "docker load -i peerd.tar"
	ssh -i ${BSP_KEY} ubuntu@${BSP} "docker load -i ordererd.tar"
fi
if [ ${cmd} == "c-image" ]
then
	echo "## COPY IMAGE"
	ssh -i ${CLIENT_KEY} ubuntu@${client} "rm -rf aggregator.tar caliper.tar"
	scp -i ${CLIENT_KEY} ./client/image/aggregator.tar ./client/image/caliper.tar ubuntu@${client}:~/

	echo "## Image load..."
	ssh -i ${CLIENT_KEY} ubuntu@${client} "docker load -i aggregator.tar"
	ssh -i ${CLIENT_KEY} ubuntu@${client} "docker load -i caliper.tar"
fi

# Yaml file 
if [ ${cmd} == "a-yaml" ]
then
	file="auditchain_dis_${AUDITOR_REGION}_${args}.yaml"
	echo ${file}
    ssh -i ${AUDITOR_KEY} ubuntu@${IP} "sudo rm -rf ~/$file"
    scp -i ${AUDITOR_KEY} ./auditor/${file} ubuntu@${IP}:~/
    ssh -i ${AUDITOR_KEY} ubuntu@${IP} "sudo mv -f $file ./2022/auditchain/bsstore/demo/docker/auditchain_dis.yaml"
fi
if [ ${cmd} == "b-yaml" ]
then
	file="edgechain0_${BSP_REGION}_.yaml"
	echo ${file}
    ssh -i ${BSP_KEY} ubuntu@${BSP} "sudo rm -rf ~/$file"
    scp -i ${BSP_KEY} ./bsp/${file} ubuntu@${BSP}:~/
    ssh -i ${BSP_KEY} ubuntu@${BSP} "sudo mv -f $file ~/2022/bsp_210817_base/edgechain0.yaml"
fi
if [ ${cmd} == "c-yaml" ]
then
	# ssh -i ${AUDITOR_KEY} ubuntu@${IP} "docker swarm join --ireen SWMTKN-1-65zuqp0s248n7zajzr5ssxogpzddqc1277tzoabcsn0o7tb4ve-cmzlnz0togfbzalk1afhm2v3f 3.37.181.153:2377"
	
	file="docker-compose-minirun_${CLIENT_REGION}_.yml"
	echo ${file}
    ssh -i ${CLIENT_KEY} ubuntu@${client} "sudo rm -rf ~/$file"
    scp -i ${CLIENT_KEY} ./client/${file} ubuntu@${client}:~/
    ssh -i ${CLIENT_KEY} ubuntu@${client} "sudo mv -f $file ~/2022/transaction_work/docker-compose-minirun.yml"

	file="agg_${CLIENT_REGION}_.yaml"
	echo ${file}
    ssh -i ${CLIENT_KEY} ubuntu@${client} "sudo rm -rf ~/$file"
    scp -i ${CLIENT_KEY} ./client/${file} ubuntu@${client}:~/
    ssh -i ${CLIENT_KEY} ubuntu@${client} "sudo mv -f $file ~/2022/bsp_210817_base/agg.yaml"
fi
