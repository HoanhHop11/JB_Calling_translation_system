output "instance_external_ips" {
  description = "Map of instance name to external IP address"
  value = {
    for name, instance in google_compute_instance.node :
    name => instance.network_interface[0].access_config[0].nat_ip
  }
}

output "instance_internal_ips" {
  description = "Map of instance name to internal IP address"
  value = {
    for name, instance in google_compute_instance.node :
    name => instance.network_interface[0].network_ip
  }
}

output "instance_self_links" {
  description = "Map of instance name to self-link"
  value = {
    for name, instance in google_compute_instance.node :
    name => instance.self_link
  }
}

output "instance_ids" {
  description = "Map of instance name to instance ID"
  value = {
    for name, instance in google_compute_instance.node :
    name => instance.instance_id
  }
}
