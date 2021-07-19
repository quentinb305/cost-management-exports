# Monthly Azure Cost Management export to ProjectOwner tag

# Contents

- [About this project](#about-this-project)
- [Architecture and Decision Design](#architecture-and-decision-design)
- [Getting Started](#getting-started)
- [Limitations and Improvements](#limitations-and-improvements)

# About this project

## Use case and requirements

The objective of this solution is to send by mail Azure projects costs to project owner.  
Project is identified as a Resource Group and project owner as value (email) of the Tag 'ProjectOwner'.  

The solution should: 
- Send an email monthly and automatically. 
- Send exports under .csv file format.
- Gather all exports as attachments under one email for the same project owner.
- Not give any role to project owner.

## Disclaimer

This solution is provided under the [MIT License](LICENSE) terms.

# Architecture and Decision Design

## Architecture
![This is architecture diagram](images/architecture.png?raw=true "Architecture")

1. Azure Policies ask for ProjectOwner Tag on each new Resource Group. New resources in resource groups inherit ProjectOwner Tag and Value.
2. Azure Event Grid subscribes to new Resource Group successfully created events and routes them to Azure Function endpoint. 
3. Azure Function is triggered based on those events and run PowerShell script to configure Azure Cost Management exports on each new Resource Group.
4. Azure Cost Management monthly sends .csv exports to Azure Blob Storage. 
5. Azure Event Grid subscribes to new blob successfully created events and routes them to an Azure Logic App. 
6. Azure Logic App processes blob in batch and call an Azure Function to get Project Owner Tag value. It then sends it an email to the Project Owner. 

## Output

![This is email generated](images/email.png?raw=true "Email generated")

![This is export attached](images/export.png?raw=true "Export attached")

## Decision Design

- Azure Policy: Tagging policy and governance is key for the solution.
- Azure Blob Storage: Blob container hierarchy is based on the Project Owner > Resource Group > Period to trigger and route relevant data to the right Project Owner.
- Azure Function: Azure Function Apps run under consumption plan to lower costs. 
- Azure Event Grid: In serverless architecture, routing events to endpoints is key.
- Azure Logic Apps: Azure Logic Apps should be as easy as possible to process quicky. They will scale out to several instances to process N small files instead of scaling up to process 1 big file. Azure Logic Apps works here in batch to manage state (batch sender - batch receiver). 

# Getting Started

## Prerequisites

- Terraform service principal: Owner role at subscription scope.
Note: Owner role is required to assign roles to deployed managed identities. For security purpose, you can delete the Terraform service principal role assignment post deployment.
- Azure DevOps service principal: Contributor and Resource Policy Contributor role at subscription scope.
- Azure DevOps service connection: All pipelines allowed to use Azure DevOps service connection.

## Step-by-step guide

1. Create a new private GitHub repository in your GitHub Organization (or create a new one)
2. Clone the repository: 'git clone https://github.com/quentinb305/cost-management-exports.git'
3. (Option 1) Replace TODO_VAR variables in YAML files within pipelines folder with your own variables. (Option 2) Withdraw all variables in YAML files and set them while reviewing your Pipeline YAML in step 11
4. Push your local cloned repository on previously created GitHub repository
5. Create a new Project in your Azure DevOps Organization (or create a new one)
6. Create a new Service connections: 'Azure Resource Manager using service principal (automatic)'
7. Manage Service Principal: Copy 'Display name'
8. Manage service connection roles: Add 'Resource Policy Contributor' role in addition to existing 'Contributor' role
9. Create a new Service connections: 'GitHub'
10. Create a new Pipeline
11. Where is your code: 'GitHub (YAML)'
12. Select a repository: Choose your previously created repository
13. Configure your pipeline: 'Existing Azure Pipelines YAML file'
14. Select an existing YAML file: Branch 'main' and Path '/pipelines/ADO-CI/azure-pipelines-gov-CI.yml'
15. Review your pipeline YAML (Option 2 only): Set 'New variable' in 'Variables'
16. Review your pipeline YAML: Save
17. Rename/move pipeline: Name 'gov-CI' and save
18. Run pipeline 
19. Reproduce steps 6 to 14 for Path '/pipelines/ADO-CI/azure-pipelines-infra-p1-CI.yml', '/pipelines/ADO-CI/azure-pipelines-infra-p2-CI.yml', '/pipelines/ADO-CI/azure-pipelines-src-functionapp-create-exports-CI.yml', '/pipelines/ADO-CI/azure-pipelines-src-functionapp-get-po-tag-CI.yml', renamed respectively 'infra-p1-CI', 'infra-p2-CI', 'src-functionapp-create-exports-CI', and 'src-functionapp-get-po-tag-CI'
20. Reproduce steps 6 to 14 for Path '/pipelines/ADO-CD/azure-pipelines-e2e-CD.yml' renamed 'e2e-CD', and run it after CI pipelines succeeded.
21. Authorize API Connections for Office 365 and Azure Event Grid.  
22. Edit Azure Logic App Sender trigger through Logic App designer with Subscription Name and save. 
23. Remove role assignment of Azure DevOps and Terraform Service Principal (optional).

Note: Azure Logic Apps process in batch files for the same Project Owner. It is set up to wait for 1 minute. In a production and large environment, it may be increased up to 1 hour.

## Test

1. Create a new Resource Group.
2. Check exports is configured for the new Resource Group (it may take a few minutes).  
2.1. Check Event Grid Topic Subscription if event is delivered.  
2.2. Check Azure Function EventGridTrigger1 is executed.  
2.3. Check Azure Function EventGridTrigger1 Monitor Invocation Traces if any error within Function execution. 
3. Run now export configuration.
4. Check .csv file is created in Azure Blob Storage.
5. Check Azure Logic App Batch Sender is triggered.
6. Check Azure Logic App Batch Receiver is triggered (do not forget that it wait 1 minute to process all matching files in batch). 
7. Check mail is received.

# Limitations and Improvements

## Limitations

- The solution works at the subscription scope. If you need to manage multiple subscription, deploy the solution multiple times.
- Remediation should be done for existing environment.

## Improvements

- Enforce matching pattern for Azure Policy.
- Create monitoring dashboards to follow solution health.
- Create Azure Key Vault to store secrets. 
- Automatize post deployment tests. 
- Keep an eye on Azure Automation Tasks for future solution. 