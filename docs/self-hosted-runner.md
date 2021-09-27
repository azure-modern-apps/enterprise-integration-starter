# GitHub Self-Hosted Runner

## Rationale

In this scenario, the GitHub self-hosted runner is used to access Azure resources within our virtual network that are not externally accessible.  For example, once the private endpoint is enabled on the Logic App, we will need to deploy the application (and updates) via a resource that has connectivity to the private endpoint, such as a VM within the same virtual network.

For more information on GitHub self-hosted runners, please see https://docs.github.com/en/actions/hosting-your-own-runners

## Creating the self-hosted runner

This sample includes a workflow, [selfHostedRunner.yml](../.github/workflows/selfHostedRunner.yml), to assist with the creation of the self-hosted runner.  It is recommended to manually execute this GitHub workflow, which will provision the virtual network, subnets, [Azure Bastion](https://docs.microsoft.com/en-us/azure/bastion/bastion-overview), and the virtual machine to host the self-hosted runner.  Other workflows will utilise this self-hosted runner and the same virtual network as deployed here.

### Prerequisites

Before executing the workflow, please ensure that the necessary credentials are added as GitHub secrets:

- `RUNNER_VM_ADMIN_USERNAME_DEV` - The username to use as the administrator on the self-hosted runner VM
- `RUNNER_VM_ADMIN_PASSWORD_DEV` - The password for the administrator on the self-hosted runner VM

Please ensure that the credentials are recorded in a secure location, as they will be used later in the process to connect to the virtual machine.

## Connecting to the self-hosted runner

In addition to the self-hosted runner VM, the above workflow will also deploy [Azure Bastion](https://docs.microsoft.com/en-us/azure/bastion/bastion-overview) into the virtual network.  This provides an easy and secure way to connect to the self-hosted runner VM.

For example, in this scenario, you could launch the [Azure Portal](https://portal.azure.com/) and navigate to the virtual machine deployed in the steps above.  On the VM Overview page, click `Connect`, select `Bastion` from the dropdown, and again click to `Use Bastion`.  Provide the username and password that were configured as secrets in the steps above and click `Connect`.

## Configuring the self-hosted runner
   
1. In a browser, open the desired GitHub repository, go to `Settings` -> `Actions` -> `Runners` -> `Add runner`. Also, see https://docs.github.com/en/actions/hosting-your-own-runners/adding-self-hosted-runners for more information on this step.

1. Connect to the virtual machine (as described above) and follow the provided instructions for the O/S and Architecture (the sample in this repository defaults to Linux & x64).  If successful, you should see the Runner listed in your repository, probably in the "Idle" state.  

1. It is also recommended to install the self-hosted runner application to run on VM startup as per https://docs.github.com/en/actions/hosting-your-own-runners/configuring-the-self-hosted-runner-application-as-a-service
    
## Required tools for the self-hosted runner

You will also need to install the necessary tooling on your self-hosted runner to support the actions they execute in your workflow.

The following are the required installations for the Linux hosts we use in our sample workflows:

- [Install the Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).  Specifically, this sample uses the [Ubuntu installation instructions](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt)

- Install zip (for zip deployments of the logic app workflows).  On Linux, this command can be used:
```
sudo apt install zip
```
- [Install Powershell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.1). Specifically, this sample uses the [Ubuntu 18.04 instructions](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7.1#ubuntu-1804)

- [Install the Azure Az Powershell module](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-6.4.0), e.g.

``` 
> pwsh

> Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force

> exit
```
