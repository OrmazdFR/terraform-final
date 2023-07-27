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