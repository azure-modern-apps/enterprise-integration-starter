# Azure Enterprise Integration Starter

Getting started with an enterprise integration platform for deployment into public sector and regulated industries often requires weeks of research, trial and error.
The Azure Enterprise Integration Starter is designed to accelerate enterprises building iPaaS solutions on Azure.

![Architecture Image](./docs/images/integration-starter-architecture.png)

## Goals

- Enable enterprises to deploy a basic integration starter with private networking to dev/test and prod
- Including services

  - App Gateway
  - APIM
  - Logic App
  - Key Vault
  - Storage Account
  - VNet Integration and Private Endpoints
  - GitHub Actions with self-hosted runner
  - BICEP
  - App Insights

- Enable Microsoft partners to deliver Integration Go-Fast (Light) engagements in 2 weeks that extend the Integration Starter with the customer's requirements and additional services

  - Service Bus
  - Event Grid
  - Azure Functions
  - CosmosDb and SQL DB
  - .... more

- Demonstrate CI/CD and IaC for an integration solution using Bicep
- Demonstrate CI/CD for APIM

## Guiding principles

- Follow today's best practices using released to production (GA) services

## Get started with the Enterprise Integration Starter

To get going with the Enterprise Integration Starter:

1. Clone the [Enterprise Integration Starter repository](https://github.com/azure-modern-apps/enterprise-integration-starter/)
2. Create a Service Principle and add it to GitHub Secrets
3. Make a resource group
4. Update GitHub Action parameters
5. Make a pull request to trigger a deployment to a test environment
