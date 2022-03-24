# PodSecurityPolicies

## Tests
```
# denied; host not resolving
kubectl --kubeconfig admin.kubeconfig -n cks-psp exec -it web-client-denied -- curl -v web01

# working with dns
kubectl --kubeconfig admin.kubeconfig -n cks-psp exec -it web-client -- curl -v web01

# working without dns
kubectl --kubeconfig admin.kubeconfig -n cks-psp exec -it web-client -- curl -v $(kubectl --kubeconfig admin.kubeconfig -n cks-psp get po web-01 -o jsonpath='{.status.podIP}')
```

## Resources

* https://github.com/ahmetb/kubernetes-network-policy-recipes

