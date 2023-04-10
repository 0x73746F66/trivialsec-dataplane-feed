output "feed_processor_dataplane_arn" {
  value = aws_lambda_function.feed_processor_dataplane.arn
}
output "feed_processor_dataplane_role" {
  value = aws_iam_role.feed_processor_dataplane_role.name
}
output "feed_processor_dataplane_role_arn" {
  value = aws_iam_role.feed_processor_dataplane_role.arn
}
output "feed_processor_dataplane_policy_arn" {
  value = aws_iam_policy.feed_processor_dataplane_policy.arn
}
