# How to use Catapult?

Once inside the Catapult container you can type `ctp-` and use the tab key to see all of the available commands, here is also list of all commands with examples:

## General commands

`ctp-install-all-requirements` - Installs all Ansible roles, collections and Python dependencies

`ctp-install-custom-requirements` - Installs only Ansible roles & collections from files that are not named requirements.yml under /srv/requirements folder.

`ctp-select-project` - Lists all available projects under /srv/inventories and allows you to select one

## Deploy commands

Examples for the deploy commands are done with one machine but you can use the same commands with multiple machines by using the `all` keyword or a group_var. Use Ansible's documentation for [Advanced deploy patterns](https://docs.ansible.com/ansible/latest/user_guide/intro_patterns.html)

`ctp-deploy` - Run the full playbook and creates the VM if it doesn't exist

_Example usage:_

```zsh
ctp-deploy <inventory_hostname> # Deploys the VM with the given inventory_hostname
```

`ctp-redeploy` - Destroys the existing VM and runs the full playbook (ctp-deploy command)

_Example usage:_

```zsh
ctp-redeploy <inventory_hostname> # Redeploys the VM with the given inventory_hostname
```

`ctp-redeploy-until-configuration` - Redeploys the machine, stops the play after os_configuration role and creates a snapshot

_Example usage:_

```zsh
ctp-deploy-until-configuration <inventory_hostname> # Redeploys the VM with the given inventory_hostname and creates a snapshot
```

This is a useful command if you want to create a snapshot of the VM after the OS is installed and configured. You can then use the snapshot to speed up the deployment/development process. This you can deploy multiple machines that depend on each other in parallel and use the `ctp-deploy-from-configuration` to configure them in the correct order.

`ctp-deploy-from-configuration` - Starts the play from /srv/<project_name>/pre_vm_role part of the playbook and runs until the end

_Example usage:_

```zsh
ctp-deploy-from-configuration <inventory_hostname> # Starts configuring the VM with the given inventory_hostname from the pre_vm_role
```

This is a useful command during mass deploy when you have ran the `ctp-deploy-until-configuration` first and then you want to configure the cloned machines. Should anything go wrong you can always revert to the snapshot and start again.

`ctp-deploy-role` - Runs only the /srv/<project_name>/vm/<role_name> part of the playbook and then stops

_Example usage:_

```zsh
ctp-deploy-role <inventory_hostname> # Only runs the role for inventory_hostname and then stops the play can also be used against all or group_var
ctp-deploy-role <inventory_hostname> -e single_role=<role> # Looks for role under /srv/<project_name>/roles/<role> and only runs it.
ctp-deploy-role <inventory_hostname> -e single_role=<role.fqcn> # Looks for role with the fully qualified role name (FQCN) in the installed collections and only runs that and stops
```

This is a useful during role developing and or when you want to minimize the time it takes to configure something. For an example only reconfiguring the user accounts of the machine by using single_role with `clarified.core.accounts` role.

`ctp-deploy-network` - Runs ctp-deploy and also includes networks configuration role

_Example usage:_

```zsh
ctp-deploy-network <inventory_hostname> # Deploys the VM with the given inventory_hostname and also configures the networks
```

`ctp-deploy-fresh` - Runs deploy as it if the machine does not exist

_Example usage:_

```zsh
ctp-deploy-fresh <inventory_hostname> # Deploys the VM with the given inventory_hostname as if it didn't exist
```

`ctp-remove` - Destroys the existing VM

_Example usage:_

```zsh
ctp-remove <inventory_hostname> # Destroys the VM with the given inventory_hostname
```

`ctp-rebuild-linode-vm` - Rebuilds the existing Linode VM with a new disk but keeps the existing IP

_Example usage:_

```zsh
ctp-rebuild-linode-vm <inventory_hostname> # Rebuilds the VM with the given inventory_hostname
```

## Deploy commands based on @start.retry file

Whenever a deploy fails a start.retry file is created under /srv/inventories/<project_name>/start.retry. Instead of going trough the logs to find what machines failed you can use the following commands to deploy only the failed machines. Keep in mind that only that latest fail is written into the start.retry file so when running multiple instances of Catapult (using `make shell` multiple times) and multiple deploys in parallel and you might get inconsistent results.

`ctp-retry-deploy` - Deploys failed machines based on start.retry file

`ctp-retry-redeploy` - Redeploy failed machines based on start.retry file

`ctp-retry-until-configuration` - Runs ctp-deploy-until-configuration on failed machines based on start.retry file

`ctp-deploy-from-configuration-` - Runs ctp-deploy-from-configuration on failed machines based on start.retry file

`ctp-retry-deploy-role` - Runs ctp-retry-deploy-role on failed machines based on start.retry file

## Snapshot modes

Different commands for managing machine snapshots. Note that the commands might not work with all providers. In that case you will receive a message that the command not implemented for the provider.

`ctp-snapshot` - Create a snapshot of the VM

_Example usage:_

