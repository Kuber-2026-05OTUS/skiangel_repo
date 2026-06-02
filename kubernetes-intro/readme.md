## namespace ##
Создаем файл с названием homework.yaml и с содерджимым:
```
apiVersion: v1
kind: Namespace
metadata:
  name: homework
```

## Создаем namespace ##
```
kubectl create -f ./homework.yaml
```

## POD ##
Создаем файл pod01.yaml со следующим содержимым:

```
apiVersion: v1
kind: Pod
metadata:
  name: homework01-pod
  namespace: homework
spec:
  containers:
  - name: nginx
    image: nginx:latest
    ports:
    - containerPort: 8000
    volumeMounts:
      - name: html
        mountPath: /usr/share/nginx/html
    lifecycle:
      preStop:
        exec:
          command: ["sh", "-c", "rm /usr/share/nginx/html/index.html"]
  initContainers:
  - name: init
    image: busybox:latest
    command: ["sh", "-c", "echo '<html><body><h1>Тест</h1></body></html>' > /init/index.ntml"]
    volumeMounts:
      - name: html
        mountPath: /init
  volumes:
    - name: html
      emptyDir: {}
```

Выполняем команду
```kubectl apply -f ./pod01.yaml```

Проверяем:
```
denis@k8s01:~$ kubectl get pods -n homework -o wide
NAME             READY   STATUS    RESTARTS   AGE   IP           NODE       NOMINATED NODE   READINESS GATES
homework01-pod   1/1     Running   0          13m   10.244.0.7   minikube   <none>           <none>
```

Дальше у меня случился затык: сервис отдает не то, что нужно.  Если делаю
```
minikube ssh
curl 10.244.0.7
```

Получаю ответ

```
<html>
<head><title>403 Forbidden</title></head>
<body>
<center><h1>403 Forbidden</h1></center>
<hr><center>nginx/1.31.1</center>
</body>
</html>
```

При этом в /var/lib/docker/volumes/minikube/_data/lib/kubelet/pods/f43f783c-153e-4e12-8444-121c190058e3/volumes/kubernetes.io~empty-dir/html 
появляется файл нужного содержимого, но, видимо, возникают проблемы с правами доступа, хотя у файла права 644.
В контейнере nginx файл лежит вроде как по правильному пути:

```
denis@k8s01:~$ kubectl -n homework exec -it homework01-pod -- /bin/bash
Defaulted container "nginx" out of: nginx, init (init)
root@homework01-pod:/# cat /usr/share/nginx/html/index.ntml 
<html><body><h1>Тест</h1></body></html>
```
