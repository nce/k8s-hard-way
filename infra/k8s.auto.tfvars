controller_instances = 3
worker_instances     = 2

etcd_version = "3.5.2"
k8s_version  = "1.23.0"
# should match k8s version
crio_version = "1.23"

cluster_service_ip   = "10.32.0.1"
cluster_service_cidr = "10.32.0.0/24"
cluster_pod_cidr     = "10.200.0.0/16"
