#!/usr/bin/env python3

import yaml
import jinja2
import os

# For some reason, some Ansible commands cannot detect the vault file from an environment variable
use_vault = os.environ.get('USE_ANSIBLE_VAULT') == '1'

# Setting autocomplete.yml path variables
autocomplete_default_src_path = '/srv/defaults/autocomplete.yml'
autocomplete_custom_src_path = '/srv/custom/autocomplete.yml'
autocomplete_personal_src_path = '/srv/personal/autocomplete.yml'
autocomplete_script_path = '/home/builder/autocomplete.sh'

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
        echo "ctp: (EXPERIMENTAL) Catapult command line tool for managing your project(s)."
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
        {% if use_vault %}
        {{ subcommand.subcommand_to_execute | safe }}
        {% else %}
        {{ subcommand.subcommand_to_execute | replace(" -e @~/.vault/vlt", "") | safe }}
        {% endif %}
    {% endfor %}
    {% endfor %}
else
    echo "Command not found, did you TAB complete all the arguments?"
fi
}

_host_completion () {
    working_folder="$(basename "$(pwd)")_hosts"

    if compset -P '@'; then

        _files

    else

        _ansible_hosts=( ${(f)"$(cat "/tmp/$working_folder")"} )
        compadd -qS: -a _ansible_hosts

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
                    {% if entry.hosts_as_arguments %}
                    compset -P '*[,:](|[&!~])'
                    compset -S '[:,]*'
                    {% endif %}
                    _arguments \\
                        '1:mode:((
                            {% for subcommand in entry.subcommands %}
                            {{ subcommand.subcommand_name }}:"{{ subcommand.subcommand_description }}"
                            {% endfor %}
                        {% if entry.hosts_as_arguments %}
                            ))' \\
                        "*:option:_host_completion"
                        {% else %}
                            ))'
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
    'autocomplete': data['autocomplete'],
    'use_vault': use_vault  # Pass use_vault variable to the template context
}

# Render template with data
rendered_script = template.render(context)

# Write rendered script to file
with open(autocomplete_script_path, 'w') as file:
    file.write(rendered_script)
