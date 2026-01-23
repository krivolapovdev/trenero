group "default" {
  targets = [
    "backend",
    "frontend",
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

target "frontend" {
  context = "./frontend"
  tags = [
    "${DOCKERHUB_USERNAME}/frontend:${IMAGE_TAG}",
    "${DOCKERHUB_USERNAME}/frontend:latest"
  ]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
