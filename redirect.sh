#!/usr/bin/bash

SERVICE=webapp


ROOT=/var/www/nginx/html
DEFAULTPAGE=index.html
ERRORPAGE=error.html

DEFAULTPATH=${ROOT}/${DEFAULTPAGE}
ERRORPATH=${ROOT}/${ERRORPAGE}

EXTERNAL_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)

NODE_PORT=$(/usr/local/bin/kubectl get service ${SERVICE} 2> ${ERRORPATH} | sed -n 's/.*\:\(.*\)\/.*/\1/p')
REDIRECT="${EXTERNAL_IP}:${NODE_PORT}"


if [[ "${NODE_PORT}" ]]; then
  sed -i "/location\.href/ s| = \"[^\"][^\"]*\"| = \"http://${REDIRECT}\"|" ${DEFAULTPATH}
else
  sed -i "/location\.href/ s| = \"[^\"][^\"]*\"| = \"${ERRORPAGE}\"|" ${DEFAULTPATH}
fi
