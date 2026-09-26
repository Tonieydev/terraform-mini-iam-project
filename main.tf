resource "aws_iam_user" "users" {
  for_each = { for user in local.users : "${user.first_name}-${user.last_name}" => user }
  name     = lower("${each.value.first_name}.${each.value.last_name}")
  path     = "/users/"
  tags = {
    "DisplayName" = "${each.value.first_name} ${each.value.last_name}"
    "Department"  = each.value.department
    "JobTitle"    = each.value.job_title
  }
}

resource "aws_iam_user_login_profile" "user_profiles" {
  for_each = aws_iam_user.users
  user    = each.value.name
  password_reset_required = true

  lifecycle {
    ignore_changes = [ password_reset_required, password_length ]
  }
}

resource "aws_iam_group_policy_attachment" "department_policy" {
  for_each = {
    for pair in flatten([
      for dept, policies in local.department_policies : [
        for policy_arn in policies : {
          key    = "${dept}-${policy_arn}"
          dept   = dept
          policy = policy_arn
        }
      ]
    ]) : pair.key => pair
  }

  group      = aws_iam_group.groups[each.value.dept].name
  policy_arn = each.value.policy
}

resource "aws_iam_policy" "require_mfa" {
  name        = "RequireMFA"
  description = "Denies all actions except MFA self-setup when MFA is not present"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowViewAccountInfo"
        Effect = "Allow"
        Action = [
          "iam:GetAccountPasswordPolicy",
          "iam:ListVirtualMFADevices"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowManageOwnMFA"
        Effect = "Allow"
        Action = [
          "iam:CreateVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:ResyncMFADevice",
          "iam:DeleteVirtualMFADevice"
        ]
        Resource = [
          "arn:aws:iam::*:mfa/$${aws:username}",
          "arn:aws:iam::*:user/$${aws:username}"
        ]
      },
      {
        Sid       = "DenyAllExceptListedIfNoMFA"
        Effect    = "Deny"
        NotAction = [
          "iam:CreateVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:GetUser",
          "iam:ListMFADevices",
          "iam:ListVirtualMFADevices",
          "iam:ResyncMFADevice",
          "sts:GetSessionToken"
        ]
        Resource = "*"
        Condition = {
          BoolIfExists = {
            "aws:MultiFactorAuthPresent" = "false"
          }
        }
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "mfa_enforcement" {
  for_each   = aws_iam_group.groups
  group      = each.value.name
  policy_arn = aws_iam_policy.require_mfa.arn
}
