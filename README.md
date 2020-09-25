<div align="center">
    <img src="https://www.terraform.io/assets/images/og-image-8b3e4f7d.png" alt="TF Logo" height="50px">
    <img src="https://raw.githubusercontent.com/adambaumeister/azure-vmseries-terraform/master/images/azure.png" alt="Azure Logo" height="50px">
</div>

<div align="center">
    <img src="https://raw.githubusercontent.com/adambaumeister/azure-vmseries-terraform/master/images/pan.png" alt="Pan Logo" height="25px">
</div>

# <div align="center">VM-Series Azure Terraform Templates</div>

## :question: Overview

This repository deploys all the components of a Transit-VNET topoloy using Palo Alto VM-Series Next Generation Firewalls and Panorama.

## :rabbit2: Quickstart

1. [Install Terraform 0.13](https://www.terraform.io/downloads.html)
2. [Install the Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. [Download and extract the latest bundle for your OS](https://github.com/adambaumeister/azure-vmseries-terraform/releases/latest)
4. From the command line (or powershell, or Bash or whatever...) change directory to the newly extracted one
5. Login to Azure

```bash
az login
```

6. Populate the variables in file `example.tfvars`
7. Initialize and apply!

```bash
terraform init
terraform apply --var-file=example.tfvars
```

## :scroll: Documentation

For post-provisioning steps and for setting up the Panorama, [click here](https://adambaumeister.github.io/azure-vmseries-terraform/panorama.html).

For the network topology and more, proceed to the [Detailed Documentation](https://adambaumeister.github.io/azure-vmseries-terraform/index).

## :beetle: Getting help

[Open an issue](https://github.com/adambaumeister/azure-vmseries-terraform/issues) on Github.
