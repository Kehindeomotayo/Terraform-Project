AWSTemplateFormatVersion: '2010-09-09'
Description: 'Break Glass IAM Users - Prod, Shared, VDI accounts'

Parameters:
  AdminUserPassword:
    Type: String
    NoEcho: true
    Description: Password for bg-admin user
    MinLength: 14

  AlertEmailAddress:
    Type: String
    Description: Email address for break glass activity alerts
    AllowedPattern: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'

Resources:

  BgPlatformUser:
    Type: AWS::IAM::User
    Properties:
      UserName: bg-itops-platform-services
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/ReadOnlyAccess
      Tags:
        - Key: Purpose
          Value: BreakGlassAccess
        - Key: Team
          Value: IT Ops Platform Services
        - Key: BreakGlass
          Value: 'true'
        - Key: Environment
          Value: Critical

  BgMonitoringUser:
    Type: AWS::IAM::User
    Properties:
      UserName: bg-monitoring
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/ReadOnlyAccess
      Tags:
        - Key: Purpose
          Value: BreakGlassAccess
        - Key: Team
          Value: Monitoring
        - Key: BreakGlass
          Value: 'true'
        - Key: Environment
          Value: Critical

  BgServerUser:
    Type: AWS::IAM::User
    Properties:
      UserName: bg-itops-server-support
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/ReadOnlyAccess
      Tags:
        - Key: Purpose
          Value: BreakGlassAccess
        - Key: Team
          Value: IT Ops Server Support
        - Key: BreakGlass
          Value: 'true'
        - Key: Environment
          Value: Critical

  BgAdminUser:
    Type: AWS::IAM::User
    Properties:
      UserName: bg-admin
      LoginProfile:
        Password: !Ref AdminUserPassword
        PasswordResetRequired: false
      Tags:
        - Key: Purpose
          Value: BreakGlassAdmin
        - Key: BreakGlass
          Value: 'true'
        - Key: Environment
          Value: Critical

  BgAdminPolicy:
    Type: AWS::IAM::ManagedPolicy
    Properties:
      ManagedPolicyName: BgAdminPolicy
      Description: Allows bg-admin to list break glass users, enable and disable console access, and manage MFA assignments
      Users:
        - !Ref BgAdminUser
      PolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Sid: ListUsers
            Effect: Allow
            Action:
              - iam:ListUsers
            Resource: "*"

          - Sid: ManageBreakGlassLoginProfiles
            Effect: Allow
            Action:
              - iam:CreateLoginProfile
              - iam:UpdateLoginProfile
              - iam:GetLoginProfile
              - iam:DeleteLoginProfile
              - iam:GetUser
            Resource:
              - !GetAtt BgPlatformUser.Arn
              - !GetAtt BgMonitoringUser.Arn
              - !GetAtt BgServerUser.Arn

          - Sid: ManageBreakGlassMFADevices
            Effect: Allow
            Action:
              - iam:CreateVirtualMFADevice
              - iam:EnableMFADevice
              - iam:DeactivateMFADevice
              - iam:DeleteVirtualMFADevice
              - iam:ListMFADevices
              - iam:ListVirtualMFADevices
              - iam:ResyncMFADevice
            Resource: "*"

  BreakGlassMFAEnforcementPolicy:
    Type: AWS::IAM::ManagedPolicy
    Properties:
      ManagedPolicyName: BreakGlassMFAEnforcement
      Description: Deny all actions unless MFA is present, except MFA setup/self-service
      PolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Sid: AllowViewOwnUser
            Effect: Allow
            Action:
              - iam:GetUser
            Resource: !Sub arn:aws:iam::${AWS::AccountId}:user/${!aws:username}

          - Sid: AllowManageOwnMFA
            Effect: Allow
            Action:
              - iam:CreateVirtualMFADevice
              - iam:EnableMFADevice
              - iam:ListMFADevices
              - iam:ListVirtualMFADevices
              - iam:ResyncMFADevice
            Resource: "*"

          - Sid: DenyEverythingElseIfNoMFA
            Effect: Deny
            NotAction:
              - iam:GetUser
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
      Users:
        - !Ref BgPlatformUser
        - !Ref BgMonitoringUser
        - !Ref BgServerUser

  BgAlertTopic:
    Type: AWS::SNS::Topic
    Properties:
      TopicName: BgActivityAlerts
      DisplayName: Break Glass Activity Alerts
      Tags:
        - Key: Purpose
          Value: BreakGlassMonitoring

  BgAlertTopicPolicy:
    Type: AWS::SNS::TopicPolicy
    Properties:
      Topics:
        - !Ref BgAlertTopic
      PolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Sid: AllowEventBridgePublish
            Effect: Allow
            Principal:
              Service: events.amazonaws.com
            Action: SNS:Publish
            Resource: !Ref BgAlertTopic

  BgAlertSubscription:
    Type: AWS::SNS::Subscription
    Properties:
      Protocol: email
      TopicArn: !Ref BgAlertTopic
      Endpoint: !Ref AlertEmailAddress

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
        - Arn: !Ref BgAlertTopic
          Id: BgConsoleLoginTarget
          InputTransformer:
            InputPathsMap:
              userName: $.detail.userIdentity.userName
              sourceIP: $.detail.sourceIPAddress
              eventTime: $.detail.eventTime
              mfaUsed: $.detail.additionalEventData.MFAUsed
              account: $.account
            InputTemplate: |
              "*** BREAK-GLASS ACCESS USED ***"
              "User: <userName>"
              "Account: <account>"
              "Source IP: <sourceIP>"
              "Time: <eventTime>"
              "MFA Used: <mfaUsed>"
              "Action Required: Verify this is an authorized break glass access and log it in the incident ticket."

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
        - Arn: !Ref BgAlertTopic
          Id: BgIAMActivityTarget
          InputTransformer:
            InputPathsMap:
              userName: $.detail.userIdentity.userName
              eventName: $.detail.eventName
              sourceIP: $.detail.sourceIPAddress
              eventTime: $.detail.eventTime
              account: $.account
            InputTemplate: |
              "*** BREAK-GLASS IAM ACTIVITY DETECTED ***"
              "User: <userName>"
              "Account: <account>"
              "Action: <eventName>"
              "Source IP: <sourceIP>"
              "Time: <eventTime>"
              "Action Required: Investigate and validate this IAM activity."

