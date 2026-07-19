Hi Team,

Below is a summary of the EC2 right-sizing activities completed.

Resized manually through the EC2 Console

The following instances were resized manually because the CloudFormation Change Set showed Replacement: Conditional for the EC2 instance and associated VolumeAttachment resources. The property-level differences primarily showed the InstanceId resolving to {{changeSet:KNOWN_AFTER_APPLY}}, so to avoid any potential unintended infrastructure changes, these instances were resized directly from the EC2 console.

CloudFormation Stack	EC2 Instance(s)
MFGProdInfraStack	EC2-MFG-Prod-Ignition-App-01, EC2-Prod-EpicorManaged-App-01
HyperionHFMProdInfraStack	EC2-Prod-Hyperion-Foundation-APP01, EC2-Prod-Hyperion-Foundation-APP02, EC2-Prod-Hyperion-HFM-APP01
CyberArkSharedInfraStack	EC2-Sec-Shared-CyberArk-App-01, EC2-Sec-Shared-CyberArk-App-02
ToolsServerSharedInfraStack	EC2-Windows-Shared-TS-App-01
SageProdInfraStack	EC2-ERP-Prod-Sage-App-01
Resized through CloudFormation

The remaining EC2 instances were resized by executing their CloudFormation Change Sets, as the updates did not present concerns requiring manual intervention.

Please let me know if you need any additional details or screenshots from the Change Sets.

Thanks,
