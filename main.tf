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
        - !Ref BgNetworkUser

  BgAlertTopic:
    Type: AWS::SNS::Topic
    Properties:
      TopicName: BgNetworkActivityAlerts
      DisplayName: Break Glass Network Activity Alerts
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
      Name: BgNetworkIAMActivityAlert
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
              - bg-itops-network-support
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
  BreakGlassUser:
    Description: Break glass network user created by this template
    Value: "bg-itops-network-support"

  BreakGlassAdmin:
    Description: Break glass admin user
    Value: "bg-admin"










AWSTemplateFormatVersion: '2010-09-09'
Description: 'Break Glass IAM User - Network account only'

Parameters:
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

  BgAdminPolicy:
    Type: AWS::IAM::ManagedPolicy
    Properties:
      ManagedPolicyName: BgNetworkAdminPolicy
      Description: Allows existing bg-admin to enable and disable network break glass console access and manage MFA assignments
      Users:
        - bg-admin
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
        - !Ref BgNetworkUser

  BgAlertTopic:
    Type: AWS::SNS::Topic
    Properties:
      TopicName: BgNetworkActivityAlerts
      DisplayName: Break Glass Network Activity Alerts
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
      Name: BgNetworkIAMActivityAlert
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
              - bg-itops-network-support
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
  BreakGlassUser:
    Description: Break glass network user created by this template
    Value: "bg-itops-network-support"

  BreakGlassAdmin:
    Description: Existing break glass admin user reused by this template
    Value: "bg-admin"
