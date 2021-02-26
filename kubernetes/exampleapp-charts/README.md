# DESCRIPTION

Short instruction for the application installion manually.
The documentation may differ of real values and is not considered real the documentation for the manual installation.

## Prerequisites

```bash
export NS=[your namespace name]
```

## Install the application infrastructure

Build the helm chart:
```sh
$ helm package ./infra -u
```
Deploy the infrastructure chart:
 ```sh
$ helm install infrastructure-dev ./infra-2.0.0.tgz --namespace=$NS
```    
Verify the chart in your cluster (pods etc):
```sh
$ helm status infrastructure-dev -n $NS
```

## Install auth-service

Build the helm chart:
```sh
helm package ./auth-service -u
```
Deploy the auth-service chart (***the command may differ of real one***):
```sh
helm install auth-service-dev ./auth-service-2.0.0.tgz \
    ...
    --namespace=$NS
```    
Verify status:
```sh
helm status auth-service-dev -n $NS
```

## Install account-service

Build the helm chart:
```sh
$ helm package ./account-service -u   
```
Deploy the account-service chart (***the command may differ of real one***):
```sh
$ helm install account-service-dev ./account-service-2.0.0.tgz \
    ...
    --namespace=$NS
 ```

Verify status:
```sh
helm status account-service-dev -n $NS
```

## Install core-service

Build the chart:
```sh
helm package ./core-service -u
```
Deploy the core-service chart (***the command may differ of real one***):
```sh
helm install core-service-dev ./core-service-2.0.0.tgz \
    ...
    --namespace=$NS
```    
Verify status:
```sh
sh helm status core-service-dev -n $NS
```

## Install logs-service

Build the chart:
```sh
$ helm package ./logs-service -u
```
Deploy the logs-service chart (***the command may differ of real one***):
```sh
$ helm install logs-service-dev ./logs-service-2.0.0.tgz \
    ...
    --namespace=$NS  
```    
Verify status:
```sh
$ helm status logs-service-dev -n $NS
```

## Install frontend

Build the chart:
```sh
$ helm package ./frontend -u
```

Deploy the frontend chart (***the command may differ of real one***):
```sh
$ helm install frontend-dev ./frontend-2.0.0.tgz \
    ...
    --namespace=$NS
```    

Verify status:
```sh
$ helm status frontend-dev -n $NS
```

# Application Endpoints

| Service | Port | Endpoint |
| ------ | ------ | ------ |
| AccountService | 8811 | http://account-service:8811/account/<resource>
| AuthService | 8812 | http://auth-service:8812/oauth/<resource>
| LogsService | 8813 | http://logs-service:8813/logs/<resource>
| CoreService | 8814 | http://core-service:8814/doc/<resource>
| Frontend | 80 | http://frontendt:80/<resource>

# Consumption Memory/CPU

| Service | Limit CPU/Memory | Request CPU/Memory | Java Params |
| ------ | ------ | ------ |  ------ |
| AccountService | 1000m/1024Mi | 100m/512Mi | -Xmx820M -XX:MaxRAM=1024M -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap |
| AuthService | 1000m/1024Mi | 100m/512Mi | -Xmx820M -XX:MaxRAM=1024M -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap |
| CoreService | 1000m/1600Mi | 100m/512Mi | -Xmx1300M -XX:MaxRAM=1600M -XX:+UnlockExperimentalVMOptions |
| LogsService | 1000m/1024Mi | 100m/512Mi | -Xmx820M -XX:MaxRAM=1024M -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap |
| Frontend | 50m/96Mi | 10m/48Mi  | - |