#!/usr/bin/env bash

export NS=[your namespace name]

kubectl delete -f ./eureka-deployment.yml -n $NS
kubectl delete -f ./eureka-statefulset.yml -n $NS
kubectl delete -f ./account-service-deployment.yml -n $NS
kubectl delete -f ./auth-service-deployment.yml -n $NS
kubectl delete -f ./core-service-deployment.yml -n $NS
kubectl delete -f ./logs-service-deployment.yml -n $NS
kubectl delete -f ./report-service-deployment.yml -n $NS
kubectl delete -f ./gateway-service-deployment.yml -n $NS
kubectl delete -f ./web-deployment.yml -n $NS
kubectl delete -f ./config-deployment.yml  -n $NS