# scrappr-site

## Setup Outside of Code Deploy:

### Connect to AWS through OIDC for GitHub Actions to Use Terraform

#### Configure AWS as an OIDC provider:
1. Log in to your AWS Console and go to IAM.
2. Select "Identity providers" and click "Add provider".
3. Choose "OpenID Connect" as the provider type.
For the provider URL, enter: `https://token.actions.githubusercontent.com`
For the "Audience", enter: `sts.amazonaws.com`
Click "Get thumbprint" and then "Add provider".
4. Create an IAM role for GitHub Actions:
    - In IAM, go to "Roles" and click "Create role".
    - Select "Web Identity" under "Trusted entity type".
    - Choose the GitHub identity provider you just created.
    - For the Audience, select `sts.amazonaws.com`
    - Create a new role (e.g., "GitHubActionsRole")
    - Choose "Web Identity" as the trusted entity
    - Select the OIDC provider you created for GitHub (`token.actions.githubusercontent.com`)
    - Add the necessary permissions for your Terraform operations.
    - Set a trust policy to restrict access to your specific GitHub repo:
    ```
    {
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_AWS_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
            "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
            "token.actions.githubusercontent.com:sub": "repo:YourGitHubOrg/*"
        }
      }
    }
  ]
}
```
5. Set the permissions for Terraform (your needs may differ):
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "s3:*",
        "dynamodb:*",
        "iam:*",
        "cloudwatch:*"
        // Add other necessary permissions
      ],
      "Resource": "*"
    }
  ]
}
```
6. Attach the policy to the role.
7. In your GitHub Actions Workflow us this action:
```
- name: Configure AWS Credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        role-to-assume: arn:aws:iam::${{ env.AWS_ACCOUNT_ID }}:role/${{ env.TERRAFORM_ROLE_NAME }}
        aws-region: ${{ env.AWS_REGION }}
```
and update the code at the top to look like this:
```
terraform-plan:
    runs-on: ubuntu-24.04
    env:
      AWS_ACCOUNT_ID: ${{ vars.AWS_ACCOUNT_ID }}
      AWS_REGION: ${{ vars.AWS_REGION }}
      ROLE_NAME: ${{ vars.TERRAFORM_ROLE_NAME }}
```
- You will need to add all values under the `env` section as environmental variables
in the GitHub Actions settings section of the repo or globally for the whole Org.
8. Add this to your GitHub Actions Workflow as well:
```
jobs:
  deploy:
    permissions:
      id-token: write
      contents: read
```
9. Use the credentials in your Terraform steps:
    - The AWS credentials will be automatically available to Terraform.
10. Ensure your Terraform code uses the assumed role:
    - In your Terraform AWS provider configuration, you don't need to specify credentials. Terraform will use the credentials from the environment.

By following these steps, you'll set up a secure OIDC connection between GitHub Actions and AWS. This method eliminates the need for long-lived AWS access keys, enhancing security. The IAM role's trust policy ensures that only your specified GitHub repository can assume the role, providing an additional layer of security
