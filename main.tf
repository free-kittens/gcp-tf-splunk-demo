provider "google" {
 project     = "possible-jetty-239813"
 region      = "europe-west1"
}

resource "random_id" "instance_id" {
 byte_length = 8
}

resource "google_compute_instance" "splunk-bigredbutton-idx" {
 name = "splunk-bigredbutton-idx-vm-${random_id.instance_id.hex}"
 machine_type = "g1-small"
 zone = "europe-west1-b"
 tags = ["splunk-bigredbutton"]

 boot_disk {
  initialize_params {
   image = "gce-uefi-images/centos-7"
  }
 }

 metadata_startup_script = "sudo yum -q -y update; yum -q -y install git; yum -q -y install ansible; git clone https://github.com/free-kittens/gcp-tf-splunk-demo.git; ansible-playbook gcp-splunk-demo/idx-install.yml"

 network_interface {
  network = "default"

  access_config {
  }
 }
}

resource "google_compute_instance" "splunk-bigredbutton-hf" {
 name = "splunk-bigredbutton-hf-vm-${random_id.instance_id.hex}"
 machine_type = "f1-micro"
 zone = "europe-west1-b"
 tags = ["splunk-bigredbutton"]

 boot_disk {
  initialize_params {
   image = "gce-uefi-images/centos-7"
  }
 }

 metadata_startup_script = "sudo yum -q -y update; yum -q -y install git; yum -q -y install ansible; git clone https://github.com/free-kittens/gcp-tf-splunk-demo.git; ansible-playbook gcp-splunk-demo/hf-install.yml"

 network_interface {
  network = "default"

  access_config {
  }
 }

 metadata {
  sshKeys = "panther:${file("id_ed25519.pub")}"
 }
}

resource  "google_compute_firewall" "default" {
 name    = "splunk-firewall"
 network = "default"

allow {
 protocol = "tcp"
 ports = ["80","8000","8089","9997"]
}
allow {
 protocol = "icmp"
}
}

output "idx-ip" {
 value = "${google_compute_instance.splunk-bigredbutton-idx.network_interface.0.access_config.0.nat_ip}"
 }
output "hf-ip" {
value = "${google_compute_instance.splunk-bigredbutton-hf.network_interface.0.access_config.0.nat_ip}"
}
