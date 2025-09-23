# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

packer {
  required_plugins {
    vultr = {
      version = ">= 2.5.0"
      source  = "github.com/vultr/vultr"
    }
  }
}

variable "vultr_api_key" {
  type    = string
  default = "${env("VULTR_API_KEY")}"
  sensitive = true
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "vultr" "ubuntu-22" {
  api_key              = "${var.vultr_api_key}"
  os_id                = "1743"
  plan_id              = "vhf-1c-1gb"
  region_id            = "dfw"
  snapshot_description = "testing"
  state_timeout        = "10m"
  ssh_username         = "root"
}

build {
  sources = ["source.vultr.ubuntu-22"]
  
  provisioner "shell" {
     script = "scripts/setup.sh"
   }
}

