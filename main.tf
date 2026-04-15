AWSTemplateFormatVersion: '2010-09-09'
Description: 'Break Glass IAM Users - Prod, Shared, VDI accounts'

Parameters:
  PlatformUserPassword:
    Type: String
    NoEcho: true
    Description: Temporary password for bg-itops-platform-services when incident access is enabled manually by bg-admin
    MinLength: 14

  MonitoringUserPassword:
    Type: String
    NoEcho: true
    Description: Temporary password for bg-monitoring when incident access is enabled manually by bg-admin
    MinLength: 14

  ServerUserPassword:
    Type: String
    NoEcho: true
    Description: Temporary password for bg-itops-server-support when incident access is enabled manually by bg-admin
    MinLength: 14

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
      Description: Allows bg-admin to enable and disable break glass user console access and manage MFA assignments
      Users:
        - !Ref BgAdminUser
      PolicyDocument:
        Version: '2012-10-17'
        Statement:
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
            Resource: !Sub arn:aws:iam::${AWS::AccountId}:user/\${aws:username}

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

Outputs:
  BreakGlassUsers:
    Value: "bg-itops-platform-services, bg-monitoring, bg-itops-server-support"
  BreakGlassAdmin:
    Value: "bg-admin"






AWSTemplateFormatVersion: '2010-09-09'
Description: 'Break Glass IAM User - Network account only'

Parameters:
  AdminUserPassword:
    Type: String
    NoEcho: true
    Description: Password for bg-admin user in the network account
    MinLength: 14

  AlertEmailAddress:
    Type: String
    Description: Email address for break glass activity alerts
    AllowedPattern: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'

Resources:

  BgNetworkUser:
    Type: AWS::IAM::User
    Properties:
      UserName: bg-itops-network-support
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/ReadOnlyAccess
      Tags:
        - Key: Purpose
          Value: BreakGlassAccess
        - Key: Team
          Value: IT Ops Network Support
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
      ManagedPolicyName: BgNetworkAdminPolicy
      Description: Allows bg-admin to enable and disable network break glass console access and manage MFA assignments
      Users:
        - !Ref BgAdminUser
      PolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Sid: ManageBreakGlassLoginProfiles
            Effect: Allow
            Action:
              - iam:CreateLoginProfile
              - iam:UpdateLoginProfile
              - iam:GetLoginProfile
              - iam:DeleteLoginProfile
              - iam:GetUser
            Resource:
              - !GetAtt BgNetworkUser.Arn

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

  MFAEnforcementPolicy:
    Type: AWS::IAM::ManagedPolicy
    Properties:
      ManagedPolicyName: BgNetworkMFAEnforcement
      Description: Deny all actions unless MFA is present, except MFA setup/self-service
      PolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Sid: AllowViewOwnUser
            Effect: Allow
            Action:
              - iam:GetUser
            Resource: !Sub arn:aws:iam::${AWS::AccountId}:user/\${aws:username}

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
        - !Ref BgNetworkUser

  BgAlertTopic:
    Type: AWS::SNS::Topic
    Properties:
      TopicName: BgNetworkActivityAlerts
      DisplayName: Break Glass Network Activity Alerts

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
      Name: BgNetworkConsoleLoginAlert
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
              - bg-itops-network-support
              - bg-admin
      Targets:
        - Arn: !Ref BgAlertTopic
          Id: BgConsoleLoginTarget







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

461164599838
us-east-1
arn:aws:cloudformation:us-east-1:461164599838:stack/StackSet-Bg-PlatformMonitoringServer-StackSet-5b33c90a-db33-4d65-84a1-9e54d95ad891/906e94a0-3819-11f1-8e28-0ea5af7cf5ad
CANCELLED
709e3203-af06-6af7-0151-bb0d37c363a0
Cancelled since failure tolerance has exceeded
NOT_CHECKED
-
751519514498
us-east-1
arn:aws:cloudformation:us-east-1:751519514498:stack/StackSet-Bg-PlatformMonitoringServer-StackSet-b9daaefc-2523-4e7a-a95d-a9e03a117a11/67226040-3819-11f1-a412-12ae37ae6ea1
INOPERABLE
709e3203-af06-6af7-0151-bb0d37c363a0
ResourceLogicalId:BgServerUser, ResourceType:AWS::IAM::User, ResourceStatusReason:Resource handler returned message: "Cannot delete entity, must delete login profile first. (Service: Iam, Status Code: 409, Request ID: a555e2a2-5579-43a4-8eaa-ca10515f04de) (SDK Attempt Count: 1)" (RequestToken: 29bfa3b1-3b04-99d0-8cd6-20833cc087cc, HandlerErrorCode: GeneralServiceException).
NOT_CHECKED
-
959563671843
us-east-1
arn:aws:cloudformation:us-east-1:959563671843:stack/StackSet-Bg-PlatformMonitoringServer-StackSet-f9d73823-9eaf-4b38-b928-42b292abb362/130af8a0-3819-11f1-b052-126de7bacae5
CANCELLED
709e3203-af06-6af7-0151-bb0d37c363a0
Cancelled since failure tolerance has exceeded







