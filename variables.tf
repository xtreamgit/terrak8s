variable "name" {
  default = "devdatalab.com"
}

variable "region" {
  default = "us-west-1"
}

variable "azs" {
  default = ["us-west-1a", "us-west-1b"]
  type    = "list"
}

variable "env" {
  default = "staging"
}

variable "vpc_cidr" {
  default = "172.21.0.0/16"
}
