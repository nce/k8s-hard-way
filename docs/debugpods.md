# Collection of useful debug pods

`kubectl --kubeconfig admin.kubeconfig run -it --rm --restart=Never --image=infoblox/dnstools:latest dnstools`

```
apiVersion: v1
kind: Pod
metadata:
  name: pod-watch
  namespace: auth
spec:
  serviceAccountName: pod-monitor
  containers:
  - name: busybox
    image: radial/busyboxplus:curl
    command: ['sh', '-c', 'TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token); while true; do if curl -s -o /dev/null -k -m 3 -H "Authorization: Bearer $TOKEN" https://kubernetes.default.svc.cluster.local/api/v1/namespaces/auth/pods/; then echo "[SUCCESS] Successfully viewed Pods!"; else echo "[FAIL] Failed to view Pods!"; fi; sleep 5; done']
```

```
apiVersion: v1
kind: Pod
metadata:
  name: svc-watch
  namespace: auth
spec:
  serviceAccountName: svc-monitor
  containers:
  - name: busybox
    image: radial/busyboxplus:curl
    command: ['sh', '-c', 'TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token); while true; do if curl -s -o /dev/null -k -m 3 -H "Authorization: Bearer $TOKEN" https://kubernetes.default.svc.cluster.local/api/v1/namespaces/auth/services/; then echo "[SUCCESS] Successfully viewed Services!"; else echo "[FAIL] Failed to view Services!"; fi; sleep 5; done']
```

