# How to use

## Enter the Catapult

- Start the Catapult container and connect to it with:

```sh
make start
```

- Connect to an already started Catapult container with:

```sh
make shell
```

Once inside the Catapult container you can type `ctp-` and use the tab key to see all of the available commands, here is also list of all commands with examples:

## General commands

- Installs all Ansible roles, collections and Python dependencies (useful for development)

```zsh
ctp-install-all-requirements
```

- Installs only Ansible roles & collections from files that are NOT named requirements.yml under /srv/requirements folder (useful for development).

```zsh
ctp-install-custom-requirements
```

- Lists all available projects under /srv/inventories and allows you to select one

```zsh
ctp-select-project
```

## Deploy commands

Examples for the deploy commands are done with one machine but you can use the same commands with multiple machines by using the `all` keyword or a group_var. Use Ansible's documentation for [Advanced deploy patterns](https://docs.ansible.com/ansible/latest/user_guide/intro_patterns.html)

### ctp-deploy

Run the full playbook and creates the VM if it doesn't exist

_Example usage:_

- Deploys the VM with the given inventory_hostname

```zsh
ctp-deploy <inventory_hostname>
```

### ctp-redeploy

Destroys the existing VM and runs the the `ctp-deploy` command

_Example usage:_

- Redeploys the VM with the given inventory_hostname

```zsh
ctp-redeploy <inventory_hostname>
```

### ctp-deploy-until-configuration

Deploys the machine, stops the play after os_configuration role and creates a snapshot. This is a useful command if you want to create a snapshot of the VM after the OS is installed and configured. You can then use the snapshot to speed up the deployment/development process. You can deploy multiple machines that depend on each other in parallel and use the `ctp-deploy-from-configuration` to configure them in the correct order afterwards.

_Example usage:_

- Deploys the VM with the given inventory_hostname and creates a snapshot

```zsh
ctp-deploy-until-configuration <inventory_hostname>
```

### ctp-redeploy-until-configuration

Redeploys the machine, stops the play after os_configuration role and creates a snapshot. This is a useful command if you want to create a snapshot of the VM after the OS is installed and configured. You can then use the snapshot to speed up the deployment/development process. You can deploy multiple machines that depend on each other in parallel and use the `ctp-deploy-from-configuration` to configure them in the correct order afterwards.

_Example usage:_

- Redeploys the VM with the given inventory_hostname and creates a snapshot

```zsh
ctp-redeploy-until-configuration <inventory_hostname>
```

### ctp-deploy-from-configuration

Starts the play from /srv/<project_name>/pre_vm_role part of the playbook and runs until the end. This is a useful command during mass deploy when you have run the `ctp-deploy-until-configuration` first and then you want to configure the cloned machines. Should anything go wrong you can always revert to the snapshot and start again.

_Example usage:_

- Starts configuring the VM with the given inventory_hostname from the pre_vm_role.

```zsh
ctp-deploy-from-configuration <inventory_hostname>
```

### ctp-deploy-role

Runs only the /srv/<project_name>/vm/<role_name> part of the playbook and then stops. This is a useful during role developing and or when you want to minimize the time it takes to configure something. For an example only reconfiguring the user accounts of the machine by using single_role with `clarified.core.accounts` role.

_Example usage:_

- Only runs the role for inventory_hostname and then stops the play can also be used against all or group_var

```zsh
ctp-deploy-role <inventory_hostname>
```

- Looks for role under `/srv/<project_name>/roles/<role>` and only runs it.

```zsh
ctp-deploy-role <inventory_hostname> -e single_role=<role>
```

- Looks for role with the fully qualified role name (FQCN) in the installed collections and only runs that and stops

```zsh
ctp-deploy-role <inventory_hostname> -e single_role=<role.fqcn>
```

### ctp-deploy-network

Runs ctp-deploy and also includes networks configuration role

_Example usage:_

- Deploys the VM with the given inventory_hostname and also configures the networks

```zsh
ctp-deploy-network <inventory_hostname>
```

### ctp-deploy-fresh

Runs deploy as if the machine does not exist. This can be useful when deploy has failed before configuring accounts. Use this command to deploy the machine again as if it didn't exist and thus use the default values for the accounts.

_Example usage:_

- Deploys the VM with the given inventory_hostname as if it didn't exist

```zsh
ctp-deploy-fresh <inventory_hostname>
```

### ctp-remove

Destroys the existing VM

_Example usage:_

- Destroys the VM with the given inventory_hostname

```zsh
ctp-remove <inventory_hostname>
```

### ctp-rebuild-linode-vm

Rebuilds the existing Linode VM with a new disk but keeps the existing IP

_Example usage:_

- Rebuilds the VM with the given inventory_hostname

```zsh
ctp-rebuild-linode-vm <inventory_hostname>
```

## Deploy commands based on @start.retry file

Whenever a deploy fails a start.retry file is created under /srv/inventories/<project_name>/start.retry. Instead of going trough the logs to find what machines failed you can use the following commands to deploy only the failed machines. Keep in mind that only that latest fail is written into the start.retry file so when running multiple instances of Catapult (using `make shell` multiple times) and multiple deploys in parallel the latest fail will be written into the start.retry file.

- Run `ctp-deploy` on failed machines based on start.retry file

```zsh
ctp-retry-deploy
```

- Run `ctp-redeploy` failed machines based on start.retry file

```zsh
ctp-retry-redeploy
```

- Runs `ctp-deploy-until-configuration` on failed machines based on start.retry file

```zsh
ctp-retry-deploy-until-configuration
```

- Runs `ctp-redeploy-until-configuration` on failed machines based on start.retry file

```zsh
ctp-retry-redeploy-until-configuration
```

- Run `ctp-deploy-from-configuration` on failed machines based on start.retry file

