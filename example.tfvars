# IP : SG Rule priority map
# Each Key is the public IP, and the number is the priority it gets in the relevant SGs
management_ips = {
  "199.199.199.199": 100,
}

# LB Rules
# These are optional, but will automatically create a PIP and inbound LB configuration.
rules = [
  {
    port = 22
    name = "testssh"
  }
]

# Admin password, used to login to the firewalls.
## !!IMPORTANT!! CHANGE ME!
# You can also pass this on the command line or via stdin to avoid putting it in a file.
password = "Don'tUseThisPassword,it'sForDemoPurposesOnly"