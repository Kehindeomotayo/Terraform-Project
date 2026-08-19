MICROSOFT AZURE WELL-ARCHITECTED FRAMEWORK
ASSESSMENT REPORT

Current-State Review, Findings & Remediation Roadmap

Prepared for: Rajesh / Cloud Engineering Team
Platform: Microsoft Azure
Assessment Date: August 2026
Version: 1.0
Classification: Internal Use

Assessment Scope

Reliability | Security | Cost Optimization | Operational Excellence | Performance Efficiency

Assessment Approach

This assessment provides a current-state review of the Microsoft Azure environment against the Azure Well-Architected Framework.

The assessment was conducted to identify existing capabilities, configuration gaps, Microsoft recommendations, risks and opportunities for improvement.

The exercise was primarily an assessment and documentation activity. No production remediation was performed solely as a result of the findings documented in this report.

Any recommendation requiring a production configuration change, additional licensing, architecture modification or potential service impact should be validated by the appropriate technical owner and progressed through the established change-management/CAB process.

1. EXECUTIVE SUMMARY

The Microsoft Azure environment was reviewed against the five pillars of the Azure Well-Architected Framework:

Reliability
Security
Cost Optimization
Operational Excellence
Performance Efficiency

The assessment used Azure-native services and configuration information including Azure Advisor, Microsoft Defender for Cloud, Azure Policy, Microsoft Entra ID, Azure Monitor, Log Analytics, Azure Update Manager, Azure Service Health, Azure Cost Management, Recovery Services Vaults, Azure Backup, Azure Site Recovery and Azure Resource Graph.

The assessment identified a number of existing strengths as well as opportunities for improvement.

Azure Advisor reported the following scores during the assessment:

Pillar	Score / Position	Assessment
Cost Optimization	97%	Strong
Security	29%	Priority improvement area
Reliability	81%	Good with improvement opportunities
Operational Excellence	59%	Improvement required
Performance Efficiency	No active recommendations	Positive
Evidence

[INSERT SCREENSHOT – AZURE ADVISOR OVERVIEW]

Figure 1 – Azure Advisor overall assessment

Overall Assessment

The Azure environment has several important foundational capabilities already implemented, particularly around backup, monitoring, governance and cost visibility.

The principal areas requiring further maturity are:

Security posture
Disaster recovery
Operational monitoring
Patch management
Resource tagging
Cost governance
Network monitoring
Explicit outbound connectivity
Standardised alerting

Azure Advisor recommendations should not automatically be implemented. Each recommendation should first be assessed for applicability, business impact, cost, dependencies and change risk.

2. ASSESSMENT METHODOLOGY

The assessment followed the structure:

Well-Architected Requirement → Current Configuration → Evidence → Observation → Risk/Gap → Recommendation

The following Azure services and capabilities were reviewed:

Azure Advisor
Microsoft Defender for Cloud
Azure Policy
Microsoft Entra ID
Conditional Access
Azure Monitor
Activity Log
Log Analytics
Change Analysis
Azure Update Manager
Azure Service Health
Azure Resource Graph
Azure Cost Management
Azure Backup
Recovery Services Vaults
Azure Site Recovery
Virtual Machines
Availability Zones
Availability Sets
Storage redundancy
VM performance metrics
Virtual WAN / Virtual Hub
ExpressRoute monitoring
Resource tagging
3. RELIABILITY
3.1 Purpose

The Reliability pillar focuses on the ability of workloads to remain available and recover from infrastructure, application or regional failures.

The assessment reviewed:

Azure Regions
Virtual Machines
Availability Zones
Availability Sets
Azure Backup
Recovery Services Vaults
Backup Policies
Storage Redundancy
Azure Site Recovery
Recovery and Failover
3.2 Azure Regions
Current Observation

Azure resources were observed primarily within East US 2, with some Recovery Services Vault resources also present within East US.

The presence of resources in multiple Azure regions provides geographical distribution; however, this does not automatically mean individual applications are configured for multi-region disaster recovery.

Assessment

Status: CONFIGURED / REQUIRES WORKLOAD-LEVEL VALIDATION

Recommendation

Document the approved primary and disaster-recovery region for each business-critical workload.

Evidence

[INSERT SCREENSHOT – RESOURCE/VM REGION INFORMATION]

