#!make

-include .makerc-vars ### Default make variables
-include custom/makefiles/.makerc-custom ### Custom (team/org) make functions
-include personal/.makerc-personal ### Your personalized make functions
-include .makerc ### Default initialization file
export

.DEFAULT_GOAL := help

## help: List all available make commands with descriptions
.PHONY: help
help:
	@echo ${LOGO} | base64 -d
	@echo
	@sed -nr 's/^##\s+/\t/p' ${MAKEFILE_LIST} | column -t -s ':'

## start: Start Catapult (if not running) and enter it
.PHONY: start
start:
	@${ROOT_DIR}/scripts/general/start.sh

## restart: Restarts Catapult and enters it
.PHONY: restart
restart:
	@${ROOT_DIR}/scripts/general/start.sh restart

## stop: Stop and remove Catapult container
.PHONY: stop
stop:
	@${ROOT_DIR}/scripts/general/start.sh stop

## clean: Stop and remove Catapult container and Docker image
.PHONY: clean
clean:
	@${MAKEVAR_SUDO_COMMAND} ${ROOT_DIR}/scripts/general/cleanup.sh

## build: Build Catapult image locally (development & testing)
.PHONY: build
build:
	@bash ${ROOT_DIR}/scripts/general/checks.sh
	@${MAKEVAR_SUDO_COMMAND} docker buildx create --use --driver-opt network=host
	@${MAKEVAR_SUDO_COMMAND} docker buildx build ${BUILD_ARGS} --network host --progress plain --tag ${IMAGE_FULL} . --load

## print-variables: Print environment variables (for debbuging)
.PHONY: print-variables
print-variables:
	@env | sort
