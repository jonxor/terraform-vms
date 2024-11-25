data "template_file" "user_data" {
  for_each = {
    for index, vm in var.virtual_Machines:
    vm.systemName => vm
  }
  vars = {
    hostname = each.value.systemName
  }
  template = (each.value.generateCloudInit ?
#If generateCloudInit is true, then generate the config from the template
    file("${path.module}/cloudinit_data/template_user_data") :
#If generateCloudInit is false, then use the file you supply
#Note: if you set this to false, and the file is not present, terraform will fail!
    file("${path.module}/cloudinit_data/${each.value.systemName}_user_data")
  )
}

data "template_file" "network_config" {
  for_each = {
    for index, vm in var.virtual_Machines:
    vm.systemName => vm
  }
  vars = {
    ip_address = each.value.IPAddress
  }
  template = (each.value.generateCloudInit ? 
#If generateCloudInit is true, then generate the config from the template
    file("${path.module}/cloudinit_data/template_network_config") :
#If generateCloudInit is false, then use the file you supply
#Note: if you set this to false, and the file is not present, terraform will fail!
    file("${path.module}/cloudinit_data/${each.value.systemName}_network_config")
  )
}

#generate cloudinit ISO for the libvirt host from above files
resource "libvirt_cloudinit_disk" "cloudinit-iso" {
  for_each = {
    for index, vm in var.virtual_Machines:
    vm.systemName => vm
  }
  pool           = "cloudinit"
  name           = "${each.value.systemName}-cloudinit.iso"
  user_data      = data.template_file.user_data[each.key].rendered
  network_config = data.template_file.network_config[each.key].rendered
}

#Make this VM's OS drive
resource "libvirt_volume" "OSVolume" {
  for_each = {
    for index, vm in var.virtual_Machines:
    vm.systemName => vm
  }
  pool   = "VM"
  name   = "${replace(each.value.baseImageFile, ".qcow2", "")}-base_${each.value.systemName}-OS.qcow2"
#Forget the empty disk that gets created by terraform, lets create one that actually works
#We can use qemu-img to create one backed by a base image, or rsync to copy it
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "root"
      host = "rainbow1.testdomain.local"
    }
    when    = create
    inline  = [
      "rm /arrays/spin1/VM/${replace(each.value.baseImageFile, ".qcow2", "")}-base_${each.value.systemName}-OS.qcow2",
      "qemu-img create -f qcow2 -b /arrays/spin1/baseimages/${each.value.baseImageFile} -F qcow2 /arrays/spin1/VM/${replace(each.value.baseImageFile, ".qcow2", "")}-base_${each.value.systemName}-OS.qcow2",
      "qemu-img resize /arrays/spin1/VM/${replace(each.value.baseImageFile, ".qcow2", "")}-base_${each.value.systemName}-OS.qcow2 ${each.value.createsize}",
      "chown libvirt-qemu:kvm /arrays/spin1/VM/${replace(each.value.baseImageFile, ".qcow2", "")}-base_${each.value.systemName}-OS.qcow2",
      "virsh pool-refresh VM"
    ]
  }
}

#Define the VM
resource "libvirt_domain" "VMDomain" {
  for_each = {
    for index, vm in var.virtual_Machines:
    vm.systemName => vm
  }
  depends_on  = [ libvirt_volume.OSVolume , libvirt_cloudinit_disk.cloudinit-iso ]
  name        = each.value.systemName
  description = each.value.systemDescription
  memory      = each.value.memoryMB
  vcpu        = each.value.vcpu
  cpu {
    mode = each.value.cpuSpecsmode
  }
  running     = each.value.makeRunning
  autostart   = each.value.makeAutoStart
  qemu_agent  = each.value.qemu_agent
  disk {
    file      = "${libvirt_volume.OSVolume[each.key].id}"
    scsi      = "true"
  }
  network_interface {
    bridge  = each.value.networkBridge
  }
  cloudinit   = libvirt_cloudinit_disk.cloudinit-iso[each.key].id

#Have you tried turning it off and on again
#This is to fix an issue with the libvirt provider that attaches the disk with the wrong subdriver
#reset the VM after attaching it correctly
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "root"
      host = "rainbow1.testdomain.local"
    }
    when    = create
    inline  = [
      "virsh detach-disk ${each.value.systemName} sda --persistent",
      "virsh attach-disk ${each.value.systemName} /arrays/spin1/VM/${replace(each.value.baseImageFile, ".qcow2", "")}-base_${each.value.systemName}-OS.qcow2 sda --persistent --subdriver qcow2",
      "sleep 1",
      "virsh reset ${each.value.systemName}"
    ]
  }
}

#Make DNS A Record
resource "dns_a_record_set" "VM_A_Record" {
  for_each = {
    for index, vm in var.virtual_Machines:
    vm.systemName => vm
  }
  zone = "testdomain.local."
  name = each.value.systemName
  addresses = [
    "${each.value.IPAddress}",
  ]
  ttl = 300
}
