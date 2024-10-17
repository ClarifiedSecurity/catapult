# How to Personalization

There several ways to personalize Catapult:

## Personal Docker Compose file

`personal/docker-compose-personal.yml` - This file is used to add to, or override the default configuration values defined in `docker/docker-compose.yml`. It can be used to add custom volumes, environment variables, or other settings that are specific to the user.

Potential use cases for this file include:

- Mounting custom shell rc files (currently only .zshrc supported)
- Adding extra environmental variables to override default Ansible values that come from `ansible.cfg`
- Mounting custom files into the container

## Personal aliases file

`personal/.personal_aliases` - This file is used to add custom shell aliases features etc.

Potential use cases for this file include:

- Adding custom aliases that are not available in the defaults
- Adding aliases that are specific to the user
- Adding specific functions that are not available in the defaults

## Personal makefile configuration

`personal/.makerc-personal` - This file is used to add custom makefile variables that are specific to the user. Refer to the `.makerc-vars` file for available options.

Potential use cases for this file include:

- Adding custom make commands that are specific to the user

## Personal CLI commands

`personal/autocomplete.yml` - This file is used to add custom autocomplete commands for `ctp` that are specific to the user. Refer to the default [autocomplete.yml](https://github.com/ClarifiedSecurity/catapult/blob/main/defaults/autocomplete.yml) as an example
