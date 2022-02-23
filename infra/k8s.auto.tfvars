controller_instances = 2
worker_instances     = 1

k8s_version  = "1.23.0"
etcd_version = "3.5.2"
# should match k8s version
crio_version = "1.23"

cluster_service_ip = "10.32.0.0"
cluster_pod_cidr   = "10.200.0.0/16"
