# How to customize

Catapult has 2 modes of customization:

- Personalization - Where users can set their own preferences that will only affect them.
- Customization - Where preferences are configured in a way that they apply to your team/organization etc.

## Personalization

There several ways to personalize Catapult:

### Personal Docker Compose file

`personal/docker-compose-personal.yml` - This file is used to add to, or override the default configuration values defined in `docker/docker-compose.yml`. It can be used to add custom volumes, environment variables, or other settings that are specific to the user.

Potential use cases for this file include:

- Mounting custom shell rc files (currently only .zshrc supported)
- Adding extra environmental variables to override default Ansible values that come from `ansible.cfg`
- Mounting custom files into the container

### Personal aliases file

`personal/.personal_aliases` - This file is used to add custom shell aliases features etc.

Potential use cases for this file include:

- Adding custom aliases that are not available in the defaults
- Adding aliases that are specific to the user
- Adding specific functions that are not available in the defaults

### Personal makefile configuration

`personal/.makerc-personal` - This file is used to add custom makefile variables that are specific to the user. Refer to the `.makerc-vars` file for available options.

Potential use cases for this file include:

- Adding custom make commands that are specific to the user

## Personal CLI commands

`personal/autocomplete.yml` - This file is used to add custom autocomplete commands for `ctp` that are specific to the user. Refer to the default [autocomplete.yml](https://github.com/ClarifiedSecurity/catapult/blob/main/defaults/autocomplete.yml) as an example

## Customization

To customize Catapult for your team or organization, a separate git project needs to be created that contains all of the required files. Then users need to be pointed that project using the `MAKEVAR_CATAPULT_CUSTOMIZER_REPO` variable in their `personal/.makerc-personal` file. Use the [Catapult Customizer](https://github.com/ClarifiedSecurity/catapult-customizer) repo as an example.

The structure of the customization repo is as follows:

## Folders

- `certificates` - Contains the trusted certificate files that will be installed into the container. The certificate format must be base64 and the file name format must be <certificate_name>.crt

- `container` - Contains .custom_aliases file that will be copied into the container. Refer to the [.default_aliases](https://github.com/ClarifiedSecurity/Catapult/blob/main/container/home/builder/.default_aliases) file as an example on how to create .custom_aliases.

- `docker` - Contains custom `docker-compose-custom.yml` to add extra environment variables/volumes/etc to the container. Refer to the default [docker-compose-custom.yml](https://github.com/ClarifiedSecurity/catapult/blob/main/defaults/docker-compose-custom.yml) & [docker-compose.yml](https://github.com/ClarifiedSecurity/catapult/blob/main/docker/docker-compose.yml) for examples.

- `docker-entrypoints` - Contains custom docker-entrypoint scripts that will run inside the container during `make start`. Refer to default [entrypoint](https://github.com/ClarifiedSecurity/Catapult/tree/main/scripts/entrypoints) scripts for examples.

- `makefiles` - Contains custom .makerc\* files specific to your organization or project. Refer to the default [.makerc](https://github.com/ClarifiedSecurity/Catapult/blob/main/.makerc) file for examples and the [Makefile](https://github.com/ClarifiedSecurity/Catapult/blob/main/Makefile#L3-L5) for different types of makefiles that get loaded if they exists.

- `scripts` - Contains custom scripts that can be used with the project. For example with `make` commands

- `start-tasks` - Contains scripts that will be run on the host during container startup. Refer to existing [start-tasks](https://github.com/ClarifiedSecurity/Catapult/tree/main/scripts/start-tasks) for examples.

## Files

- `start.yml` - In some rare cases you might want to customize the deployment tree of Catapult. For that you can create your own start.yml file and it will be used instead of the default one. Refer to the default [start.yml](https://github.com/ClarifiedSecurity/Catapult/blob/main/defaults/start.yml) as an example.

- `autocomplete.yml` - Contains custom completion commands that can be used with the `ctp` command in the container. Refer to the default [autocomplete.yml](https://github.com/ClarifiedSecurity/catapult/blob/main/defaults/autocomplete.yml) as an example.
