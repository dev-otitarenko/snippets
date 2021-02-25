#!/usr/bin/env bash

kubectl delete -f ./eureka-deployment.yml -n <<your-namespace>>
kubectl delete -f ./eureka-statefulset.yml -n <<your-namespace>>
kubectl delete -f ./account-service-deployment.yml -n <<your-namespace>>
kubectl delete -f ./auth-service-deployment.yml -n <<your-namespace>>
kubectl delete -f ./core-service-deployment.yml -n <<your-namespace>>
kubectl delete -f ./logs-service-deployment.yml -n <<your-namespace>>
kubectl delete -f ./report-service-deployment.yml -n <<your-namespace>>
kubectl delete -f ./gateway-service-deployment.yml -n <<your-namespace>>
kubectl delete -f ./web-deployment.yml -n <<your-namespace>>
kubectl delete -f ./config-deployment.yml  -n <<your-namespace>>