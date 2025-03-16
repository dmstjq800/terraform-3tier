variable "vpc_id" {
  description = "vpc_id"
  type = string
}
variable "security_group_id" {
  description = "security-group-id"
  type = string
}
variable "private_subnet_id" {
  description = "private_subnet_id"
  type = list(string)
}
variable "iam_role_profile_arn" {
  description = "iam_instance_role_profile_arn"
  type = string
}
variable "db_dns" {
  description = "db_dns"
  type = string
}