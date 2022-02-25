locals {
  //vpc_cidr = "10.0.0.0/24"
  vpc_cidr = "172.80.0.0/16"
}
locals {
  /* private_subnet_1 = "10.0.1.0/24"
   private_subnet_2 = "10.0.2.0/24"
   private_subnet_3 = "10.0.3.0/24"*/
  private_subnet_1 = "172.80.1.0/24"
  private_subnet_2 = "172.80.2.0/24"
  private_subnet_3 = "172.80.3.0/24"
}

locals {
  /*public_subnet_1 = "10.0.4.0/24"
  public_subnet_2 = "10.0.5.0/24"
  public_subnet_3 = "10.0.6.0/24"*/
  public_subnet_1 = "172.80.4.0/24"
  public_subnet_2 = "172.80.5.0/24"
  public_subnet_3 = "172.80.6.0/24"
}

locals {
  cluster_name = "${var.environment_name}-cicd-eks"
  nexus_blob_store_bucket_name = "${var.environment_name}-nexus-blob-store-scrnx"
  nexus_blob_store_replica_bucket_name = "${var.environment_name}-nexus-blob-store-scrnx-replica"
}
