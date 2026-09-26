data "aws_caller_identity" "users_caller_id" {}

output "account_id" {
  value = data.aws_caller_identity.users_caller_id.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.users_caller_id.arn
}

output "caller_user" {
  value = data.aws_caller_identity.users_caller_id.user_id
}
