# OIDC Migration Plan

Tracks the migration from static IAM credentials to OIDC-based authentication.

Related issues: #39, #48

## Current State

- CI (GitHub Actions) authenticates to AWS using static `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` stored as GitHub Actions secrets.
- Lambda functions retrieve static AWS keys from SSM parameters (`/xomcloud/aws/ACCESS_KEY`, `/xomcloud/aws/SECRET_KEY`).

## Target State

- CI authenticates via GitHub Actions OIDC provider using `aws-actions/configure-aws-credentials` with `role-to-assume`.
- Lambda functions use their execution role (already attached) instead of stored static keys.
- Static key SSM parameters (`access_key`, `secret_key`) and corresponding Terraform variables are removed.

## Migration Steps

### 1. Create OIDC Identity Provider in AWS
- Add `aws_iam_openid_connect_provider` for `token.actions.githubusercontent.com` in the shared infra repo (xomware-infrastructure).
- Scope the trust policy to the `Xomware/xomcloud-infrastructure` repo.

### 2. Create CI Role
- Create an IAM role with trust policy for the OIDC provider.
- Attach permissions: Terraform state S3 access, DynamoDB lock table, and whatever `terraform plan`/`apply` needs.

### 3. Update GitHub Actions Workflow
- Replace `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` env vars with:
  ```yaml
  - uses: aws-actions/configure-aws-credentials@v4
    with:
      role-to-assume: arn:aws:iam::ACCOUNT_ID:role/xomcloud-ci
      aws-region: us-east-1
  ```

### 4. Remove Static Keys from Lambda
- Audit Lambda code to confirm it uses boto3 default credential chain (execution role) and not the SSM-stored keys.
- Remove SSM parameters `access_key` and `secret_key` from `ssm.tf`.
- Remove `access_key` and `secret_key` variables from `variables.tf`.
- Remove corresponding GitHub Actions secrets.

### 5. Rotate and Decommission Static Keys
- Rotate the IAM access key in the AWS console.
- After confirming everything works on OIDC, delete the IAM user entirely.
