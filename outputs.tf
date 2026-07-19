Hi Team,

Here’s a summary of the EC2 right-sizing activities.

The following servers were resized manually through the EC2 console because the CloudFormation Change Set showed Replacement: Conditional for the EC2 instance and the associated VolumeAttachment. When reviewing the property-level changes, the only difference I could see was the InstanceId being displayed as {{changeSet:KNOWN_AFTER_APPLY}}. To avoid any unexpected changes during the stack update, I resized these instances manually instead.

EC2-MFG-Prod-Ignition-App-01 (MFGProdInfraStack)
EC2-Prod-EpicorManaged-App-01 (MFGProdInfraStack)
EC2-Prod-Hyperion-Foundation-APP01 (HyperionHFMProdInfraStack)
EC2-Prod-Hyperion-Foundation-APP02 (HyperionHFMProdInfraStack)
EC2-Prod-Hyperion-HFM-APP01 (HyperionHFMProdInfraStack)
EC2-Sec-Shared-CyberArk-App-01 (CyberArkSharedInfraStack)
EC2-Sec-Shared-CyberArk-App-02 (CyberArkSharedInfraStack)
EC2-Windows-Shared-TS-App-01 (ToolsServerSharedInfraStack)
EC2-ERP-Prod-Sage-App-01 (SageProdInfraStack)

All other EC2 instances included in the right-sizing effort were resized successfully by executing their CloudFormation Change Sets.

Please let me know if you need any additional details or screenshots from the Change Sets.

Thanks.
