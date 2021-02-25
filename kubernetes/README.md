#

[Here](https://github.com/dev-otitarenko/others/blob/main/kubernetes/CONTAINER-SECURITY.md) is information about container security in K8S


# Display CPU/MEMORY usage for nodes

```sh
kubectl top nodes
```

output
```
NAME            CPU(cores)  CPU%  MEMORY(bytes)  MEMORY%
aks-linuxpool-21051943-0  292m     15%  4527Mi     84%
aks-linuxpool-21051943-2  424m     22%  4485Mi     83%
```

# Show request/limits cpu/memory per node

```sh
kubectl get nodes --no-headers | awk '{print $1}' | xargs -I {​}​ sh -c 'echo {​}​; kubectl describe node {​}​ | grep Allocated -A 5 | grep -ve Event -ve Allocated -ve percent -ve -- ; echo'
```

output:
```
aks-linuxpool-21051943-0
  Resource                       Requests      Limits
  cpu                            1339m (70%)   6950m (365%)
  memory                         3672Mi (68%)  8740Mi (162%)

aks-linuxpool-21051943-2
  Resource                       Requests      Limits
  cpu                            1145m (60%)   6800m (357%)
```

# Get the pods that use the most CPU and MEMORY you can use the kubectl top pod command:

for all namespaces:
```sh
kubectl top pods --all-namespaces
```
output:
```
NAMESPACE      NAME                                             CPU(cores)   MEMORY(bytes)
kube-system    azure-cni-networkmonitor-d4k7f                   1m           20Mi
kube-system    azure-cni-networkmonitor-prtqn                   1m           22Mi
kube-system    azure-ip-masq-agent-fm2fx                        1m           15Mi
kube-system    azure-ip-masq-agent-prpqp                        1m           13Mi
kube-system    coredns-79766dfd68-kpgtv                         4m           24Mi
kube-system    coredns-79766dfd68-tv4sn                         5m           25Mi
kube-system    coredns-autoscaler-66c578cddb-rsr2l              1m           7Mi
kube-system    dashboard-metrics-scraper-6f5fb5c4f-h5fwr        1m           21Mi
kube-system    kube-proxy-k46bb                                 2m           28Mi
kube-system    kube-proxy-mr5vd                                 1m           29Mi
kube-system    kubernetes-dashboard-56dbcd8bf5-jj4w5            2m           24Mi
kube-system    metrics-server-7f5b4f6d8c-h69s5                  2m           18Mi
kube-system    omsagent-497sp                                   19m          263Mi
kube-system    omsagent-6hcw4                                   14m          247Mi
kube-system    omsagent-rs-99d4f8b49-84rlg                      14m          152Mi
kube-system    tunnelfront-549f69d4cd-xcflf                     82m          12Mi
kured          kured-mmfm7                                      1m           8Mi
kured          kured-nj7tv                                      1m           8Mi
ns-app-java    rabbitmq-rabbitmq-ha-0                           170m         146Mi
ns-app-java    rabbitmq-rabbitmq-ha-1                           124m         142Mi
```

for a particular namespace:
```sh
kubectl top pods -n ns-app-java
```

output:
```
NAMESPACE      NAME                                             CPU(cores)   MEMORY(bytes)
ns-app-java    rabbitmq-rabbitmq-ha-0                           170m         146Mi
ns-app-java    rabbitmq-rabbitmq-ha-1                           124m         142Mi
```

