locals {
  users= csvdecode(file("users.csv"))
}

locals {
  departments = toset([for user in local.users : user.department])
}

locals {
  department_policies = {
    "Engineering"        = ["arn:aws:iam::aws:policy/PowerUserAccess"]
    "Corporate"          = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
    "Finance"            = ["arn:aws:iam::aws:policy/job-function/Billing"]
    "Accounting"         = ["arn:aws:iam::aws:policy/job-function/Billing"]
    "HR"                 = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
    "Sales"              = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
    "Customer Service"   = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
    "Reception"          = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
    "Warehouse"          = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
    "Quality Assurance"  = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
    "Supplier Relations" = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
    "Product"            = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
    "Temps"              = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  }
}

