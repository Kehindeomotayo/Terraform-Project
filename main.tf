# Project7-VPC

resource "aws_vpc" "VPC-PROJECT-7" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"


  tags = {
    Name = "VPC-PROJECT-7"
  }
}

# Public-subnets

resource "aws_subnet" "Prod-pub-sub-1" {
  vpc_id            = aws_vpc.VPC-PROJECT-7.id
  cidr_block        = var.Public_subnet_1_cidr
  availability_zone = var.Availibilty_zone_1
  tags = {
    Name = "Prod-pub-sub-1"
  }
}

resource "aws_subnet" "Prod-pub-sub-2" {
  vpc_id            = aws_vpc.VPC-PROJECT-7.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.Availibilty_zone_2
  tags = {
    Name = "Prod-pub-sub-2"
  }
}

# Private -subnets
resource "aws_subnet" "Prod-priv-sub-1" {
  vpc_id            = aws_vpc.VPC-PROJECT-7.id
  cidr_block        = var.Private_subnet_1_cidr
  availability_zone = var.Availibilty_zone_3
  tags = {
    Name = "Prod-priv-sub-1"
  }
}

resource "aws_subnet" "Prod-priv-sub-2" {
  vpc_id            = aws_vpc.VPC-PROJECT-7.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = var.Availibilty_zone_4
  tags = {
    Name = "Prod-priv-sub-2"
  }
}

# Prod-public-route-table
resource "aws_route_table" "Prod-pub-route-table" {
  vpc_id = aws_vpc.VPC-PROJECT-7.id

  tags = {
    Name = "Prod-pub-route-table"
  }
}

# Prod-priv-route-table
resource "aws_route_table" "Prod-priv-route-table" {
  vpc_id = aws_vpc.VPC-PROJECT-7.id

  tags = {
    Name = "Prod-priv-route-table"
  }
}

# public-route-table-association

resource "aws_route_table_association" "public-route-table-association-1" {
  subnet_id      = aws_subnet.Prod-pub-sub-1.id
  route_table_id = aws_route_table.Prod-pub-route-table.id
}

resource "aws_route_table_association" "public-route-table-association-2" {
  subnet_id      = aws_subnet.Prod-pub-sub-2.id
  route_table_id = aws_route_table.Prod-pub-route-table.id
}

# private-route-table-association

resource "aws_route_table_association" "private-route-table-association-1" {
  subnet_id      = aws_subnet.Prod-priv-sub-1.id
  route_table_id = aws_route_table.Prod-priv-route-table.id
}

resource "aws_route_table_association" "private-route-table-association-2" {
  subnet_id      = aws_subnet.Prod-priv-sub-2.id
  route_table_id = aws_route_table.Prod-priv-route-table.id

}

#internet-gateway
resource "aws_internet_gateway" "Prod-igw" {
  vpc_id = aws_vpc.VPC-PROJECT-7.id

  tags = {
    Name = "Prod-igw"
  }
}

# internet-gateway route
resource "aws_route" "Prod-igw-association" {
  route_table_id         = aws_route_table.Prod-pub-route-table.id
  gateway_id             = aws_internet_gateway.Prod-igw.id
  destination_cidr_block = "0.0.0.0/0"
}

#Elastic ip allocation
resource "aws_eip" "nat-eip" {
}


resource "aws_nat_gateway" "Prod-Nat-gateway" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.Prod-pub-sub-1.id

  tags = {
    Name = "Prod-Nat-gateway"
  }
}

resource "aws_route" "Prod-Nat-association" {
  route_table_id         = aws_route_table.Prod-priv-route-table.id
  gateway_id             = aws_nat_gateway.Prod-Nat-gateway.id
  destination_cidr_block = "0.0.0.0/0"
}




resource "aws_instance" "T_ec2" {
  ami           = "ami-028eb925545f314d6"
  instance_type = "t2.micro"

  tags = {
    Name = "T-ec2"
  }
}






I have already implemented a break-glass access solution using CloudFormation StackSets with the following design:

