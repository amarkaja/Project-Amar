provider "google" {
  credentials = file("./pro-lattice-421310-7e6e1d38b83b.json")
  project  = var.project_id
  region   = var.region_zone
}

resource "google_container_cluster" "gke_cluster" {
  name     = "my-gke-cluster"
  location = var.region_zone

  initial_node_count = 2
  deletion_protection = false

}
