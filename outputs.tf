AWSTemplateFormatVersion: 2010-09-09

Description: Template to launch server in AWS environment

Parameters:
  AMZNInstanceKeyName:
    Description: Select the key pair for AMZNInstance Server
    Type: AWS::EC2::KeyPair::KeyName
    Default: WindowsPrintServerSharedKP
  RoleName:
    Description: IAM Role Name for SSM Instance Profile
    Type: String
    Default: SSMInstanceProfileRole-APS1
    ConstraintDescription: Must be a valid IAM Role

Resources:
  AppInstance01:
    Type: AWS::EC2::Instance
    Properties:
      DisableApiTermination: 'true'
      EbsOptimized: 'true'
      ImageId: ami-00cdaf46e6cab9c27 #INGURPRINT01
      InstanceType: t3a.large
      IamInstanceProfile: !Ref RoleName
      KeyName: !Ref AMZNInstanceKeyName
      NetworkInterfaces:
        - NetworkInterfaceId: eni-056dc54232fce5bd5
          DeviceIndex: 0
        # SecurityGroupIds:
        #   - sg-017ea4a4658d813f5 # AVTR-SHARED-WINDOWS-PRINT-SERVICES-APP-APS1 
        #   - sg-026d9eef340af1ffd # AVTR-WIN-SHARED-MGMT-APS1 
        #   - sg-083513d44511809fb # AVTR-BASE-SHARED-APP-APS1 
      Tags:
        - Key: Name
          Value: EC2-Shared-Core-Ingurprint-App-01-APS1
        - Key: Costcenter
          Value: 80803255
        - Key: Environment
          Value: Shared
        - Key: Application
          Value: Windows Print Services
        - Key: FunctionalArea
          Value: BusinessFunctions_IT
        - Key: Platform
          Value: AWS Infrastructure
        - Key: Compliance
          Value: None
        - Key: CreatedBy
          Value: Presidio
        - Key: SAR
          Value: SAR80002025-00153
  
  AppInstance03:
    Type: AWS::EC2::Instance
    Properties:
      DisableApiTermination: 'true'
      EbsOptimized: 'true'
      ImageId: ami-0e079fa8958305745 #INMUMPRINT01
      InstanceType: t3a.medium
      IamInstanceProfile: !Ref RoleName
      KeyName: !Ref AMZNInstanceKeyName
      NetworkInterfaces:
        - NetworkInterfaceId: eni-028995c1635b5ec8d
          DeviceIndex: 0
        # SecurityGroupIds:
        #   - sg-017ea4a4658d813f5 # AVTR-SHARED-WINDOWS-PRINT-SERVICES-APP-APS1 
        #   - sg-026d9eef340af1ffd # AVTR-WIN-SHARED-MGMT-APS1 
        #   - sg-083513d44511809fb # AVTR-BASE-SHARED-APP-APS1 
      Tags:
        - Key: Name
          Value: EC2-Shared-Core-Inmumprint-App-01-APS1
        - Key: Costcenter
          Value: 80803255
        - Key: Environment
          Value: Shared
        - Key: Application
          Value: Windows Print Services
        - Key: FunctionalArea
          Value: BusinessFunctions_IT
        - Key: Platform
          Value: AWS Infrastructure
        - Key: Compliance
          Value: None
        - Key: CreatedBy
          Value: Presidio
        - Key: SAR
          Value: SAR80002025-00153
