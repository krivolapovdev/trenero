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
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}

target "nginx" {
  context = "./frontend"
  tags = [
    "${DOCKERHUB_USERNAME}/nginx:${IMAGE_TAG}",
    "${DOCKERHUB_USERNAME}/nginx:latest"
  ]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
