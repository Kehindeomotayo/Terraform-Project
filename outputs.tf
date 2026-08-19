Azure Well-Architected Assessment

Current-State Review, Evidence Pack and Remediation Roadmap

Prepared for: Cloud / Platform Engineering Leadership
Assessment evidence gathered: July-August 2026





Azure Advisor overview used as the consolidated pillar-level baseline.


Azure Well-Architected Assessment | Internal Working Document | August 2026

1. Executive Summary

This assessment reviews the current Azure platform against the five Azure Well-Architected pillars: Cost Optimization, Security, Reliability, Operational Excellence and Performance Efficiency. The review is evidence-led and uses Azure Advisor, Defender for Cloud / security posture views, Azure Policy and governance views, Service Health, Resource Graph, virtual-machine configuration, Storage Center and Azure Monitor metrics. Selected AWS screenshots are retained only as a cross-cloud maturity reference and are not treated as Azure evidence.

Pillar

Observed position

Assessment

Cost Optimization

Advisor score 97%; 2 active cost recommendations affecting 3 resources

Strong; address remaining recommendations and improve allocation/tagging discipline

Security

Advisor score 29%; 44 active security recommendations affecting 62 resources

Priority improvement area

Reliability

Advisor score 81%; 31 active reliability recommendations affecting 45 resources

Generally established, with resilience gaps to close

Operational Excellence

Advisor score 59%; 6 active recommendations; 642/761 active resources shown

Partially mature; monitoring and platform operations need standardisation

Performance Efficiency

Advisor reports all performance recommendations followed

Strong point-in-time position; continue trend-based validation

Overall conclusion: the environment has a solid Azure management foundation and good cost/performance signals, but the assessment should not be presented as “complete compliance.” Security posture and operational standardisation are the main remediation themes. The Advisor scores are directional service signals, not a substitute for a full control-by-control audit.

2. Scope and Methodology

The review covered the Azure tenant/subscription scope visible in the supplied evidence, including management/governance services, virtual machines, networking, storage, monitoring, health alerts and Advisor recommendations. Screenshots were captured from the Azure portal and reviewed as point-in-time evidence. Where a metric was sampled over 24 hours, conclusions are limited to that window.

3. Environment and Resource Inventory

Resource Graph and portal inventory views were used to establish what is deployed and to support scope validation. The supplied VM inventory shows six virtual machines in the viewed compute scope. Storage Center shows six managed disks: four standard and two premium, with three attached and three reserved; all six use LRS in the displayed view.



Azure Resource Graph Explorer used for subscription/resource inventory queries.



Storage Center disk inventory: six disks, standard/premium mix, attached/reserved state and LRS redundancy.

4. Cost Optimization Assessment

Azure Advisor reports a 97% Cost score with two active cost recommendations affecting three resources. This indicates that the assessed scope is close to Microsoft Advisor guidance for cost, while still leaving specific optimisation actions to validate. Cost governance should also include ownership tags, budget/forecast review, rightsizing based on longer-term utilisation, and lifecycle controls for unused resources.

Review both remaining Advisor cost recommendations and record accept/remediate/waive decisions.

Use 7-30 day utilisation windows before VM rightsizing; avoid decisions based only on a 24-hour sample.

Enforce a minimum tagging standard such as Application, Owner, Environment, CostCenter and BusinessService where organisational policy allows.

Review unattached/reserved disks, snapshots and idle resources on a recurring basis.



Advisor overview: Cost score 97%, with two active cost recommendations affecting three resources.

5. Security Assessment

Security is the most significant improvement area in the evidence set. Advisor reports a 29% Security score with 44 active security recommendations affecting 62 resources. Earlier portal evidence also shows security/governance configuration being reviewed across policy, Defender/security posture and identity controls. The low Advisor score should drive a prioritised remediation backlog rather than a blanket conclusion that the platform is insecure; recommendations must be triaged by severity, applicability, compensating controls and workload criticality.

Triage high-severity Defender/Advisor recommendations first and assign accountable owners and target dates.

Validate Defender for Cloud plans and coverage at the appropriate management-group/subscription scope.

Review Azure Policy initiatives and non-compliance, especially controls for secure transfer, network exposure, logging, encryption and tagging.

