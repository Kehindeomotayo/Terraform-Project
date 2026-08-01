AWSTemplateFormatVersion: 2010-09-09

Description: Deploys the EC2 resources for Avantor GovCloud GCC production environment.

Resources:
  # Keypairs
  GCCProdKP:
    Type: AWS::EC2::KeyPair
    Properties:
      KeyName: GCCProdKP
      KeyType: rsa

  # Instances
  NuSilMMGCCProd01:
    Type: AWS::EC2::Instance
    DeletionPolicy: Retain
    DependsOn: GCCProdKP
    Properties:
      BlockDeviceMappings:
        - DeviceName: /dev/sda1
          Ebs:
            VolumeSize: 80
        - DeviceName: xvdf
          Ebs:
            VolumeSize: 1000
        - DeviceName: xvdg
          Ebs:
            VolumeSize: 500
      DisableApiTermination: true
      IamInstanceProfile: AmazonSSMRoleForInstancesQuickSetup
      ImageId: ami-04be5f6b04e00a0e9
      InstanceType: r5a.xlarge
      KeyName: GCCProdKP
      PrivateIpAddress: 10.26.66.5
      PropagateTagsToVolumeOnCreation: true
      SecurityGroupIds:
        - sg-0ad765e18ce4a8c08
        - sg-0a575682ea2392b15
        - sg-0ff5fd7f77fda9b97
        - sg-01c033ccc627bf371
        - sg-0b5a69a2b1ca1b1f0
        - sg-098f5c7391b08ec57
        - sg-04928b31e2774e542
        - sg-0ffb6fdea90e6f660
        - sg-06627574d8e4eaf53
        - sg-09c1562fa0c0822b3
      SubnetId: subnet-02fc568013777dfcf
      Tags:
        - Key: Name
          Value: PGOVNUSILDB02
        - Key: Costcenter
          Value: 81303005
        - Key: Environment
          Value: Gov Prod
        - Key: Application
          Value: NuSil Main Menu
        - Key: FunctionalArea
          Value: BusinessFunctions_IT
        - Key: Platform
          Value: AWS Infrastructure
        - Key: Compliance
          Value: ITAR
        - Key: SAR
          Value: 80002024-00107

  NuSilMCGCCProd01:
    Type: AWS::EC2::Instance
    DeletionPolicy: Retain
    DependsOn: GCCProdKP
    Properties:
      BlockDeviceMappings:
        - DeviceName: /dev/sda1
          Ebs:
            VolumeSize: 100
        - DeviceName: xvdf
          Ebs:
            VolumeSize: 1000
        - DeviceName: xvdg
          Ebs:
            VolumeSize: 500
      DisableApiTermination: true
      IamInstanceProfile: AmazonSSMRoleForInstancesQuickSetup
      ImageId: ami-0e57cb01995a25f08
      InstanceType: r5a.large
      KeyName: GCCProdKP
      PrivateIpAddress: 10.26.66.6
      PropagateTagsToVolumeOnCreation: true
      SecurityGroupIds:
        - sg-04a6d026fd356bd8e
        - sg-0ad765e18ce4a8c08
        - sg-04030bd83dd01f1d4
      SubnetId: subnet-02fc568013777dfcf
      Tags:
        - Key: Name
          Value: PGOVNUSILDB03
        - Key: Costcenter
          Value: 81303005
        - Key: Environment
          Value: Gov Prod
        - Key: Application
          Value: Maintenance Connect (NuSil)
        - Key: FunctionalArea
          Value: BusinessFunctions_IT
        - Key: Platform
          Value: AWS Infrastructure
        - Key: Compliance
          Value: ITAR
        - Key: SAR
          Value: 80002023-00624

  NuSilADFS01:
    Type: AWS::EC2::Instance
    DeletionPolicy: Retain
    DependsOn: GCCProdKP
    Properties:
      BlockDeviceMappings:
        - DeviceName: /dev/sda1
          Ebs:
            VolumeSize: 100
      DisableApiTermination: true
      IamInstanceProfile: AmazonSSMRoleForInstancesQuickSetup
      ImageId: ami-08a4442f69b1ab005
      InstanceType: t3a.large
      KeyName: GCCProdKP
      PrivateIpAddress: 10.26.64.10
      PropagateTagsToVolumeOnCreation: true
      SecurityGroupIds:
        - sg-04a6d026fd356bd8e
        - sg-0ad765e18ce4a8c08
      SubnetId: subnet-0e27f89987e0d71dd
      Tags:
        - Key: Name
          Value: PGOVNUSILADFS01
        - Key: Costcenter
          Value: 81303005
        - Key: Environment
          Value: Gov Prod
        - Key: Application
          Value: ComplianceWire
        - Key: FunctionalArea
          Value: BusinessFunctions_IT
        - Key: Platform
          Value: AWS Infrastructure
        - Key: Compliance
          Value: ITAR

  NuSilSysaidApp01:
    Type: AWS::EC2::Instance
    DeletionPolicy: Retain
    DependsOn: GCCProdKP
    Properties:
      BlockDeviceMappings:
        - DeviceName: /dev/sda1
          Ebs:
            VolumeSize: 100
      DisableApiTermination: true
      IamInstanceProfile: AmazonSSMRoleForInstancesQuickSetup
      ImageId: ami-0760e9298cab6667b
      InstanceType: c5.xlarge
      KeyName: GCCProdKP
      PrivateIpAddress: 10.26.65.15
      PropagateTagsToVolumeOnCreation: true
      SecurityGroupIds:
        - sg-04a6d026fd356bd8e
        - sg-0ad765e18ce4a8c08
        - sg-0958cbe5a356c6f1f
      SubnetId: subnet-014401597e4ef47c9
      Tags:
        - Key: Name
          Value: PGOVSYSAPP01
        - Key: Costcenter
          Value: 81303005
        - Key: Environment
          Value: Gov Prod
        - Key: Application
          Value: Sysaid
        - Key: FunctionalArea
          Value: BusinessFunctions_IT
        - Key: Platform
          Value: AWS Infrastructure
        - Key: Compliance
          Value: ITAR
        - Key: SAR
          Value: 80002024-00373

  NuSilSysaidDB01:
    Type: AWS::EC2::Instance
    DeletionPolicy: Retain
    DependsOn: GCCProdKP
    Properties:
      BlockDeviceMappings:
        - DeviceName: /dev/sda1
          Ebs:
            VolumeSize: 100
      DisableApiTermination: true
      IamInstanceProfile: AmazonSSMRoleForInstancesQuickSetup
      ImageId: ami-0760e9298cab6667b
      InstanceType: c5.xlarge
      KeyName: GCCProdKP
      PrivateIpAddress: 10.26.66.15
      PropagateTagsToVolumeOnCreation: true
      SecurityGroupIds:
        - sg-04a6d026fd356bd8e
        - sg-0ad765e18ce4a8c08
        - sg-0958cbe5a356c6f1f
      SubnetId: subnet-02fc568013777dfcf
      Tags:
        - Key: Name
          Value: PGOVSYSDB01
        - Key: Costcenter
          Value: 81303005
        - Key: Environment
          Value: Gov Prod
        - Key: Application
          Value: Sysaid
        - Key: FunctionalArea
          Value: BusinessFunctions_IT
        - Key: Platform
          Value: AWS Infrastructure
        - Key: Compliance
          Value: ITAR
        - Key: SAR
          Value: 80002024-00373

  NuSilDEDB01:
    Type: AWS::EC2::Instance
    DeletionPolicy: Retain
    DependsOn: GCCProdKP
    Properties:
      BlockDeviceMappings:
        - DeviceName: /dev/sda1
          Ebs:
            VolumeSize: 175
        - DeviceName: xvdf
          Ebs:
            VolumeSize: 545
      DisableApiTermination: true
      IamInstanceProfile: AmazonSSMRoleForInstancesQuickSetup
      ImageId: ami-06ab28fb70634866b
      InstanceType: m5.xlarge
      KeyName: GCCProdKP
      PrivateIpAddress: 10.26.66.67
      PropagateTagsToVolumeOnCreation: true
      SecurityGroupIds:
        - sg-04a6d026fd356bd8e
        - sg-0ad765e18ce4a8c08
        - sg-0f7e8b7daf5a69658
      SubnetId: subnet-02fc568013777dfcf
      Tags:
        - Key: Name
          Value: PGOVNSLDEDB01
        - Key: Costcenter
          Value: 80803130
        - Key: Environment
          Value: Gov Prod
        - Key: Application
          Value: Delivery Excellence Data Staging
        - Key: FunctionalArea
          Value: BusinessFunctions_IT
        - Key: Platform
          Value: AWS Infrastructure
        - Key: Compliance
          Value: ITAR
