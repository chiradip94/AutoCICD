resource "aws_sqs_queue" "this" {
  name                      = var.sqs_name
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.queue_deadletter.arn
    maxReceiveCount     = 4
  })
  fifo_queue            = var.enable_fifo
}


resource "aws_sqs_queue" "queue_deadletter" {
  name = "${var.sqs_name}_deadletter"
}

