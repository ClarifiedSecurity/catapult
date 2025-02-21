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

## update: Check for Catapult updates
.PHONY: update
update:
	@${ROOT_DIR}/scripts/general/update-catapult.sh

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

## customizations: Pulls the latest Catapult customizations if they exist
.PHONY: customizations
customizations:
	@${ROOT_DIR}/scripts/general/catapult-customizer.sh

## build: Build Catapult image locally (development & testing)
.PHONY: build
build:
	@${ROOT_DIR}/scripts/general/build.sh

## print-variables: Print environment variables (for debugging)
.PHONY: print-variables
print-variables:
	@env | sort
