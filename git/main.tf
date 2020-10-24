provider "github" {
  token        = var.token
}
resource "github_repository" "terraform-crashcourse" {
  name        = "terraform-crashcourse"
  description = "devops-03 task by Dmytro Lenchuk"
  auto_init   = true
}

resource "github_branch" "develop" {
  repository = "terraform-crashcourse"
  branch     = "develop"
  source_branch = "master"
  depends_on = [github_repository.terraform-crashcourse]
}
resource "github_branch_protection" "foo" {
  repository_id     = github_repository.terraform-crashcourse.node_id
  pattern         = "master"
  enforce_admins = true
  required_pull_request_reviews {
    dismiss_stale_reviews = true
  }
}
resource "github_user_ssh_key" "id-rsa" {
  title = "id-rsa"
  key   = file("C:/Users/dimal/.ssh/id_rsa.pub")
}