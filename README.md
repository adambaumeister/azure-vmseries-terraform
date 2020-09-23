<div align="center">
    <img src="https://www.terraform.io/assets/images/og-image-8b3e4f7d.png" alt="TF Logo" height="100px">
    <img src="https://raw.githubusercontent.com/adambaumeister/azure-vmseries-terraform/master/images/azure.png" alt="Azure Logo" height="100px">
</div>

<div align="center">
    <img src="https://raw.githubusercontent.com/adambaumeister/azure-vmseries-terraform/master/images/pan.png" alt="Pan Logo" height="25px">
</div>

# <div align="center">VM-Series Azure Terraform Templates</div>

## :question: Overview
This repository deploys all the components of a Transit-VNET topoloy using Palo Alto VM-Series Next Generation Firewalls and Panorama.

## :rabbit2: Quickstart  
1. [Install Terraform](https://www.terraform.io/downloads.html)
2. [Install the Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. [Download and extract the latest bundle for your OS](https://github.com/adambaumeister/azure-vmseries-terraform/releases/latest)
4. From the command line (or powershell, or Bash or whatever...) CD to the newly extracted directory.
5. Login to Azure
```
az login
```
5. Correctly populate the variables in the vars file example.tfvars
6. Init terraform
```
terraform init
```
7. Apply!
```
terraform apply --var-file=example.tfvars 
```

## :scroll: Documentation
To know post-provisioning steps and for help standing up Panorama, [click here](https://adambaumeister.github.io/azure-vmseries-terraform/panorama.html)

For more detailed documentation including the network topology and more, proceed to [Detailed Documentation](https://adambaumeister.github.io/azure-vmseries-terraform/index)

## :beetle: Getting help
[Open an Issue on Github](https://github.com/adambaumeister/azure-vmseries-terraform/issues)

