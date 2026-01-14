group "default" {
  targets = [
    "backend",
    "nginx",
  ]
}

variable "DOCKERHUB_USERNAME" {
  default = "krivolapovdev"
}

variable "IMAGE_TAG" {
  default = "latest"
}

target "backend" {
  context = "./backend"
  tags = [
    "${DOCKERHUB_USERNAME}/backend:${IMAGE_TAG}",
    "${DOCKERHUB_USERNAME}/backend:latest"
  ]
}

target "nginx" {
  context = "./nginx"
  tags = [
    "${DOCKERHUB_USERNAME}/nginx:${IMAGE_TAG}",
    "${DOCKERHUB_USERNAME}/nginx:latest"
  ]
}