```zsh
ctp-snapshot <inventory_hostname> # Creates a snapshot of the VM for the given inventory_hostname with the default snapshot name
ctp-snapshot <inventory_hostname> -e snapshot_name=<snapshot_name> # Creates a snapshot of the VM for the given inventory_hostname with the given snapshot name
```

`ctp-clean-snapshot` - Remove all existing snapshots and create a new snapshot of the VM

_Example usage:_

```zsh
ctp-clean-snapshot <inventory_hostname> # Removes all existing snapshots and creates a new snapshot of the VM for the given inventory_hostname
ctp-clean-snapshot <inventory_hostname> -e snapshot_name=<snapshot_name> # Removes all existing snapshots and creates a new snapshot of the VM for the given inventory_hostname with the given snapshot name
```

`ctp-live-snapshot` - Creates a snapshot of a running machine including memory, mostly applicable to VMware products

_Example usage:_

```zsh
ctp-live-snapshot <inventory_hostname> # Creates a live snapshot of the VM for the given inventory_hostname
ctp-live-snapshot <inventory_hostname> -e snapshot_name=<snapshot_name> # Creates a live snapshot of the VM for the given inventory_hostname with the given snapshot name
```

`ctp-revert` - Revert to the latest default snapshot or to the given snapshot name

_Example usage:_

```zsh
ctp-revert <inventory_hostname> # Reverts the VM for the given inventory_hostname to the latest default snapshot
ctp-revert <inventory_hostname> -e snapshot_name=<snapshot_name> # Reverts the VM for the given inventory_hostname to the given snapshot name

```

`ctp-remove-snapshot=` - Removing snapshot, requires -e snapshot_name=snapshot_name_to_remove

_Example usage:_

```zsh
ctp-remove-snapshot <inventory_hostname> -e snapshot_name=snapshot_name_to_remove # Removes the snapshot for the given inventory_hostname
ctp-remove-snapshot <inventory_hostname> -e remove_all_snapshots=true # Removes all snapshots for the given inventory_hostname
```

`ctp-rename-snapshot=` - Renaming snapshot, requires -e snapshot_name=existing_snapshot_name_to_rename -e new_snapshot_name=new_snapshot_name

_Example usage:_

```zsh
ctp-rename-snapshot <inventory_hostname> -e snapshot_name=existing_snapshot_name_to_rename -e new_snapshot_name=new_snapshot_name # Renames the snapshot with for given inventory_hostname
```

## Power state

These commands are for managing the power state of the VMs. Without connection to them over SSH. For an example using VMTools on VMware products.

`ctp-poweron` - Power on VM

`ctp-restart` - Restart VM

`ctp-shutdown` - Shut down VM (graceful shutdown)

`ctp-poweroff` - Power off VM (ungraceful shutdown)

`ctp-reset` - Reset VM (very ungraceful)

_Example usage:_

```zsh
ctp-poweron <inventory_hostname> # Powers on the VM for the given inventory_hostname
ctp-restart <inventory_hostname> # Restarts the VM for the given inventory_hostname
ctp-shutdown <inventory_hostname> # Shuts down the VM for the given inventory_hostname
ctp-poweroff <inventory_hostname> # Powers off the VM for the given inventory_hostname
ctp-reset <inventory_hostname> # Resets the VM for the given inventory_hostname
```

## MISC commands

`ctp-update-os` - Runs only the clarified.core.updates role on the given targets. Useful for only updating the OS packages.

_Example usage:_

```zsh
ctp-update-os <inventory_hostname> # Updates the OS packages for the given inventory_hostname
```

`ctp-list` - List the inventory_hostnames for the given project, group_var or just to check if the inventory_hostname is valid

_Example usage:_

```zsh
ctp-list <inventory_hostname> # Checks if the inventory_hostnames exists
ctp-list all # Lists all of the inventory_hostnames for the given project
ctp-list <group_var> # Lists all of the inventory_hostnames for the given group_var
```

This command is useful to use a a pre-check before running any of the other commands. You can make sure that your advanced regex is correct and you don't run the command on the wrong inventory_hostname.

`ctp-list-vars` - List (most) of the variables for the given inventory_hostname

_Example usage:_

```zsh
ctp-list-vars <inventory_hostname> # Lists the variables for the given inventory_hostname
```

This command is useful to check what variables are available in the given inventory_hostname. It is not a complete list of all the variables because of home some host_vars get loaded but it's useful when getting started with the role development.

`ctp-rename-vm` - Renaming VM

_Example usage:_

```zsh
ctp-rename-vm <inventory_hostname> -e old_vm_name=<old_name> -e new_vm_name=<new_name> # Renames the VM for the given inventory_hostname with the given values
cpp-rename-vm <inventory_hostname> -e new_vm_name=<new_name> # Renames the VM for the given inventory_hostname where the old name is the current value defined in the group or host vars
```

This command is useful when the naming scheme for the VMs has changed and you want to rename some or all of them for the project.

`ctp-get-ip` - Getting the IP's and FQDN of the VM

_Example usage:_

```zsh
ctp-get-ip <inventory_hostname> # Gets the IP's and FQDN of the VM for the given inventory_hostname
```