* IAM users are created locally in each target AWS account
* Users log in directly to each account (no role assumption or switch role)
* MFA is enforced
* Read-only access is assigned using AWS managed policies
* Two StackSets are used:

  * One for Network account only
  * One for other critical accounts (Prod, Shared, VDI)

Now I need to enhance this solution with additional security and operational improvements.

Please help me extend the existing CloudFormation template to include:

1. Login Notification:

   * Capture AWS Console login events using EventBridge
   * Send notifications via SNS when a break-glass user logs in
   * The notification should clearly indicate "Break-Glass Access Used"

2. Tagging:

   * Tag all IAM users with something like:

     * BreakGlass = true
     * Environment = Critical

3. Optional enhancement (design-ready, not fully enforced yet):

   * Prepare the template to support a future model where IAM users can be disabled by default and enabled during incidents

4. Keep everything aligned with the existing architecture:

   * No AssumeRole
   * No centralized login account
   * No cross-account trust relationships

The output should be:

* Clean, modular CloudFormation YAML
* Easy to extend for future teams (e.g., VDI, application teams)
* Production-ready and security-focused




Here's a full summary of everything built for the Break Glass solution:

Architecture Decision

Moved away from the original approach (users in Audit account + AssumeRole)

Users are now created directly in each target account

No AssumeRole, no Switch Role, no cross-account trust

Reason: STS AssumeRole API could fail during an outage, defeating the purpose

Two StackSets Created

Bg-PlatformMonitoringServer-StackSet.yaml

Deploys to: Prod, Shared, VDI and Network accounts

Creates 3 break glass users:

bg-itops-platform-services

bg-monitoring

bg-itops-server-support

Bg-Network-StackSet.yaml

Deploys to: Network account only

Creates 1 break glass user:

bg-itops-network-support

Security Controls Built In

MFA enforced - users can't do anything without MFA

ReadOnly access - ReadOnlyAccess managed policy attached to all users

Users disabled by default - EnableUsers = false, no LoginProfile created on deployment

PasswordResetRequired = false - users can login directly without forced reset

Tags on all users:

BreakGlass = true

Environment = Critical

Purpose = BreakGlassAccess

bg-admin User

Created in Bg-PlatformMonitoringServer-StackSet.yaml

Username: bg-admin

Always has an active LoginProfile - never disabled

Has restricted IAM permissions to only:

iam:CreateLoginProfile - enable a break glass user

iam:DeleteLoginProfile - disable a break glass user

iam:UpdateLoginProfile - update password

iam:GetLoginProfile - check status

Can only perform these actions on the 3 break glass users, nothing else

How Enable/Disable Works

Normal state: all break glass users have no LoginProfile - cannot login

During incident: bg-admin logs in → goes to IAM → enables the relevant user's console access → shares password with the team

After incident: bg-admin goes back to IAM → disables console access → user is locked out again

Monitoring & Alerts

SNS Topic created in each account for alerts

EventBridge rules capture:

Console login by any break glass user → fires *** BREAK-GLASS ACCESS USED *** alert

Any IAM activity by break glass users → fires alert

All alerts sent to the configured email address

Everything logged in CloudTrail

Network StackSet Specific

All resource names prefixed with Network to avoid conflicts:

BgNetworkActivityAlerts (SNS)

BgNetworkMFAEnforcement (policy)

BgNetworkConsoleLoginAlert (EventBridge)

BgNetworkIAMActivityAlert (EventBridge)

Login Flow During an Outage

bg-admin logs into the affected account

Enables the relevant break glass user via IAM console

Shares credentials with the team

Team logs in directly using:

https://[account-id].signin.aws.amazon.com/console

Username + Password + MFA

Team investigates and resolves the incident

bg-admin disables the user after the incident

Everything is logged and alerted throughout

Still Pending

Team feedback on permissions (read-only vs SSO-aligned)

Updating the StackSets in AWS console with the latest templates

Setting up MFA for bg-admin after deployment

Updating the documentation to reflect the new architecture










