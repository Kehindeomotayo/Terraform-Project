“Here’s how break‑glass works now:
Every AWS account has its own local break‑glass users, so we’re not dependent on SSO or the Audit account.
Platform, Monitoring, and Server teams can access all four accounts; the Network team only gets the Network account.
bg‑admin is in every account and is the only one who can turn console login on or off and generate passwords.
When there’s an outage, the admin enables login, the user signs in, sets up MFA, and then gets read‑only access.
Everything they do is logged and alerts the security team.”
