variable "user_names" {
  type = set(string)
}
variable "aws_region" {
  type = string
}

variable "servers" {
  type = map(object({
    environment   = string
    instance_type = string
    ami_id        = string
  }))


}
variable "db_environment" {
    type = string
  }