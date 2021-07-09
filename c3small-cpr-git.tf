## This script will deploy a reserved c3.small node into your project and peform default partitions.
## Beofore using it please make sure you have a c3.small reserved to the project you plan to deploy to,
## replace "metal-api-token" with your own token, and "project-id" with your project ID where the c3.small is 
## reserved.
## Please contact me at lama@equinix.com with comments or questions

terraform {
  required_providers {
    metal = {
      source = "equinix/metal"
      version = "2.1.0"
    }
  }
}
provider "metal" {
  auth_token = "metal-api-token"
}

locals {
  project  = "project-id"
}

resource "metal_device" "c3small_cpr" {
  hostname         = "c3.small.cpr01"
  plan             = "c3.small.x86"
  facilities       = ["sv15"]
  operating_system = "ubuntu_20_04"
  billing_cycle    = "hourly"
  project_id       =  local.project
  hardware_reservation_id = "next-available"
  storage                 = <<EOS
  {
    "disks": [
    {
      "device": "/dev/sda",
      "wipeTable": true,
      "partitions": [
        {
          "label": "BIOS",
          "number": 1,
          "size": "4096"
        },
        {
          "label": "SWAP",
          "number": 2,
          "size": "3993600"
        },
        {
          "label": "ROOT",
          "number": 3,
          "size": "0"
        }
      ]
    }
  ],
  "filesystems": [
    {
      "mount": {
        "device": "/dev/sda3",
        "format": "ext4",
        "point": "/",
        "create": {
          "options": [
            "-L",
            "ROOT"
          ]
        }
      }
    },
    {
      "mount": {
        "device": "/dev/sda2",
        "format": "swap",
        "point": "none",
        "create": {
          "options": [
            "-L",
            "SWAP"
          ]
        }
      }
    }
  ]
 } 
EOS
} 
