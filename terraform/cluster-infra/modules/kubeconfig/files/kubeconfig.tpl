apiVersion: v1
kind: Config
current-context: ${k8s_cluster_name}
clusters:
- cluster:
    certificate-authority-data: ${base64encode(k8s_pki_ca_crt)}
    server: https://${k8s_api}
  name: ${k8s_cluster_name}
contexts:
- context:
    cluster: ${k8s_cluster_name}
    namespace: default
    user: ${k8s_username}
  name: ${k8s_cluster_name}
users:
- name: ${k8s_username}
  user:
%{~ if k8s_pki_client_crt != null }
    client-certificate-data: ${base64encode(k8s_pki_client_crt)}
    client-key-data: ${base64encode(k8s_pki_client_key)}
%{~ endif ~}
%{~ if k8s_token != null }
    token: ${k8s_token}
%{~ endif ~}
