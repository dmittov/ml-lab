variable "region" {
  type = string
}
variable "project" {
  type = string
}
variable "zone" {
  type        = string
  default     = "b"
  description = "zone for a zone-cluster"
}
