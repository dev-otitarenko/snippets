#!/bin/bash

#
# User-defined values
# Path to the public rsa key: ssh-keygen -m PEM -t rsa -b 4096
export SSH_PUBLIC_KEY_FILE=rsakey.pub
# Location of a data center
export LOCATION=westus
# Resource group name
export RESOURCE_GROUP=RG_deployments
export SUBSCRIPTION_ID=$(az account show --query id --output tsv)
export SUBSCRIPTION_NAME=$(az account show --query name --output tsv)
export TENANT_ID=$(az account show --query tenantId --output tsv)
export DEPLOYMENT_SUFFIX=$(date +%S%N)

echo " ** --- Parameters Information -------------------------------------------- **"
echo "SubscriptionId: $SUBSCRIPTION_ID, Name: $SUBSCRIPTION_NAME"
echo "TenantId: $TENANT_ID"
echo "DeploymentSuffix: $DEPLOYMENT_SUFFIX"
echo " ** ----------------------------------------------------------------------- **"

#
# Create service principal for AKS
export SP_DETAILS=$(az ad sp create-for-rbac --role="Contributor" -o json) && \
export SP_APP_ID=$(echo $SP_DETAILS | jq ".appId" -r) && \
export SP_CLIENT_SECRET=$(echo $SP_DETAILS | jq ".password" -r) && \
export SP_OBJECT_ID=$(az ad sp show --id $SP_APP_ID -o tsv --query objectId)

echo " ** --- Service Principle-------------------------------------------------- **"
echo " AppId: $SP_APP_ID, ObjectId: $SP_OBJECT_ID"
echo " ** ----------------------------------------------------------------------- **"

# Deploy the resource groups and managed identities
# These are deployed first in a separate template to avoid propagation delays with AAD
export DEV_PREREQ_DEPLOYMENT_NAME=azuredeploy-prereqs-${DEPLOYMENT_SUFFIX}-dev
az deployment create \
   --name $DEV_PREREQ_DEPLOYMENT_NAME \
   --location $LOCATION \
   --template-file ./azuredeploy-prereqs.json \
   --parameters resourceGroupName=$RESOURCE_GROUP \
                resourceGroupLocation=$LOCATION

export IDENTITIES_DEV_DEPLOYMENT_NAME=$(az deployment show -n $DEV_PREREQ_DEPLOYMENT_NAME --query properties.outputs.identitiesDeploymentName.value -o tsv) && \
export DELIVERY_ID_NAME=$(az group deployment show -g $RESOURCE_GROUP -n $IDENTITIES_DEV_DEPLOYMENT_NAME --query properties.outputs.deliveryIdName.value -o tsv) && \
export DELIVERY_ID_PRINCIPAL_ID=$(az identity show -g $RESOURCE_GROUP -n $DELIVERY_ID_NAME --query principalId -o tsv) && \
export DRONESCHEDULER_ID_NAME=$(az group deployment show -g $RESOURCE_GROUP -n $IDENTITIES_DEV_DEPLOYMENT_NAME --query properties.outputs.droneSchedulerIdName.value -o tsv) && \
export DRONESCHEDULER_ID_PRINCIPAL_ID=$(az identity show -g $RESOURCE_GROUP -n $DRONESCHEDULER_ID_NAME --query principalId -o tsv) && \
export WORKFLOW_ID_NAME=$(az group deployment show -g $RESOURCE_GROUP -n $IDENTITIES_DEV_DEPLOYMENT_NAME --query properties.outputs.workflowIdName.value -o tsv) && \
export WORKFLOW_ID_PRINCIPAL_ID=$(az identity show -g $RESOURCE_GROUP -n $WORKFLOW_ID_NAME --query principalId -o tsv) && \
export GATEWAY_CONTROLLER_ID_NAME=$(az group deployment show -g $RESOURCE_GROUP -n $IDENTITIES_DEV_DEPLOYMENT_NAME --query properties.outputs.appGatewayControllerIdName.value -o tsv) && \
export GATEWAY_CONTROLLER_ID_PRINCIPAL_ID=$(az identity show -g $RESOURCE_GROUP -n $GATEWAY_CONTROLLER_ID_NAME --query principalId -o tsv) && \
export RESOURCE_GROUP_ACR=$(az group deployment show -g $RESOURCE_GROUP -n $IDENTITIES_DEV_DEPLOYMENT_NAME --query properties.outputs.acrResourceGroupName.value -o tsv)

# Wait for AAD propagation
until az ad sp show --id ${DELIVERY_ID_PRINCIPAL_ID} &> /dev/null ; do echo "Waiting for AAD propagation" && sleep 5; done
until az ad sp show --id ${DRONESCHEDULER_ID_PRINCIPAL_ID} &> /dev/null ; do echo "Waiting for AAD propagation" && sleep 5; done
until az ad sp show --id ${WORKFLOW_ID_PRINCIPAL_ID} &> /dev/null ; do echo "Waiting for AAD propagation" && sleep 5; done
until az ad sp show --id ${GATEWAY_CONTROLLER_ID_PRINCIPAL_ID} &> /dev/null ; do echo "Waiting for AAD propagation" && sleep 5; done

