#!/bin/bash

az policy assignment create --scope /subscriptions/%subscription_id% --policy cd3aa116-8754-49c9-a813-ad46512ece54 --name "Inherit ProjectOwner tag from resource groups" -p "{ \"tagName\": \
{ \"value\": \"ProjectOwner\" } }" --assign-identity --location %identity_location%