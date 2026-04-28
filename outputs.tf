AWSTemplateFormatVersion: '2010-09-09'
Description: Break-glass users and policies for Shared/Prod/VDI accounts

Parameters:
  AlertEmail:
    Type: String
    Description: Email address to receive break-glass login alerts
  BgAdminPassword:
    Type: String
    NoEcho: true
    MinLength: 12
    Description: Password for bg-admin user (will be forced to reset on first login)

Resources:
  # ---------------- SNS + Alerts ----------------
  BreakGlassAlertsTopic:
    Type: AWS::SNS::Topic
    Properties:
      TopicName: break-glass-alerts

  BreakGlassAlertSubscription:
    Type: AWS::SNS::Subscription
    Properties:
      Protocol: email
      Endpoint: !Ref AlertEmail
      TopicArn: !Ref BreakGlassAlertsTopic

  # ---------------- EventBridge Monitoring Rules (Corrected) ----------------
  ConsoleLoginRule:
    Type: AWS::Events::Rule
    Properties:
      Name: BgConsoleLoginAlert
      Description: Alert on break glass user console login
      State: ENABLED
      EventPattern:
        source:
          - aws.signin
        detail-type:
          - AWS Console Sign In via CloudTrail
        detail:
          userIdentity:
            type:
              - IAMUser
            userName:
              - bg-itops-platform-services
              - bg-monitoring
              - bg-itops-server-support
              - bg-admin
      Targets:
        - Arn: !Ref BreakGlassAlertsTopic
          Id: BgConsoleLoginTarget
          InputTransformer:
            InputPathsMap:
              userName: $.detail.userIdentity.userName
              sourceIP: $.detail.sourceIPAddress
              eventTime: $.detail.eventTime
              mfaUsed: $.detail.additionalEventData.MFAUsed
              account: $.account
            InputTemplate: |
              "ALERT: Break Glass Console Login Detected"
              "User: <userName>"
              "Account: <account>"
              "Source IP: <sourceIP>"
              "Time: <eventTime>"
              "MFA Used: <mfaUsed>"
              "Action Required: Verify this is an authorized break glass access."

  IAMActivityRule:
    Type: AWS::Events::Rule
    Properties:
      Name: BgIAMActivityAlert
      Description: Alert on any IAM activity by break glass users
      State: ENABLED
      EventPattern:
        source:
          - aws.iam
        detail-type:
          - AWS API Call via CloudTrail
        detail:
          userIdentity:
            type:
              - IAMUser
            userName:
              - bg-itops-platform-services
              - bg-monitoring
              - bg-itops-server-support
              - bg-admin
      Targets:
        - Arn: !Ref BreakGlassAlertsTopic
          Id: BgIAMActivityTarget
          InputTransformer:
            InputPathsMap:
              userName: $.detail.userIdentity.userName
              eventName: $.detail.eventName
              sourceIP: $.detail.sourceIPAddress
              eventTime: $.detail.eventTime
              account: $.account
            InputTemplate: |
              "ALERT: Break Glass IAM Activity Detected"
              "User: <userName>"
              "Action: <eventName>"
              "Account: <account>"
              "Source IP: <sourceIP>"
              "Time: <eventTime>"
              "Action Required: Verify this is an authorized break glass activity."

  # ---------------- MFA Enforcement Policy ----------------
  MfaEnforcementPolicy:
    Type: AWS::IAM::ManagedPolicy
    Properties:
      ManagedPolicyName: break-glass-mfa-enforcement
      Description: Enforce MFA for break-glass users
      PolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Sid: DenyAllExceptListedIfNoMFA
            Effect: Deny
            NotAction:
              - iam:CreateVirtualMFADevice
              - iam:EnableMFADevice
              - iam:ListMFADevices
              - iam:ListVirtualMFADevices
              - iam:ResyncMFADevice
              - sts:GetSessionToken
            Resource: "*"
            Condition:
              BoolIfExists:
                aws:MultiFactorAuthPresent: "false"

  # ---------------- Break-glass Read-only Policies ----------------
  MonitoringBreakGlassReadOnlyPolicy:
    Type: AWS::IAM::ManagedPolicy
    Properties:
      ManagedPolicyName: monitoring-break-glass-readonly
      Description: Read-only break-glass policy for Monitoring team
      PolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Action:
              - cloudwatch:Describe*
              - cloudwatch:Get*
              - cloudwatch:List*
              - logs:Describe*
              - logs:Get*
              - logs:List*
              - xray:BatchGet*
              - xray:Get*
              - xray:List*
            Resource: "*"

  ServerSupportBreakGlassReadOnlyPolicy:
    Type: AWS::IAM::ManagedPolicy
    Properties:
      ManagedPolicyName: server-support-break-glass-readonly
      Description: Read-only break-glass policy for Server Support team
      PolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Action:
              - ec2:Describe*
              - autoscaling:Describe*
              - elasticloadbalancing:Describe*
              - cloudwatch:Describe*
              - cloudwatch:Get*
              - cloudwatch:List*
            Resource: "*"

  # ---------------- Corrected bg-admin Policy ----------------
  BgAdminPolicy:
    Type: AWS::IAM::ManagedPolicy
    Properties:
      ManagedPolicyName: bg-admin-policy
      Description: Admin policy for managing break-glass credentials and MFA
      PolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Sid: ManageBreakGlassUsers
            Effect: Allow
            Action:
              - iam:GetUser
              - iam:ListMFADevices
              - iam:CreateLoginProfile
              - iam:UpdateLoginProfile
              - iam:DeleteLoginProfile
              - iam:EnableMFADevice
              - iam:DeactivateMFADevice
              - iam:ResyncMFADevice
            Resource: "arn:aws:iam::*:user/bg-*"

          - Sid: ListAllUsers
            Effect: Allow
            Action:
              - iam:ListUsers
            Resource: "*"

          - Sid: ViewAccountPasswordPolicy
            Effect: Allow
            Action:
              - iam:GetAccountPasswordPolicy
            Resource: "*"

  # ---------------- Users ----------------
  BgItopsPlatformServicesUser:
    Type: AWS::IAM::User
    Properties:
      UserName: bg-itops-platform-services
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/ReadOnlyAccess
        - !Ref MfaEnforcementPolicy

  BgMonitoringUser:
    Type: AWS::IAM::User
    Properties:
      UserName: bg-monitoring
      ManagedPolicyArns:
        - !Ref MonitoringBreakGlassReadOnlyPolicy
        - !Ref MfaEnforcementPolicy

  BgItopsServerSupportUser:
    Type: AWS::IAM::User
    Properties:
      UserName: bg-itops-server-support
      ManagedPolicyArns:
        - !Ref ServerSupportBreakGlassReadOnlyPolicy
        - !Ref MfaEnforcementPolicy

  BgAdminUser:
    Type: AWS::IAM::User
    Properties:
      UserName: bg-admin
      LoginProfile:
        Password: !Ref BgAdminPassword
        PasswordResetRequired: true
      ManagedPolicyArns:
        - !Ref BgAdminPolicy
        - !Ref MfaEnforcementPolicy

Outputs:
  BreakGlassAlertsTopicArn:
    Description: SNS topic ARN for break-glass alerts
    Value: !Ref BreakGlassAlertsTopic

  BreakGlassLoginEventRuleName:
    Description: EventBridge rule name for break-glass logins
    Value: !Ref ConsoleLoginRule
