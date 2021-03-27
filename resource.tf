
/*
resource "null_resource" "prereqs" {

  provisioner "local-exec" {
    command = <<EOT
        echo "Hack to install Anisble on Terraform agent!"
	no_prxy=`printenv NO_PROXY`
	export NO_PROXY=*
	cd /etc/apt/
	echo "deb http://deb.debian.org/pub/debian/ stretch main" > sources.list
	echo "deb http://deb.debian.org/debian stable main contrib non-free" >> sources.list
	apt update -y
	apt install -y python3-pip
	pip3 install ansible
	pip3 install paramiko
	ansible-galaxy collection install cisco.nxos
	export NO_PROXY=$no_prxy      
     EOT
  }


}
*/



resource "null_resource" "enable_features" {
  provisioner "local-exec" {
    command    = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook  -i inventory enable_features.yaml"
    on_failure = fail
  }

}



resource "null_resource" "pre" {

  connection {
    type     = "ssh"
    user     = "root"
    password = "nbv12345"
    host     = "173.36.220.114"
    timeout  = "300s"
  }

  provisioner "remote-exec" {
    inline = [
      "sshpass -p nbv12345 ssh -o IdentitiesOnly=yes admin@173.36.220.34 show vlan"
    ]
  }
}




resource "null_resource" "create_vlan" {
  depends_on = [
    null_resource.pre
  ]



  provisioner "local-exec" {
    command    = "ANSIBLE_HOST_KEY_CHECKING=False ansible -m ping localhost"
    on_failure = fail
  }



  provisioner "local-exec" {
    command    = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook  -i inventory create_vlan.yaml"
    on_failure = fail
  }

}



resource "null_resource" "post" {
  depends_on = [
    null_resource.create_vlan
  ]
  connection {
    type     = "ssh"
    user     = "root"
    password = "nbv12345"
    host     = "173.36.220.114"
    timeout  = "300s"
  }

  provisioner "remote-exec" {
    inline = [
      "sshpass -p nbv12345 ssh -o IdentitiesOnly=yes admin@173.36.220.34 show vlan"
    ]
  }

  /*
  provisioner "local-exec" {
    command = <<EOT
      echo Host ${vsphere_cluster.ip} >> ${var.local_ssh_config};
      echo IdentityFile ${var.local_identity_file} >> ${var.local_ssh_config}
    EOT

  }
  */
}
