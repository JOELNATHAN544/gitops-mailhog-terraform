---

### **Sections**

1. **Overview**
2. **Learning Objectives**
3. **Prerequisites**
4. **Project Structure**
5. **Step-by-Step Guide**
    - Install Argo CD with Terraform
    - Configure Argo CD
    - Deploy Mailhog with GitOps
6. **Bonus Challenges**
7. **Cleanup**
8. **Resources**

---

### **📌 Overview**

This workshop demonstrates **GitOps automation** using:

- **Terraform** for provisioning Argo CD
- **Argo CD** for GitOps workflows
- **Kustomize** for environment overlays
- **Mailhog** as a test email service

Duration: **4 hours**

Mode: Hands-on

---

### **🎯 Learning Objectives**

By the end of this session, students will:

- Understand **GitOps principles** (Declarative config, Git as the source of truth)
- Deploy **Argo CD** on Kubernetes using Terraform
- Manage application deployments (Mailhog) via **GitOps and Kustomize**
- Validate deployments through UI and CLI

---

### **✅ Prerequisites**

- A running **Kubernetes cluster** (Minikube, k3s, or remote)
- Installed tools:
    - `kubectl`
    - `terraform`
    - `argocd` CLI
- GitHub account for hosting the manifests
- Basic understanding of Git, Kubernetes, and YAML

---

### **📂 Project Structure**

```
gitops-mailhog-terraform/
├── README.md
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── providers.tf
│   └── argocd.tf
├── manifests/
│   ├── base/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── kustomization.yaml
│   └── overlays/
│       ├── dev/kustomization.yaml
│       └── prod/kustomization.yaml
└── argocd-apps/
    └── mailhog-app.yaml

```

---

### **✅ Step 1: Install Argo CD with Terraform**

Navigate to the terraform folder:

```bash
cd terraform
terraform init
terraform apply -auto-approve

```

This will:

- Create the `argocd` namespace
- Install Argo CD using Helm

---

### **✅ Step 2: Get Argo CD Admin Password**

```bash
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 --decode

```

---

### **✅ Step 3: Access Argo CD**

Port-forward the service:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

> **Note for VM / Headless Server Users:** If you are running this on a remote server and want to access the UI from your local machine, you must add the `--address 0.0.0.0` flag to the command. This will make it accessible over your server's network IP (e.g., your Tailscale IP).
> 
> ```bash
> kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8080:443
> ```

Open [**https://localhost:8080**](https://localhost:8080/) (or `https://<your-server-ip>:8080` if using the address flag).

Login with:

- Username: `admin`
- Password: (from previous step)

---

### **✅ Step 3a: (Optional) Access Argo CD via CLI**

For command-line users, you can authenticate and interact with the Argo CD API. Make sure the port-forward command from Step 3 is running in a separate terminal.

1.  **Get Admin Password and Store It:**
    ```bash
    ARGO_PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 --decode)
    ```

2.  **Get a Session Token:**
    This command sends your credentials and saves the returned session token to a variable named `TOKEN`.
    ```bash
    TOKEN=$(curl -k -s -X POST -d '{"username":"admin","password":"'"$ARGO_PASSWORD"'"}' https://localhost:8080/api/v1/session | jq -r .token)
    ```
    *(Note: This command uses `jq` to parse the JSON response. You may need to install it, e.g., `brew install jq` or `sudo apt-get install jq`)*

3.  **List Applications:**
    Use the token in an `Authorization` header to make authenticated API calls.
    ```bash
    curl -k -s -H "Authorization: Bearer $TOKEN" https://localhost:8080/api/v1/applications
    ```
    *(This will return an empty list until you complete Step 5).*

---

### **✅ Step 4: Prepare Manifests**

- **Base Manifests:**
    
    `manifests/base/deployment.yaml`
    

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mailhog
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mailhog
  template:
    metadata:
      labels:
        app: mailhog
    spec:
      containers:
      - name: mailhog
        image: mailhog/mailhog:latest
        ports:
        - containerPort: 1025
        - containerPort: 8025

```

`manifests/base/service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mailhog
spec:
  selector:
    app: mailhog
  type: NodePort
  ports:
  - name: smtp
    port: 1025
    targetPort: 1025
  - name: web
    port: 8025
    targetPort: 8025

```

---

### **✅ Step 5: Create Argo CD Application**

`argocd-apps/mailhog-app.yaml`

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: mailhog
  namespace: argocd
spec:
  project: default
  source:
    repoURL: "https://github.com/YOUR_GITHUB_USERNAME/gitops-mailhog-terraform.git"
    targetRevision: HEAD
    path: manifests/overlays/dev
  destination:
    server: "https://kubernetes.default.svc"
    namespace: mailhog
  syncPolicy:
    automated:
      prune: true
      selfHeal: true

```

Apply:

```bash
kubectl apply -f argocd-apps/mailhog-app.yaml

```

---

### **✅ Step 6: Access Mailhog**

Port-forward Mailhog service:

```bash
kubectl port-forward svc/mailhog -n mailhog 8025:8025

```

Open [**http://localhost:8025**](http://localhost:8025/)

---

### **✅ Bonus Challenges**

- Add a **prod overlay** and configure separate environments
- Replace raw YAML with **Helm charts**
- Add **Sealed Secrets or SOPS** for managing sensitive data
- Configure **Argo CD Projects** for multi-app isolation

---

### **🧹 Cleanup**

```bash
terraform destroy -auto-approve
kubectl delete ns mailhog

```

---

### ✅ **Resources**

- [Argo CD Official Docs](https://argo-cd.readthedocs.io/)
- [Kustomize](https://kustomize.io/)
- [Terraform Kubernetes Provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)
- [Mailhog](https://github.com/mailhog/MailHog)
