# Structure
During a terraform refactoring i decided to split the terraform provisioning in
two parts.

* [cluster-infra](cluster-infra/) for everything leading to a functioning k8s API
* [cluster-config](cluster-config/) for everything depending on a k8s API

This way i mitigate long terraform runs and provider dependency.
