## подготовка ##

Выполняем действия из предыдущего урока. Для краткости собрал необходимое в start.sh

### пытаюсь создать Service clusterIP ###
```
kubectl apply -f service.yaml
```

В выводе kubectl get svc -A вижу:
```
default       nginx-service   ClusterIP      10.102.204.123   <none>        80/TCP                       24m
```

### gatewayAPI / Traefik ###

Добавляем Kubernetes Gateway API CRDs:
```
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.1/standard-install.yaml
```

Создаем values.yaml с необходимыми значениями.
Устанавливаем  Traefik
```
helm repo add traefik https://traefik.github.io/charts
helm repo update
helm install traefik traefik/traefik -f values.yaml --wait
kubectl apply -f gateway.yaml
kubectl apply -f httproute.yaml
```
После этого если из бизибокса внутри кластера обращаюсь на внутренний адрес gateway, то получаю ответ от конечного 
nginx:
```
/ # wget -q -O- http://demo.otus:8000
<html><body><h1>Тест</h1></body></html>
```
Впрочем, я всю голову сломал, откуда берется порт 8000, в конфигах его нет, почему траефик слушает именно на нем - не могу понять.
Ну и, как внешний адрес навесить на Traefik, я так и не разобрался пока, он у меня висит вот в таком 
состоянии:

```
denis@k8s01:~/docs/otus_git/skiangel_repo/kubernetes-networks$ kubectl get svc -A
NAMESPACE     NAME            TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
default       kubernetes      ClusterIP      10.96.0.1        <none>        443/TCP                      21m
default       traefik         LoadBalancer   10.105.145.165   <pending>     80:30882/TCP,443:30878/TCP   18m
homework      nginx-service   ClusterIP      10.96.104.94     <none>        80/TCP                       21m
kube-system   kube-dns        ClusterIP      10.96.0.10       <none>        53/UDP,53/TCP,9153/TCP       21m
```
Соответственно, обратиться я к нему не могу. 
