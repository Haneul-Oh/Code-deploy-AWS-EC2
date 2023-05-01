#!/bin/bash

cmd=${1}
IP=${2}
REGION=${3}
args=${4}

curPATH=$(pwd)

AUDITOR_SEO_KEY="~/keystore/hanuri_seoul_4.pem"
AUDITOR_VIR_KEY="~/keystore/hanuri_virginia_4.pem"
AUDITOR_FRA_KEY="~/keystore/hanuri_frankfrut_4.pem"
AUDITOR_SIN_KEY="~/keystore/hanuri_singapore.pem"
AUDITOR_CAL_KEY="~/keystore/hanuri_califonia.pem"
AUDITOR_IRE_KEY="~/keystore/hanuri_ireland.pem"

AUDITOR_KEY=""
AUDITOR_REGION=""

if [ "${REGION}" == "seo" ]
then
	AUDITOR_KEY="${AUDITOR_SEO_KEY}"
	AUDITOR_REGION="seo"
fi
if [ "${REGION}" == "vir" ]
then
	AUDITOR_KEY="${AUDITOR_VIR_KEY}"
	AUDITOR_REGION="vir"
fi
if [ "${REGION}" == "fra" ]
then
	AUDITOR_KEY="${AUDITOR_FRA_KEY}"
	AUDITOR_REGION="fra"
fi
if [ "${REGION}" == "sin" ]
then
	AUDITOR_KEY="${AUDITOR_SIN_KEY}"
	AUDITOR_REGION="sin"
fi
if [ "${REGION}" == "cal" ]
then
	AUDITOR_KEY="${AUDITOR_CAL_KEY}"
	AUDITOR_REGION="cal"
fi
if [ "${REGION}" == "ire" ]
then
	AUDITOR_KEY="${AUDITOR_IRE_KEY}"
	AUDITOR_REGION="ire"
fi

# preliminary files
if [ ${cmd} == "copy" ]
then
	# cd ${curPATH}
	scp -i ${AUDITOR_KEY} ./docker.sh ./goInstall.sh ./removeImage.sh ./go1.14.1.linux-amd64.tar.gz  /home/hanuri/.profile ubuntu@${IP}:~/
	# scp -i ${AUDITOR_KEY} ./docker.sh ubuntu@${IP}:~/
	# ssh -i ${AUDITOR_KEY} ubuntu@${IP} "./docker.sh"
fi
if [ ${cmd} == "setup" ]
then
	# # echo "## INSTALL Doker "
	# $(ssh -i ${AUDITOR_KEY} ubuntu@${IP} "./dockerInstall.sh" &
	
	# install docker & docker-compose & go 
	echo "## INSTALL GO "
	ssh -i ${AUDITOR_KEY} ubuntu@${IP} "./goInstall.sh && source ~/.profile"

	# make 2022 dir 
	echo "## MAKE 2022 DIR & Unzip files"
	ssh -i ${AUDITOR_KEY} ubuntu@${IP} "sudo rm -rf 2022 && mkdir 2022"	
	scp -i ${AUDITOR_KEY} ${curPATH}/auditor/file/aud.tar  ubuntu@${IP}:~/2022/
	ssh -i ${AUDITOR_KEY} ubuntu@${IP} "cd 2022; sudo rm -rf ./auditchain && sudo tar -xf aud.tar" &
	# ssh -i ${AUDITOR_KEY} ubuntu@${IP} "sudo rm -rf aud.tar"
fi

# Image load
if [ ${cmd} == "image" ]
then
	echo "## COPY IMAGE: " ${IP}
	cd ${curPATH}/auditor/image/optimizedAuditchain
	ssh -i ${AUDITOR_KEY} ubuntu@${IP} "./removeImage.sh && rm -rf secondary_mod.tar"
	scp -i ${AUDITOR_KEY} ./secondary_mod.tar ubuntu@${IP}:~/

	echo "## IMAGE LOAD... " ${IP}
	ssh -i ${AUDITOR_KEY} ubuntu@${IP} "docker load -i secondary_mod.tar" &
fi
if [ ${cmd} == "imageDownload" ]
then
	# scp -i ${AUDITOR_KEY} ./removeImage.sh ubuntu@${IP}:~/
	cd ${curPATH}/auditor/image/optimizedAuditchain
	if [ ${args} -eq 0 ] 
	then 
		# echo "## EXTRACT IMAGE"
		# ssh hanuri@141.223.181.51 "rm -rf secondary_mod.tar && docker save -o secondary_mod.tar secondary:latest"
		rm -rf ./secondary_mod.tar
		scp hanuri@141.223.181.51:/home/hanuri/secondary_mod.tar ./
	fi 

	echo "## COPY IMAGE"
	ssh -i ${AUDITOR_KEY} ubuntu@${IP} "./removeImage.sh && rm -rf secondary_mod.tar"
	scp -i ${AUDITOR_KEY} ./secondary_mod.tar ubuntu@${IP}:~/

	echo "## IMAGE LOAD..."
	ssh -i ${AUDITOR_KEY} ubuntu@${IP} "docker load -i secondary_mod.tar" &
fi


# Image load
if [ ${cmd} == "basicImage" ]
then
	echo "## COPY BASIC IMAGE: " ${IP}
	cd ${curPATH}/auditor/image/basicAuditchain
	ssh -i ${AUDITOR_KEY} ubuntu@${IP} " rm -rf secondary_basic.tar"
	scp -i ${AUDITOR_KEY} ./secondary_basic.tar ubuntu@${IP}:~/

	# echo "## IMAGE BASIC LOAD... " ${IP}
	# ssh -i ${AUDITOR_KEY} ubuntu@${IP} "docker load -i secondary_basic.tar" &
fi
if [ ${cmd} == "basicImageDownload" ]
then
	cd ${curPATH}/auditor/image/basicAuditchain
	if [ ${args} -eq 0 ] 
	then 
		echo "## EXTRACT BASIC IMAGE"
		ssh hanuri@141.223.181.51 "rm -rf secondary_basic.tar && docker save -o secondary_basic.tar secondary:latest"
		rm -rf ./secondary_basic.tar
		scp hanuri@141.223.181.51:/home/hanuri/secondary_basic.tar ./
	fi 

	echo "## COPY BASIC IMAGE"
	ssh -i ${AUDITOR_KEY} ubuntu@${IP} "./removeImage.sh && rm -rf secondary_basic.tar"
	scp -i ${AUDITOR_KEY} ./secondary_basic.tar ubuntu@${IP}:~/

	echo "## IMAGE LOAD..."
	ssh -i ${AUDITOR_KEY} ubuntu@${IP} "docker load -i secondary_basic.tar" &
fi

# Yaml file 
if [ ${cmd} == "yaml" ]
then
	file="auditchain_dis_${AUDITOR_REGION}_${args}.yaml"
	# echo YAML: ${IP} ${file}
	cd ${curPATH}/auditor/config
    ssh -i ${AUDITOR_KEY} ubuntu@${IP} "sudo rm -rf ~/$file"
    scp -i ${AUDITOR_KEY} ./${file} ubuntu@${IP}:~/
    ssh -i ${AUDITOR_KEY} ubuntu@${IP} "sudo mv -f $file ./2022/auditchain/bsstore/demo/docker/auditchain_dis.yaml"
fi
