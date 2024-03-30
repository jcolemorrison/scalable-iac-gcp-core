variable "gcp_project_id" {
  description = "The ID of the GCP project"
  type        = string
}

variable "project_name" {
  description = "default project name for grouping resources"
  type        = string
}

variable "default_region" {
  description = "default region for the project deployment"
  type        = string
  default     = "us-west1"
}

variable "deployment_regions" {
  description = "regions to deploy"
  type        = list(string)
  default     = ["us-west1", "us-east1"]
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "server_instance_type" {
  description = "type of instance for game servers"
  type        = string
  default     = "n2-standard-4"
}

variable "server_port" {
  description = "The port the server will listen on"
  type        = number
  default     = 80
}

variable "server_environment_type" {
  description = "The environment type (e.g., 'development', 'staging', 'production')"
  type        = string
}

variable "server_app_version" {
  description = "The version of the application to be deployed (e.g., '1.0.0' sans the 'v')"
  type        = string
}

variable "server_cert_name" {
  description = "value of the server certificate name"
  type        = string
}

variable "redis_service_accounts" {
  description = "List of service account emails that need read access to the Redis instances"
  type        = list(string)
  default     = []
}

variable "client_site_service_account_email" {
  description = "The email of the service account"
  type        = string
}

variable "client_cert_name" {
  description = "value of the client certificate name"
  type        = string
}