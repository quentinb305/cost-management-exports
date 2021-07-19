#!/bin/bash

rgtflocation="%rg_tf_location%"
rgtfname="%rg_tf_name%"
tags="%tags%"
terraformsaname="%terraform_sa_name%"
terraformsactnname="%terraform_sa_ctn_name%"

az group create --location $rgtflocation --name $rgtfname --tags $tags
az storage account create --name $terraformsaname --resource-group $rgtfname --location $rgtflocation --allow-blob-public-access false
az storage container create --name $terraformsactnname --account-name $terraformsaname