Validate Entra Conditional Access/MFA coverage for privileged and standard administrative access, including emergency-access exclusions and monitoring.

For VMs, review Trusted Launch applicability, encryption-at-host requirements, patching, endpoint protection and network exposure.



Azure security posture / recommendation evidence reviewed during the assessment.



Security recommendation detail used to identify remediation opportunities.

6. Reliability Assessment

Advisor reports an 81% Reliability score with 31 active reliability recommendations affecting 45 resources. Service Health alerting is configured for the landing-zone hub and targets VPN Gateway service-health events in East US and East US 2. VM evidence also shows availability and platform metrics. These are positive controls, but the active reliability recommendations should be reviewed for redundancy, backup, zone design, connectivity and recovery readiness.

Review all 31 reliability recommendations and classify them by production impact.

Validate backup policy, restore testing and recovery objectives for critical workloads.

Confirm zone/region resilience for critical compute and network components rather than relying only on single-instance availability.

Retain Service Health alerts and verify action-group routing/escalation.

Review VPN/ExpressRoute resiliency and monitor connectivity health.



Advisor overview: Reliability score 81% and 31 active reliability recommendations.



Azure Service Health activity-log alert for VPN Gateway-related service-health events.



VM overview showing availability, CPU and disk telemetry available in the portal.

7. Operational Excellence Assessment

Operational Excellence is partially mature. Advisor reports a 59% score and six active recommendations. The recommendation list highlights concrete platform operations gaps: Trusted Launch for existing VMs, migration to Azure Monitor-based backup alerts, VM Insights enablement, Virtual Hub health monitoring, ExpressRoute Connection Monitor and explicit outbound connectivity for network interfaces. These recommendations are directly actionable and should form the first operational backlog.

Recommendation observed

Impact / evidence

Recommended treatment

Enable Trusted Launch foundational excellence and modern security for existing VMs

High; 4 of 5 VMs shown

Assess compatibility and remediate through controlled change

Switch to Azure Monitor based alerts for backup

Medium; 4 of 4 Recovery Services vaults

Standardise alerting and retire legacy alert path

Enable VM Insights for virtual machines

Medium; 5 of 6 VMs

Enable where supported and route data to agreed monitoring workspace

Monitor health for virtual hubs

Medium; 1 of 1 Virtual Hubs

Create health/metric alerts and operational runbook

Configure Connection Monitor for ExpressRoute

Medium; 2 of 2 circuits

Implement end-to-end connectivity monitoring

Add explicit outbound method to disable default outbound

Medium; 629 of 974 network interfaces

Plan migration to explicit outbound/NAT design; prioritise supported production networks



Advisor Operational Excellence: six active recommendations and affected-resource counts.

8. Performance Efficiency Assessment

Azure Advisor shows no active Performance recommendations for the selected scope, which is a strong point-in-time signal. Azure Monitor evidence demonstrates visibility into CPU-related metrics, disk I/O and network traffic for selected VMs. For VM-Network-test-01, the captured 24-hour views show bursty disk and network activity rather than sustained saturation. For VMDATACORPPRODEASTUS2, disk read/write and network-in metrics are available; CPU-credit charts contain no visible datapoints, so they should be documented as “no datapoints observed / potentially not applicable” rather than interpreted as a fault.

Keep Advisor performance recommendations under recurring review.

Use 7-30 days of CPU, memory (via guest/VM Insights), disk latency/IOPS/throughput and network metrics for rightsizing decisions.

Create alerts for sustained threshold breaches, not isolated spikes.

Avoid deprecated metrics such as “Network In Billable (Deprecated)” for future baselines; use supported network metrics.



Advisor Performance view: no active performance recommendations for the selected subscriptions/resources.



VM-Network-test-01 CPU Credits Consumed over the displayed 24-hour period.



VM-Network-test-01 Disk Read Bytes: bursty I/O with several short peaks.



VM-Network-test-01 Disk Write Bytes: bursty writes rather than sustained saturation.



VMDATACORPPRODEASTUS2 Disk Read Bytes monitoring evidence.



VMDATACORPPRODEASTUS2 Disk Write Bytes: approximately 17.1 GiB shown for the displayed period.



