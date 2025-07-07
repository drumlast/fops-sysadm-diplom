variable "yc_token" {}
variable "yc_cloud_id" {}
variable "yc_folder_id" {}
variable "image_id" {
  default = "fd8f0g7n8v4f1p*********" # Ubuntu 24.04, актуальный образ получи через YC CLI:
}

variable "public_key" {
  default = "~/.ssh/id_rsa.pub"
}