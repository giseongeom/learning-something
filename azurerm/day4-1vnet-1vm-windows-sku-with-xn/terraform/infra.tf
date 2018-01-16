module "resource_group" {
  source = "./infra/resource_group"

  name     = "lab-westus"
  location = "westus"
}
