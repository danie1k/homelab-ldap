NAME = homelab-ldap

# Docker

build:
	@docker build -t $(NAME) .

build-nocache:
	@docker build -t $(NAME) --no-cache .

run:
	@docker rm -f $(NAME) || true
	docker run --rm --name $(NAME) -p 8088:80 -p 389:389 $(NAME)

# QA

hadolint:
	@hadolint --version
	@hadolint Dockerfile

shellcheck:
	@shellcheck --version
	@shellcheck docker/docker-entrypoint.sh

yamllint:
	@yamllint --version
	@yamllint --strict .

lint-all: hadolint shellcheck yamllint


.PHONY: build build-nocache hadolint run shellcheck yamllint
