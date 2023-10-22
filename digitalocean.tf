variable "DO" {}
variable "PRIVATE_VPN" {}
variable "PUBLIC_VPN" {}

terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
  }
}

provider "digitalocean" {
  token = var.DO
}

resource "digitalocean_ssh_key" "vpn-main" {
  name       = "DO VPN MAIN"
  public_key = file(var.PUBLIC_VPN)
}

resource "digitalocean_droplet" "vpn" {
  image              = "centos-7-x64"
  name               = "the-vpn-main"
  region             = "sfo3"
  size               = "s-1vcpu-2gb"
  monitoring         = false
  ipv6               = false
  private_networking = true
  ssh_keys           = [digitalocean_ssh_key.vpn-main.fingerprint]

  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = file(var.PRIVATE_VPN)
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    scripts = [
      "bin/vpn-install.sh"
    ]
  }
}

resource "digitalocean_firewall" "wireguard" {
  name = "ssh-and-wireguard-current"

  droplet_ids = [digitalocean_droplet.vpn.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0"]
  }

  inbound_rule {
    protocol         = "udp"
    port_range       = "51194"
    source_addresses = ["0.0.0.0/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "443"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "tcp"
    port_range            = "80"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
    protocol              = "tcp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
