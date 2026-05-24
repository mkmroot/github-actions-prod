variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "github-action-key"
}

output "ecr_repository_url" {
  value = aws_ecr_repository.node_app_repo.repository_url
}
