# Facilitation playbook

This playbook helps trainers keep a mixed-skill room moving through a dense Azure
hybrid day without losing the Module B storyline.

## Core facilitation stance

- Be time-boxed, practical, and evidence-led.
- Narrate why a task matters before showing how to click or type.
- Prefer short demos followed by hands-on work.
- Treat broken labs as teachable operations incidents, not failures.
- Keep reminding the room: Azure Local is the target operating model; Azure Arc is the control-plane bridge used in the classroom.

## Classroom dynamics

### Start strong

- Ask pupils to introduce their role and one customer hybrid scenario they see often.
- Group by mixed experience: Azure operators, trainers, migration consultants, and security specialists.
- Set norms:
  - Use the help queue.
  - Pair before waiting silently.
  - Do not paste secrets in chat.
  - Stop at checkpoints even if you want to keep exploring.

### Keep mixed-skill rooms together

Use three lanes:

| Lane | Signal | Trainer response |
| --- | --- | --- |
| Green | Completed current task and can explain it | Ask them to help a neighbor or capture evidence. |
| Yellow | Resource exists but validation is unclear | Give a targeted diagnostic command. |
| Red | Blocked by identity, quota, policy, or failed deployment | Move to proctor support or trainer demo mode. |

Do not let green pupils race two challenges ahead. Ask them to improve evidence,
write a runbook note, or prepare a checkpoint answer.

## Pacing signals

- **Five-minute warning:** announce when a block has five minutes left and name the minimum success criterion.
- **Checkpoint stop:** stop the room, even if only 70% are complete. Use shared demos for the rest.
- **Recovery window:** use breaks and lunch for individual repairs.
- **Capstone protection:** avoid consuming Challenge 06 time. It is the Train-the-Trainer differentiator.

## Demo versus productive struggle

Demo when:

- A concept is new and has many portal paths, such as Arc resource navigation.
- A task has a hidden prerequisite, such as provider registration or Defender plan lag.
- A common failure would waste more than five minutes for most pupils.

Let pupils struggle when:

- The error message is actionable and safe.
- The task reinforces operational diagnosis, such as `az account show` or KQL validation.
- Pairing can solve it faster than a front-of-room explanation.

Use this rhythm: **why, show, do, validate, evidence**.

## Recovery strategies when a lab breaks

### Triage quickly

1. Confirm subscription and tenant:

   ```bash
   az account show --query '{name:name,id:id,tenant:tenantId,user:user.name}' -o table
   ```

1. Confirm environment variables:

   ```bash
   echo "$ARM_SUBSCRIPTION_ID"
   echo "$AZURE_DEFAULTS_GROUP"
   ```

1. Confirm resource group:

   ```bash
   az group show --name "rg-mhb-<initials>" -o table
   ```

1. Confirm provider state:

   ```bash
   az provider show --namespace Microsoft.HybridCompute --query registrationState -o tsv
   ```

1. Decide: fix now, defer to break, or switch to demo mode.

### Use trainer demo mode

Trainer demo mode is acceptable when the learning objective is conceptual or
evidence interpretation. Say explicitly:

> "Your subscription is blocked by policy. You will follow the evidence review on
> my resource and still answer the Module B checkpoint. We will not burn the
> room's time on tenant policy."

### Preserve morale

- Avoid blaming pupils for Azure subscription policy or transient capacity.
- Celebrate useful diagnostics, not just completed deployments.
- Ask fast finishers to become table captains.

## Energy management

- Change modality every 20-30 minutes: story, demo, hands-on, checkpoint, pair review.
- Keep lunch protected. Hybrid labs are cognitively heavy.
- Use the AI capstone as a late-day energy lift: pupils get to see their evidence turned into runbooks and gap lists.
- Keep teardown short but non-negotiable.

## Virtual delivery tips

- Ask pupils to rename themselves with status: `Name - Green`, `Name - Yellow`, or `Name - Red`.
- Use one support breakout room and rotate proctors through it.
- Keep command snippets in chat, but direct pupils to docs for full steps.
- Use screen share for portal navigation; use terminal zoom for commands.
- Pause after every copy-paste command so slower typists and screen-reader users can keep up.

## In-person delivery tips

- Walk the room during Terraform and Arc onboarding; do not stay behind the lectern.
- Put QR codes or short links to [troubleshooting](troubleshooting.md) and [teardown](teardown.md) on slides.
- Keep a printed list of provider namespaces and default naming.
- Use colored sticky notes or table cards for green/yellow/red status.

## Accessibility

- Provide all commands in text, not only verbally or on screenshots.
- Read important portal labels aloud.
- Avoid relying on color alone; pair color with words such as green/yellow/red.
- Leave enough time for screen-reader navigation in the portal.
- Offer keyboard-friendly alternatives where possible through Azure CLI.
- For hearing-impaired participants, enable captions in virtual meetings and repeat questions before answering.
- Use descriptive link text in slides and docs.

## Handling sensitive information

- Never ask pupils to share secrets, full access tokens, or customer data.
- Subscription IDs are not secrets, but still avoid displaying them in recordings when possible.
- Use `--query` to limit command output.
- Remind pupils that Copilot prompts must not include customer confidential data unless their organization's policy allows it.

## Trainer anti-patterns to avoid

- Turning the day into an Azure Local hardware lecture.
- Letting Terraform failures consume the whole morning.
- Skipping Module B control mapping because the technical tasks are interesting.
- Claiming exact ACR or specialization thresholds without checking the current official requirements.
- Ending without teardown verification.
