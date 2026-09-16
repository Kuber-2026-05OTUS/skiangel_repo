minikube start
kubectl create -f ./homework.yaml
kubectl label nodes minikube worknode=first
kubectl apply -f ./deployment.yaml
kubectl apply -f ./service.yaml
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.1/standard-install.yaml
helm repo add traefik https://traefik.github.io/charts
helm repo update
helm install traefik traefik/traefik -f values.yaml
kubectl apply -f gateway.yaml
kubectl apply -f httproute.yaml
echo "Ожидаем запуска traefik"
sleep 5
TIP=`kubectl get svc traefik --no-headers |awk -F " " '{print $3}'`
echo "Получен ip адрес traefik: $TIP"
sed -i "s/- ip: .*/- ip: \"$TIP\"/" helper-busibox.yaml
kubectl apply -f helper-busibox.yaml
echo "Ожидаем 30 секунд запуска busibox"
sleep 30
kubectl -n homework exec busybox-infinity -it -- wget -q -O- http://demo.otus
HTUN=`ps ax |grep "minikube tunnel"|grep -v "grep"`
#echo $HTUN
if [ $? -gt 0 ]; then
    echo "Для доступа с хостовой машины запустите minikube tunnel"
fi


