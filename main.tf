# Cross-Account AMI Sharing for Encrypted Windows SQL Server AMI

## Objective

Share a hardened Windows Server 2025 SQL Server 2025 AMI from the Shared Services account (959563671843) to the Production account (076327095561).

## Issue Encountered

When attempting to share the AMI directly, AWS returned the following error:

"Snapshots encrypted with the AWS Managed CMK can't be shared."

The source AMI was encrypted using the default AWS-managed EBS key (aws/ebs), which does not support cross-account sharing.

## Solution

### Step 1: Identify the Source AMI

Source AMI:

* AVTR-Hardened-WindowsServer2025-SQL2025std-AMI

Associated Snapshot:

* snap-02e18d895c4629238

Source Account:

* Shared Services (959563671843)

Region:

* us-east-1 (N. Virginia)

### Step 2: Copy the Snapshot Using a Customer Managed KMS Key

Navigate to:

EC2 → Snapshots

Select the source snapshot:

snap-02e18d895c4629238

Actions → Copy Snapshot

Configuration:

* Destination Region: us-east-1
* Encryption: Enabled
* KMS Key: AVTR-WIN-SHARED-KEY (Customer Managed Key)

Submit the copy request.

Wait for the copied snapshot to reach the Completed state.

### Step 3: Create a New AMI From the Copied Snapshot

Navigate to:

EC2 → Snapshots

Select the newly copied snapshot.

Actions → Create Image from Snapshot

AMI Name:
AVTR-Hardened-WindowsServer2025-SQL2025-Shared

Default settings used:

* Architecture: x86_64
* Root Device: /dev/sda1
* Virtualization Type: Hardware-assisted virtualization

Create the AMI.

Wait until the AMI status becomes Available.

### Step 4: Share the AMI

Navigate to:

EC2 → AMIs

Select:
AVTR-Hardened-WindowsServer2025-SQL2025-Shared

Actions → Edit AMI Permissions

Add Account ID:

076327095561

Save changes.

### Step 5: Validate Access from Production Account

Switch to Production account:

076327095561

Navigate to:

EC2 → AMIs

Locate:

AVTR-Hardened-WindowsServer2025-SQL2025-Shared

Validation Results:

* AMI visible in Production account
* AMI status: Available
* Launch Instance option available

### Outcome

Successfully shared a hardened Windows Server 2025 SQL Server 2025 AMI from Shared Services to Production by re-encrypting the underlying snapshot with a Customer Managed KMS Key.

### Key Learning

AWS-managed KMS keys (aws/ebs) do not support cross-account AMI sharing.

For cross-account AMI sharing, snapshots must be encrypted using a Customer Managed KMS Key (CMK) with the appropriate permissions.
