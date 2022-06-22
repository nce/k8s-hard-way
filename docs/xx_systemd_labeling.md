# Systemd Labeling Problem

The master nodes need to be labeld with master & controlplane.

A Systemd service is not evaluating `%l or %H` to the correct hostname.

```
# cat /etc/systemd/system/k8s-labeler.service
[Unit]
Description=Nodelabeler
Wants=network-online.target
After=network-online.target kubelet.service

[Service]
Type=oneshot
ExecStart=/opt/bin/kubectl --kubeconfig /etc/kubernetes/admin.conf label nodes/%H node-role.kubernetes.io/master= --overwrite
ExecStart=/opt/bin/kubectl --kubeconfig /etc/kubernetes/admin.conf label nodes/%H node-role.kubernetes.io/control-plane= --overwrite
ExecStop=/opt/bin/kubectl --kubeconfig /etc/kubernetes/admin.conf label nodes/%H node-role.kubernetes.io/master- --overwrite
ExecStop=/opt/bin/kubectl --kubeconfig /etc/kubernetes/admin.conf label nodes/%H node-role.kubernetes.io/control-plane- --overwrite
```

evaluates in flatcar after boot to this:

```
    Process: 63318 ExecStart=/opt/bin/kubectl --kubeconfig /etc/kubernetes/admin.conf label nodes/localhost node-role.kubernetes.io/master= --overwrite (code=exited, status=1/FAILURE)
```

Instead of `localhost` there should be the instance name...

Relink the unit files (`systemctl daemon-reload`) fixes the issue...

## Switching to `%H`

:boom: does not fix

## Modifing the unit dependency
Like:
```
After=network-online.target systemd-hostnamed.service kubelet.service
```

:boom: does not fix

## Using the coreos metadataservice
```
Requires=coreos-metadata.service
After=coreos-metadata.service

[Service]
Type=oneshot
EnvironmentFile=/run/metadata/flatcar
ExecStart=/opt/bin/kubectl --kubeconfig /etc/kubernetes/admin.conf label nodes/$${COREOS_EC2_INSTANCE_ID} node-role.kubernetes.io/master= --overwrite
```

:white_check_mark: [fixed](https://github.com/nce/k8s-hard-way/commit/0d190c9ff568d64518a5a32061b63d8f61b90644)
