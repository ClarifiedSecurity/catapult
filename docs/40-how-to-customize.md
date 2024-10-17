# How to customize

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
