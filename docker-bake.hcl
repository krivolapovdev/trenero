group "default" {
  targets = [
    "server"
  ]
}

variable "DOCKERHUB_USERNAME" {
  default = "krivolapovdev"
}

variable "IMAGE_TAG" {
  default = "latest"
}

target "server" {
  context = "./server"
  tags = [
    "${DOCKERHUB_USERNAME}/server:${IMAGE_TAG}",
    "${DOCKERHUB_USERNAME}/server:latest"
  ]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
