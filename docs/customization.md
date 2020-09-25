# Customizing the deployment

## Variables
A number of terraform variables are provided that allow you to customize aspects of the deployment. Almost all variables
start with default values so you don't need to populate all of them. 

At minimum, you must set the following:

**management_ips**

Map[string]int, configures security group rules that allow access to the management networks of your
deployment. The map key is the IP address or subnet and the int is the position within the security group. 

**password**

Sets the default password for all deployed systems including panorama and the test host (if you use it.)

The default username is panadmin, and this is also tweakable with the **username** variable. 

All of the available variables can be found in [variables.tf](https://github.com/adambaumeister/azure-vmseries-terraform/blob/master/variables.tf).
You can set any variable from the command line, but for simplicity it's easiest to use a tfvars file and pass it to 
the terraform apply command as below:

```
terraform apply --var-file=my_variables.tfvars
```

Some important variables (and an example of a tfvars file) are in [example.tfvars](https://github.com/adambaumeister/azure-vmseries-terraform/blob/master/example.tfvars).

## Disabling the Bootstrap process

This deployment automatically configures bootstrapping to facilitate the scale set deployment. In some cases though, 
you may not want the firewalls to automatically bootstrap. To disable the bootstrap process, change the vm-series module resource
to use *vm-no-bootstrap* in main.tf as below:

```
module "vm-series" {
  source = "./modules/vmss-no-bootstrap"

  location = var.location
  name_prefix = var.name_prefix
  username = var.username
  password = var.password

  subnet-mgmt = module.networks.subnet-mgmt
  subnet-private = module.networks.subnet-private
  subnet-public = module.networks.subnet-public
  
  private_backend_pool_id = module.outbound-lb.backend-pool-id
  public_backend_pool_id = module.inbound-lb.backend-pool-id
}
```
Note you can delete several bootstrap related variables and the dependency on the Panorama module.

# Deploying without Panorama

If you don't want to deploy Panorama, or more likely you already *have* a panorama instance deployed, you can customize
this deployment to not include it. 

1. Deleting [modules/panorama/panorama.tf](https://github.com/adambaumeister/azure-vmseries-terraform/blob/master/modules/panorama/panorama.tf)
2. Removing the external data source that retrieves the auth key from [modules/panorama/bootstrap.tf](https://github.com/adambaumeister/azure-vmseries-terraform/blob/master/modules/panorama/bootstrap.tf)
```
data "external" "panorama_bootstrap" {
...
}
```
This will still deploy the bootstrap and VHD storage requirements, but it won't add any of the bootstrap files.

# Deploying Without ScaleSets
In some cases you may want to deploy an environment that uses dedicated virtual machines and not VMSS. 

A second terraform deployment is provided under the *no-vmss* directory. This deployment is otherwise identical to the 
normal deployment model using VMSS. 

To use it, simply change directory to *no-vmss* before running terraform as normal.
```bash
terraform init
terraform apply --var-file=example.tfvars
```