VMDATACORPPRODEASTUS2 Network In Total monitoring evidence.

9. Governance, Tagging and Monitoring Observations

The assessment evidence shows active use of Resource Graph, Azure Policy/governance views, Advisor and Azure Monitor. This is the correct tooling foundation for a scalable Azure control framework. The next maturity step is consistency: common policy assignment scope, mandatory ownership metadata, diagnostic settings, central log retention, alert routing and exception governance.

Define and publish a minimum Azure resource-tag standard.

Use Azure Policy to audit or enforce required controls where operationally safe.

Centralise Activity Logs and resource diagnostic logs in the approved Log Analytics/SIEM architecture.

Document alert ownership, severity mapping, escalation paths and maintenance-window handling.

Schedule a monthly Advisor/Defender/Policy review with tracked remediation decisions.



Resource/governance inventory evidence supporting control standardisation.

10. AWS Baseline / Azure Parity Reference

The supplied AWS screenshots are useful as a maturity comparator only. They show controls already familiar to the organisation, including Compute Optimizer rightsizing findings, EC2 status checks, IMDSv2 enforcement, SSM instance-profile usage and controlled termination/decommission activity. The Azure target should achieve equivalent outcomes using Azure-native controls rather than duplicating AWS implementation details.



AWS comparison: EC2 instance with Compute Optimizer “Over-provisioned” finding, IMDSv2 required and SSM instance profile.



AWS comparison: EC2 system, instance and EBS status checks passing.



AWS comparison: controlled decommission evidence after termination protection removal.

11. Prioritised Remediation Roadmap

Priority

Timeframe

Actions

P1 - Security

0-30 days

Triage 44 security recommendations; address high severity; validate Defender coverage, Conditional Access/MFA, critical Policy non-compliance and exposed resources.

P1 - Operations

0-30 days

Move backup alerting to Azure Monitor; establish owners/action groups; implement Virtual Hub and ExpressRoute monitoring.

P2 - Platform hygiene

30-60 days

Enable VM Insights where appropriate; assess Trusted Launch; standardise diagnostic settings, tags and log retention.

P2 - Networking

30-90 days

Plan explicit outbound connectivity and removal of reliance on default outbound access; validate resilient egress design.

P3 - Optimisation

Ongoing

Close remaining cost/reliability recommendations; use 7-30 day performance trends for rightsizing; review Advisor monthly.

12. Recommended Target State

The target state is an Azure platform where management-group policy defines the baseline, Defender for Cloud provides continuous security posture management, Azure Monitor/Log Analytics provides central observability, Service Health and workload alerts route through owned action groups, identity is protected by Conditional Access/MFA, networking uses explicit and resilient connectivity, and Advisor recommendations are reviewed through a documented operational cadence. Exceptions should be time-bound, owned and auditable.

13. Assessment Limitations

This is a point-in-time assessment based on portal screenshots and visible configuration; it is not a penetration test or formal compliance certification.

Advisor scores and recommendation counts can change as resources, subscriptions and Microsoft recommendation logic change.

The 24-hour performance screenshots are insufficient for definitive capacity planning or rightsizing.

Some screenshots represent selected resources rather than every resource in every subscription.

AWS screenshots are contextual comparison evidence and must not be reported as Azure findings.

14. Management Summary / Suggested Message

The Azure Well-Architected review has been completed across the five pillars using Azure Advisor and supporting portal evidence. Cost Optimization and Performance Efficiency are currently the strongest areas, while Reliability is generally established but still has active recommendations. Security and Operational Excellence require the most focused remediation. The recommended next step is to convert the identified Advisor, Defender, Policy and monitoring findings into a prioritised backlog, address high-risk security and monitoring items first, and then re-assess the environment after remediation.

Appendix A - Evidence Index

Evidence area

Screenshots included

Advisor pillar baseline

Advisor Overview, Performance, Operational Excellence

Reliability / health

Service Health alert, VM availability/monitoring

Performance

CPU-credit, disk read/write and network metrics for selected VMs

Storage

Storage Center managed disk summary

Governance / inventory

Resource Graph and governance views

Cross-cloud reference

AWS Compute Optimizer, EC2 status checks and decommission evidence

Azure Well-Architected Assessment | Internal Working Document | August 2026

