## подготовка ##

Выполняем действия из предыдущего урока.
Все предыдущие действия и последующие, описанные здесь, собрад в start.sh
Можно просто запустить этот сценарий в директории с манифестами.

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

В httproutes.yaml добавляю секцию для перезаписывания пути /homepage на корень сервиса:
```
    - matches:
        - path:
            type: PathPrefix
            value: /homepage
      filters:
        - type: URLRewrite
          urlRewrite:
            path:
              type: ReplacePrefixMatch
              replacePrefixMatch: /
```
После этого можно в соседней консоли запустить minkube tunnel
После этого получить внешний адрес гейтвея, вписать его на хостовой машине в /etc/hosts и увидеть ответ из подов nginx
```
EIP=`kubectl get svc traefik --no-headers |awk -F " " '{print $4}'`
echo "$EIP    homework.otus" >> /etc/hosts
curl http://homework.otus
<html><body><h1>Тест</h1></body></html>
curl http://homework.otus/homepage
<html><body><h1>Тест</h1></body></html>
```
