
autoload -U compinit; compinit

# Define the functions for the ctp function
ctp() {
    local command="$1"
    local subcommand="$2"
    # Check if there are enough arguments to shift
    if [[ "$#" -ge 2 ]]; then
        shift 2 # Shift the arguments to exclude the command and subcommand
    else
        shift "$#" # Shift all remaining arguments
    fi

    if [[ "$command" = "" ]]; then
        echo "ctp: Catapult command line tool for managing your environment(s)."
        echo "Usage:"
        echo "  ctp <command> <subcommand> [options] "
        echo
        echo "Commands:"
        echo "  host           Commands for configuring hosts"
        echo "  retry          Commands for retrying failed machines"
        echo "  vm             Commands for configuring hosts on an hypervisor level"
        echo "  secrets        Commands for managing your personal secrets"
        echo "  project        Commands for managing projects"
        echo "  update         Commands for Catapult component updates"
        echo "  dev            Commands for Catapult developers"
        echo "  local          Commands for configuring your local machine"
        echo
        echo "For more information - https://clarifiedsecurity.github.io/catapult-docs/catapult/02-how-to-use"
        echo
        return
    fi

if [[ "$command" = "host" && $subcommand = "deploy" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -l "$@"
elif [[ "$command" = "host" && $subcommand = "redeploy" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=redeploy -l "$@"
elif [[ "$command" = "host" && $subcommand = "deploy-until-configuration" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -e just_clone=true -l "$@"
elif [[ "$command" = "host" && $subcommand = "redeploy-until-configuration" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=redeploy -e just_clone=true -l "$@"
elif [[ "$command" = "host" && $subcommand = "deploy-from-configuration" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -e role_only_wp=true -l "$@"
elif [[ "$command" = "host" && $subcommand = "deploy-role" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -e role_only=true -l "$@"
elif [[ "$command" = "host" && $subcommand = "deploy-single-role" ]]; then
    local role="$1"
    shift
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -e role_only=true -e single_role="$role" -l "$@"
elif [[ "$command" = "host" && $subcommand = "deploy-pre-role" ]]; then
    local role="$1"
    shift
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -e role_only=true -e pre_role="$role" -l "$@"
elif [[ "$command" = "host" && $subcommand = "deploy-network" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -e reconfigure_network=yes -l "$@"
elif [[ "$command" = "host" && $subcommand = "remove" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=undeploy -l "$@"
elif [[ "$command" = "host" && $subcommand = "rebuild-linode-vm" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -e rebuild=yes -l "$@"
elif [[ "$command" = "host" && $subcommand = "vars" ]]; then
    ansible-inventory $PWD/playbook.yml -e @~/.vault/vlt --vars --host "$@"
elif [[ "$command" = "host" && $subcommand = "list" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy --list-hosts -l "$@"
elif [[ "$command" = "host" && $subcommand = "update" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -e role_only=true -e=single_role=nova.core.updates -l "$@"
elif [[ "$command" = "host" && $subcommand = "ip" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -e pre_role=nova.core.get_ip -l "$@"
elif [[ "$command" = "host" && $subcommand = "connect" ]]; then
    /srv/scripts/general/connect.sh "$@"
elif [[ "$command" = "host" && $subcommand = "console" ]]; then
    ansible-console -e @~/.vault/vlt -l "$@"
elif [[ "$command" = "host" && $subcommand = "unlock-encrypted-container" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -e role_only=true -e=single_role=shared.roles.encrypted_container -l "$@"
elif [[ "$command" = "host" && $subcommand = "upload" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -e role_only=true -e single_role=shared.roles.sync -e upload=yes -l "$@"
elif [[ "$command" = "host" && $subcommand = "download" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -e role_only=true -e single_role=shared.roles.sync -e download=yes -l "$@"
elif [[ "$command" = "host" && $subcommand = "archive-project" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -e role_only=true -e single_role=shared.roles.archive -l "$@"
elif [[ "$command" = "host" && $subcommand = "remmina-profile" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -e pre_role=shared.roles.create_remmina_profile -l "$@"
elif [[ "$command" = "host" && $subcommand = "revdep" ]]; then
    /srv/personal/scripts/revdep.sh "$@"
elif [[ "$command" = "retry" && $subcommand = "deploy" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -l @playbook.retry "$@"
elif [[ "$command" = "retry" && $subcommand = "redeploy" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=redeploy -l @playbook.retry "$@"
elif [[ "$command" = "retry" && $subcommand = "deploy-until-configuration" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -e just_clone=true -l @playbook.retry "$@"
elif [[ "$command" = "retry" && $subcommand = "redeploy-until-configuration" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=redeploy -e just_clone=true -l @playbook.retry "$@"
elif [[ "$command" = "retry" && $subcommand = "deploy-from-configuration" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -e role_only_wp=true -l @playbook.retry "$@"
elif [[ "$command" = "retry" && $subcommand = "deploy-role" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -e role_only=true -l @playbook.retry "$@"
elif [[ "$command" = "vm" && $subcommand = "snapshot-create" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -e=snapshot_mode=snap -e pre_role=nova.core.snapshots -l "$@"
elif [[ "$command" = "vm" && $subcommand = "snapshot-create-clean" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -e=snapshot_mode=clean-snap -e pre_role=nova.core.snapshots -l "$@"
elif [[ "$command" = "vm" && $subcommand = "snapshot-create-live" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -e=snapshot_mode=snap -e live_snap=true -e pre_role=nova.core.snapshots -l "$@"
elif [[ "$command" = "vm" && $subcommand = "snapshot-revert" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -e=snapshot_mode=revert -e pre_role=nova.core.snapshots -l "$@"
elif [[ "$command" = "vm" && $subcommand = "snapshot-remove" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -e=snapshot_mode=remove -e pre_role=nova.core.snapshots -l "$@"
elif [[ "$command" = "vm" && $subcommand = "snapshot-remove-all" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -e=snapshot_mode=remove -e remove_all_snapshots=true -e pre_role=nova.core.snapshots -l "$@"
elif [[ "$command" = "vm" && $subcommand = "snapshot-rename" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -e=snapshot_mode=rename -e pre_role=nova.core.snapshots -l "$@"
elif [[ "$command" = "vm" && $subcommand = "poweron" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -e=poweron=true -e pre_role=nova.core.powerstate -l "$@"
elif [[ "$command" = "vm" && $subcommand = "restart" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -e=restart=true -e pre_role=nova.core.powerstate -l "$@"
elif [[ "$command" = "vm" && $subcommand = "shutdown" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -e=shutdown=true -e pre_role=nova.core.powerstate -l "$@"
elif [[ "$command" = "vm" && $subcommand = "poweroff" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -e=poweroff=true -e pre_role=nova.core.powerstate -l "$@"
elif [[ "$command" = "vm" && $subcommand = "reset" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -e=reset=true -e pre_role=nova.core.powerstate -l "$@"
elif [[ "$command" = "vm" && $subcommand = "suspend" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -e=suspend=true -e pre_role=nova.core.powerstate -l "$@"
elif [[ "$command" = "vm" && $subcommand = "rename" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -e pre_role=nova.core.rename_vm -l "$@"
elif [[ "$command" = "vm" && $subcommand = "unlock-disk-encryption" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=unlock -e pre_role=shared.roles.disk_encryption -l "$@"
elif [[ "$command" = "vm" && $subcommand = "export" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=export -e pre_role=shared.roles.vcenter_ovf -l "$@"
elif [[ "$command" = "vm" && $subcommand = "import" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=import -e pre_role=shared.roles.vcenter_ovf -l "$@"
elif [[ "$command" = "vm" && $subcommand = "console-login" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -e role_only=true -e pre_role=shared.roles.vm_console_login -l "$@"
elif [[ "$command" = "secrets" && $subcommand = "unlock" ]]; then
    /srv/scripts/general/secrets-unlock.sh
elif [[ "$command" = "secrets" && $subcommand = "edit" ]]; then
    /srv/scripts/general/secrets-edit.sh
elif [[ "$command" = "secrets" && $subcommand = "change-password" ]]; then
    /srv/scripts/general/secrets-change-password.sh
elif [[ "$command" = "project" && $subcommand = "select" ]]; then
    source /srv/scripts/general/select-inventory.sh
elif [[ "$command" = "project" && $subcommand = "update-inventory" ]]; then
    source /srv/scripts/general/generate-inventory-completion.sh
elif [[ "$command" = "project" && $subcommand = "create-env" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -e pre_role=shared.roles.manage_env -l 'all[0]' "$@"
elif [[ "$command" = "project" && $subcommand = "remove-env" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=undeploy -e pre_role=shared.roles.manage_env -l 'all[0]' "$@"
elif [[ "$command" = "project" && $subcommand = "remove-all" ]]; then
    ctp host remove all ; ctp project remove-env
elif [[ "$command" = "project" && $subcommand = "remmina-config" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -e pre_role=shared.roles.create_remmina_profiles -l 'all[0]' "$@"
elif [[ "$command" = "project" && $subcommand = "vault" ]]; then
    ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -e role_only=true -e pre_role=roles/_fetch_root_token -l 'all[0]' "$@"
elif [[ "$command" = "update" && $subcommand = "builtin-collections" ]]; then
    /srv/scripts/general/install-collections.sh
elif [[ "$command" = "update" && $subcommand = "nova" ]]; then
    /srv/scripts/entrypoints/first-run/02-nova-core-version-check.sh
elif [[ "$command" = "update" && $subcommand = "venv" ]]; then
    /srv/scripts/general/update-venv.sh
elif [[ "$command" = "update" && $subcommand = "shared-roles" ]]; then
    /srv/custom/docker-entrypoints/first-run/02-shared-roles-version-check.sh
elif [[ "$command" = "update" && $subcommand = "shared-vulns" ]]; then
    /srv/custom/docker-entrypoints/first-run/03-shared-vulns-version-check.sh
elif [[ "$command" = "dev" && $subcommand = "enable-timing" ]]; then
    export ANSIBLE_CALLBACKS_ENABLED=ansible.posix.profile_tasks
elif [[ "$command" = "dev" && $subcommand = "disable-timing" ]]; then
    unset ANSIBLE_CALLBACKS_ENABLED && echo 'Timing disabled'
elif [[ "$command" = "local" && $subcommand = "configure-my-laptop" ]]; then
    read -s "usr_pass?Enter password for user - $CONTAINER_USER_NAME " && ansible-playbook $PWD/playbook.yml -e @~/.vault/vlt -e=deploy_mode=deploy -e ansible_become_password=$usr_pass -l my-laptop "$@"
else
    echo "Command not found, did you TAB complete all the arguments?"
fi
}

_host_completion () {
    hosts_completion_file="$(basename "$(pwd)")_hosts"

    if compset -P '@'; then
        _files
    else
        # To handle Ansible pattern syntax
        compset -P '*[,:](|[&!~])'
        compset -S '[:,]*'

        if [[ -f "/tmp/$hosts_completion_file" ]]; then
			_ansible_hosts=( ${(f)"$(cat "/tmp/$hosts_completion_file")"} )
			compadd -M 'l:|=* r:|=*' -qS: -a _ansible_hosts
        else
            echo -e "Project inventory missing! Use \x1b[96mctp project select\x1b[0m to generate it."
            return
        fi
    fi

}

_role_completion () {
    roles_completion_file="$(basename "$(pwd)")_roles"

    if [[ -f "/tmp/$roles_completion_file" ]]; then
        _roles=( ${(f)"$(cat "/tmp/$roles_completion_file")"} )
        compadd -M 'l:|=* r:|=*' -a _roles
    else
        echo -e "Tab completable role list missing! Use \x1b[96mctp project select\x1b[0m to generate it."
        return
    fi
}

# Set up tab completion for the ctp function
# Based on https://clarifiedsecurity.github.io/catapult-docs/catapult/02-how-to-use/
_ctp() {

    _arguments \
        '1:command:->commands' \
        '*:: :->args'

    case $state in
        commands)
            local -a commands
            commands=(
                'host:Commands for configuring hosts'
                'retry:Commands for retrying failed machines'
                'vm:Commands for configuring hosts on an hypervisor level'
                'secrets:Commands for managing your personal secrets'
                'project:Commands for managing projects'
                'update:Commands for Catapult component updates'
                'dev:Commands for Catapult developers'
                'local:Commands for configuring your local machine'
            )
            _describe 'command' commands
            ;;
        args)
            case $line[1] in
                host)
                    if [[ "$line[2]" == "deploy-single-role" || "$line[2]" == "deploy-pre-role" ]]; then
                        _arguments \
                            '2:role:_role_completion' \
                            "*:option:_host_completion"
                    else
                        _arguments \
                            '1:mode:((
                                deploy:"Deploys the VM with the given inventory_hostname"
                                redeploy:"Destroys the existing VM and runs the ctp deploy command"
                                deploy-until-configuration:"Deploys the VM with the given inventory_hostname and creates a snapshot"
                                redeploy-until-configuration:"Destroys the existing VM and runs the ctp deploy-until-configuration command"
                                deploy-from-configuration:"Starts the play from /srv/<project_name>/pre_vm_role part of the playbook and runs until the end"
                                deploy-role:"Runs only the /srv/<project_name>/vm/<role_name> part of the playbook and then stops"
                                deploy-single-role:"Runs only the role defined as the fist tab-completable argument and then stops"
                                deploy-pre-role:"Runs only the role defined as the fist tab-completable argument as pre_role and then stops"
                                deploy-network:"Runs ctp deploy and also includes networks configuration role"
                                remove:"Destroys the existing VM"
                                rebuild-linode-vm:"Rebuilds the existing Linode VM with a new disk but keeps the existing IP"
                                vars:"Lists the variables for the given inventory_hostname"
                                list:"Lists the hosts for the given inventory_hostname, group or matching pattern"
                                update:"Installs the OS updates for the given inventory_hostname"
                                ip:"Get the IP of the given inventory_hostname"
                                connect:"Connecting the given inventory_hostname over SSH"
                                console:"Open Ansible console for the given inventory_hostname"
                                unlock-encrypted-container:"Unlocking encrypted container for given inventory_hostname"
                                upload:"Uploading files from your inventory/upload to target /srv/upload"
                                download:"Downloading files from target /srv/download to your inventory/download folder"
                                archive-project:"Archiving data from your target (RT specific)"
                                remmina-profile:"Generation Remmina profile(s) for given inventory_hostname with the shared.roles.create_remmina_profile role"
                                revdep:"Reverting to latest snapshot and deploying from configuration"
                                ))' \
                            "*:option:_host_completion"
                    fi
                    ;;
                retry)
                        _arguments \
                            '1:mode:((
                                deploy:"Run deploy on failed machines based on playbook.retry file"
                                redeploy:"Run redeploy failed machines based on playbook.retry file"
                                deploy-until-configuration:"Run deploy-until-configuration on failed machines based on playbook.retry file"
                                redeploy-until-configuration:"Run redeploy-until-configuration on failed machines based on playbook.retry file"
                                deploy-from-configuration:"Run deploy-from-configuration on failed machines based on playbook.retry file"
                                deploy-role:"Run deploy-role on failed machines based on playbook.retry file"
                                ))'
                    ;;
                vm)
                        _arguments \
                            '1:mode:((
                                snapshot-create:"Creates a snapshot"
                                snapshot-create-clean:"Removes existing snapshots and creates a new one"
                                snapshot-create-live:"Creates a running state snapshot"
                                snapshot-revert:"Reverts to latest snapshot or the one defined as -e snapshot_name=<snapshot_name>"
                                snapshot-remove:"Removes snapshot defined as -e snapshot_name=<snapshot_name_to_remove>"
                                snapshot-remove-all:"Removes all snapshots"
                                snapshot-rename:"Renames the snapshot defined as -e snapshot_name=<snapshot_name_to_rename> to -e new_snapshot_name=<new_snapshot_name>"
                                poweron:"Powers on the VM"
                                restart:"Restarts the VM"
                                shutdown:"Shuts down the VM"
                                poweroff:"Powers off the VM"
                                reset:"Resets the VM"
                                suspend:"Suspends the VM"
                                rename:"Renames the VM with the given inventory_hostname"
                                unlock-disk-encryption:"Unlocking disk encryption for given inventory_hostname"
                                export:"Exporting VM for given inventory_hostname"
                                import:"Importing VM for given inventory_hostname"
                                console-login:"Logging in from vCenter console as Administrator/root for given inventory_hostname"
                                ))' \
                            "*:option:_host_completion"
                    ;;
                secrets)
                        _arguments \
                            '1:mode:((
                                unlock:"Unlocks the Ansible Vault"
                                edit:"Opens the Ansible Vault for editing"
                                change-password:"Changes the Ansible Vault password"
                                ))'
                    ;;
                project)
                        _arguments \
                            '1:mode:((
                                select:"Lists all available projects under /srv/inventories and allows you to select one"
                                update-inventory:"Updates the tab-completable inventory for currently selected project"
                                create-env:"Create project folders & networks on the hypervisor"
                                remove-env:"Removes project folders & networks from the hypervisor"
                                remove-all:"Removes all VMs and then runs remove-env"
                                remmina-config:"Generating Remmina configuration files based on current project inventory"
                                vault:"Getting LAIR/RT project Vault root token and address"
                                ))'
                    ;;
                update)
                        _arguments \
                            '1:mode:((
                                builtin-collections:"Re-installs (overwrites) builtin roles and collections"
                                nova:"Checks for nova.core collection updates"
                                venv:"Updates Python virtual environment packages"
                                shared-roles:"Checks for shared.roles collection updates"
                                shared-vulns:"Checks for shared.vulns collection updates"
                                ))'
                    ;;
                dev)
                        _arguments \
                            '1:mode:((
                                enable-timing:"Enables timing for tasks"
                                disable-timing:"Disables timing for tasks"
                                ))'
                    ;;
                local)
                        _arguments \
                            '1:mode:((
                                configure-my-laptop:"Run the playbook to configure my laptop"
                                ))'
                    ;;
            esac
            ;;
    esac
}

compdef _ctp ctp