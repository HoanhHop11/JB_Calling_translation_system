resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.network_name}-allow-ssh"
  project = var.project_id
  network = var.network_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["translation-node"]

  description = "Allow SSH access from anywhere"
}

resource "google_compute_firewall" "allow_http_https" {
  name    = "${var.network_name}-allow-http-https"
  project = var.project_id
  network = var.network_id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["translation-node"]

  description = "Allow HTTP and HTTPS traffic"
}

resource "google_compute_firewall" "allow_webrtc_udp" {
  name    = "${var.network_name}-allow-webrtc-udp"
  project = var.project_id
  network = var.network_id

  allow {
    protocol = "udp"
    ports    = ["40000-40019"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["translation-node"]

  description = "Allow WebRTC media UDP traffic"
}

resource "google_compute_firewall" "allow_turn" {
  name    = "${var.network_name}-allow-turn"
  project = var.project_id
  network = var.network_id

  allow {
    protocol = "tcp"
    ports    = ["3478", "5349"]
  }

  allow {
    protocol = "udp"
    ports    = ["3478", "5349", "49152-49156"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["translation-node"]

  description = "Allow TURN/STUN TCP and UDP traffic"
}

resource "google_compute_firewall" "allow_k8s_api" {
  name    = "${var.network_name}-allow-k8s-api"
  project = var.project_id
  network = var.network_id

  allow {
    protocol = "tcp"
    ports    = ["6443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["translation-node"]

  description = "Allow Kubernetes API server access"
}

resource "google_compute_firewall" "allow_internal_cluster" {
  name    = "${var.network_name}-allow-internal-cluster"
  project = var.project_id
  network = var.network_id

  allow {
    protocol = "tcp"
    ports = [
      "2379-2380",
      "10250",
      "10259",
      "10257",
      "30000-32767",
    ]
  }

  allow {
    protocol = "udp"
    ports    = ["4789"]
  }

  source_ranges = [var.subnet_cidr]
  target_tags   = ["translation-node"]

  description = "Allow internal Kubernetes cluster communication (etcd, kubelet, kube-scheduler, kube-controller-manager, NodePort, Calico VXLAN)"
}

resource "google_compute_firewall" "allow_internal_icmp" {
  name    = "${var.network_name}-allow-internal-icmp"
  project = var.project_id
  network = var.network_id

  allow {
    protocol = "icmp"
  }

  source_ranges = [var.subnet_cidr]
  target_tags   = ["translation-node"]

  description = "Allow ICMP between cluster nodes"
}
