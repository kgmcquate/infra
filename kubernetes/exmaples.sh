cp kubernetes/kubectl.conf ~/.kube/config

# ingress
helm repo add nginx-stable https://helm.nginx.com/stable 
helm install nginx-ingress nginx-stable/nginx-ingress -n dagster --create-namespace
kubectl get pods -n nginx-ingress
kubectl get services -n nginx-ingress
kubectl get ingress --all-namespaces

kubectl -n nginx-ingress get services -o wide -w nginx-ingress-controller

helm uninstall nginx-ingress -n dagster

kubectl exec -n nginx-ingress --stdin --tty nginx-ingress-controller-7c6db9f77d-p67qh -- /bin/bash
kubectl logs -f nginx-ingress-controller-7c6db9f77d-p67qh -n nginx-ingress 

# Another ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/baremetal/deploy.yaml
kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/baremetal/deploy.yaml


# dashboard
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/               
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard
kubectl get pods -n kubernetes-dashboard
kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443

# dagster
helm upgrade --install dagster dagster/dagster -n dagster --create-namespace -f dagster/values.yaml
kubectl get pods -n dagster
helm uninstall dagster -n dagster
kubectl logs dagster-dagster-webserver-5968dd5c9c-pgfhm  -n dagster
# debug
kubectl describe service dagster-dagster-webserver -n dagster

# local chart
helm upgrade --install dagster ./Chart.yaml -n dagster  --create-namespace -f values.yaml


# oauth proxy
kubectl create -f dagster/templates/oauth2-proxy.yaml -n dagster
kubectl delete -f dagster/templates/oauth2-proxy.yaml -n dagster

# dagster chart
# helm upgrade --install dagster dagster/dagster \
#     -n dagster --create-namespace \
#     -f dagster/values.yaml

# tls
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=dagster.kevin-mcquate.net"
kubectl create secret tls tls-secret --key="tls.key" --cert="tls.crt" -n nginx-ingress


openssl genrsa -out cert_key.pem 2048
openssl req -new -key cert_key.pem -out cert_csr.pem -subj "/CN=dagster.kevin-mcquate.net"
openssl x509 -req -in cert_csr.pem -sha256 -days 365 -extensions v3_ca -signkey cert_key.pem -CAcreateserial -out cert_cert.pem

kubectl create secret tls tls-secret --cert=cert_cert.pem --key=cert_key.pem -n dagster
kubectl delete secret tls-secret -n dagster