Figure 2 – Azure resource regional deployment

3.3 Virtual Machines

Multiple Azure Virtual Machines were identified during the assessment.

Examples included:

VM-Network-test-01
VMDATACORPPRODEASTUS2
vmjbprodeastus2
Windows 365-related resources
Assessment

Status: CONFIGURED

Recommendation

Maintain workload ownership and criticality information for VMs using standard tags such as:

Application
Owner
Environment
Business Criticality
Support Team
Backup Requirement
DR Requirement
Evidence

[INSERT SCREENSHOT – VIRTUAL MACHINES LIST]

Figure 3 – Azure Virtual Machine inventory

3.4 Availability Zones

Availability Zones provide physically separate datacentre locations within an Azure region.

During the assessment, VM-Network-test-01 was observed in:

Region: East US 2
Availability Zone: Zone 1

Observation

Availability Zones are being used for at least some Azure resources.

However, a single VM deployed in Zone 1 does not by itself provide multi-zone application resilience.

Assessment

Status: PARTIALLY ALIGNED

Recommendation

Identify business-critical workloads and determine whether components should be distributed across multiple Availability Zones.

Evidence

[INSERT SCREENSHOT – VM SHOWING AVAILABILITY ZONE 1]

Figure 4 – Availability Zone configuration

3.5 Availability Sets
Current Observation

No Availability Sets were identified during the assessment.

Assessment

Status: NOT CONFIGURED

This should not automatically be considered a gap because modern workloads may use Availability Zones instead.

Recommendation

For workloads that cannot use Availability Zones, determine whether Availability Sets are required to provide VM-level resilience.

Evidence

[INSERT SCREENSHOT – AVAILABILITY SETS SHOWING NO RESOURCES]

Figure 5 – Availability Sets

3.6 Azure Backup and Recovery Services Vaults

Azure Backup is being used through Recovery Services Vaults.

Four Recovery Services Vaults were identified during the assessment.

A reviewed vault showed:

Backup Items: 2
Backup Storage: Approximately 222.94 GB
Storage Redundancy: GRS

The Recovery Services Vaults also displayed a Good security level.

Assessment

Status: CONFIGURED

Recommendation

Continue validating:

Backup success
Retention
Soft Delete
Immutability requirements
Recovery testing
Business RPO/RTO requirements
Evidence

[INSERT SCREENSHOT – RECOVERY SERVICES VAULTS]

Figure 6 – Recovery Services Vault inventory

[INSERT SCREENSHOT – BACKUP ITEMS / 222.94 GB GRS]

Figure 7 – Azure Backup configuration

3.7 Backup Policies

A reviewed backup policy showed:

Schedule: Daily
Backup Time: Approximately 02:00 AM Eastern Time
Daily Retention: 30 days
Instant Restore Retention: 7 days

Weekly, monthly and yearly retention were not configured on the reviewed policy.

Assessment

Status: CONFIGURED

Recommendation

Validate retention against application and regulatory requirements rather than assuming the existing 30-day retention is appropriate for every workload.

Evidence

[INSERT SCREENSHOT – BACKUP POLICY]

Figure 8 – Azure Backup policy

3.8 Storage Redundancy

The assessment identified different redundancy configurations.

A reviewed storage account used:

Locally Redundant Storage (LRS)

Backup storage was observed using:

Geo-Redundant Storage (GRS)

Assessment

Status: CONFIGURED / WORKLOAD DEPENDENT

Recommendation

Determine redundancy requirements based on workload criticality.

LRS should not automatically be considered inadequate, but business-critical data may require ZRS, GRS or GZRS depending on availability and recovery requirements.

Evidence

[INSERT SCREENSHOT – STORAGE REDUNDANCY]

Figure 9 – Azure storage redundancy

3.9 Azure Site Recovery

Azure Site Recovery provides workload replication and disaster-recovery failover.

Current Observation

The Recovery Services Vault showed:

Replicated Items: 0

No active workload replication was evidenced during the assessment.

No Recovery Plans were identified in the reviewed scope.

Assessment

Status: DR CAPABILITY NOT EVIDENCED

Risk

Where production applications require disaster recovery, the absence of replication could result in extended recovery times following a major failure.

Recommendation

Determine workload-specific:

