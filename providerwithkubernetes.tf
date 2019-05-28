# providers info
provider "google" {
  credentials = "${file("/home/user01/GOOGLE/tp2/ageless-answer-241907-64ea0d333027.json")}"
  project = "ageless-answer-241907"
  region = "europe-west1"
}

resource "google_compute_network" "vn" {
  name = "virtual-network"
  auto_create_subnetworks = "false"
}

resource "google_compute_firewall" "allow-ssh" {
  name    = "allow-internal"
  network = "${google_compute_network.vn.name}"

 allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags = ["ssh"]
  }
 

resource "google_compute_subnetwork" "sub1" {
  name   = "subnetwork1"
  ip_cidr_range = "10.0.0.0/8"
  region = "europe-west1"
  network = "${google_compute_network.vn.self_link}"
}

resource "google_compute_subnetwork" "sub2" {
  name   = "subnetwork2"
  ip_cidr_range = "192.168.0.0/16"
  region = "europe-west1"
  network = "${google_compute_network.vn.self_link}"
    
 secondary_ip_range {
    range_name    = "plage-secondaire1"
    ip_cidr_range = "172.16.0.0/16"
  }
 secondary_ip_range {
    range_name    = "plage-secondaire2"
    ip_cidr_range = "172.17.0.0/16"
  }
}

resource "google_container_cluster" "cluster" {
  name               = "cluster-k8s"
  network            = "${google_compute_network.vn.self_link}"
  subnetwork         = "${google_compute_subnetwork.sub2.self_link}"
  location           = "europe-west1-b"
  initial_node_count = 2
  remove_default_node_pool = true

   ip_allocation_policy {
   cluster_secondary_range_name = "plage-secondaire1"
   services_secondary_range_name = "plage-secondaire2"
 
 }
 
 
 
 master_authorized_networks_config {
      cidr_blocks {
        cidr_block = "10.0.0.0/8"
      }

  }

 private_cluster_config {
    master_ipv4_cidr_block = "9.0.0.0/28"
    enable_private_endpoint = true
    enable_private_nodes = true
    
  }
    

   
 
}

resource "google_container_node_pool" "extra-pool" {
  name               = "extra-node-pool"
  location           = "europe-west1-b"
  cluster            = "${google_container_cluster.cluster.name}"
  node_count         = 1
  #initial_node_count = 2
}


resource "google_compute_instance" "k8s" {
 name         = "client-kubectl"
 machine_type = "n1-standard-1"
 zone         = "europe-west1-b"
 tags          = ["ssh"]  

 boot_disk {
   initialize_params {
     image = "centos-cloud/centos-7"
     type = "pd-standard"
   }
 }
 network_interface {
    network = "${google_compute_network.vn.self_link}"
    subnetwork = "${google_compute_subnetwork.sub1.self_link}" 
    access_config {
        
        }
    }

 metadata {
        #clé SSH en dur
   ssh-keys = "user01:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCcEsC8FWQ2XSSs2JanvqxffD7/FPaR+Az0bcKJ9koN4Z/bA541VdHZoS14M5vRp12VtcQGdp+upfL0W7ZngOyBODO4N+uSWEMyKeL9bHLKXS4x7wc+ur2WbY/mYJXtI2W0reVIVvDl9bfaVxq2BvlHxuh/oUNwM3Y3jefQkRWDdvHv1yILvjaZ2VLaDwZRa/gDw3RJhhWcBAWTJ8ojPYrpuQ9/cmV4/RzM2fsuL0rhHNJRYe0TKQPNn+ra15wjopnD++4co8YmeLmpQcHPQivGBliLgMqBfhySNtA+s+smjdxEd5MXZDPSsUkIpFuwYtbMwrNyUA4Y9RhpuOwbmalD user01@localhost.localdomain"
   #clé SSH via le fichier
   #"ssh-keys" = 
   #"user01:${file("/home/user01/.ssh/id_rsa.pub")}"
  }
}
