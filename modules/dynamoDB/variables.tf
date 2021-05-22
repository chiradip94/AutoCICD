variable "name" {
  type    = string
  default = null
}

variable "hash_key" {
  type    = string
  default = null
}

variable "hash_key_type" {
  type    = string
  default = "S"
}

variable "billing_mode" {
  type    = string
  default = "PAY_PER_REQUEST"
}

variable "dynamodb_attributes" {
  type = list(object({
    name = string
    type = string
  }))
  default     = []
}