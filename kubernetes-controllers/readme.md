## namespace ##
Создаем файл с названием homework.yaml и с содерджимым:
```
apiVersion: v1
kind: Namespace
metadata:
  name: homework
```

### Создаем namespace ###
```
kubectl create -f ./homework.yaml
```

## Node ##
добавляем label ноде, для этого сначала получаем имя ноды:
```
denis@k8s01:~/docs/otus_git/skiangel_repo/kubernetes-controllers$ kubectl get nodes
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   8d    v1.35.1
```

и, собственно, добавляем label:
```
kubectl label nodes minikube worknode=first
```

## Deployment ##

Создаем файл deployment.yaml со сдледующим содержимым:
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: homework
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        readinessProbe:
          exec:
            command:
            - cat
            - /usr/share/html/index.html
          initialDelaySeconds: 5
          periodSeconds: 5
        ports:
        - containerPort: 8000
        volumeMounts:
        - name: html
          mountPath: /usr/share/nginx/html
        lifecycle:
          preStop:
            exec:
              command: ["sh", "-c", "rm /usr/share/nginx/html/index.html"]
        readinessProbe:
          exec:
            command:
            - cat
            - /usr/share/nginx/html/index.html
          initialDelaySeconds: 5
          periodSeconds: 5
      initContainers:
      - name: init
        image: busybox:latest
        command: ["sh", "-c", "echo '<html><body><h1>Тест</h1></body></html>' > /init/index.html"]
        volumeMounts:
          - name: html
            mountPath: /init
      volumes:
        - name: html
          emptyDir: {}
      nodeSelector:
          worknode: first
  strategy:
   type: RollingUpdate
   rollingUpdate:
     maxUnavailable: 1
     maxSurge: 2
```

Запускаем депоймент:
```
kubectl apply -f ./deployment.yaml
```

В deployment.yaml описываем деплоймент с тремя репликами, привязываем его к ноде с меткой "worknode: first", создаем deadiness пробу
```
        readinessProbe:
          exec:
            command:
            - cat
            - /usr/share/nginx/html/index.html
          initialDelaySeconds: 5
          periodSeconds: 5
```
Согласно этой пробе kubelet должен раз в 5 секунд проверять наличие файла /usr/share/nginx/html/index.html в контейнерах nginx
Проверил, если неправильно указываю имя файла в пробе, то в дескрайбе пода получаю сообщение "readiness probe failed".
Кроме того, попробовал сделать http readiness пробу (файл deployment_html.yaml)
```
        readinessProbe:
          httpGet:
            path: /index.html
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
```
Работает так же, если указываю неправильный путь, проба падает.

## обновление ##

Описываем стратегию обновления:
```
  strategy:
   type: RollingUpdate
   rollingUpdate:
     maxUnavailable: 1
     maxSurge: 2
```
Указываем, что во время обновления одновременно может быть не более одного недоступного пода. Так как во время обновления не учитываются стартующие и останавливающиеся поды, 
то может быть создано подов больше, чем указано в репликах, соответственно, указываем, что всего подов сверх нормы может быть не более двух.
Для проверки даем команду
```
kubectl -n homework set image deployment/nginx-deployment nginx=nginx:1.16.1
```
В интерфейсе k9s видим, что поды начинают обновляться, при этом постоянно в состоянии running находится два пода, и в обновлении/перезагрузке - еще три, что укладывается 
в определённую нами стратегию.
