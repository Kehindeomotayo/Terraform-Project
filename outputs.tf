Break Glass Access – Emergency AWS Login System
Overview

Break Glass Access is an emergency login mechanism used only when normal access (AWS SSO or IAM roles) is unavailable.

Each AWS account (Prod, Shared, VDI, Network) contains local IAM break-glass users.

Break-glass access is:

Restricted
MFA-enforced
Fully monitored
Temporarily enabled/disabled by bg-admin

Use only during real emergencies.

When to Use

Break-glass access is allowed only in the following scenarios:

Loss of IAM or administrative access
AWS SSO or identity provider outage
Critical AWS service outage impacting access

Not allowed for routine use.

Governance & Approval

Break-glass activation requires dual authorization:

Request Initiator: TBD
Approver: TBD

No single user can enable access alone.

Ownership
bg-admin is owned by the Security Team
Platform/Monitoring/Server/Network teams request access
Security team approves and audits usage
How It Works
bg-admin enables console login
User logs in with temporary password
User must configure MFA
User gains restricted read-only access
bg-admin disables access after incident
Access Scope

Break-glass users:

Can investigate (read-only)
Cannot modify resources

Future improvement:

Replace AWS ReadOnlyAccess with scoped custom policies
MFA Enforcement
MFA is required before any action
Applies to all break-glass users including bg-admin
IP Restriction
Access allowed only from corporate/VPN IPs
All source IPs logged and monitored
Audit Logging
AWS CloudTrail enabled in all accounts
Logs include:
Console logins
API actions
MFA usage

Logs are immutable and validated.

Alerts

Alerts triggered on:

Console login
IAM activity

Sent to Security Team for validation.

Session Control
Maximum session duration: 4 hours (recommended)
Extensions require re-approval
Activation & Deactivation
Access enabled only during incidents
Access disabled immediately after
All actions linked to incident ticket
Communication Plan

During incidents:

Primary: Email
Secondary: Slack/Teams
Fallback: Phone/escalation
Password Management
Passwords generated on-demand
Not reused
Disabled after incident
Break-Glass Drills
Conduct quarterly tests
Validate:
Login
MFA
Alerts
Access flow
Periodic Validation

Quarterly checks:

User access review
MFA validation
Remove stale users
Post-Incident Process

After usage:

Disable access
Review CloudTrail logs
Validate actions
Document findings
Compliance Alignment

Supports:

ISO 27001
SOC 2
PCI DSS
Security Recommendations Roadmap
🔴 Critical
Enforce MFA before all actions
Require MFA for bg-admin
Dual authorization
Replace ReadOnlyAccess
Enable CloudTrail immutability
🟡 High
SLA definition
Session limits
Incident declaration
Backup communication
IP allowlisting
🟢 Medium
Quarterly drills
Password rotation automation
GuardDuty & Config
Compliance mapping
Post-incident review
