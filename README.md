![Failed Containership](docs/containership.jpg)

# k8s the hard way - terraform
*Disclaimer: this is - by no means - production grade material.*

:warning: All private keys/encryption tokens and other secrets are stored in the terraform
state & on disk; some are even displayed on screen.
Furthermore there are certain in-cluster security issues:
* K8s Pods reach the aws metadataservice
* IAM Roles set on ec2 instances/user instead of irsa
* Dex idP clientSecrets are visible

This is an aws based k8s-the-hard-way setup, solely deployed with terraform and
hacky shell scripts, triggered by cloud-init.

*The project developed itself to a playground for all of my k8s/aws tech related curiosity.*

## Hosts
Rhel8 Images are used for control- & workernodes with SELinux enabled.

## Network
The controller & worker nodes are evenly distributed among all availabe AZs.
AZ 1a CIDR: `10.10.16.0/20`
AZ 1b CIDR: `10.10.32.0/20`
AZ 1c CIDR: `10.10.48.0/20`
Service CIDR: `10.32.0.0/24`
Cluster CIDR: `10.200.0.0/16`
Cluster DNS: `10.32.0.53`

# Usage
## Get admin kubeconfig
Copy the kubeconfig from remote to local station:
`scp -J ec2-user@$(terraform output -raw bastion_ip_public) ec2-user@$(terraform output -raw first_controller_ip):admin.kubeconfig .`


# Roadmap

- [x] CoreDNS
- [x] CNI Networking with ~~weave~~ calico
- [x] [aws cloud controller manager](https://github.com/kubernetes/cloud-provider-aws) (as external cloud provider in k8s)
- [x] [aws-lb-controller](https://github.com/kubernetes-sigs/aws-load-balancer-controller) as ingress class
- [x] [external_dns](https://github.com/kubernetes-sigs/external-dns) with route53 access
- [x] Dex as idP with Github Backend for all login related Toosl (`kubectl`, argoCD)
- [x] ArgoCD
- [ ] binary checksum verification
- [ ] `kube-bench` reasonable score
- [ ] ImageScanWebook
- [ ] Block aws metadata access from cluster
- [ ] Static pods
- [ ] etcd autodiscovery (etcd in autoscalingroups)
- [ ] bootstrap tokens
- [ ] https://github.com/aws/amazon-vpc-cni-k8s
- [ ] crossplane
- [ ] scaling of nodes dependend on load
- [ ] secretprovider like sealedsecrets with aws KMS
- [ ] replace ec2 IAM rules with [IRSA](https://aws.amazon.com/blogs/opensource/introducing-fine-grained-iam-roles-service-accounts/)

### calico
### open ToDos
- [ ] move to helm chart

### dex
intro in dex...
installing kubectl login plugin...


#### open ToDos
- [ ] Distribute Client secret in a different way
- [ ] Use github tokens as secrets
- [ ] view only clusterrolebinding
- [ ] restore fine grained security groups
