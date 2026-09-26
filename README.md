# CSV-Driven IAM User Onboarding (Terraform)

## Overview
Automated AWS IAM user provisioning driven entirely by a CSV file. Adding, removing, or changing a row in `users.csv` and re-running `terraform apply` creates or updates the corresponding IAM user, console login profile, department-based group membership, and attached permissions — no manual IAM console work per employee.

## Architecture

![Architecture diagram](docs/architecture.png)

## How It Works

1. **`users.csv`** is the single source of truth — one row per employee (name, department, job title, email, phone).
2. **`locals.users`** decodes the CSV into a list Terraform can loop over.
3. **`aws_iam_user`** creates one IAM user per row, keyed by `first_name-last_name` (unique key, since names alone can collide across a large employee list). Username is generated from full first name + last name; department and job title are stored as tags for auditability.
4. **`aws_iam_user_login_profile`** generates a console password for each user with `password_reset_required = true` — nobody uses a Terraform-generated password long-term; everyone sets their own on first login.
5. **`aws_iam_group`** creates one group per unique department found in the CSV — departments aren't hardcoded, they're derived from the data. Department names containing spaces (e.g. "Quality Assurance") are sanitized to hyphens for AWS naming compliance.
6. **`aws_iam_group_membership`** assigns each user to the group matching their `Department` tag.
7. **`aws_iam_group_policy_attachment`** attaches department-appropriate permissions — e.g. broader access for Engineering, read-only for most other departments — via a `department -> policy ARN` map.
8. **`aws_iam_policy "RequireMFA"`**, attached to every group, blocks all actions except MFA self-enrollment until the user sets up multi-factor authentication themselves.

## Prerequisites

- AWS CLI configured with a named profile
- Terraform >= 1.0
- `users.csv` present with columns: `first_name, last_name, department, job_title, email, phone_number`

## Deployment

```bash
terraform init
terraform plan
terraform apply
```

## Onboarding a New Employee

Add a row to `users.csv`, then:

```bash
terraform plan
terraform apply
```

Terraform will create exactly the new user, their login profile, and their group membership — no changes to existing users.

## Proof of Work

**All 43 IAM users provisioned from the CSV, each auto-tagged and grouped:**
![IAM users list](docs/screenshots/iam-users-list.png)

**14 department groups created automatically from `local.departments`:**
![IAM groups list](docs/screenshots/iam-groups-list.png)

**Corporate group membership — users correctly assigned by department:**
![Corporate group members](docs/screenshots/corporate-group-members.png)

**User tags populated directly from the CSV row (Department, JobTitle, DisplayName):**
![User tags](docs/screenshots/user-tags.png)

**Permissions correctly inherited through group membership — ReadOnlyAccess and RequireMFA both attached via the Corporate group, not set per-user:**
![User permissions](docs/screenshots/user-permissions-policies.png)

## Security Design Decisions

**Why `password_reset_required = true`, not a distributed password:**
Terraform-generated passwords would need to be securely delivered to each user somehow (Secrets Manager, email, etc.) and would sit in Terraform state either way. Forcing a reset on first login means no real password ever needs to be stored or transmitted after creation.

**Why department-based groups instead of per-user policies:**
Scales correctly — permissions are defined once per department, not once per employee. Onboarding someone new means adding a CSV row and letting the existing department policy apply automatically, not writing new IAM policy from scratch per hire.

**Why MFA enforcement is a Deny-by-default policy, not a suggestion:**
IAM has no built-in "require MFA" toggle at the account level for IAM users (unlike SSO/Identity Center). The standard workaround is a policy that denies nearly everything unless `aws:MultiFactorAuthPresent` is true, while explicitly allowing the handful of actions needed to self-enroll a device. Attached to every group, so it applies uniformly regardless of department.

## Issues Hit and Fixed During Build

**1. Username collisions on first-initial scheme**
Original username scheme (`first-initial + last-name`) collided for two pairs of employees sharing a last name and first initial (`Chiamaka Adewale` / `Chukwuemeka Adewale`, `Aminu Shehu` / `Adebayo Shehu`), causing `EntityAlreadyExists` errors on `apply`. Switched to `firstname.lastname` for guaranteed uniqueness given the dataset.

**2. Invalid IAM group names**
AWS IAM resource names reject spaces. Department strings like `"Quality Assurance"` and `"Customer Service"` failed group creation until sanitized with `replace(each.value, " ", "-")` at the point of use, while the original department string is retained everywhere else (tags, filtering, membership lookups).

**3. `aws_iam_group_membership` is replace-not-append**
This resource sets a group's *entire* member list on every apply — it doesn't add to it. Creating one membership resource per user (instead of per department) caused separate resources to overwrite each other's changes to the same group. Fixed by keying `for_each` on unique departments and filtering `local.users` down to each department's members within a single resource per group.

## Known Limitations

- No automated password/credential delivery — first login and MFA enrollment are manual, user-driven steps
- Department -> policy mapping is a starting point (broad ReadOnlyAccess default, PowerUserAccess for Engineering) and should be tightened to least-privilege per real job function before production use
- No offboarding automation — removing a CSV row and re-applying will destroy the IAM user, but access revocation timing should be verified for anything security-sensitive

## Next Steps

- Migrate to AWS IAM Identity Center (SSO) for production — removes per-user IAM console passwords entirely (separate project; changes the access model significantly enough to warrant its own repo rather than extending this one)
- Tighten department policy mappings to least-privilege, function-specific policies rather than broad managed policies
- Add automated offboarding trigger (e.g. CI pipeline on CSV row removal)

## Cleanup

```bash
terraform destroy
```

Removes all IAM users, login profiles, groups, memberships, and policy attachments.
