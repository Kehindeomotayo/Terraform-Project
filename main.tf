Hi Marco , Rajesh ,

As you are aware we are working on MDR project ( Managed Detection and Response ) to replace Splunk & MSSP ( managed security service provider ) model to enhance our security detection and response capabilities. 
As part of our initiative to enhance cloud threat detection and monitoring, we are planning to integrate AWS logs (for both Avantor and NuSil environments) with Red Canary.

This integration leverages AWS CloudTrail and related telemetry, enabling visibility into account activity, API calls, IAM changes, and potential suspicious behavior across our AWS environments.   Please review the AWS integration document for more details.

We require your support on the following:

1. Prerequisites Validation
•	Confirm AWS CloudTrail is enabled in all regions (multi-region trail preferred)
•	Ensure CloudTrail is configured to log:
o	Management events (Read/Write)
o	Data events (S3, Lambda – if applicable)
•	Validate log retention and centralized logging (S3 bucket)

2. Access & Permissions
•	Identify an AWS admin who can:
o	Create and configure IAM role for Red Canary integration
o	Establish cross-account trust (if required)
•	Confirm readiness to allow Red Canary to access AWS logs via IAM role assumption

3. IAM Role Configuration
•	Create an IAM role with:
o	Read access to CloudTrail logs (S3 bucket)
o	Permissions to describe account configurations (read-only)
•	Configure trust relationship to allow Red Canary AWS account to assume the role

4. Logging & Coverage
Confirm availability of:
•	CloudTrail logs (all regions/accounts)
•	IAM activity (user/role creation, policy changes)
•	Console login activity
•	S3 access logs (if enabled)
•	GuardDuty findings (recommended, if available)

5. Multi-Account / Multi-Environment Setup
•	Confirm AWS account structure:
o	Separate accounts for Avantor and NuSil?
o	Use of AWS Organizations / centralized logging account?
•	Identify if integration needs to be:
o	Per account OR
o	Centralized via log aggregation account

6. Security & Network Considerations
•	Confirm no restrictions on:
o	IAM role assumption by external AWS account (Red Canary)
o	Access to S3 log buckets
•	Validate bucket policies allow secure external read access (least privilege)

7. Governance / Compliance
•	Confirm approval for sharing AWS telemetry with Red Canary
•	Highlight any regulatory or data residency constraints

8. Integration Readiness
•	Provide:
o	AWS Account IDs (Avantor & NuSil)
o	CloudTrail S3 bucket details
•	Share point of contact for implementation
•	Confirm if change window is required

Please review and share:
•	Owner from Platform Services team
•	Timeline for prerequisite validation and IAM role setup

Please let me know if you need a working session to complete the configuration and validation steps.


Regards,
Senthil Kumar.K
Manager - Security Incident Response
Avantor,
Coimbatore- India.
Senthilkumar.kalimuthu@avantorsciences.com
 

