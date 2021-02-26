#!/usr/bin/env bash

export NS=[your namespace name]

kubectl apply -f ./config-deployment.yml  -n $NS
kubectl apply -f ./eureka-deployment.yml -n $NS
kubectl apply -f ./eureka-statefulset.yml -n $NS
kubectl apply -f ./account-service-deployment.yml -n $NS
kubectl apply -f ./auth-service-deployment.yml -n $NS
kubectl apply -f ./core-service-deployment.yml -n $NS
kubectl apply -f ./logs-service-deployment.yml -n $NS
kubectl apply -f ./report-service-deployment.yml -n $NS
kubectl apply -f ./gateway-service-deployment.yml -n $NS
kubectl apply -f ./web-deployment.yml -n $NS