# Export the kubernetes cluster version
export KUBERNETES_VERSION=$(az aks get-versions -l $LOCATION --query "orchestrators[?default!=null].orchestratorVersion" -o tsv)
export SERVICETAGS_LOCATION=$(az account list-locations --query "[?name=='${LOCATION}'].displayName" -o tsv | sed 's/[[:space:]]//g')

# Deploy cluster and microservices Azure services
export DEV_DEPLOYMENT_NAME=azuredeploy-${DEPLOYMENT_SUFFIX}-dev
az group deployment create -g $RESOURCE_GROUP --name $DEV_DEPLOYMENT_NAME --template-file ./azuredeploy.json \
--parameters servicePrincipalClientId=${SP_APP_ID} \
            servicePrincipalClientSecret=${SP_CLIENT_SECRET} \
            servicePrincipalId=${SP_OBJECT_ID} \
            kubernetesVersion=${KUBERNETES_VERSION} \
            sshRSAPublicKey="$(cat ${SSH_PUBLIC_KEY_FILE})" \
            deliveryIdName=${DELIVERY_ID_NAME} \
            deliveryPrincipalId=${DELIVERY_ID_PRINCIPAL_ID} \
            droneSchedulerIdName=${DRONESCHEDULER_ID_NAME} \
            droneSchedulerPrincipalId=${DRONESCHEDULER_ID_PRINCIPAL_ID} \
            workflowIdName=${WORKFLOW_ID_NAME} \
            workflowPrincipalId=${WORKFLOW_ID_PRINCIPAL_ID} \
            appGatewayControllerIdName=${GATEWAY_CONTROLLER_ID_NAME} \
            appGatewayControllerPrincipalId=${GATEWAY_CONTROLLER_ID_PRINCIPAL_ID} \
            acrResourceGroupName=${RESOURCE_GROUP_ACR} \
            acrResourceGroupLocation=$LOCATION

export VNET_NAME=$(az group deployment show -g $RESOURCE_GROUP -n $DEV_DEPLOYMENT_NAME --query properties.outputs.aksVNetName.value -o tsv) && \
export CLUSTER_SUBNET_NAME=$(az group deployment show -g $RESOURCE_GROUP -n $DEV_DEPLOYMENT_NAME --query properties.outputs.aksClusterSubnetName.value -o tsv) && \
export CLUSTER_SUBNET_PREFIX=$(az group deployment show -g $RESOURCE_GROUP -n $DEV_DEPLOYMENT_NAME --query properties.outputs.aksClusterSubnetPrefix.value -o tsv) && \
export CLUSTER_NAME=$(az group deployment show -g $RESOURCE_GROUP -n $DEV_DEPLOYMENT_NAME --query properties.outputs.aksClusterName.value -o tsv) && \
export CLUSTER_SERVER=$(az aks show -n $CLUSTER_NAME -g $RESOURCE_GROUP --query fqdn -o tsv) && \
export FIREWALL_PIP_NAME=$(az group deployment show -g $RESOURCE_GROUP -n $DEV_DEPLOYMENT_NAME --query properties.outputs.firewallPublicIpName.value -o tsv) && \
export ACR_NAME=$(az group deployment show -g $RESOURCE_GROUP -n $DEV_DEPLOYMENT_NAME --query properties.outputs.acrName.value -o tsv) && \
export ACR_SERVER=$(az acr show -n $ACR_NAME --query loginServer -o tsv) && \
export DELIVERY_REDIS_HOSTNAME=$(az group deployment show -g $RESOURCE_GROUP -n $DEV_DEPLOYMENT_NAME --query properties.outputs.deliveryRedisHostName.value -o tsv)

# Restrict cluster egress traffic
az group deployment create -g $RESOURCE_GROUP --name azuredeploy-firewall-${DEPLOYMENT_SUFFIX} --template-file ./azuredeploy-fw.json \
--parameters aksVnetName=${VNET_NAME} \
            aksClusterSubnetName=${CLUSTER_SUBNET_NAME} \
            aksClusterSubnetPrefix=${CLUSTER_SUBNET_PREFIX} \
            firewallPublicIpName=${FIREWALL_PIP_NAME} \
            serviceTagsLocation=${SERVICETAGS_LOCATION} \
            aksFqdns="['${CLUSTER_SERVER}']" \
            acrServers="['${ACR_SERVER}']" \
            deliveryRedisHostNames="['${DELIVERY_REDIS_HOSTNAME}']"