RTO
RPO
DR region
Replication requirements
Recovery plans
Test failover requirements

before implementing Site Recovery.

Evidence

[INSERT SCREENSHOT – SITE RECOVERY / NO REPLICATED ITEMS]

Figure 10 – Azure Site Recovery status

3.10 Reliability Conclusion

Azure Advisor reported a Reliability score of approximately 81%.

The environment has a good backup foundation and makes use of Availability Zones for some resources.

The primary improvement area identified is workload-level disaster-recovery capability and further validation of resilience architecture.

Reliability Assessment

GOOD / PARTIALLY ALIGNED

4. SECURITY
4.1 Purpose

The Security pillar focuses on protecting:

Identities
Applications
Infrastructure
Networks
Data

The assessment included:

Microsoft Defender for Cloud
Azure security recommendations
Defender CSPM
Azure Policy
Microsoft Entra ID
Conditional Access
Privileged roles
Storage security
Resource governance
4.2 Microsoft Defender for Cloud

Microsoft Defender for Cloud provides cloud security posture management and workload-protection capabilities.

Current Observation

Defender for Cloud is available within the Azure environment.

However, advanced Defender CSPM capabilities were identified as requiring additional enablement/licensing.

Assessment

Status: PARTIALLY CONFIGURED

Recommendation

Do not enable Defender CSPM without approval.

First assess:

Security benefit
Existing security tooling
Number of protected resources
Monthly cost
Licensing
Business requirement
Evidence

[INSERT SCREENSHOT – DEFENDER FOR CLOUD OVERVIEW / CSPM]

Figure 11 – Microsoft Defender for Cloud

4.3 Security Recommendations

Azure security recommendations were identified during the assessment.

Azure Advisor reported a Security score of approximately:

29%

This was the lowest Advisor score across the assessed categories.

Assessment

Status: PRIORITY IMPROVEMENT AREA

Recommendation

Security recommendations should be reviewed by severity and applicability.

High-priority areas should include:

Internet exposure
Identity
Privileged access
Encryption
Vulnerability findings
Network security
Defender recommendations
Evidence

[INSERT SCREENSHOT – DEFENDER SECURITY RECOMMENDATIONS]

Figure 12 – Azure security recommendations

4.4 Azure Policy Compliance

Azure Policy was reviewed to assess governance and compliance.

The captured evidence showed:

Overall Resource Compliance: 12%

Compliant Resources: 6 of 52

Non-Compliant Resources: 46 of 52

The Policy compliance view also showed approximately:

1,133 policy evaluation results

of which:

965 were compliant

and:

168 were non-compliant

Five reviewed initiatives were shown as non-compliant.

Important Clarification

The 52 resources and 1,133 policy evaluation results represent different measurements and should not be compared as though they are the same count.

Assessment

Status: NEEDS IMPROVEMENT

Recommendation

Review non-compliance by:

Policy
Initiative
Subscription
Resource
Severity
Business applicability

Then separate genuine remediation requirements from approved exemptions.

Evidence

[INSERT SCREENSHOT – AZURE POLICY COMPLIANCE]

Figure 13 – Azure Policy compliance

4.5 Microsoft Entra ID

Microsoft Entra ID was reviewed as the Azure identity platform.

Observation

Identity and administrative role information was accessible.

The assessment identified approximately:

140 privileged role assignments

while the portal displayed guidance recommending significantly fewer privileged role assignments.

Assessment

Status: REVIEW REQUIRED

The existence of 140 assignments does not automatically mean all assignments are inappropriate.

Recommendation

Perform a privileged-access review covering:

Permanently assigned privileged roles
Eligible roles
PIM
Dormant administrators
Service accounts
Emergency access accounts
Least privilege
Evidence

[INSERT SCREENSHOT – MICROSOFT ENTRA ROLES AND ADMINISTRATORS]

Figure 14 – Microsoft Entra privileged role assignments

4.6 Conditional Access / Identity Protection
Current Observation

The account used for the assessment did not have sufficient permissions to fully view Conditional Access and Identity Protection information.

Assessment

Status: NOT FULLY VALIDATED

This should not be recorded as "Conditional Access is not configured."

The correct conclusion is that the assessment account could not validate the configuration.

Recommendation

An authorised Entra administrator should validate:

