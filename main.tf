terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

variable "nginx_image" {
  type = string
  default = "nginx:latest"
  description = "nginx image"
}

variable "nginx_name" {
  type = string
  default = "nginx_to_curl"
}

variable "vault_image" {
  type = string
  default = "hashicorp/vault:latest"
  description = "vault image"
}

variable "vault_name" {
  type = string
  default = "terraform_vault"
}

provider "docker" {
  host = "unix:///home/ormazd/.docker/desktop/docker.sock"
}

resource "docker_image" "nginx_image" {
    name = var.nginx_image
    keep_locally = false
}

resource "docker_container" "nginx_to_curl" {
    image = docker_image.nginx_image.image_id
    name = var.nginx_name

    ports {
        internal = 80
        external = 800
    }

    provisioner "local-exec" {
        command = "curl localhost:800 > index.html"
    }
}

resource docker_image "vault_image" {
    name = var.vault_image
    keep_locally = false
}

resource "docker_container" "vault_container" {
    image = docker_image.vault_image.image_id
    name = var.vault_name
    env = ["VAULT_DEV_ROOT_TOKEN_ID=myroot", "VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:1222"]
    ports {
        internal = 1222
        external = 1222
    }
    capabilities {
        add = ["IPC_LOCK"]
    }
}