Outputs:
  BreakGlassUsers:
    Description: Break glass users created by this template
    Value: "bg-itops-platform-services, bg-monitoring, bg-itops-server-support"

  BreakGlassAdmin:
    Description: Break glass admin user
    Value: "bg-admin"





AWS account
	
AWS Region
	
Stack ID
	
Detailed status
	
Last operation ID
	
Status Reason
	
Drift status
	
Last drift check time

AWS account
	
AWS Region
	
Stack ID
	
Detailed status
	
Last operation ID
	
Status Reason
	
Drift status
	
Last drift check time

076327095561
us-east-1
arn:aws:cloudformation:us-east-1:076327095561:stack/StackSet-Bg-PlatformMonitoringServer-StackSet-4de247c2-0079-4e4b-8ee9-cf4f781eebb3/9c1588c0-3906-11f1-a4a3-1262d45d8089
CANCELLED
d99bd3dc-77b0-c0d9-fdbe-5af82b6681ef
Cancelled since failure tolerance has exceeded
NOT_CHECKED
-
461164599838
us-east-1
arn:aws:cloudformation:us-east-1:461164599838:stack/StackSet-Bg-PlatformMonitoringServer-StackSet-b3e8d3b4-374a-4179-b7df-1e7abeb35d3a/c5037080-3906-11f1-9b6b-0e7b22b3967b
FAILED
d99bd3dc-77b0-c0d9-fdbe-5af82b6681ef
ResourceLogicalId:BgAdminPolicy, ResourceType:AWS::IAM::ManagedPolicy, ResourceStatusReason:Resource handler returned message: "A policy called BgAdminPolicy already exists. Duplicate names are not allowed. (Service: Iam, Status Code: 409, Request ID: 92c5d69e-20b6-413d-94bd-0f877384c109) (SDK Attempt Count: 1)" (RequestToken: 021a5ecf-0929-9702-c1d3-0cfda96b6712, HandlerErrorCode: AlreadyExists).
NOT_CHECKED
-
751519514498
us-east-1
arn:aws:cloudformation:us-east-1:751519514498:stack/StackSet-Bg-PlatformMonitoringServer-StackSet-da7422b0-5469-4554-b444-6186f6083321/ee1d7150-3906-11f1-9ac1-125e736e87c1
CANCELLED
d99bd3dc-77b0-c0d9-fdbe-5af82b6681ef
Cancelled since failure tolerance has exceeded
NOT_CHECKED
-
959563671843
us-east-1
arn:aws:cloudformation:us-east-1:959563671843:stack/StackSet-Bg-PlatformMonitoringServer-StackSet-43e990ff-0194-46e2-a30a-b33470ce6dd6/16db4860-3907-11f1-b8db-1273ede9a5b1
CANCELLED
d99bd3dc-77b0-c0d9-fdbe-5af82b6681ef
Cancelled since failure tolerance has exceeded
NOT_CHECKED
-
