# Microservices Monitoring with Prometheus, Loki, and Grafana on Minikube

This guide sets up a monitoring stack for your microservices using Prometheus (metrics), Loki (logs), and Grafana (visualization) on a Minikube Kubernetes cluster.

## Prerequisites

*   **Minikube:** Installed and configured.
*   **kubectl:** Installed and configured to interact with your Minikube cluster.
*   **Helm:** Installed for managing Kubernetes charts.
*   **Docker:** Installed and configured. (If you are building your microservice images locally).

## Setup

1. **Start Minikube Cluster:**

    ```sh
    minikube start --cpus=16 --memory=16g
    ```

2. **Create Namespaces:**

    ```sh
    kubectl create namespace gem
    kubectl create namespace monitoring
    kubectl create namespace ingress-nginx
    ```

3. **Set Default Namespace:**

    ```sh
    kubectl config set-context --current --namespace=gem
    ```

4. **Enable Minikube Docker Environment:**

    ```sh
    eval $(minikube docker-env)
    ```

5. **Add Helm Repositories:**

    (You only need to do this once if you haven't already added these repositories.)
    
    ```sh
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm repo update
    helm dependency update gem 
    helm dependency update monitoring 
    ```

6. **Install all charts:**

    ```sh
    helm install gem gem -n gem
    helm install monitoring monitoring -n monitoring
    helm install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx
    ```

7. **Open ingress port:**

    ```sh
    sudo -E kubectl -n ingress-nginx port-forward svc/ingress-nginx-controller 80:80 --address='0.0.0.0'
    ```

8. **Open grafana port:**

    ```sh
    kubectl port-forward -n monitoring $(kubectl get pod -n monitoring -l app.kubernetes.io/name=grafana -o jsonpath="{.items[0].metadata.name}") 9090:3000
    ```

9. **Uninstall all charts:**

    (If something not working.)

    ```sh
    helm uninstall gem -n gem
    helm uninstall monitoring -n monitoring
    helm uninstall ingress-nginx -n ingress-nginx
    ```

10. **Stop minikube:**

     ```sh
     minikube stop
     ```

11. **Uninstall all:**

     (Total restart.)

     ```sh
     minikube delete --all --purge
     ```

12. **Get microservices pods status:**

     ```sh
     kubectl get pod -n gem
     ```

13. **Get monitoring pods status:**

    ```sh
    kubectl get pod -n monitoring
    ```
