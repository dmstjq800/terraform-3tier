output "web_security_group_id" {
  value = aws_security_group.WEBSG.id
}
output "was_security_group_id" {
  value = aws_security_group.WASSG.id 
}
output "db_security_group_id" {
  value = aws_security_group.DBSG.id
}
output "iam_role_profile_arn" {
  value = aws_iam_instance_profile.iamprofile.arn
}