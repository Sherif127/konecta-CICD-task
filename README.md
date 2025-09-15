# CI/CD Task

## Scenario
This project demonstrates a full CI/CD workflow using Jenkins, Terraform, Ansible, and Docker with ephemeral EC2 instances:

1. **Pipeline 1 (Provision & Configure)**: Triggered by a Git webhook push to `main`.  
   - Creates an ephemeral EC2 instance using Terraform with a remote backend.  
   - Configures the instance using Ansible to install and start Docker.  

2. **Pipeline 2 (Build, Push & Deploy)**: Automatically triggered after Pipeline 1.  
   - Builds a Docker image (`nginx:alpine`) with a custom `index.html`.  
   - Pushes the image to a private Docker Hub repository.  
   - Deploys the container to the provisioned EC2 instance via SSH and verifies it with `curl`.  

3. **Pipeline 3 (Daily Cleanup)**: Scheduled to run daily at **00:00 Africa/Cairo**.  
   - Automatically discovers and terminates all EC2 instances tagged as ephemeral.  

---

## Repository Layout

```
.
├── Jenkinsfile.provision          # Pipeline 1
├── Jenkinsfile.deploy             # Pipeline 2
├── Jenkinsfile.cleanup            # Pipeline 3
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf                 # outputs public IP
│   └── backend.tf                 # remote backend (S3 + DynamoDB)
├── ansible/
│   └── playbook.yaml              # installs Docker, enables service
└── App/
    ├── Dockerfile                 # nginx:alpine container
    └── index.html                 # placeholder replaced during build
```

---

## Pipeline 1 — Provision & Configure

**Trigger:** Git webhook push to `main`.  

**Steps:**
1. Initialize Terraform with a remote backend (no local state).  
2. Create an EC2 instance (`t3.micro`) with the following tags:
   - `Name=ci-ephemeral`, `lifespan=ephemeral`, `owner=jenkins`  
3. Output the public IP of the EC2 instance.  
4. Run Ansible playbook to install Docker and start the service.  

**Screenshots:**
- Webhook added in GitHub  
  ![Add Webhook](screenshots/add%20webhook%20screen.PNG)  

- Webhook trigger in Jenkins  
  ![Webhook Trigger](screenshots/webhook%20screenshot.PNG)  

- Terraform + Ansible output (provisioning)  
  ![Provision Output](screenshots/first%20pipeline%20provision%20output.PNG)  

- EC2 instance summary  
  ![Instance Summary](screenshots/instance%20summary.PNG)  

- Provision pipeline overview in Jenkins  
  ![Provision Pipeline Overview](screenshots/pipeline%20provision%20overview.PNG)  

---

## Pipeline 2 — Build, Push & Deploy

**Trigger:** Automatically after Pipeline 1 with `EC2_IP` parameter.  

**Steps:**
1. Build Docker image from `nginx:alpine` with a custom `index.html` showing the build number and timestamp.  
2. Authenticate to private Docker Hub using Jenkins credentials.  
3. Push Docker image tagged with `docker.io/<namespace>/nginx-ci:<BUILD_NUMBER>` or Git SHA.  
4. SSH deploy:
   - Remove any existing container named `web`.  
   - Run the new container on port 80.  
   - Verify deployment with `curl`.  

**Screenshots:**
- Deploy pipeline overview in Jenkins  
  ![Deploy Pipeline Overview](screenshots/pipleine%20deploy%20overview.PNG)
- Browser showing the deployed app  
  ![Browser Deployed App](screenshots/browser%20of%20public.PNG)


---

## Pipeline 3 — Daily Cleanup

**Trigger:** Jenkins scheduled job at 12:00 AM Africa/Cairo.

**Steps:**
1. Use AWS CLI with Jenkins credentials to find ephemeral EC2 instances:
   - `lifespan=ephemeral`, `owner=jenkins`  
   - State: `pending`, `running`, `stopping`, `stopped`  
2. Terminate all discovered instances.  
3. Log the IDs of terminated instances.  

**Cron Schedule Example:**  
```
TZ=Africa/Cairo
0 0 * * *
```

**Screenshots:**
- Cleanup pipeline overview in Jenkins  
  ![Cleanup Pipeline Overview](screenshots/pipeline%20cleanup%20overview.PNG)  

---