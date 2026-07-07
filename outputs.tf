Hi team, I'm working on a SOX follow-up request for the devops-assume IAM user in AWS GovCloud. I believe I have the purpose of the account and the roles/responsibilities covered, but I need some clarification on the remaining items:

How is the password for this account managed? Is it managed through CyberArk?
What is the password rotation policy for this account?
The auditors also requested evidence that "security questions" are enabled. Is this referring to CyberArk or another authentication mechanism? I couldn't find anything related to security questions in AWS IAM.








1. Purpose of the Account

The devops-assume IAM user is an administrative IAM account in the AWS GovCloud management account. Based on the AWS IAM review, the account has never been used for console sign-in, the active access key has never been used, and no AWS services have been accessed during the tracked period. The account currently has console access enabled and the AWS managed AdministratorAccess policy attached.

2. Authentication

The IAM user has console access enabled. Based on the AWS IAM console review, no MFA device is configured for this IAM user. AWS IAM users do not support configurable security questions. Authentication for this account is governed by the organization's authentication and access controls.

3. Password Management

The IAM user has a console password configured. The method used to manage the password cannot be determined from the AWS IAM console and is currently being confirmed.

4. Password Rotation Policy

The AWS account password policy enforces the following requirements:

Passwords expire every 90 days.
Minimum password length of 8 characters.
Passwords must contain at least one uppercase letter.
Passwords must contain at least one lowercase letter.
Passwords must contain at least one numeric character.
Passwords must contain at least one special character.
Password reuse is prevented for the previous 5 passwords.
Users are permitted to change their own passwords.
5. Roles and Responsibilities

The IAM user is assigned the AWS managed AdministratorAccess policy, which provides administrative permissions to AWS resources. Based on the AWS console review, the account has administrative privileges but has never been used for console access, the active access key has never been used, and no AWS services have been accessed during the tracked period.

Supporting Evidence Attached
IAM User Summary
Security Credentials
Console Access Configuration
AdministratorAccess Policy
Last Accessed Information
AWS Account Password Policy
