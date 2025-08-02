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

Open [**https://localhost:8080**](https://localhost:8080/)

Login with:

- Username: `admin`
- Password: (from previous step)

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
