data "aws_iam_policy_document" "feed_processor_dataplane_assume_role_policy" {
  statement {
    sid = "${var.app_env}TrivialScannerFeedProcessorDataplaneAssumeRole"
    actions    = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}
data "aws_iam_policy_document" "feed_processor_dataplane_iam_policy" {
  statement {
    sid = "${var.app_env}TrivialScannerFeedProcessorDataplaneLogging"
    actions   = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${local.aws_default_region}:${local.aws_master_account_id}:log-group:/aws/lambda/${local.function_name}:*"
    ]
  }
  statement {
    sid = "${var.app_env}TrivialScannerFeedProcessorDataplaneObjList"
    actions   = [
      "s3:Head*",
      "s3:List*",
    ]
    resources = [
      "arn:aws:s3:::${data.terraform_remote_state.trivialscan_s3.outputs.trivialscan_store_bucket}",
      "arn:aws:s3:::${data.terraform_remote_state.trivialscan_s3.outputs.trivialscan_store_bucket}/*",
    ]
  }
  statement {
    sid = "${var.app_env}TrivialScannerFeedProcessorDataplaneObjAccess"
    actions   = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = [
      "arn:aws:s3:::${data.terraform_remote_state.trivialscan_s3.outputs.trivialscan_store_bucket}/${var.app_env}/*",
    ]
  }
  statement {
    sid = "${var.app_env}TrivialScannerFeedProcessorDataplaneSecrets"
    actions   = [
      "ssm:GetParameter",
    ]
    resources = [
      "arn:aws:ssm:${local.aws_default_region}:${local.aws_master_account_id}:parameter/${var.app_env}/${var.app_name}/*",
    ]
  }
  statement {
    sid = "${var.app_env}DataPlaneEWSQueueSQS"
    actions   = [
      "sqs:SendMessage",
      "sqs:ChangeMessageVisibility",
      "sqs:Get*",
    ]
    resources = [
      data.terraform_remote_state.ews_sqs.outputs.early_warning_service_queue_arn
    ]
  }
}
resource "aws_iam_role" "feed_processor_dataplane_role" {
  name               = "${lower(var.app_env)}_feed_processor_dataplane_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.feed_processor_dataplane_assume_role_policy.json
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_iam_policy" "feed_processor_dataplane_policy" {
  name        = "${lower(var.app_env)}_feed_processor_dataplane_lambda_policy"
  path        = "/"
  policy      = data.aws_iam_policy_document.feed_processor_dataplane_iam_policy.json
}
resource "aws_iam_role_policy_attachment" "policy_attach" {
  role       = aws_iam_role.feed_processor_dataplane_role.name
  policy_arn = aws_iam_policy.feed_processor_dataplane_policy.arn
}