MFA
Administrator MFA
Conditional Access
Legacy authentication
Guest access
Risk-based policies
Emergency access exclusions
Evidence

The access-denied screenshot may be retained in an appendix if required, but it is not necessary in the main report.

4.7 Security Conclusion

Azure has foundational security controls, but security represents the largest improvement area identified through Azure Advisor.

Security Assessment

NEEDS IMPROVEMENT / FURTHER VALIDATION

5. COST OPTIMIZATION
5.1 Purpose

Cost Optimization ensures Azure resources provide required business value without unnecessary expenditure.

The assessment reviewed:

Cost Management
Cost Analysis
Budgets
Cost Alerts
Azure Advisor
Savings Plans
Reservations
VM rightsizing
Resource tagging
5.2 Cost Management

Cost Management was available for the reviewed subscriptions.

A captured July 2026 view for landingzone-hub showed approximately:

$1,808

with an average daily cost of approximately:

$61.37

Evidence

[INSERT SCREENSHOT – COST ANALYSIS]

Figure 15 – Azure Cost Analysis

5.3 Budgets and Cost Alerts
Observation

No budget was observed for the reviewed scope.

The Cost Alerts page showed:

No Alerts to display

Assessment

Status: NEEDS IMPROVEMENT

Recommendation

Establish budgets and alerts at appropriate subscription/workload levels.

Example alert thresholds:

50%
75%
90%
100%
Evidence

[INSERT SCREENSHOT – BUDGET]

[INSERT SCREENSHOT – COST ALERTS / NO ALERTS TO DISPLAY]

Figure 16 – Azure Cost governance

5.4 Azure Advisor Cost Recommendations

Azure Advisor reported a Cost score of approximately:

97%

Advisor identified potential savings opportunities including:

Azure Savings Plan

Estimated annual savings:

Approximately $1,953

Cosmos DB Reserved Capacity

Estimated annual savings:

Approximately $84

VM Rightsizing / Shutdown

An additional underutilised VM opportunity of approximately:

$1,620 annually

was also observed during the assessment.

Assessment

Status: STRONG WITH OPTIMIZATION OPPORTUNITIES

Recommendation

Do not purchase reservations or Savings Plans solely because Advisor recommends them.

Validate:

Historical utilisation
Workload stability
Future demand
Commitment duration
Application lifecycle
Evidence

[INSERT SCREENSHOT – ADVISOR COST RECOMMENDATIONS]

Figure 17 – Azure Advisor Cost recommendations

5.5 Cost Optimization Conclusion

Azure currently demonstrates a strong Advisor cost position.

The principal governance improvements are:

Budgets
Cost alerts
Tagging
Cost ownership
Regular rightsizing
Cost Assessment

STRONG / PARTIALLY ALIGNED

6. OPERATIONAL EXCELLENCE
6.1 Purpose

Operational Excellence focuses on the ability to effectively:

Monitor
Operate
Maintain
Troubleshoot
Patch
Automate

Azure workloads.

6.2 Azure Monitor

Azure Monitor was reviewed and provides access to:

Metrics
Alerts
Logs
Change Analysis
VM Insights
Network Insights
Application Insights
Workbooks
Assessment

Status: CONFIGURED

Evidence

[INSERT SCREENSHOT – AZURE MONITOR OVERVIEW]

Figure 18 – Azure Monitor

6.3 Activity Log

Azure Activity Log records Azure control-plane activity.

The assessment confirmed that administrative and resource events were visible.

Assessment

Status: CONFIGURED

Evidence

[INSERT SCREENSHOT – ACTIVITY LOG]

Figure 19 – Azure Activity Log

6.4 Log Analytics

A Log Analytics workspace named:

ServicesHub-OnDemandAssessments

was identified.

Approximately 31 days retention was observed.

Assessment

Status: CONFIGURED / RETENTION REQUIRES VALIDATION

Recommendation

Confirm whether 31 days satisfies:

Operational troubleshooting
Security monitoring
Audit
Compliance
Evidence

[INSERT SCREENSHOT – LOG ANALYTICS WORKSPACES]

Figure 20 – Log Analytics

6.5 Change Analysis

Azure Change Analysis was operational.

Approximately:

1,013 changes

were visible within the selected 24-hour period.

Assessment

Status: CONFIGURED

Evidence

