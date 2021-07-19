#!/bin/bash

az policy assignment create --scope /subscriptions/%subscription_id% --policy 96670d01-0a4d-4649-9c89-2d3abc0a5025 --name "Require ProjectOwner tag on resource groups" -p "{ \"tagName\": \
{ \"value\": \"ProjectOwner\" } }" 