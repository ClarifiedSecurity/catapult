#!make

-include .makerc-vars ### Default make variables
-include custom/makefiles/.makerc-custom ### Custom (team/org) make functions
-include personal/.makerc-personal ### Your personalized make functions
-include .makerc ### Default initialization file
export

.DEFAULT_GOAL := help

## help: List all available make targets with descriptions
.PHONY: help
help:
	@echo ${LOGO} | base64 -d
	@echo
	@sed -nr 's/^##\s+/\t/p' ${MAKEFILE_LIST} | column -t -s ':' | sort

## build: Run checks and then build container image
.PHONY: build
build:
	@bash ${ROOT_DIR}/scripts/general/checks.sh
	@${MAKEVAR_SUDO_COMMAND} docker buildx create --use --driver-opt network=host
	@${MAKEVAR_SUDO_COMMAND} docker buildx build ${BUILD_ARGS} --network host --progress plain --tag ${IMAGE_FULL} . --load

## stop: Stop and remove the container
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

## start: Starts the container (if not running) and enters the shell
.PHONY: start
start:
	@${ROOT_DIR}/scripts/general/start.sh

## restart: Restarts the container and enters the shell
.PHONY: restart
restart:
	@${ROOT_DIR}/scripts/general/start.sh restart

## print-variables: Prints environment variables for debbuging
.PHONY: print-variables
print-variables:
	@env | sort
