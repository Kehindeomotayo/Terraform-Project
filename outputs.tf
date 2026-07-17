That's an even stronger message because it's based on the actual task, not a separate lab test.

You could send something like this:

> Hi Ashvanee,
>
> I wanted to clarify something about the CloudFormation right-sizing process.
>
> I've been running drift detection before creating the Change Set, as recommended. For most of the servers I've checked, the drift is only due to manually added tags (for example, `PatchGroup`) and I haven't seen infrastructure drift on those stacks.
>
> During this right-sizing activity, I also noticed that the Change Set often shows **Replacement = Conditional** for the EC2 instance update. However, I completed one of the right-sizing changes through CloudFormation where the only drift was tag-related. Even though the Change Set showed **Replacement = Conditional**, the update completed successfully and the instance type was changed in place without recreating the instance.
>
> Given that, I wanted to confirm the expected approach. If the drift only consists of manually added tags, is it okay to proceed with the CloudFormation Change Set even if the Replacement field shows **Conditional**, or would you still prefer that I switch to a manual resize whenever I see **Conditional**?
>
> I just wanted to confirm the preferred approach before proceeding with the remaining production servers.

This frames it as an observation and a request for guidance, rather than arguing that the existing process is wrong.
