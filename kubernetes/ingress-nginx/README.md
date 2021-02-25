# How to make available some features for ingress controller

I hope these scripts hepl someone who works in Kubernetes and uses the ingress controller. Sometime you as kubernetes administrator or software enginner need to change obvious things in ingress controller

# 1. Creating general ingress resource

Full manifest file could be found <a href="./1-general.yml">here "./1-general.yml"</a>

# 2. Custom authentication with kubernetes Ingress

Full manifest file could be found <a href="./2-custom-auth.yml">here "./2-custom-auth.yml"</a>

# 3. Allow uploading large files through ingress controller (setting max upload size)

The Kubernetes Nginx Ingress server has a default allowed request body size that is quite low to avoid voluntary or involuntary DOS attacks.
You could set it to a higher value in the Ingress server config directly or in a specific ingress resource.

Just add these two lines in the metadata: annotations section of the ingress resource:
```yml
nginx.ingress.kubernetes.io/proxy-body-size: "50m"
nginx.org/client-max-body-size: "50m"
```

Full manifest file could be found <a href="./3-set-max-upload-size.yml">here "./3-set-max-upload-size.yml"</a>

WARNING: In terms of security and flexibility, that's a good compromise that allows you to know exactly what is allowed per application.

# 4. Deny access to some specific paths using server-snippet

The snippet denies access to the specific path for incoming traffic. For example, you have the service exposed as /api/backend/, and you would like to deny access to api/backend/actuator. To resolve it, you have to prepare 2 ingresses.

First one is to allow the traffic for /api/backend/ (<a href="./1-general.yml">full manifest file here</a>). And second one is to deny the path /api/backend/actuator (<a href="./4-deny-specific-path.yml">full manifest file here</a>).

# 5. Deploying Multiple Ingress Controllers in a Kubernetes Cluster

If you’re running multiple ingress controllers in a single Kubernetes cluster, you need to specify the annotation kubernetes.io/ingress.class: "controller-name" in all ingresses that you would like the ingress-nginx controller to claim.

To achieve above, configuration changes would be as follows (look at ***kubernetes.io/ingress.class: "nginx-internal"*** below):
```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: hello-world
  annotations:
    kubernetes.io/ingress.class: "nginx-internal"
spec:
  tls:
  - secretName: tls-secret
  rules:
  - http:
      paths:
      - backend:
          serviceName: frontend
          servicePort: 80
```          
on the above, you can see the ingress class is defined as “nginx-internal”. So you need to define one of your Nginx controllers to have the class name as “nginx-internal” to route the traffic (look at ***ingress-class=nginx-internal*** below): 
```
spec:
  template:
     spec:
       containers:
         - name: nginx-ingress-internal-controller
           args:
             - /nginx-ingress-controller
             - '--election-id=ingress-controller-leader-internal'
             - '--ingress-class=nginx-internal'
             - '--configmap=ingress/nginx-ingress-internal-controller'
```             
Here you need to set the ‘ingress-class’ argument name as the same as in ingress-resource. In my case, it is “nginx-internal”.
This way you can even have an ingress controller per namespace as well.
