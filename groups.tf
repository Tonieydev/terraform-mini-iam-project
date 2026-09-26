resource "aws_iam_group" "groups" {
  for_each = local.departments
  name     = replace(each.value, " ", "-")
  path     = "/users/"
}   

resource "aws_iam_group_membership" "Accounting_membership" {
   # e.g. toset of unique departments
  name  = "Accounting-membership"
  group = aws_iam_group.groups["Accounting"].name

  users = [for user in aws_iam_user.users: user.name if user.tags.Department == "Accounting"]
}

resource "aws_iam_group_membership" "Corporate_membership" {
   # e.g. toset of unique departments
  name  = "Corporate-membership"
  group = aws_iam_group.groups["Corporate"].name

  users = [for user in aws_iam_user.users: user.name if user.tags.Department == "Corporate"]
}

resource "aws_iam_group_membership" "Customer_Service_membership" {
   # e.g. toset of unique departments
  name  = "Customer_Service-membership"
  group = aws_iam_group.groups["Customer Service"].name

  users = [for user in aws_iam_user.users: user.name if user.tags.Department == "Customer Service"]
}

resource "aws_iam_group_membership" "Engineering_membership" {
   # e.g. toset of unique departments
  name  = "Engineering-membership"
  group = aws_iam_group.groups["Engineering"].name

  users = [for user in aws_iam_user.users: user.name if user.tags.Department == "Engineering"]
}

resource "aws_iam_group_membership" "Finance_membership" {
   # e.g. toset of unique departments
  name  = "Finance-membership"
  group = aws_iam_group.groups["Finance"].name

  users = [for user in aws_iam_user.users: user.name if user.tags.Department == "Finance"]
}

resource "aws_iam_group_membership" "HR_membership" {
   # e.g. toset of unique departments
  name  = "HR-membership"
  group = aws_iam_group.groups["HR"].name

  users = [for user in aws_iam_user.users: user.name if user.tags.Department == "HR"]
}

resource "aws_iam_group_membership" "Product_membership" {
   # e.g. toset of unique departments
  name  = "Product-membership"
  group = aws_iam_group.groups["Product"].name

  users = [for user in aws_iam_user.users: user.name if user.tags.Department == "Product"]
}

resource "aws_iam_group_membership" "Quality_Assurance_membership" {
   # e.g. toset of unique departments
  name  = "Quality_Assurance-membership"
  group = aws_iam_group.groups["Quality Assurance"].name

  users = [for user in aws_iam_user.users: user.name if user.tags.Department == "Quality Assurance"]
}

resource "aws_iam_group_membership" "Sales_membership" {
   # e.g. toset of unique departments
  name  = "Sales-membership"
  group = aws_iam_group.groups["Sales"].name

  users = [for user in aws_iam_user.users: user.name if user.tags.Department == "Sales"]
}

resource "aws_iam_group_membership" "Warehouse_membership" {
   # e.g. toset of unique departments
  name  = "Warehouse-membership"
  group = aws_iam_group.groups["Warehouse"].name

  users = [for user in aws_iam_user.users: user.name if user.tags.Department == "Warehouse"]
}

resource "aws_iam_group_membership" "Temps_membership" {
   # e.g. toset of unique departments
  name  = "Temps-membership"
  group = aws_iam_group.groups["Temps"].name

  users = [for user in aws_iam_user.users: user.name if user.tags.Department == "Temps"]
}

resource "aws_iam_group_membership" "supplier_membership" {
   # e.g. toset of unique departments
  name  = "Supplier_Relations-membership"
  group = aws_iam_group.groups["Supplier Relations"].name

  users = [for user in aws_iam_user.users: user.name if user.tags.Department == "Supplier Relations"]
}