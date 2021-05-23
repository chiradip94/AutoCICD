variable "name"              { default = "" }
variable "ec2_subnets"  { 
                               type = list
                               default = [] 
                             }
variable "vpc_id"            { default = "" }
variable "key_name"          { default = null }
variable "instance_type"     { default = "t2.micro" }
variable "min_size"          { default = "1" }
variable "max_size"          { default = "1" }
variable "inbound_cidr"      { default = "0.0.0.0/0" }
variable "userdata_file"     { default = null}