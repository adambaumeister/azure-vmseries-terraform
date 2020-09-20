<div align="center">
    <img src="https://www.terraform.io/assets/images/og-image-8b3e4f7d.png" alt="TF Logo" height="100px">
    <img src="https://raw.githubusercontent.com/adambaumeister/azure-vmseries-terraform/master/images/azure.png" alt="Azure Logo" height="100px">
</div>

# <div align="center">VM-Series on Azure Terraform Templates</div>

## :rabbit2: Quickstart  
1. [Install Terraform](https://www.terraform.io/downloads.html)
2. [Install the Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. [Download and extract the latest bundle for your OS](https://github.com/adambaumeister/azure-vmseries-terraform/releases/latest)
4. From the command line (or powershell, or Bash or whatever...) CD to the newly extracted directory.
5. Login to Azure
```
az login
```
5. Init terraform
```
terraform init
```
6. Apply!
```
terraform apply
```