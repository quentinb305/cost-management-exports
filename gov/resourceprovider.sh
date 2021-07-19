#!/bin/bash

state=$(az provider show --namespace Microsoft.CostManagementExports --query registrationState -o tsv)
if [ "$state" == "Unregistered" ]
then 
    echo "Microsoft.CostManagementExports resource provider is ${state}"
    echo "Start registration"
    SECONDS=0
    az provider register --namespace Microsoft.CostManagementExports
    state=$(az provider show --namespace Microsoft.CostManagementExports --query registrationState -o tsv)
    until [ "$state" == "Registered" ]
    do
        echo "Microsoft.CostManagementExports resource provider state is ${state}... ${SECONDS}s"
        state=$(az provider show --namespace Microsoft.CostManagementExports --query registrationState -o tsv)
        sleep 5s
        if [ "$state" == "Registered" ]
        then
            echo "Registration Finished"
            state=$(az provider show --namespace Microsoft.CostManagementExports --query registrationState -o tsv)
            echo "Microsoft.CostManagementExports resource provider state is ${state}!"
            break
        fi
    done
else
    echo "Microsoft.CostManagementExports resource provider state is ${state}!"
fi