```zsh
ctp-retry-deploy-from-configuration
```

- Run `ctp-deploy-role` on failed machines based on start.retry file

```zsh
ctp-retry-deploy-role
```

## Snapshot modes

Different commands for managing machine snapshots. Note that the commands might not work with all providers. In that case you will receive a message that the command not implemented for the provider.

### ctp-snapshot

Create a snapshot of the VM

_Example usage:_

- Creates a snapshot of the VM for the given inventory_hostname with the default snapshot name

```zsh
ctp-snapshot <inventory_hostname>
```

- Creates a snapshot of the VM for the given inventory_hostname with the given snapshot name

```zsh
ctp-snapshot <inventory_hostname> -e snapshot_name=<snapshot_name>
```

### ctp-clean-snapshot

Remove all existing snapshots and create a new snapshot of the VM

_Example usage:_

- Removes all existing snapshots and creates a new snapshot of the VM for the given inventory_hostname

```zsh
ctp-clean-snapshot <inventory_hostname>
```

- Removes all existing snapshots and creates a new snapshot of the VM for the given inventory_hostname with the given snapshot name

```zsh
ctp-clean-snapshot <inventory_hostname> -e snapshot_name=<snapshot_name>
```

### ctp-live-snapshot

Creates a snapshot of a running machine including memory, mostly applicable to VMware products

_Example usage:_

- Creates a live snapshot of the VM for the given inventory_hostname

```zsh
ctp-live-snapshot <inventory_hostname>
```

- Creates a live snapshot of the VM for the given inventory_hostname with the given snapshot name

```zsh
ctp-live-snapshot <inventory_hostname> -e snapshot_name=<snapshot_name>
```

### ctp-revert

Revert to the latest default snapshot or to the given snapshot name

_Example usage:_

- Reverts the VM for the given inventory_hostname to the latest default snapshot

```zsh
ctp-revert <inventory_hostname>
```

- Reverts the VM for the given inventory_hostname to the given snapshot name

```zsh
ctp-revert <inventory_hostname> -e snapshot_name=<snapshot_name>

```

### ctp-remove-snapshot

Removing snapshot, requires -e snapshot_name=snapshot_name_to_remove

_Example usage:_

- Removes the snapshot for the given inventory_hostname

```zsh
ctp-remove-snapshot <inventory_hostname> -e snapshot_name=snapshot_name_to_remove
```

- Removes all snapshots for the given inventory_hostname

```zsh
ctp-remove-snapshot <inventory_hostname> -e remove_all_snapshots=true
```

### ctp-rename-snapshot

Renaming snapshot, requires -e snapshot_name=existing_snapshot_name_to_rename -e new_snapshot_name=new_snapshot_name

_Example usage:_

- Renames the snapshot for given inventory_hostname machine

```zsh
ctp-rename-snapshot <inventory_hostname> -e snapshot_name=existing_snapshot_name_to_rename -e new_snapshot_name=new_snapshot_name
```

## Power state

These commands are for managing the power state of the VMs. Without connection to them over SSH. For an example using VMTools on VMware products.

### ctp-poweron

Power on VM

### ctp-restart

Restart VM

### ctp-shutdown

Shut down VM (graceful shutdown)

### ctp-poweroff

Power off VM (ungraceful shutdown)

### ctp-reset

Reset VM (very ungraceful)

_Example usage:_

- Powers on the VM for the given inventory_hostname

```zsh
ctp-poweron <inventory_hostname>
```

- Restarts the VM for the given inventory_hostname

```zsh
ctp-restart <inventory_hostname>
```

- Shuts down the VM for the given inventory_hostname

```zsh
ctp-shutdown <inventory_hostname>
```

- Powers off the VM for the given inventory_hostname

```zsh
ctp-poweroff <inventory_hostname>
```

- Resets the VM for the given inventory_hostname

```zsh
ctp-reset <inventory_hostname>
```

## MISC commands

### ctp-update-os

Runs only the clarified.core.updates role on the given targets. Useful for only updating the OS packages.

_Example usage:_

- Updates the OS packages for the given inventory_hostname

```zsh
ctp-update-os <inventory_hostname>
```

### ctp-list

List the inventory_hostnames for the given project, group_var or just to check if the inventory_hostname is valid. This command is useful to use a a pre-check before running any of the other commands. You can make sure that your advanced regex is correct and you don't run the command on the wrong inventory_hostname.

_Example usage:_

- Checks if the inventory_hostnames exists

```zsh
ctp-list <inventory_hostname>
```

- Lists all of the inventory_hostnames for the given project

```zsh
ctp-list all
```

- Lists all of the inventory_hostnames for the given group_var

```zsh
ctp-list <group_var>
```

### ctp-list-vars

List (most) of the variables for the given inventory_hostname. This command is useful to check what variables are available in the given inventory_hostname. It is not a complete list of all the variables because of home some host_vars get loaded but it's useful when getting started with the role development.

_Example usage:_

- Lists the variables for the given inventory_hostname

```zsh
ctp-list-vars <inventory_hostname>
```

### ctp-rename-vm

Renaming VM. This command is useful when the naming scheme for the VMs has changed and you want to rename some or all of them for the project.

_Example usage:_

- Renames the VM for the given inventory_hostname with the given values

```zsh
ctp-rename-vm <inventory_hostname> -e old_vm_name=<old_name> -e new_vm_name=<new_name>
```

- Renames the VM for the given inventory_hostname where the old name is the current value defined in

```zsh
cpp-rename-vm <inventory_hostname> -e new_vm_name=<new_name>the group or host vars
```

### ctp-get-ip

Getting the IP's and FQDN of the VM

_Example usage:_

- Gets the IP's and FQDN of the VM for the given inventory_hostname

```zsh
ctp-get-ip <inventory_hostname>
```