[INSERT SCREENSHOT – CHANGE ANALYSIS]

Figure 21 – Azure Change Analysis

6.6 Azure Update Manager

Six machines were discovered.

The captured evidence indicated:

3 unsupported
3 without update assessment data
Periodic assessment disabled across the reviewed machines
Assessment

Status: PARTIALLY CONFIGURED

Recommendation

Investigate:

Unsupported operating systems
Periodic assessment
Patch scheduling
Maintenance windows
Reboot handling
Compliance reporting
Evidence

[INSERT SCREENSHOT – AZURE UPDATE MANAGER]

Figure 22 – Azure Update Manager

6.7 Automation Accounts

No Azure Automation Accounts were identified.

Assessment

Status: NOT CONFIGURED

This should not automatically be classified as a defect.

Automation should be introduced where there is a defined operational requirement.

Evidence

[INSERT SCREENSHOT – AUTOMATION ACCOUNTS / NO RESULTS]

Figure 23 – Azure Automation

6.8 Service Health

No active Azure service issues were observed at the time of assessment.

Several Health Advisories were present.

Approximately:

6 Health Advisories

were observed.

Assessment

Status: MONITORING AVAILABLE / ADVISORIES REQUIRE TRACKING

Evidence

[INSERT SCREENSHOT – SERVICE HEALTH]

[INSERT SCREENSHOT – HEALTH ADVISORIES]

Figure 24 – Azure Service Health

6.9 Azure Advisor Operational Excellence

Azure Advisor reported an Operational Excellence score of approximately:

59%

Six active recommendations were identified.

Recommendation	Impact	Affected
Enable Trusted Launch for existing Generation 2 VMs	High	4 of 5
Switch to Azure Monitor-based alerts for Backup	Medium	4 of 4 vaults
Enable VM Insights	Medium	5 of 6 VMs
Monitor Virtual Hub health	Medium	1 of 1
Configure Connection Monitor for ExpressRoute	Medium	2 of 2
Add explicit outbound method	Medium	597 active affected resources shown
Evidence

[INSERT SCREENSHOT – ALL SIX OPERATIONAL EXCELLENCE RECOMMENDATIONS]

Figure 25 – Azure Advisor Operational Excellence

6.10 Trusted Launch

Trusted Launch was the High-impact Operational Excellence recommendation.

Recommendation

Before implementation, validate:

VM generation
Secure Boot
vTPM
OS compatibility
Application impact
Rollback procedure

Implement through CAB/change control where applicable.

Evidence

[INSERT SCREENSHOT – TRUSTED LAUNCH RECOMMENDATION]

Figure 26 – Trusted Launch recommendation

6.11 Backup Monitoring

Four Recovery Services Vaults were recommended for migration to Azure Monitor-based alerts.

Recommendation

Review existing alerting and Action Groups before implementing.

Evidence

[INSERT SCREENSHOT – BACKUP ALERT RECOMMENDATION]

Figure 27 – Backup monitoring recommendation

6.12 VM Insights

Five of six applicable VMs were identified.

Recommendation

Review:

Azure Monitor Agent
Data Collection Rules
Log Analytics
Data ingestion
Monitoring cost

before enablement.

Evidence

[INSERT SCREENSHOT – VM INSIGHTS RECOMMENDATION]

Figure 28 – VM Insights recommendation

6.13 ExpressRoute Connection Monitor

Two ExpressRoute circuits were identified.

Recommendation

Coordinate with the network team to determine appropriate monitoring endpoints before configuration.

Evidence

[INSERT SCREENSHOT – CONNECTION MONITOR FOR EXPRESSROUTE]

Figure 29 – ExpressRoute monitoring recommendation

6.14 Explicit Outbound Connectivity

Approximately:

597 active resources

were shown under the explicit outbound recommendation.

Many were associated with:

windows365-prod

and appeared to be Windows 365 / Cloud PC network interfaces.

Assessment

Status: ARCHITECTURE REVIEW REQUIRED

Important Recommendation

Do not modify hundreds of individual NICs.

Review:

Subnets
Route tables
NAT Gateway
Azure Firewall
Load Balancer outbound rules
Windows 365 ownership
Microsoft-managed resources

before deciding on remediation.

Evidence

[INSERT SCREENSHOT – 597 EXPLICIT OUTBOUND RESOURCES]

