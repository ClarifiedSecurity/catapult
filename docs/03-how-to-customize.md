# How to customize

Catapult has 2 modes of customization:

- Personalization - Where users can set their own preferences that will only affect them.
- Customization - Where preferences are configured in a way that they apply to your team/organization etc.

## Personalization

There several ways to personalize Catapult:

### Personal Docker Compose file

`docker/docker-compose-personal.yml` - This file is used to add to, or override the default configuration values defined in `docker/docker-compose.yml`. It can be used to add custom volumes, environment variables, or other settings that are specific to the user.

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

`personal/.makerc-personal` - This file is used to add custom makefile variables that are specific to the user.

Potential use cases for this file include:

- Adding custom make commands that are specific to the user

## Personal CLI commands

`personal/autocomplete.yml` - This file is used to add custom autocomplete commands for `ctp` that are specific to the user. Refer to the default [autocomplete.yml](https://github.com/ClarifiedSecurity/catapult/blob/main/defaults/autocomplete.yml) as an example

## Customization

To customize Catapult for your team or organization, a separate git project needs to be created that contains all of the required files. Then users need to be pointed that project using the `MAKEVAR_CATAPULT_CUSTOMIZER_REPO` variable in their `.makerc-vars` file. For a full list of available options, see the example [Catapult Customizer](https://github.com/ClarifiedSecurity/catapult-customizer) repo.
