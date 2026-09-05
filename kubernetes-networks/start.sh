minikube start
kubectl create -f ./homework.yaml
kubectl label nodes minikube worknode=first
kubectl apply -f ./deployment.yaml
kubectl apply -f ./service.yaml
