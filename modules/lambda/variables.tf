variable "function_name" {
  type    = string
  default = null
}

variable "runtime" {
  type    = string
  default = null
}

variable "role_arn" {
  type    = string
  default = null
}

variable "handler" {
  type    = string
  default = "repo.main"
}

variable "file_path" {
  type    = string
  default = "repo.main"
}