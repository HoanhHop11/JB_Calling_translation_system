output "firewall_rule_names" {
  description = "List of created firewall rule names"
  value = [
    google_compute_firewall.allow_ssh.name,
    google_compute_firewall.allow_http_https.name,
    google_compute_firewall.allow_webrtc_udp.name,
    google_compute_firewall.allow_turn.name,
    google_compute_firewall.allow_k8s_api.name,
    google_compute_firewall.allow_internal_cluster.name,
    google_compute_firewall.allow_internal_icmp.name,
  ]
}

output "firewall_rule_ids" {
  description = "List of created firewall rule self-links"
  value = [
    google_compute_firewall.allow_ssh.self_link,
    google_compute_firewall.allow_http_https.self_link,
    google_compute_firewall.allow_webrtc_udp.self_link,
    google_compute_firewall.allow_turn.self_link,
    google_compute_firewall.allow_k8s_api.self_link,
    google_compute_firewall.allow_internal_cluster.self_link,
    google_compute_firewall.allow_internal_icmp.self_link,
  ]
}
