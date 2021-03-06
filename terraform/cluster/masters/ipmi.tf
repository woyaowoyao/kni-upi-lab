resource "null_resource" "ipmi_master" {
    count = var.virtual_masters == "true" ? 0 : var.master_count
    provisioner "local-exec" {
        command = <<EOT
          ipmitool -I lanplus -H ${element(split(":", var.master_nodes[count.index]["ipmi_host"]),0)} %{if element(split(":", var.master_nodes[count.index]["ipmi_host"]),1)!=var.master_nodes[count.index]["ipmi_host"]}-p ${element(split(":", var.master_nodes[count.index]["ipmi_host"]),1)}%{ endif } -U ${var.master_nodes[count.index]["ipmi_user"]} -P ${var.master_nodes[count.index]["ipmi_pass"]} chassis bootdev pxe;
          ipmitool -I lanplus -H ${element(split(":", var.master_nodes[count.index]["ipmi_host"]),0)} %{if element(split(":", var.master_nodes[count.index]["ipmi_host"]),1)!=var.master_nodes[count.index]["ipmi_host"]}-p ${element(split(":", var.master_nodes[count.index]["ipmi_host"]),1)}%{ endif } -U ${var.master_nodes[count.index]["ipmi_user"]} -P ${var.master_nodes[count.index]["ipmi_pass"]} power cycle || ipmitool -I lanplus -H ${element(split(":", var.master_nodes[count.index]["ipmi_host"]),0)} %{if element(split(":", var.master_nodes[count.index]["ipmi_host"]),1)!=var.master_nodes[count.index]["ipmi_host"]}-p ${element(split(":", var.master_nodes[count.index]["ipmi_host"]),1)}%{ endif } -U ${var.master_nodes[count.index]["ipmi_user"]} -P ${var.master_nodes[count.index]["ipmi_pass"]} power on;
EOT
    }
}

resource "null_resource" "ipmi_virtual_master" {
    count = var.virtual_masters == "true" ? var.master_count : 0

    provisioner "local-exec" {
        command = <<EOT
          ipmitool -I lanplus -H ${element(split(":", var.master_nodes[count.index]["ipmi_host"]),0)} %{if element(split(":", var.master_nodes[count.index]["ipmi_host"]),1)!=var.master_nodes[count.index]["ipmi_host"]}-p ${element(split(":", var.master_nodes[count.index]["ipmi_host"]),1)}%{ endif } -U ${var.master_nodes[count.index]["ipmi_user"]} -P ${var.master_nodes[count.index]["ipmi_pass"]} chassis bootdev pxe;
          ipmitool -I lanplus -H ${element(split(":", var.master_nodes[count.index]["ipmi_host"]),0)} %{if element(split(":", var.master_nodes[count.index]["ipmi_host"]),1)!=var.master_nodes[count.index]["ipmi_host"]}-p ${element(split(":", var.master_nodes[count.index]["ipmi_host"]),1)}%{ endif } -U ${var.master_nodes[count.index]["ipmi_user"]} -P ${var.master_nodes[count.index]["ipmi_pass"]} power off || ipmitool -I lanplus -H ${element(split(":", var.master_nodes[count.index]["ipmi_host"]),0)} %{if element(split(":", var.master_nodes[count.index]["ipmi_host"]),1)!=var.master_nodes[count.index]["ipmi_host"]}-p ${element(split(":", var.master_nodes[count.index]["ipmi_host"]),1)}%{ endif } -U ${var.master_nodes[count.index]["ipmi_user"]} -P ${var.master_nodes[count.index]["ipmi_pass"]} power on;
          ipmitool -I lanplus -H ${element(split(":", var.master_nodes[count.index]["ipmi_host"]),0)} %{if element(split(":", var.master_nodes[count.index]["ipmi_host"]),1)!=var.master_nodes[count.index]["ipmi_host"]}-p ${element(split(":", var.master_nodes[count.index]["ipmi_host"]),1)}%{ endif } -U ${var.master_nodes[count.index]["ipmi_user"]} -P ${var.master_nodes[count.index]["ipmi_pass"]} power on;
          sleep 3;
          ipmitool -I lanplus -H ${element(split(":", var.master_nodes[count.index]["ipmi_host"]),0)} %{if element(split(":", var.master_nodes[count.index]["ipmi_host"]),1)!=var.master_nodes[count.index]["ipmi_host"]}-p ${element(split(":", var.master_nodes[count.index]["ipmi_host"]),1)}%{ endif } -U ${var.master_nodes[count.index]["ipmi_user"]} -P ${var.master_nodes[count.index]["ipmi_pass"]} chassis bootdev disk;
EOT
    }
}

resource "null_resource" "ipmi_master_cleanup" {
    count = var.master_count
    provisioner "local-exec" {
        when = "destroy"
        command = <<EOT
          ipmitool -I lanplus -H ${element(split(":", var.master_nodes[count.index]["ipmi_host"]),0)} %{if element(split(":", var.master_nodes[count.index]["ipmi_host"]),1)!=var.master_nodes[count.index]["ipmi_host"]}-p ${element(split(":", var.master_nodes[count.index]["ipmi_host"]),1)}%{ endif } -U ${var.master_nodes[count.index]["ipmi_user"]} -P ${var.master_nodes[count.index]["ipmi_pass"]} power off;
EOT
    }
}
