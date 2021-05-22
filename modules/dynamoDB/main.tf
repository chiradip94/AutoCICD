locals {

  attributes = concat(
    [
      {
        name = var.hash_key
        type = var.hash_key_type
      }
    ],
    var.dynamodb_attributes
  )

  from_index = 0

  attributes_final = slice(local.attributes, local.from_index, length(local.attributes))
}

resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = var.name
  hash_key       = var.hash_key
  billing_mode   = var.billing_mode

  dynamic "attribute" {
    for_each = local.attributes_final
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }
}