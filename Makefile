#!make

-include .makerc-vars ### your personal values
-include .makerc-custom ### for your custom make functions
-include .makerc-personal ### for your own make functions
-include .makerc ### Default initialization file
export

.DEFAULT_GOAL := help

## help: List all available make targets with descriptions
.PHONY: help
help: project-banner
	@echo "${C_YELLOW}[*] ${C_WHITE}usage: ${C_MAGENTA}make ${C_CYAN}<target>${C_RST}"
	@echo
	@sed -nr 's/^##\s+/\t/p' ${MAKEFILE_LIST} | column -t -s ':' | sort

## checks: Running different checks before starting the container
.PHONY: checks
checks:
	@bash ${ROOT_DIR}/scripts/general/checks.sh

## prepare: Run checks and install project requirements
.PHONY: prepare
prepare: customizations checks
	@${MAKEVAR_SUDO_COMMAND} ${ROOT_DIR}/scripts/general/prepare.sh

## start-tasks: Runs requires configurations tasks before starting the container
# .PHONY: start-tasks
start-tasks: checks
	@${ROOT_DIR}/scripts/general/start-tasks-loader.sh

## build: Run checks and then build container image
.PHONY: build
build: customizations checks
	@${MAKEVAR_SUDO_COMMAND} docker buildx create --use --driver-opt network=host
	@${MAKEVAR_SUDO_COMMAND} docker buildx build ${BUILD_ARGS} --network host --tag ${IMAGE_FULL} . --load

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
start: project-banner customizations checks start-tasks run shell

## project-banner: Print project banner
.PHONY: project-banner
project-banner:
	@echo ${LOGO} | base64 -d