Figure 30 – Explicit outbound recommendation

7. PERFORMANCE EFFICIENCY
7.1 Azure Advisor

Azure Advisor reported:

You are following all of our performance recommendations for the selected subscriptions and resources.

No active Performance recommendations were shown.

Assessment

Status: CURRENTLY ALIGNED

Evidence

[INSERT SCREENSHOT – ADVISOR PERFORMANCE]

Figure 31 – Azure Advisor Performance

7.2 VM Performance Monitoring

Performance metrics were reviewed for sample VMs.

Metrics included:

CPU
Memory
Disk Read
Disk Write
Network
Availability
Evidence

[INSERT CPU SCREENSHOT]

Figure 32 – VM CPU utilisation

[INSERT MEMORY SCREENSHOT]

Figure 33 – VM memory availability

[INSERT DISK READ SCREENSHOT]

Figure 34 – Disk read activity

[INSERT DISK WRITE SCREENSHOT]

Figure 35 – Disk write activity

[INSERT NETWORK SCREENSHOT]

Figure 36 – Network activity

7.3 Performance Observation

The sampled VM metrics did not demonstrate sustained CPU, memory, disk or network saturation during the captured periods.

Azure Advisor also reported no active Performance recommendations.

Recommendation

Do not make production rightsizing decisions based on a single 24-hour view.

Use approximately 7–30 days of representative utilisation data before resizing.

Performance Assessment

CURRENTLY ALIGNED / CONTINUE MONITORING

8. OVERALL ASSESSMENT
Pillar	Position	Priority
Reliability	Good / Partially Aligned	Medium
Security	Needs Improvement	High
Cost Optimization	Strong	Low/Medium
Operational Excellence	Needs Improvement	High
Performance Efficiency	Currently Aligned	Low
9. PRIORITISED REMEDIATION ROADMAP
Priority 1 – Security
Review Defender findings
Review Azure Policy non-compliance
Validate Conditional Access/MFA with authorised Entra administrator
Review privileged role assignments
Evaluate Defender CSPM
Review storage security controls
Priority 2 – Operational Excellence
Trusted Launch
VM Insights
Backup alerts
Virtual Hub monitoring
ExpressRoute Connection Monitor
Explicit outbound architecture
Update Manager
Priority 3 – Reliability
Define RTO/RPO
Determine Site Recovery requirements
Review Availability Zone architecture
Validate backup recovery
Test restore/failover procedures
Priority 4 – Governance and Cost
Introduce tagging standard
Configure budgets
Configure cost alerts
Evaluate Savings Plans/Reservations
Establish cost ownership
Priority 5 – Performance
Continue Azure Monitor monitoring
Establish 7–30 day baseline
Rightsize only where supported by long-term evidence
10. CHANGE / CAB APPROACH

For each recommendation:

1. Validate applicability

Confirm the recommendation applies to the resource.

2. Identify owner

Application, Cloud, Security, Network, Windows 365, Database, etc.

3. Assess risk and cost

Determine production impact, downtime, dependencies and licensing.

4. Capture pre-change state

Record current configuration.

5. Create implementation plan

Document exact steps.

6. Create rollback plan

Document recovery steps.

7. CAB approval

Submit production-impacting changes.

8. Implement

Make the approved change.

9. Validate

Confirm service, monitoring, connectivity and security.

10. Close

Attach evidence and update the remediation tracker.

11. CONCLUSION

The Azure Well-Architected Framework assessment established a current-state baseline across Reliability, Security, Cost Optimization, Operational Excellence and Performance Efficiency.

The environment already contains several important foundational capabilities, including Azure Backup, Recovery Services Vaults, Azure Monitor, Log Analytics, Azure Policy, Cost Management and Azure Advisor.

The assessment identified Security and Operational Excellence as the principal areas requiring improvement, while Cost Optimization and Performance Efficiency currently demonstrate stronger positions.

The next phase should therefore focus on controlled remediation rather than additional discovery.

Recommendations should be validated with the appropriate technical owners and prioritised according to business risk and workload criticality.

Changes affecting production workloads, network connectivity, security configuration or paid services should be progressed through the organisation's established change-management and CAB process.

The assessment should subsequently be repeated periodically to measure improvement and identify new recommendations as the Azure environment evolves.
