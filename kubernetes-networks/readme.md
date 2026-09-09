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
```

Здесь я окончательно запутался. Никак в голове не сложится картина сетевого взаимодействия.
Насколько я понимаю, traefik  должен повиснуть на каком-то внешнем ip, чтобы слушать обращения.
Но он висит в статусе pending на External IP
```
denis@k8s01:~/docs/otus_git/skiangel_repo/kubernetes-networks$ kubectl get svc -A
NAMESPACE     NAME            TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
default       kubernetes      ClusterIP      10.96.0.1        <none>        443/TCP                      21m
default       traefik         LoadBalancer   10.105.145.165   <pending>     80:30882/TCP,443:30878/TCP   18m
homework      nginx-service   ClusterIP      10.96.104.94     <none>        80/TCP                       21m
kube-system   kube-dns        ClusterIP      10.96.0.10       <none>        53/UDP,53/TCP,9153/TCP       21m
```
Соответственно, обратиться я к нему не могу. Из бизибокса тоже отклика на нем не вижу, вернее, на 80 порту он отдает 404 ошибку.
Кажется, я чего-то не доделываю, не пойму, чего.