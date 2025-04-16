#!/usr/bin/env python3

import yaml
import jinja2
import os

# Setting autocomplete.yml path variables
autocomplete_default_src_path = '/srv/defaults/autocomplete.yml'
autocomplete_custom_src_path = '/srv/custom/autocomplete.yml'
autocomplete_personal_src_path = '/srv/personal/autocomplete.yml'
autocomplete_script_path = '/home/builder/autocomplete.zsh'

# Loading the default autocomplete file
with open(autocomplete_default_src_path, 'r') as file:
    data = yaml.safe_load(file)

# Checking if the custom and personal files exist if they do then merging them with the default file
for src_path in [autocomplete_custom_src_path, autocomplete_personal_src_path]:
    if os.path.exists(src_path):
        with open(src_path, 'r') as file:
            custom_data = yaml.safe_load(file)
        if 'autocomplete' in custom_data and 'commands' in custom_data['autocomplete']:
            for cmd2 in custom_data['autocomplete']['commands']:
                command_exists = any(cmd1['command'] == cmd2['command'] for cmd1 in data['autocomplete']['commands'])
                if command_exists:
                    for cmd1 in data['autocomplete']['commands']:
                        if cmd1['command'] == cmd2['command']:
                            cmd1['subcommands'].extend(cmd2['subcommands'])
                            break
                else:
                    data['autocomplete']['commands'].append(cmd2)

# Define Jinja template inline
jinja_template = """
autoload -U compinit; compinit

# Define the functions for the {{ autocomplete.function_name }} function
{{ autocomplete.function_name }}() {
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
        {% for entry in autocomplete.commands %}
        echo "  {{ entry.command }}{{ ' ' * (15 - entry.command|length) }}{{ entry.description }}"
        {% endfor %}
        echo
        echo "For more information - https://clarifiedsecurity.github.io/catapult-docs/catapult/02-how-to-use"
        echo
        return
    fi

    {% for entry in autocomplete.commands %}
    {% set command = entry.command %}
    {% set loop_index = loop.index %}
    {% for subcommand in entry.subcommands %}
    {% if loop_index == 1 and loop.index == 1 %}if{% else %}elif{% endif %} [[ "$command" = "{{ command }}" && $subcommand = "{{ subcommand.subcommand_name }}" ]]; then
    {% if subcommand.subcommand_name in ["deploy-single-role", "deploy-pre-role"] %}
    local role="$1"
    shift
    {% endif %}
    {{ subcommand.subcommand_to_execute | safe }}
    {% endfor %}
    {% endfor %}
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
            echo -e "Project inventory missing! Use \\x1b[96mctp project select\\x1b[0m to generate it."
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
        echo -e "Tab completable role list missing! Use \\x1b[96mctp project select\\x1b[0m to generate it."
        return
    fi
}

# Set up tab completion for the ctp function
# Based on https://clarifiedsecurity.github.io/catapult-docs/catapult/02-how-to-use/
_{{ autocomplete.function_name }}() {

    _arguments \\
        '1:command:->commands' \\
        '*:: :->args'

    case $state in
        commands)
            local -a commands
            commands=(
                {% for entry in autocomplete.commands %}
                '{{ entry.command }}:{{ entry.description }}'
                {% endfor %}
            )
            _describe 'command' commands
            ;;
        args)
            case $line[1] in
                {% for entry in autocomplete.commands %}
                {{ entry.command }})
                    {% if entry.command == "host" %}
                    if [[ "$line[2]" == "deploy-single-role" || "$line[2]" == "deploy-pre-role" ]]; then
                        _arguments \\
                            '2:role:_role_completion' \\
                            "*:host:_host_completion"
                    else
                        {% endif %}
                        _arguments \\
                            '1:mode:((
                                {% for subcommand in entry.subcommands %}
                                {{ subcommand.subcommand_name }}:"{{ subcommand.subcommand_description | safe }}"
                                {% endfor %}
                            {% if entry.hosts_as_arguments %}
                                ))' \\
                            "*:host:_host_completion"
                            {% else %}
                                ))'
                            {% endif %}
                    {% if entry.command == "host" %}
                    fi
                    {% endif %}
                    ;;
                {% endfor %}
            esac
            ;;
    esac
}

compdef _{{ autocomplete.function_name }} {{ autocomplete.function_name }}
"""

# Create a Jinja template object
template = jinja2.Template(jinja_template, lstrip_blocks=True, trim_blocks=True, autoescape=True)

# Define context variables
context = {
    'autocomplete': data['autocomplete']
}

# Render template with data
rendered_script = template.render(context)

# Write rendered script to file
with open(autocomplete_script_path, 'w') as file:
    file.write(rendered_script)
