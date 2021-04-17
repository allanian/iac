resource "proxmox_vm_qemu" "proxmox_vm" {
  count                = var.instances
  name                 = "${var.vm_name}-${count.index + 1}"
  desc = "A test for using terraform and cloudinit"

  # Node name has to be the same name as within the cluster
  target_node       = "pve"
  # The template name to clone this vm from
  clone             = "CentOS8Stream-Template"
  full_clone        = "true"
  # Activate QEMU agent for this VM
  agent             = 1
  os_type           = "centos"
  # SPEC
  cores             = var.vm_cores
  sockets           = var.vm_sockets
  vcpus             = var.vm_vcpus
  memory            = var.vm_memory
  scsihw            = "virtio-scsi-pci"
  bootdisk          = "scsi0"
  define_connection_info = true
  # Setup the disk
  disk {
    size="20G"
    type            = "scsi"
    storage         = "local-lvm"
    format          = "raw"
    iothread        = 1
    discard         = "on"
  }
  disk {
    size=var.vm_disk_size
    type            = "scsi"
    storage         = "local-lvm"
    format          = "raw"
    iothread        = 1
    discard         = "on"
  }

  # Setup the network interface
  os_network_config  = "centos"
  searchdomain =var.vm_searchdomain
  nameserver = var.vm_nameserver


  network {
    model           = "virtio"
    bridge          = "vmbr0"
  }

  ssh_user = var.ssh_user
  sshkeys = var.ssh_key



  provisioner "remote-exec" {
    inline = [
      "sudo ls /sys/class/scsi_host/ | while read host ; do echo '- - -' |sudo tee /sys/class/scsi_host/$host/scan > /dev/null; done",
      "sudo pvcreate /dev/sdb",
      "sudo vgcreate data /dev/sdb",
      "sudo lvcreate -l 100%FREE -n lv_data data",
      "sudo mkfs.xfs -n ftype=1 /dev/data/lv_data",
      "sudo echo '/dev/mapper/data-lv_data /data                       xfs     defaults        0 0' | sudo tee -a /etc/fstab >/dev/null",
      "sudo mkdir /data && mount /data",
    ]
    connection {
      #host     = self.default_ipv4_address
#      host        = proxmox_vm_qemu.proxmox_vm.ssh_host
      host = self.ssh_host
      type     = "ssh"
      user     = var.ssh_user
      password = var.ssh_password
      #private_key = "file(./.ssh/id_rsa)"
      #private_key = var.ssh_private_key
    }
  }
  provisioner "local-exec" {
    working_dir = "./ansible/"
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ansible -i '${self.ssh_host},' ansible.yml"
  }
}
