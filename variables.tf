variable "bucket_name" {
  description = "Base name for the S3 bucket (will have random suffix added)"
  type        = string
  default     = "static-website"
}