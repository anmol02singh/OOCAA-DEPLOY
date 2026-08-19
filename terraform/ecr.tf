resource "aws_ecr_repository" "api" {
    name = "oocaa-api"
    force_delete = true
}

resource "aws_ecr_repository" "ui" {
    name = "oocaa-ui"
    force_delete = true
}

output "api_repo_url" {
    value = aws_ecr_repository.api.repository_url
}

output "ui_repo_url" {
    value = aws_ecr_repository.ui.repository_url
}