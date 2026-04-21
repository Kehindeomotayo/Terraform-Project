📘 RUNBOOK: Implementing Automated S3 → S3 File Sync Using AWS DataSync (Production Task)
1. Purpose
This document describes the steps required to configure an ongoing automated file sync between two Amazon S3 locations using AWS DataSync.
It is intended for production tasks where accuracy, validation, and careful execution are required.

2. Scope
This runbook applies to:

S3 → S3 continuous sync

Production workloads

Tasks requiring incremental updates

Scenarios where the requester explicitly asks for “file sync” rather than replication or manual copy

3. Prerequisites
Before starting:

Confirm with the requester whether they need:

One‑time copy, or

Ongoing automated sync

Ensure you have:

Access to AWS Console

Permissions for DataSync, S3, and IAM

Gather the required S3 paths:

Source path

Destination path

4. Implementation Steps
Step 1 — Open AWS DataSync
Log in to AWS Console

Search for DataSync

Click Create task

Step 2 — Configure Source Location
Select Amazon S3

Choose the source bucket

Enter the source folder path

Allow DataSync to create an IAM role

Example: AWSDataSyncS3BucketAccess-<bucket>-<id>

Save the location

Step 3 — Configure Destination Location
Select Amazon S3

Choose the destination bucket

Enter the destination folder path

Allow DataSync to create the IAM role

Save the location

Step 4 — Configure Task Settings
Recommended settings for production:

Mode: Enhanced

Transfer mode: Incremental

Verify data: Verify only transferred data

Overwrite files: Yes

Keep deleted files: Yes (safe default)

Preserve tags: Yes

Queueing: Enabled

Step 5 — Configure Schedule
Choose a schedule appropriate for the workload:

Examples:

Every 15 minutes

Every hour

Daily

Avoid weekly schedules unless specifically requested.

Step 6 — Create the Task
Review all settings → Click Create task

Step 7 — Run Initial Sync
Open the task

Click Start

Choose Start with default options

Monitor the execution

This validates:

IAM permissions

Path correctness

Data transfer behavior

Step 8 — Validate Sync
After the first run:

Check Execution history

Confirm SUCCESS status

Verify files appear in the destination bucket

Confirm no permission or path errors

5. Production Considerations
Always validate with the requester before enabling sync

Double‑check S3 paths to avoid overwriting wrong locations

Monitor the first execution

If unsure, ask for a second review before running in prod

Document all changes in the ticket

6. ServiceNow Work Notes Template
You can paste this into the task:
