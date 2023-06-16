terraform {
  cloud {
    organization = "fancycorp"

    workspaces {
      name = "multispace-blog"
    }
  }
}
