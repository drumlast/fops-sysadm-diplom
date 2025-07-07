variable "yc_token" {}
variable "yc_cloud_id" {}
variable "yc_folder_id" {}

variable "yc_zone" {
  default = "ru-central1-a"
}

variable "public_ssh_key" {}
variable "image_id" {
  description = "ID публичного образа Ubuntu 24.04"
  default     = "fd876gids9srs8ma0592"
}