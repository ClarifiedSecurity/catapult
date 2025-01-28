# How to use

Catapult's commands fall into two categories:

- External commands - All commands that start with `make` are external commands and are used to manage the Catapult container itself.
- Internal commands - All commands that start with `ctp` are internal commands and are used when the user is inside the Catapult container.

Catapult has 2 modes for modifications:

- Personalization - Where users can set their own preferences that will only affect them.
- Customization - Where preferences are configured in a way that they apply to your team/organization etc.

Follow the `# How to Personalization` & `# How to Customize` sections if you want to personalize or customize Catapult.

## Variables

When running catapult for the first time it'll ask you to create a new Ansible Vault file and fill it out with your secrets. The secrets are used to connect to the hypervisors, cloud providers, and other services. Besides the required `deployer_username` & `deployer_password` here are some other variables that you might need when using Catapult with [nova.core](https://github.com/ClarifiedSecurity/nova.core) collection:

- `aws_access_key_id:` - AWS access key ID - can be generated from the AWS Identity and Access Management (IAM) console
- `aws_access_key:` - AWS access key itself - can be generated from the AWS Identity and Access Management (IAM) console
- `linode_api_token:` - Linode API token - can be generated from the [Linode Cloud Manager](https://cloud.linode.com/profile/tokens)

## Enter the Catapult

- Start the Catapult container if it does not exist and connect to it, if the container is running it'll just connect to it:

```sh
make start
```

- Remove > Create > Start the Catapult container and connect to it:

```sh
make restart
```

## Projects

Catapult is designed to work with multiple projects. Each project has its own inventory, roles, and variables. The project is selected when the user enters the Catapult container. The project is selected based on the presence of the `.git` folder in the `/srv/inventories` project directory subfolder. If there is only one project the command will select it automatically. Refer to [catapult-project-example](https://github.com/ClarifiedSecurity/catapult-project-example) on how to structure your project.

## Tips and tricks

- Use tab completion to get the list of available commands. For example, type `ctp` and press tab to get the list of available commands.
- Use `Ctrl + R` to search through the command history and find the command you have used before. Fuzzy search is enabled so you can type parts of the commands or separate words that must be contained in the command.
- Use arrow up after you have started typing the command to get the previous command that starts the same way. For example, if you have used `ctp host deploy` before you can use arrow up to get the previous `ctp host deploy` commands.

## General commands

### ctp secrets edit

- Open your Ansible Vault for editing your personal secrets. When saving the Vault the syntax will be checked and the Vault will be re-encrypted.

```zsh
ctp secrets edit
```

### ctp secrets change-password

- Change the password for your existing Ansible Vault file.

```zsh
ctp secrets change-password
```

### ctp project select

- Lists all available projects under /srv/inventories and allows you to select one if there is only one project the command will select it automatically. The command looks for projects that contain `.git` folder. If you are not using git for your project you can create an empty `.git` folder to make the project selectable.

```zsh
ctp project select
```

### ctp project update-inventory

- Updates the tab-completable inventory cache.

```zsh
ctp project update-inventory
```

## Host commands

Examples for the commands that are run against the inventory_hostname or group in Ansible. These commands usually interact with the target OS and the hypervisor. Use Ansible's documentation for [Advanced deploy patterns](https://docs.ansible.com/ansible/latest/user_guide/intro_patterns.html)

### ctp host list

List the inventory_hostnames for the given project, group_var or just to check if the inventory_hostname is valid. This command is useful to use a a pre-check before running any of the other commands. You can make sure that your advanced regex is correct and you don't run the command on the wrong inventory_hostname.

_Example usage:_

- Checks if the inventory_hostnames exists

```zsh
ctp host list <inventory_hostname>
```

- Lists all of the inventory_hostnames for the given project

```zsh
ctp host list all
```

- Lists all of the inventory_hostnames for the given group_var

```zsh
ctp host list <group_var>
```

### ctp host vars

List (most) of the variables for the given inventory_hostname. This command is useful to check what variables are available in the given inventory_hostname. It is not a complete list of all the variables because of home some `host_vars` get loaded but it's useful when getting started with the role development.

_Example usage:_

- Lists the variables for the given inventory_hostname

```zsh
ctp host vars <inventory_hostname>
```

### ctp host ip

Getting the IP's and FQDN of the VM. Based on the hypervisor or cloud provider and the project the command will look up the IP from the inventory variables or the machine itself. In the latter case the machine needs to be up and running.

_Example usage:_

- Gets the IP's and FQDN of the VM for the given inventory_hostname

```zsh
ctp host ip <inventory_hostname>
```

### ctp host deploy

Run the full playbook and creates the VM if it doesn't exist

_Example usage:_

- Deploys the VM with the given inventory_hostname

```zsh
ctp host deploy <inventory_hostname>
```

### ctp host redeploy

Destroys the existing VM and runs the the `ctp host deploy` command

_Example usage:_

- Redeploys the VM with the given inventory_hostname

```zsh
ctp host redeploy <inventory_hostname>
```

### ctp host deploy-until-configuration

Deploys the machine, stops the play after os_configuration role and creates a snapshot. This is a useful command if you want to create a snapshot of the VM after the OS is installed and configured. You can then use the snapshot to speed up the deployment/development process. You can deploy multiple machines that depend on each other in parallel and use the `ctp host deploy-from-configuration` to configure them in the correct order afterwards.

_Example usage:_

- Deploys the VM with the given inventory_hostname and creates a snapshot

```zsh
ctp host deploy-until-configuration <inventory_hostname>
```

### ctp host redeploy-until-configuration

Redeploys the machine, stops the play after os_configuration role and creates a snapshot. This is a useful command if you want to create a snapshot of the VM after the OS is installed and configured. You can then use the snapshot to speed up the deployment/development process. You can deploy multiple machines that depend on each other in parallel and use the `ctp host deploy-from-configuration` to configure them in the correct order afterwards.

_Example usage:_

- Redeploys the VM with the given inventory_hostname and creates a snapshot

```zsh
ctp host redeploy-until-configuration <inventory_hostname>
```

### ctp host deploy-from-configuration

Starts the play from `/srv/<project_name>/pre_vm_role part` of the playbook and runs until the end. This is a useful command during mass deploy when you have run the `ctp host deploy-until-configuration` first and then you want to configure the cloned machines. Should anything go wrong you can always revert to the snapshot and start again.

_Example usage:_

- Starts configuring the VM with the given inventory_hostname from the pre_vm_role.

```zsh
ctp host deploy-from-configuration <inventory_hostname>
```

### ctp host deploy-role

Runs only the `/srv/<project_name>/vm/<role_name>` part of the playbook and then stops. This is a useful during role developing and or when you want to minimize the time it takes to configure something. For an example only reconfiguring the user accounts of the machine by using single_role with `nova.core.accounts` role.

_Example usage:_

- Only runs the role for inventory_hostname and then stops the play can also be used against all or group_var

```zsh
ctp host deploy-role <inventory_hostname>
```

- Looks for role under defined path and only runs that and stops

```zsh
ctp host deploy-role <inventory_hostname> -e single_role=path/to/role
```

- Looks for role with the fully qualified role name (FQCN) in the installed collections and only runs that and stops

```zsh
ctp host deploy-role <inventory_hostname> -e single_role=<role.fqcn>
```

### ctp host deploy-network

Runs ctp host deploy and also includes networks configuration role

_Example usage:_

- Deploys the VM with the given inventory_hostname and also configures the networks

```zsh
ctp host deploy-network <inventory_hostname>
```

### ctp host deploy-fresh

Runs deploy as if the machine does not exist. This can be useful when deploy has failed before configuring accounts. Use this command to deploy the machine again as if it didn't exist and thus use the default values for the accounts.

_Example usage:_

- Deploys the VM with the given inventory_hostname as if it didn't exist

```zsh
ctp host deploy-fresh <inventory_hostname>
```

### ctp host remove

Destroys the existing VM

_Example usage:_

- Destroys the VM with the given inventory_hostname

```zsh
ctp host remove <inventory_hostname>
```

### ctp host rebuild-linode-vm

Rebuilds the existing Linode VM with a new disk but keeps the existing IP

_Example usage:_

- Rebuilds the VM with the given inventory_hostname

```zsh
ctp host rebuild-linode-vm <inventory_hostname>
```

### ctp host update

Runs only the `nova.core.updates` role on the given targets. Useful for only updating the OS packages.

_Example usage:_

- Updates the OS packages for the given inventory_hostname

```zsh
ctp host update <inventory_hostname>
```

### ctp host connect

Finds the IP and user credentials for a an inventory_hostname and connects to the machine using SSH.

_Example usage:_

- Connect to given inventory_hostname over SSH from the Catapult container

```zsh
ctp host connect <inventory_hostname>
```

### ctp host console

Enters [Ansible console](https://docs.ansible.com/ansible/latest/cli/ansible-console.html) for a given inventory_hostname. This is useful when you want to run ad-hoc commands on the machine or debug variables.

_Example usage:_

- Enters Ansible console for the given inventory_hostname

```zsh
ctp host console <inventory_hostname>
```

## Deploy commands based on @start.retry file

Whenever a deploy fails a start.retry file is created under `/srv/inventories/<project_name>/start.retry`. Instead of going trough the logs to find what machines failed you can use the following commands to deploy only the failed machines. Keep in mind that only that latest fail is written into the start.retry file so when running multiple instances of Catapult (using `make shell` multiple times) and multiple deploys in parallel the latest fail will be written into the start.retry file.

- Runs `ctp host deploy` on failed machines based on start.retry file

```zsh
ctp retry deploy
```

- Runs `ctp host redeploy` failed machines based on start.retry file

```zsh
ctp retry redeploy
```

- Runs `ctp host deploy-until-configuration` on failed machines based on start.retry file

```zsh
ctp retry deploy-until-configuration
```

- Runs `ctp host redeploy-until-configuration` on failed machines based on start.retry file

```zsh
ctp retry redeploy-until-configuration
```

- Runs `ctp host deploy-from-configuration` on failed machines based on start.retry file

```zsh
ctp retry deploy-from-configuration
```

- Runs `ctp host deploy-role` on failed machines based on start.retry file

```zsh
ctp retry deploy-role
```

## VM commands

These commands will be used to manage the VMs from the hypervisor or cloud provider.

### ctp vm rename

Renaming VM. This command is useful when the naming scheme for the VMs has changed and you want to rename some or all of them for the project.

_Example usage:_

- Renames the VM for the given inventory_hostname with the given values

```zsh
ctp vm rename <inventory_hostname> -e old_vm_name=<old_name> -e new_vm_name=<new_name>
```

- Renames the VM for the given inventory_hostname where the old name is the current value defined in the group or host vars

```zsh
ctp vm rename <inventory_hostname> -e new_vm_name=<new_name>
```

### ctp vm snapshot-create

Shuts down the VM, creates a snapshot and powers the VM back on.

_Example usage:_

- Creates a snapshot of the VM for the given inventory_hostname with the default snapshot name

```zsh
ctp vm snapshot-create <inventory_hostname>
```

- Creates a snapshot of the VM for the given inventory_hostname with the given snapshot name

```zsh
ctp vm snapshot-create <inventory_hostname> -e snapshot_name=<snapshot_name>
```

### ctp vm snapshot-create-clean

Remove all existing snapshots and create a new snapshot of the VM

_Example usage:_

- Removes all existing snapshots and creates a new snapshot of the VM for the given inventory_hostname

```zsh
ctp vm snapshot-create-clean <inventory_hostname>
```

- Removes all existing snapshots and creates a new snapshot of the VM for the given inventory_hostname with the given snapshot name

```zsh
ctp vm snapshot-create-clean <inventory_hostname> -e snapshot_name=<snapshot_name>
```

### ctp vm snapshot-live

Creates a snapshot of a running machine including memory, mostly applicable to VMware products

_Example usage:_

- Creates a live snapshot of the VM for the given inventory_hostname

```zsh
ctp vm snapshot-create-live <inventory_hostname>
```

- Creates a live snapshot of the VM for the given inventory_hostname with the given snapshot name

```zsh
ctp vm snapshot-create-live <inventory_hostname> -e snapshot_name=<snapshot_name>
```

### ctp vm snapshot-revert

Revert to the latest default snapshot or to the given snapshot name

_Example usage:_

- Reverts the VM for the given inventory_hostname to the latest default snapshot

```zsh
ctp vm snapshot-revert <inventory_hostname>
```

- Reverts the VM for the given inventory_hostname to the given snapshot name

```zsh
ctp vm snapshot-revert <inventory_hostname> -e snapshot_name=<snapshot_name>

```

### ctp vm snapshot-remove

Removing snapshot, requires `-e snapshot_name=snapshot_name_to_remove` or removes current snapshot if snapshot_name is not defined

_Example usage:_

- Removes the snapshot for the given inventory_hostname

```zsh
ctp vm snapshot-remove <inventory_hostname> -e snapshot_name=snapshot_name_to_remove
```

### ctp vm snapshot-remove-all

- Removes all snapshots for the given inventory_hostname

```zsh
ctp vm snapshot-remove-all <inventory_hostname>
```

### ctp vm snapshot-rename

Renaming snapshot, requires `-e snapshot_name=existing_snapshot_name_to_rename -e new_snapshot_name=new_snapshot_name`

_Example usage:_

- Renames the snapshot for given inventory_hostname machine

```zsh
ctp vm snapshot-rename <inventory_hostname> -e snapshot_name=existing_snapshot_name_to_rename -e new_snapshot_name=new_snapshot_name
```

Refer to the [nova.core.snapshots](https://github.com/novateams/nova.core/tree/main/nova/core/roles/snapshots) role for more command line options.

### ctp vm poweron

Power on VM

_Example usage:_

```zsh
ctp vm poweron <inventory_hostname>
```

### ctp vm restart

Restart VM

_Example usage:_

```zsh
ctp vm restart <inventory_hostname>
```

### ctp vm shutdown

Shut down VM (graceful shutdown)

_Example usage:_

```zsh
ctp vm shutdown <inventory_hostname>
```

### ctp vm poweroff

Power off VM (ungraceful shutdown)

_Example usage:_

```zsh
ctp vm poweroff <inventory_hostname>
```

### ctp vm reset

Reset VM (very ungraceful)

_Example usage:_

```zsh
ctp vm reset <inventory_hostname>
```

### ctp vm suspend

Suspend VM

_Example usage:_

```zsh
ctp vm suspend <inventory_hostname>
```

## Update commands

These commands will be used to manually check and update for Catapult components. These are mostly useful for people who are modifying or developing Catapult. For most users the `make restart` command is enough to restart, check and update the Catapult container and components.

### reinstall-default-collections

Reinstall the default collections that come with Catapult. This is useful when you have made changes to the collections and you want to revert them back to the default state.

_Example usage:_

```zsh
ctp update reinstall-default-collections
```

### update-nova

Update the `nova.core` collection to the latest version. This is useful when you want to update the `nova.core` collection to the latest version without restarting the Catapult container.

_Example usage:_

```zsh
ctp update update-nova
```

### update-venv

Update the Python virtual environment to the latest version. This is useful when you want to update the Python virtual environment to the latest version without restarting the Catapult container.

## Development commands

These commands are useful when developing or debugging Catapult.

### enable-timing

Enables timing for the Ansible playbook. This is useful when you want to see how long each task takes to run.

_Example usage:_

```zsh
ctp dev enable-timing
```

### disable-timing

Disables timing for the Ansible playbook. This is useful when you want to disable the timing for the Ansible playbook.

_Example usage:_

```zsh
ctp dev disable-timing
```
