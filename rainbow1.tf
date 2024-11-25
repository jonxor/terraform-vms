provider "libvirt" {
uri = "qemu+ssh://root@rainbow1.testdomain.local/system"
}

provider "dns" {
  update {
    server        = "192.168.202.5"
    key_name      = "terraformkey.testdomain.local."
    key_algorithm = "hmac-sha256"
    key_secret    = "SecretRedactedHMACKey"
  }
}

#These are not neccesary for how we do things

#resource "libvirt_network" "br101" {
#  name   = "br101"
#  mode   = "bridge"
#  bridge = "br101"
#}

#resource "libvirt_network" "br200" {
#  name   = "br200"
#  mode   = "bridge"
#  bridge = "br200"
#}

#resource "libvirt_pool" "VM" {
#  id   = "dda8854e-bc2a-427d-9ce4-24a900ff5408"
#  name = "VM"
#  type = "dir"
#  path = "/arrays/spin1/VM"
#}

#resource "libvirt_pool" "ISO" {
#  id   = "00ff6ec9-b25c-4921-9130-fe024b28aa97"
#  name = "ISO"
#  type = "dir"
#  path = "/arrays/spin1/ISO"
#}

#resource "libvirt_pool" "cloudinit" {
#  id   = "fdbc39de-5904-4aa8-a098-dae02fdd1015"
#  name = "cloudinit"
#  type = "dir"
#  path = "/arrays/spin1/cloudinit"
#}
