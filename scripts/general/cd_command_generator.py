#!/usr/bin/env python3

import yaml
import jinja2
import os

# Setting autocomplete file paths
autocomplete_default_src_path = '/srv/defaults/autocomplete.yml'
autocomplete_custom_src_path = '/srv/custom/autocomplete.yml'
autocomplete_personal_src_path = '/srv/personal/autocomplete.yml'
script_path = '/home/builder/.venv/bin/ctp'

# Loading the default autocomplete file
with open(autocomplete_default_src_path, 'r') as file:
    data = yaml.safe_load(file)

# Checking if the custom and personal files exist and merging them with the default file
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

# Jinja template for raw ctp script
ctp_template = """#!/usr/bin/env bash

C_RED="\x1b[91m"
C_RST="\x1b[0m"

command="$1"
subcommand="$2"

# Shift the first two arguments out of $@
shift 2

    {% for entry in autocomplete.commands %}
    {% set command = entry.command %}
    {% set loop_index = loop.index %}
    {% for subcommand in entry.subcommands %}
    {% if loop_index == 1 and loop.index == 1 %}if{% else %}elif{% endif %} [[ "$command" = "{{ command }}" && $subcommand = "{{ subcommand.subcommand_name }}" ]]; then
    {{ subcommand.subcommand_to_execute | safe }}
    {% endfor %}
    {% endfor %}
else
    echo "UNKNOWN COMMAND: ${C_RED}ctp $command $subcommand $@${C_RST}"
    exit 1
fi
"""

# Create Jinja templates
ctp_template = jinja2.Template(ctp_template, lstrip_blocks=True, trim_blocks=True)

# Define context variables
context = {
    'autocomplete': data['autocomplete']
}

# Render templates
ctp_script = ctp_template.render(context)

# Write rendered scripts to files
with open(script_path, 'w') as file:
    file.write(ctp_script)

# Make the file executable
os.chmod(script_path, 0o755)  # Adds execute permissions for owner, group, and others