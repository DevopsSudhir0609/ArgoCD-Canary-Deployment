# AIPlanetProject
Dockerizing a simple web application, deploy it to a Kubernetes cluster using Argo CD, and manage its release process with Argo Rollouts

<img src="images/">

### Software Requirements

- Kubernetes cluster (Minikube, kind, or a cloud provider's Kubernetes service)
- Docker
- Git version control
- Argo CD installed on the Kubernetes cluster
- Argo Rollouts installed on the Kubernetes cluster

### Knowledge Requirements

- Basic understanding of Kubernetes concepts (Pods, Deployments, Services)
- Familiarity with Docker and containerization
- Experience with Git for version control
- Basic understanding of GitOps practices
- Familiarity with Argo CD and Argo Rollouts documentation

##
## Step-by-Step Guide to GitOps with Argo CD and Argo Rollouts

### Task 1: Setup and Configuration

**Create a Git Repository:**

1. Create a new repository on GitHub (or another Git hosting platform).

**Install Argo CD:**

1. Deploy Argo CD using the following command:

```
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

2. Check if Argo CD is running:

```
kubectl get pods -n argocd
```

**Install Argo Rollouts:**

1. Deploy Argo Rollouts using the following command:

```
kubectl apply -n argocd -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
```

2. Check if Argo Rollouts is running:

```
kubectl get pods -n argocd
```

### Task 2: Creating the GitOps Pipeline

**Dockerize the Application:**

1. Create a Dockerfile to build your web application image, e.g.:

```
FROM nginx
COPY index.html /usr/share/nginx/html
```

2. Build the image using `docker build -t <repo>/<image> .` and push it to a container registry (e.g., Docker Hub).

**Deploy the Application Using Argo CD:**

1. Create a Kubernetes application manifest in your repository, e.g. `deployment.yaml`:

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: <repo>/<image>
        ports:
        - containerPort: 80
```

2. Set up Argo CD to watch your repository and deploy the manifest automatically:

```
argo cd create my-app --repo=https://github.com/<user>/<repo> --path=./my-app --dest-namespace=my-app --sync-policy=auto
```

### Task 3: Implementing a Canary Release with Argo Rollouts

**Define a Rollout Strategy:**

1. Modify the Kubernetes manifest to use Argo Rollouts, specifying a canary release strategy in the rollout definition, e.g.:

```
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: my-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: <repo>/<image>
        ports:
        - containerPort: 80
  strategy:
    canary:
      steps:
      - setWeight: 25
        duration: 10m
      -setWeight: 50
        duration: 10m
      -setWeight: 75
        duration: 10m
      -setWeight: 100
        duration: 10m
```

**Trigger a Rollout:**

1. Update the Docker image in your repository.
2. Update the rollout definition to use the new image.
3. Trigger a rollout using:

```
argo rollouts rollout my-app
```

**Monitor the Rollout:**

1. Use Argo Rollouts to track the progress of the canary release:

```
kubectl rollout status deployment my-app
```

2. Ensure the canary release completes successfully.

### Task 4: Documentation and Cleanup

**Document the Process:**

1. Create a `readme.md` file in your repository to document the steps you took, including any challenges encountered and how they were resolved.

**Clean Up:**

1. Remove all resources created during this assignment from the Kubernetes cluster using kubectl commands, e.g.:

```
kubectl delete deployment my-app
kubectl delete rollout my-app
```
```
