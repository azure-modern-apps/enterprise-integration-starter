# Getting Started

To get going with the Enterprise Integration Starter we will:

1. Clone the [Enterprise Integration Starter repository](https://github.com/azure-modern-apps/enterprise-integration-starter/)
2. Create a Service Principle and add it to GitHub Secrets
3. Make a resource group
4. Update GitHub Action parameters
5. Make a pull request to trigger a deployment to a test environment

## 1 - Fork and pull the repository

Go to the [Enterprise Integration Starter repository](https://github.com/azure-modern-apps/enterprise-integration-starter/)

To fork the repository, click the Fork button in the header of the repository.

![The Fork Button](./images/github-fork.png)
Figure: The repository's fork button

Checkout the repo locally

```BASH
 git clone github.com/{YOUR_USERNAME}/enterprise-integration-starter.git

 ## for example git clone github.com/janesmith/enterprise-integration-starter.git
```

## 2 - Create the resource group for your dev/test environment

To practice least privilige we only allow our deployment action to access a specific resource group. In the next step you will create a service principle that can access this resource group.

If you do not have the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/) installed you can use the Azure portal to access the az cli.

If you have the Azure CLI installed you can run this next command locally, but the simplest way to run this command is to run this command in the Azure Portal's Cloud Shell.

- Check you are using the right subscription and save your subscription id for the next step

```BASH
az account show
```

![Azure CLI output example](./images/display-azure-account-id.png)
Image: Azure portal

- Create resource group

```BASH
az group create --location {LOCATION} --name {RESOURCE_GROUP_NAME}

## for example az group create --location australiaeast --name rg-eis-dev-auea
```

## 3 - Create a Service Principle and add it to GitHub secrets

We need to make a service principle and add it to your repositories GitHub Secrets. This gives GitHub the ability to deploy Azure resources automatically.

To have authorization to provision Azure Resources from GitHub we will need to make a [service principal](https://docs.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals). A service principle is a set of keys we can get from running the below Azure CLI commands.

- Create a service prinicpal
  Change the xxx-xxx to be your your subscription id which we will have gotten from the 'id' field in the command we just ran.

```BASH
az ad sp create-for-rbac --name {SERVICE_PRINCIPAL_NAME} --sdk-auth --role contributor --scopes /subscriptions/{SUBSCRIPTION_ID}/resourceGroups/{RESOURCE_GROUP_NAME}

## for example  az ad sp create-for-rbac --name integration-starter --sdk-auth --role contributor --scopes /subscriptions/1111-1111-1111-1111/resourceGroups/rg-eis-dev-auea
```

- Add the service principle to your repositories GitHub Secrets with the name ```AZURE_CREDENTIALS_DEV```.

![Add secret to GitHub](./images/add-secret-to-github.png)
Image: Add secret to GitHub

> Note: If you get stuck you can follow the instructions from the community the GitHub Action [Azure Login ](https://github.com/marketplace/actions/azure-login) we will be using.

## 4 - Add remaining secrets to GitHub
We need to have a place to store a few variables for our pipeline and until GitHub variables are released we will use a mix of GitHub secrets and local action file variables.

1. AZURE_RESOURCE_GROUP_DEV

    For example ```rg-eis-dev-auea```

2. AZURE_SUBSCRIPTION_ID_DEV

    For example ```11111-11111-11111-11111-11111```

3. LOGIC_APP_NAME_DEV 

    For example ```logic-eis-dev-auea```

## 5 - Update ```.github/workflows/logicApp.yml``` action file variables
We need to have a place to store a few variables for our pipeline and until GitHub variables are released we will use a mix of GitHub secrets and local action file variables.

```YML
env:
  LA_NAME: '{YOUR_LOGIC_APP_NAME}'
  APIM_NAME: '{YOUR_APIM_NAME}'
  WORKFLOW_NAME: '{YOUR_WORKFLOW_NAME}'

## for example
## env:
##   LA_NAME: 'logic-eis-dev-auea'
##   APIM_NAME: 'apim-eis-dev-aue'
##   WORKFLOW_NAME: 'eisHttpRequest'
```

