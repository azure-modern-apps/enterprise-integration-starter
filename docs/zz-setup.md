
## 4. Make and approve a pull request (PR) to automatically provision the app in your Azure subscription

- Add remote origin to be able to push you local repository you just cloned to your new GitHub repository. Make sure to change the below command to have your GitHub repo URL. You can remove the previous remote called 'origin' if it exists with the command ```git remote rm origin```

```
git remote add origin http://xxxx.xxxxx.git
```

If you are new to pull requests you can learn more here [Manage repository changes by using pull requests on GitHub](https://docs.microsoft.com/en-us/learn/modules/manage-changes-pull-requests-github/) and here [Understanding the GitHub flow](https://guides.github.com/introduction/flow/). 

- Deploy main branch to your new repository

```
git push -u origin feature/01-deploy
```

- Run the below command in the root of the project directory to creat a new branch called 'feature/01-new-feature'. The 'feature/' prefix is needed as it is used to trigger a build.

```
git checkout -b feature/01-deploy
```

- Change the name of your project in the 'APPLICATION_NAME' environment variable in the GitHub action YAML file names '.github/workflows/azure-deploy.yml. Choose something unique for the name portion currently 'amw' as this is also used for urls of services like storage and need to be globally unique in Azure or the build will fail.

- Git commit your code locally
```
git status
git add .
git commit -m "update project name in actions file"
```

- Push your local feature branch to GitHub.
```
git push -u origin new-feature
```

> Note: for now you can approve your own PR but we will be configuring rules in GitHub later to enforce a number of reviewers.

- Create a new pull request in GitHub
Go to GitHub repository and click on Pull Requests and you should see an option to make a pull request with the main branch from your last commit we just did. No need to approve the pull request yet but it should trigger an Action to build and deploy our Azure resources.

![Add secret to GitHub](./images/create-pull-request.png)
Image: Create a GitHub pull request

- Review GitHub Actions output in actions tab
Choose the Actions tab and select the azure-deploy tab to see the action run.

![GitHub action logs](./images/github-action-logs.png)
Image: GitHub Action Logs

## 5. Review Azure Resource in your Azure Portal
- Go to your azure portal and you should be able to see the deployed resource under a resource group names YOUR_APPLICATION_NAME-aue-dev-001.
- Go to the Azure FrontDoor resource and copy the app URL which should be
// TODO: check frontdoor URL
https://YOUR_APPLICATION_NAME.afd.net

