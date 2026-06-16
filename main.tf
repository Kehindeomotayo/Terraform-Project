Break Glass Review Update
Good morning everyone.
I had a review session with the AWS Security team regarding our Break Glass implementation.
Overall, AWS's feedback was positive. They stated that the design demonstrates a mature security posture and has strong controls around isolation, authorization, auditing, and compliance.
The review covered our break-glass implementation across the Production, Shared, VDI, and Network accounts.

What AWS Liked
AWS highlighted several strengths in the current design:
Per-account isolation of break-glass users.
MFA enforcement.
Two-person approval process.
Read-only access by default.
CloudTrail auditing.
SNS alerting.
GuardDuty monitoring.
Team-specific permissions.
Quarterly reviews and compliance checks.
Post-incident review process.
AWS considered these strong security controls and did not identify any major security concerns.

Discussion Around Separate AWS Account
One of the main discussions was around AWS's recommendation to use a dedicated Break Glass AWS account.
Their recommendation was:
Create one dedicated Break Glass account.
Create break-glass users in that account.
Use AssumeRole into Production, Shared, VDI and Network accounts.
Deploy the roles using CloudFormation StackSets.
The benefit from AWS's perspective is:
Easier management.
Easier monitoring.
Easier scaling.
Centralized administration.
My response was that we intentionally chose not to depend on a centralized authentication model.
Our concern is that during a major outage:
AWS Identity Center (SSO) may be unavailable.
Federation services may be unavailable.
Authentication APIs may be unavailable.
If our emergency access depends on a centralized account and role assumption, then that becomes another dependency during an outage.
For that reason, we created local break-glass users directly inside each AWS account.
This means:
Production can be accessed independently.
Shared can be accessed independently.
VDI can be accessed independently.
Network can be accessed independently.
Even if SSO or federation services are unavailable.
AWS acknowledged the reasoning and identified account isolation as one of the strengths of the current design.
At this stage I am not recommending changing the architecture.

AWS Recommendations
1. Automated Session Expiry
Current state:
bg-admin enables access.
bg-admin manually disables access after the incident.
AWS recommendation:
EventBridge detects activation.
Lambda automatically disables access after four hours.
SNS notification sent.
My response:
We intentionally designed the solution to be manual because Break Glass is intended for worst-case outage scenarios and we wanted to minimize dependencies on automation.
However, AWS recommended automation as an additional safeguard.
Documentation update:
Add Automated Session Expiry recommendation.

2. Hardware Security Keys
Current state:
Virtual MFA.
AWS recommendation:
Use FIDO2 hardware security keys.
Store them securely for emergency use.
Benefit:
No dependency on mobile devices.
Faster emergency access.
Stronger MFA security.
Documentation update:
Add Hardware Security Key recommendation.

3. Level 2 Containment Access
Current state:
Break Glass access is read-only.
AWS concern:
If an active attack is discovered, the team cannot:
Stop EC2 instances.
Remove security group rules.
Disable compromised accounts.
AWS recommendation:
Create:
Level 1
Read-only investigation.
Level 2
Emergency containment actions.
With:
Additional approvals.
Short-duration access.
Full audit logging.
SNS alerts.
Documentation update:
Add Level 2 Containment Escalation section.

4. MFA Clarification
AWS initially interpreted the documentation as MFA being configured during an incident.
I clarified that our intention is:
MFA is pre-configured.
MFA is tested before any incident.
MFA devices already exist before emergency use.
Documentation update:
Clarify that MFA is pre-configured and validated before incidents.

5. Password Vault Independence
AWS recommended validating that the password vault storing break-glass credentials remains available even if SSO is unavailable.
Documentation update:
Add vault dependency validation.

6. Communication Channel Validation
AWS noted that if Microsoft services become unavailable:
Teams may be unavailable.
Outlook may be unavailable.
Recommendation:
Have a secondary communication method such as:
SMS
Phone bridge
Emergency call process
Documentation update:
Add communication fallback procedure.

7. GuardDuty Validation
AWS recommended verifying that all GuardDuty protection plans are enabled, including:
S3 Protection
EKS Protection
Lambda Protection
RDS Protection
Malware Protection
Runtime Monitoring
Documentation update:
Add GuardDuty verification checklist.

8. SSO Failure Drills
AWS recommended periodically simulating an actual SSO outage.
This validates:
Break Glass access.
MFA.
Alerts.
Communication procedures.
Documentation update:
Add annual SSO outage testing procedure.

9. AWS Security Incident Response
AWS recommended enabling AWS Security Incident Response if not already enabled.
Benefits:
Direct AWS security expert involvement during incidents.
Included with Enterprise Support.
Action:
Verify whether the service is already enabled.

Documentation Updates Planned
I will update the document to include:
Clarification that MFA is pre-configured.
Automated Session Expiry recommendation.
Hardware Security Key recommendation.
Level 2 Containment Escalation process.
Password Vault Independence validation.
Communication fallback procedure.
GuardDuty verification checklist.
SSO outage testing procedure.
AWS Security Incident Response recommendation.

Conclusion
AWS did not identify any major security concerns with the current design.
Their feedback was primarily focused on operational maturity and future enhancements.
My recommendation is to keep the current per-account break-glass architecture because it provides account isolation and does not depend on SSO or centralized authentication during an outage, while incorporating the AWS recommendations into the documentation and future roadmap.

