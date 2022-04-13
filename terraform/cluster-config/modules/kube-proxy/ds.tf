resource "kubectl_manifest" "ds_kube_proxy" {
  yaml_body = <<YAML
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: kube-proxy
  namespace: kube-system
spec:
  selector:
    matchLabels:
      app: kube-proxy
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
  template:
    metadata:
      labels:
        app: kube-proxy
    spec:
      hostNetwork: true
      priorityClassName: system-node-critical
      serviceAccountName: kube-proxy
      tolerations:
      - effect: NoSchedule
        operator: Exists
      - effect: NoExecute
        operator: Exists
      containers:
      - name: kube-proxy
        image: k8s.gcr.io/kube-proxy:v${var.k8s_version}
        command:
        - /usr/local/bin/kube-proxy
        - --config=/var/lib/kube-proxy/config.yaml
        - --hostname-override=$(NODE_NAME)
        env:
        - name: NODE_NAME
          valueFrom:
            fieldRef:
              apiVersion: v1
              fieldPath: spec.nodeName
        livenessProbe:
          httpGet:
            path: /healthz
            port: 10256
          initialDelaySeconds: 15
          timeoutSeconds: 15
        securityContext:
          privileged: true
        volumeMounts:
        - name: kube-proxy
          mountPath: /var/lib/kube-proxy
          readOnly: true
        - name: lib-modules
          mountPath: /lib/modules
          readOnly: true
        - name: xtables
          mountPath: /run/xtables.lock
        resources:
          requests:
            cpu: 50m
            memory: 25Mi
          limits:
            cpu: 100m
            memory: 100Mi
      volumes:
      - name: kube-proxy
        configMap:
          name: kube-proxy
      - name: lib-modules
        hostPath:
          path: /lib/modules
      - name: xtables
        hostPath:
          path: /run/xtables.lock
          type: File
YAML
}
