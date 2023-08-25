# How to customize

Catapult has 2 modes of customization:

- Personalization - Where users can set their own preferences that will only affect them.
- Customization - Where preferences are configured in a way that they apply to all users.

## Personalization

There are 2 ways to personalize Catapult:

### Personal Docker Compose file

`docker/docker-compose-personal.yml` - This file is used to add to, or override the default configuration values defined in `docker/docker-compose.yml`.

Potential use cases for this file include:

- Mounting custom shell rc files (currently only .zshrc supported)
- Using environmental variables to override default Ansible values that come from `ansible.cfg`
- Mounting custom files into the container

### Personal aliases file

`container/home/builder/.personal_aliases` - This file is used to add custom aliases that will only be available to the user.

Potential use cases for this file include:

- Adding custom aliases that are not available in the default aliases file
- Adding aliases that are specific to the user

## Customization

To customize Catapult for all users, a separate git project needs to be created that contains all of the required files. Then users need to point to that project using the `MAKEVAR_CATAPULT_CUSTOMIZER_REPO` variable in their `.makerc-vars` file. For a full list of available options, see the example [Catapult Customizer](https://github.com/ClarifiedSecurity/catapult-customizer) repo.
