#!make

-include .makerc-vars ### Default make variables
-include custom/makefiles/.makerc-custom ### Custom (team/org) make functions
-include personal/.makerc-personal ### Your personalized make functions
-include .makerc ### Default initialization file
export

.DEFAULT_GOAL := help

## help: List all available make targets with descriptions
.PHONY: help
help: project-banner
	@echo
	@sed -nr 's/^##\s+/\t/p' ${MAKEFILE_LIST} | column -t -s ':' | sort

## checks: Running different checks before starting the container
.PHONY: checks
checks:
	@bash ${ROOT_DIR}/scripts/general/checks.sh

## start-tasks: Runs requires configurations tasks before starting the container
# .PHONY: start-tasks
start-tasks: checks
	@${ROOT_DIR}/scripts/general/start-tasks-loader.sh

## build: Run checks and then build container image
.PHONY: build
build: checks
	@make customizations --no-print-directory
	@${MAKEVAR_SUDO_COMMAND} docker buildx create --use --driver-opt network=host
	@${MAKEVAR_SUDO_COMMAND} docker buildx build ${BUILD_ARGS} --network host --progress plain --tag ${IMAGE_FULL} . --load

## stop: Stop the container
.PHONY: stop
stop:
	@${ROOT_DIR}/scripts/general/start.sh stop

## shell-raw: Bypass docker-entrypoint.sh and directly into shell
.PHONY: shell-raw
shell-raw:
	${MAKEVAR_SUDO_COMMAND} docker exec -it ${CONTAINER_NAME} zsh

## clean: Stop and delete the container and the image
.PHONY: clean
clean:
	@${MAKEVAR_SUDO_COMMAND} ${ROOT_DIR}/scripts/general/cleanup.sh

## customizations: Clone and configure Catapult customizations
.PHONY: customizations
customizations:
	@${ROOT_DIR}/scripts/general/catapult-customizer.sh

## start: Starts the container (if not running) and enters the shell
.PHONY: start
start:
	@${ROOT_DIR}/scripts/general/start.sh

## restart: Restarts the container and enters the shell
.PHONY: restart
restart:
	@${ROOT_DIR}/scripts/general/start.sh restart

## project-banner: Print project banner
.PHONY: project-banner
project-banner:
	@echo ${LOGO} | base64 -d

## print-env: Prints environment variables for debbuging
.PHONY: project-env
print-env:
	@env | sort
