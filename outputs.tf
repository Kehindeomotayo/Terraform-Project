AWS Decommission - Simple Reusable Steps

Dedicated Host + Load Balancers

Use this as a copy-and-paste checklist for similar AWS decommission tasks. Replace anything in [brackets] with the actual resource details.

1. Information to Collect

AWS account: [ACCOUNT NAME / ID]

Region: [REGION]

Load Balancer 1: [NAME / ARN]

Load Balancer 2: [NAME / ARN]

Target Group: [NAME / ARN]

Dedicated Host: [HOST ID]

Change / Request number: [TICKET NUMBER]

2. Load Balancer Checks

Repeat these checks for each load balancer.

EC2 -> Load Balancers -> search for [LB NAME / ARN].

Confirm the load balancer name, ARN, account, region, type and scheme.

Open Listeners and rules. Record the listener port/protocol.

Open Resource map or Target Groups.

Check Registered targets. Confirm there are no active targets.

Open Tags. Check for CloudFormation, Terraform or other automation ownership.

Open Attributes. Check whether Deletion protection is enabled or disabled.

Copy the load balancer DNS name for the DNS check below.

STOP: If there are active targets, unexpected listeners, or IaC ownership that is not understood, do not delete the load balancer until the dependency is confirmed.

3. DNS / Route 53 Check

Route 53 -> Hosted zones.

Check public and private hosted zones for an Alias or CNAME pointing to the load balancer DNS name.

If the account has no hosted zones, record that no Route 53 dependency exists in that account.

If DNS is managed centrally or externally, confirm there is no remaining DNS dependency before deletion.

4. Target Group Check

EC2 -> Target Groups -> open [TARGET GROUP].

Open Targets and confirm Registered targets = 0.

Check Tags for automation ownership or another application dependency.

Only remove the target group after the load balancer is removed and the target group is confirmed unused.

5. Dedicated Host Checks

EC2 -> Dedicated Hosts -> search for [HOST ID].

Confirm the host name/ID matches the request.

Check State, Instance family, Availability Zone, Auto-placement and Host Reservation.

Check Running instances. Confirm there are no running instances.

Use "View all instances launched on this host" and confirm there are no current running or stopped instances that still depend on the host.

Check Sharing and Tags for any other account, application or automation dependency.

Important: For a Dedicated Host, Release Host is the decommission action. There is no separate delete step afterward.

6. Recommended Decommission Order

Complete all dependency checks and confirm change approval.

Release the Dedicated Host if it is empty and approved for decommissioning.

Delete Load Balancer 1.

Delete Load Balancer 2.

Delete the unused target group(s), if applicable.

Remove retired DNS records only if they are part of the approved decommission scope.

Refresh the AWS console and verify the resources are gone/released.

7. Final Validation

Dedicated Host state shows Released.

Load Balancers are no longer present.

Unused target group is removed, if in scope.

No active DNS record points to the retired load balancer.

No unexpected application or service impact is reported.

8. Copy-and-Paste Ticket Closure Note

Decommissioning completed successfully in AWS [ENVIRONMENT/ACCOUNT]. Dedicated Host [HOST ID] was verified with no dependent instances and successfully released. Load balancers [LB1] and [LB2] were validated and decommissioned after confirming there were no active backend targets. Associated unused target group(s) and DNS records were removed where applicable and within scope. Post-change validation completed successfully.

9. Copy-and-Paste Email Reply

Subject: RE: [REQUEST / CHANGE TITLE]

Hi [NAME],

The requested AWS decommissioning activities have now been completed successfully. The Dedicated Host [HOST ID] has been released, and load balancers [LB1] and [LB2] have been decommissioned. Any associated unused target group/DNS entry within scope was also cleaned up.

I will update the request accordingly and proceed with closure.

Thanks,
[YOUR NAME]

10. Quick Checklist

☐ Correct AWS account and region confirmed

☐ LB1 checked - no active targets

☐ LB2 checked - no active targets

☐ Tags / IaC ownership checked

☐ Deletion protection checked

☐ Route 53 / DNS checked

☐ Target group checked

☐ Dedicated Host has no dependent instances

☐ Dedicated Host released

☐ Load balancers deleted

☐ Unused target groups removed if in scope

☐ Post-change validation completed

☐ Ticket updated and closed

☐ Completion email sent