AWSTemplateFormatVersion: '2010-09-09'
Description: 'Break Glass IAM Users - Deploy to Prod, Shared, VDI and Network accounts'

Parameters:
  PlatformUserPassword:
    Type: String
    NoEcho: true
    Description: Password for bg-itops-platform-services user
    MinLength: 14

  MonitoringUserPassword:
    Type: String
    NoEcho: true
    Description: Password for bg-monitoring user
    MinLength: 14

  ServerUserPassword:
    Type: String
    NoEcho: true
    Description: Password for bg-itops-server-support user
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

  EnableUsers:
    Type: String
    Default: 'false'
    AllowedValues:
      - 'true'
      - 'false'
    Description: Set to true to enable break glass users during an incident

Conditions:
  UsersEnabled: !Equals [!Ref EnableUsers, 'true']

Resources:

  # IAM Users
  BgPlatformUser:
    Type: AWS::IAM::User
    Properties:
      UserName: bg-itops-platform-services
      LoginProfile: !If
        - UsersEnabled
        - Password: !Ref PlatformUserPassword
          PasswordResetRequired: false
        - !Ref AWS::NoValue
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
      LoginProfile: !If
        - UsersEnabled
        - Password: !Ref MonitoringUserPassword
          PasswordResetRequired: false
        - !Ref AWS::NoValue
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
      LoginProfile: !If
        - UsersEnabled
        - Password: !Ref ServerUserPassword
          PasswordResetRequired: false
        - !Ref AWS::NoValue
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

  # BG Admin User - Enable/Disable break glass users during incidents
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
      Description: Allows bg-admin to enable and disable break glass user login profiles only
      PolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Sid: ManageBreakGlassLoginProfiles
            Effect: Allow
            Action:
              - iam:CreateLoginProfile
              - iam:DeleteLoginProfile
              - iam:UpdateLoginProfile
              - iam:GetLoginProfile
              - iam:GetUser
              - iam:CreateVirtualMFADevice
              - iam:EnableMFADevice
              - iam:DeactivateMFADevice
              - iam:DeleteVirtualMFADevice
              - iam:ListMFADevices
              - iam:ListAccessKeys
              - iam:ListServiceSpecificCredentials
              - iam:ListSSHPublicKeys
              - iam:ListSigningCertificates
            Resource:
              - !GetAtt BgPlatformUser.Arn
              - !GetAtt BgMonitoringUser.Arn
              - !GetAtt BgServerUser.Arn










AWSTemplateFormatVersion: '2010-09-09'
Description: 'Break Glass IAM Users - Deploy to Network account only'

Parameters:
  NetworkUserPassword:
    Type: String
    NoEcho: true
    Description: Password for bg-itops-network-support user
    MinLength: 14

  AlertEmailAddress:
    Type: String
    Description: Email address for break glass activity alerts
    AllowedPattern: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'

  EnableUsers:
    Type: String
    Default: 'false'
    AllowedValues:
      - 'true'
      - 'false'
    Description: Set to true to enable break glass users during an incident

Conditions:
  UsersEnabled: !Equals [!Ref EnableUsers, 'true']

Resources:

  # IAM User (Network Break Glass)
  BgNetworkUser:
    Type: AWS::IAM::User
    Properties:
      UserName: bg-itops-network-support
      LoginProfile: !If
        - UsersEnabled
        - Password: !Ref NetworkUserPassword
          PasswordResetRequired: false
        - !Ref AWS::NoValue
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

  # MFA Enforcement Policy (FIXED)
  MFAEnforcementPolicy:
    Type: AWS::IAM::ManagedPolicy
    Properties:
      ManagedPolicyName: BgNetworkMFAEnforcement
      Description: Denies all access if MFA is not present
      PolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Sid: DenyConsoleAndAPIAccessWithoutMFA
            Effect: Deny
            Action: "*"
            Resource: "*"
            Condition:
              Bool:
                aws:MultiFactorAuthPresent: "false"
      Users:
        - !Ref BgNetworkUser

  # SNS Alerts
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

  # EventBridge Monitoring Rules

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
