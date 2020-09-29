# Licensing the VM series components 

By default, this terraform code deploys a scale set using *bundled* licensing. However, it's common to use
BYOL licensing.

To support BYOL licensing, you must:

1. Create a "license" directory in the root directory (i.e, next to main.tf)
2. Populate that directory with any licensing files (*.key files, authcodes etc.)
3. Set the following variable:
```
vm_series_sku = "byol"
```

Everything in the "license" directory you have created locally will be mirrored to the bootstrap share for both 
inbound and outbound. This code runs once, as part of the provisioner process for panorama, and will not re-run 
unless it is reprovisioned. 