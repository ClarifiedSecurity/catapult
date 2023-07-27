#!make

-include .makerc-vars ### your personal values
-include .makerc-custom ### for your custom make functions
-include .makerc-personal ### for your own make functions
-include .makerc ### Default initialization file
export

.DEFAULT_GOAL := help

C_RED      = \033[31m
C_GREEN    = \033[32m
C_YELLOW   = \033[33m
C_BLUE     = \033[34m
C_MAGENTA  = \033[95m
C_CYAN     = \033[36m
C_WHITE    = \033[97m
CB_RED     = \033[91;1m
CB_GREEN   = \033[92;1m
CB_YELLOW  = \033[93;1m
CB_BLUE    = \033[94;1m
CB_MAGENTA = \033[95;1m
CB_CYAN    = \033[96;1m
CB_WHITE   = \033[97;1m
C_RST      = \033[0m

## help: List all available make targets with descriptions
.PHONY: help
help: project-banner
	@echo -e "${C_YELLOW}[*] ${C_WHITE}usage: ${C_MAGENTA}make ${C_CYAN}<target>${C_RST}"
	@sed -nr 's/^##\s+/\t/p' ${MAKEFILE_LIST} | column -t -s ':' | sort

## checks: Running different checks before starting the container
.PHONY: checks
checks:
	@bash ${ROOT_DIR}/scripts/general/checks.sh

## prepare: Run checks and install project requirements
.PHONY: prepare
prepare: checks customizations
	@${MAKEVAR_SUDO_COMMAND} ${ROOT_DIR}/scripts/general/prepare.sh

## start-tasks: Runs requires configurations tasks before starting the container
# .PHONY: start-tasks
start-tasks: checks
	@${ROOT_DIR}/scripts/general/start-tasks-loader.sh

## build: Run checks and then build container image
.PHONY: build
build: checks customizations
	@${MAKEVAR_SUDO_COMMAND} docker buildx create --use
	@${MAKEVAR_SUDO_COMMAND} docker buildx build ${BUILD_ARGS} -t ${IMAGE_FULL} . --load

## run: Run the container
.PHONY: run
run:
	@${MAKEVAR_SUDO_COMMAND} ${ROOT_DIR}/scripts/general/run.sh

## stop: Stop the container
.PHONY: stop
stop:
	@${MAKEVAR_SUDO_COMMAND} docker stop ${CONTAINER_NAME} || true

## shell: Go into container shell via entrypoint
.PHONY: shell
shell:
	@${MAKEVAR_SUDO_COMMAND} docker exec -it ${CONTAINER_NAME} ${CONTAINER_ENTRYPOINT}

## shell-raw: Bypass docker-entrypoint.sh and directly into shell
.PHONY: shell-raw
shell-raw:
	${MAKEVAR_SUDO_COMMAND} docker exec -it ${CONTAINER_NAME} zsh

## docker-login: Log in Docker registry and copy the credentials under root
.PHONY: docker-login
docker-login:
	@${MAKEVAR_SUDO_COMMAND} ${ROOT_DIR}/scripts/general/docker-login.sh

## clean: Stop and delete the container and the image
.PHONY: clean
clean: stop
	@${MAKEVAR_SUDO_COMMAND} ${ROOT_DIR}/scripts/general/cleanup.sh

## customizations: Clone and configure Catapult customizations
.PHONY: customizations
customizations:
	@${ROOT_DIR}/scripts/general/catapult-customizer.sh

## start: Removes any existing container, starts the container and runs shell
.PHONY: start
start: project-banner checks customizations start-tasks run shell

## project-banner: Print project banner
.PHONY: project-banner
project-banner:
	@echo ${LOGO} | base64 -d
