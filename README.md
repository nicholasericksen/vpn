# The VPN
A crowd configured, security-focused, and open source VPN solution.

### Overview
Virtual Private Networks, or VPNs, are network devices that provide basic protection from wifi network attacks
and hide information about you, such as your exact location, from prying eyes.
If you are using a public wifi network you should ALWAYS use a VPN.

The IP of the VPN is determined by where the service is hosted.
The rise of cloud computing in recent years makes deploying computer services in data centers around the world much easier.
Today these datacenter providers are currently large scale enterprises such as Amazon Web Services, Microsoft Azure, Google Cloud Platform, Digitial Ocean, etc.
As these cloud providers monitor these servers for security and performance reasons hosting a VPN service does not hide all your activity.
You should not do illegal things.
The goal of this project is to make it easy to stay safe while browsing the internet at your local coffee shop.
Work with your local governments to create the change you want to see in the world.
Although you are not completely hidden behind a VPN hosted on a enterprise cloud provider, you are protected from local area network attacks on unprotected public wifi networks.
Eventually we will support easily deploying a VPN on your home network.

The goal of this project is to provide an easy way to deploy VPN servers that you control with a cloud provider you trust.
This repo contains scripts to configure the servers required in a secure fashion and we can all update it with the best recommended security practices to help each other.
So you can feel secure without having to neccesarily understand the inner workers of how the service is configured.
Since this is a FOSS project you are free to audit the code and study it as you wish.
Contributions always welcome!


The infrastructure for deploying the VPN is also open source as it leverages Terraform for provisioning the servers and Wireguard as the VPN service itself.
This project is of course targeted at support mainly for Linux servers as well.


### Supported Cloud Providers
```
[x] Digital Ocean
[] Amazon Web Services
[] Google Cloud Platform
[] Microsoft Azure

[] Host your own at home
```

### Prerequisites
* Terraform
* Supported Cloud Provider API Key
* Local SSH key


### Installation
Install terraform for your machine according to the documentation

Generate SSH key for the project
`ssh-keygen`

Call the key what you would like, in this example `id_rsa_terraform_vpn`.
and leave the passphrase empty for now.

Add the following to `.bash_profile`

```
export TF_VAR_DO="<DO_API_KEY>"
export TF_VAR_PRIVATE_VPN="<path_to_key>/id_rsa_terraform_vpn"
export TF_VAR_PUBLIC_VPN="<path_to_key>/id_rsa_terraform_vpn.pub"

export ADMIN_EMAIL=<your_email_address>
```

where 

`<DO_API_KEY>` is your Digital Ocean API key.\
`<path_to_key>` is the absolute path to the ssh keys created on your system.\
`<your_email_address>` is an email account you have access to.


And then run `source ~/.bash_profile` to enable the changes.

You can then run `terraform init`, `terraform plan`, `terraform apply` to build each server.

To take down the VPN server run `terraform destroy`.


### Wireguard Client
Once the VPN server is deployed you will have received your client configuration file via email.
You will need to download a Wireguard VPN client from your devices app store onto your device.


[WireGuard Installation](https://www.wireguard.com/install/)

You can then import your VPN configuration into the app and connect your device to the VPN.

WireGuard Setup.  Select the `+` button to import a new configuration.

<img src="docs/imgs/wireguard-empty-client.png" width="250" />

Select to "Import From File or Archive"

<img src="docs/imgs/wireguard-import-from-file.png" width="250" />

Select the `.conf` file received by email once the VPN server has completed its installation.
Once loaded in the VPN instance will be listed in the WireGuard client.

<img src="docs/imgs/wireguard-loaded-in.png" width="250" />

You can now toggle the VPN on and off to access your secure network.
It is also possible to see the VPN details and change the name to something more human readable.

<img src="docs/imgs/wireguard-setup.png" width="250" />


### Adding new vpn clients
You can create new VPN keys for additional clients by running the following command

`ssh root@MachineB 'bash -s' < vpn-add-client.sh`

### Changing the VPN region
Before running the terraform commands you can change the digitalocean.tf file and update it to a different deployment region.

In the droplet section change the region to any supported DO slug.
```
region             = "nyc1"
```

Example DO regions
```
New York City: "nyc1"
Amsterdam: "ams3"
San Francisco: "sfo3"
Singapore: "sgp1"
London: "lon1"
Frankfurt: "fra1"
Toronto: "tor1"
Bangalore: "blr1"
```

