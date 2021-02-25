#!/usr/bin/env bash

kubectl apply -f ./config-deployment.yml  -n <<your-namespace>>
kubectl apply -f ./eureka-deployment.yml -n <<your-namespace>>
kubectl apply -f ./eureka-statefulset.yml -n <<your-namespace>>
kubectl apply -f ./account-service-deployment.yml -n <<your-namespace>>
kubectl apply -f ./auth-service-deployment.yml -n <<your-namespace>>
kubectl apply -f ./core-service-deployment.yml -n <<your-namespace>>
kubectl apply -f ./logs-service-deployment.yml -n <<your-namespace>>
kubectl apply -f ./report-service-deployment.yml -n <<your-namespace>>
kubectl apply -f ./gateway-service-deployment.yml -n <<your-namespace>>
kubectl apply -f ./web-deployment.yml -n <<your-namespace>>