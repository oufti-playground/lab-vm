
output "instance_dns_list" {
  value = "${join(":10000,", aws_instance.lab_node.*.public_dns)}"
}
