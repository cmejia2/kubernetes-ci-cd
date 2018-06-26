#!/bin/bash

#Retrieve the latest git commit hash
TAG=`git rev-parse --short HEAD`

#Build the docker image
docker build -t mycluster.icp:8443/kr8sswordz:$TAG -f applications/kr8sswordz-pages/Dockerfile applications/kr8sswordz-pages

#Setup the proxy for the registry
#docker stop socat-registry; docker rm socat-registry; docker run -d -e "REGIP=`minikube ip`" --name socat-registry -p 30400:5000 chadmoon/socat:latest bash -c "socat TCP4-LISTEN:5000,fork,reuseaddr TCP4:`minikube ip`:30400"

echo "5 second sleep to make sure the registry is ready"
sleep 5;

#Push the images
docker push mycluster.icp:8443/kr8sswordz:$TAG

#Stop the registry proxy
# docker stop socat-registry

# Create the deployment and service for the front end aka kr8sswordz
sed 's#mycluster.icp:8443/kr8sswordz:latest#mycluster.icp:8443/kr8sswordz:'$TAG'#' applications/kr8sswordz-pages/k8s/deployment.yaml | kubectl apply -f -
