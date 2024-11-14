# GoGreen Insurance Terraform PoC Infrastructure

## **Project Overview**

This project showcases the use of **Terraform** to set up a proof-of-concept (PoC) infrastructure for **GoGreen Insurance**. The objective of this infrastructure is to demonstrate the creation of essential cloud resources using **AWS Free Tier** options, while ensuring scalability, security, and a seamless user experience. 

The PoC infrastructure consists of:

- An **isolated virtual network** (VPC) with subnetting.
- **Web server** and **database instance** configured to demonstrate data updates.
- **Compute capacity** with attached **EBS volumes**.
- Security configurations via **security groups** for each layer of the architecture.
- A **high-performance database storage tier**.
- An **S3 bucket** to store object data.

By utilizing Terraform, we can automate the provisioning of the entire infrastructure, ensuring consistency and ease of deployment across various environments (Dev, Test, Prod).

---

## **Terraform Code Overview**

The Terraform configuration is structured to provision a variety of AWS services with minimal manual intervention. Here's a breakdown of the key components and decisions made:

### **1. VPC Configuration**

We start by defining a **VPC** (Virtual Private Cloud) to isolate the infrastructure in a private network. This VPC is then split into different subnets to ensure proper segmentation between the web, app, and DB layers. 

- **Decision**: Subnetting is crucial to apply security controls and enable proper traffic routing between different layers of the architecture.
- **Why**: This isolates different parts of the infrastructure, improving both security and performance by ensuring that traffic between layers is controlled.

### **2. EC2 Instance (Web Server)**

A **web server** is deployed on an **EC2 instance** with a public IP, enabling access from the internet. It serves as the frontend of the application.

- **Decision**: We used a **t2.micro instance** to stay within the AWS Free Tier.
- **Why**: The web server doesn’t require high compute capacity, and using the **Free Tier** allows us to keep costs minimal while ensuring sufficient resources for a PoC environment.

### **3. RDS Instance (Database)**

An **RDS instance** is used to manage the database tier. This instance is configured with the necessary parameters, such as storage size, engine version, and security configurations.

- **Decision**: The database is provisioned with **General Purpose (SSD) storage**.
- **Why**: We selected this tier to provide a good balance between cost and performance for a PoC while remaining eligible for the **AWS Free Tier**.

### **4. S3 Bucket (Object Store)**

The **S3 bucket** is set up for storing data objects such as backups or logs.

- **Decision**: We configured the **S3 bucket** to be publicly accessible for demo purposes but also included an **ACL** (Access Control List) to restrict access.
- **Why**: While the bucket can be made publicly accessible for the demo, we must configure access controls to ensure security in production environments.

### **5. Security Groups**

Security groups are defined for the EC2, RDS, and S3 resources. These security groups restrict traffic based on IP addresses and ports.

- **Decision**: Each component (EC2, RDS) is placed behind a security group that restricts access only to necessary traffic.
- **Why**: This ensures that the environment remains secure by minimizing exposure to unauthorized access.

---

## **Why Terraform?**

Using Terraform allows for **Infrastructure as Code (IaC)**, which ensures that the infrastructure can be easily replicated, versioned, and maintained. It also reduces human errors during deployment and enables automated updates.

- **Reusability**: The configuration files can be reused across different AWS accounts and environments.
- **Consistency**: Terraform ensures the infrastructure is deployed the same way every time.
- **Scalability**: If the PoC moves to a larger production environment, the configuration can be extended without major changes.

---

## **AWS Console Deployment Proof**

Below are the screenshots from the **AWS Console** proving the deployment of the infrastructure.

### **VPC**

![VPC Screenshot](images/VPC%20Resource%20Map.png)

### **EC2 Instance (Web Server)**

![EC2 Screenshot](images/EC2%20Panel.png)

### **S3 Bucket**

![S3 Screenshot](images/S3%20Panel.png)

### **RDS Instance**

![RDS Screenshot](images/RDS%20Panel.png)

---

## **Tutorials and Resources**

Check out the following tutorials for step-by-step guidance on how to deploy this Terraform configuration:

- [Beginners Tutorial to Terraform with AWS](https://www.youtube.com/watch?v=XxTcw7UTues)
- [Learn Terraform (and AWS) - Full Course for Beginners by freeCodeCamp.org](https://www.youtube.com/watch?v=iRaai1IBlB0)
- [Longer, More in-depth Project Tutorial](https://www.youtube.com/playlist?list=PL184oVW5ERMCirZu6wRL2NmUENHixB4mt)

---

**Enjoy experimenting with Terraform and AWS!**
