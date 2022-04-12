![Failed Containership](docs/containership.jpg)

# k8s the hard way - terraform
*Disclaimer: this is - by no means - production grade material.*

:warning: All private keys/encryption tokens and other secrets are stored in the terraform
state & on disk; some are even displayed on screen.
Furthermore there are certain in-cluster security issues:
* K8s Pods reach the aws metadataservice
* IAM Roles set on ec2 instances/user instead of irsa
* ~~Dex idP clientSecrets are visible~~

This is an aws based k8s-the-hard-way setup (inspired by [Kelsey Hightower](https://github.com/kelseyhightower/kubernetes-the-hard-way)), solely deployed with terraform and
hacky shell scripts, triggered by cloud-init.

---
> The project evolved to a playground for all of my k8s/aws tech related curiosity.
---

Reference: 
https://github.com/kubernetes/kubeadm/blob/main/docs/design/design_v1.10.md

# Roadmap
- Clustersetup
  - [x] CoreDNS
  - [x] CNI Networking with ~~weave~~ calico
  - [ ] Static pods
  - [ ] Move away from shell-scripts to cloudinit
  - [ ] Switch from rhel8 to flatcar/talon/bottlerocket
  - [ ] binary checksum verification
  - [ ] `kube-bench` with a reasonable score
  - [ ] https://github.com/aws/amazon-vpc-cni-k8s
  - [x] Move the bastion LB for the k8s api to `aws_lb`  
    The Bastion Host has a nginx loadbalancing the k8s-api; This should be
    replaced by an aws network lb
  - [ ] Migrate the hacky shell scripts to ignition  
    https://github.com/coreos/container-linux-config-transpiler/blob/master/doc/configuration.md


- Clusteraddons
  - [x] [aws cloud controller manager](https://github.com/kubernetes/cloud-provider-aws) (as external cloud provider in k8s)
  - [x] [aws-lb-controller](https://github.com/kubernetes-sigs/aws-load-balancer-controller) as ingress class  
    Using IRSA for aws management access
  - [x] [external_dns](https://github.com/kubernetes-sigs/external-dns) with route53 access  
    Using IRSA for aws management access
  - [x] [sealed-secrets](https://github.com/bitnami-labs/sealed-secrets) as secretstorage  
    With external private Key (from aws ssm parameter store) for global secrets
    like Github tokens, which should surive clusterrebuilds
  - [x] [aws-eks-pod-identity-webhook](https://github.com/aws/amazon-eks-pod-identity-webhook) for IRSA  
    Mutating webhook to allow SAs using aws IAM
- IdentityManagement
  - [x] Dex as idP with Github Backend for all login related Toosl (`kubectl`, argoCD)
  - [x] Implement [IRSA](https://aws.amazon.com/blogs/opensource/introducing-fine-grained-iam-roles-service-accounts/) for aws acces
- Autoscaling
  - [ ] ...
  - [ ] scaling of nodes dependend on load -> karpenter
  - [ ] spot instances
- Application
  - [x] ArgoCD

- Ungrouped
  - [ ] ImageScanWebook
  - [ ] Block aws metadata access from cluster
  - [ ] etcd autodiscovery (etcd in autoscalingroups)
  - [ ] bootstrap tokens
  - [ ] crossplane vs aws-controllers-k8s
  - [ ] kyverno vs gatekeeper/opa vs kubevious
  - [ ] cluster backup -> velero
  - [ ] refactor terraform in module groups
  - [ ] https://kubernetes.io/blog/2021/04/21/graceful-node-shutdown-beta/
  - [ ] aws ssm instead of ssh
  - [ ] logging: cloudwatch
  - [ ] check encryption: etcd; ebs; s3
  - [ ] kubecost

# Implementation
## Hosts
Rhel8 Images are used for control- & workernodes with SELinux enabled.

## Network
The controller & worker nodes are evenly distributed among all availabe AZs:
- AZ 1a CIDR: `10.10.16.0/20`
- AZ 1b CIDR: `10.10.32.0/20`
- AZ 1c CIDR: `10.10.48.0/20`
- Service CIDR: `10.32.0.0/24`
- Cluster CIDR: `10.200.0.0/16`
- Cluster DNS: `10.32.0.53`

### calico
### open ToDos
- [ ] move to helm chart

### dex
intro in dex...
installing kubectl login plugin...

## open ToDos
- [ ] view only clusterrolebinding
- [ ] restore fine grained security groups

# Usage

# References
## Gerneral Reference
* https://github.com/kubernetes/kubeadm/blob/main/docs/design/design_v1.10.md
* https://kubernetes.io/docs/concepts/architecture/control-plane-node-communication/
## Kubernetes TLS
* https://kubernetes.io/docs/setup/best-practices/certificates/
## Kubernetes Bootstrapping
* https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet-tls-bootstrapping/
## Etcd Autodiscovery
* https://etcd.io/docs/v3.5/op-guide/clustering/#dns-discovery
## Userdata/Ignition
* https://github.com/coreos/container-linux-config-transpiler/blob/master/doc/configuration.md
* https://www.flatcar.org/docs/latest/provisioning/ignition/specification/
