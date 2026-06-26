#!/usr/bin/env python3

import yaml
import jinja2
import os


def _zsh_dq_escape(s):
    return s.replace('\\', '\\\\').replace("'", "\\'").replace('\n', '\\n')


autocomplete_default_src_path = '/srv/defaults/autocomplete.yml'
autocomplete_custom_src_path = '/srv/custom/autocomplete.yml'
autocomplete_personal_src_path = '/srv/personal/autocomplete.yml'
autocomplete_script_path = '/home/builder/autocomplete.zsh'

with open(autocomplete_default_src_path, 'r') as file:
    data = yaml.safe_load(file)

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

# Compute max lengths and escape descriptions for zsh $'...' quoting
cmd_names = [e['command'] for e in data['autocomplete']['commands']]
data['autocomplete']['_cmd_max_len'] = max(len(n) for n in cmd_names)

for entry in data['autocomplete']['commands']:
    entry['_desc_zsh'] = _zsh_dq_escape(entry['description'])
    if entry.get('subcommands'):
        entry['_sub_max_len'] = max(len(s['subcommand_name']) for s in entry['subcommands'])
        for sub in entry['subcommands']:
            sub['_desc_zsh'] = _zsh_dq_escape(sub['subcommand_description'])

jinja_template = """
autoload -U compinit; compinit

{{ autocomplete.function_name }}() {
    local command="$1"
    local subcommand="$2"
    if [[ "$#" -ge 2 ]]; then
        shift 2
    else
        shift "$#"
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
    {% for entry in autocomplete.commands %}
elif [[ "$command" = "{{ entry.command }}" ]]; then
    echo "ctp {{ entry.command }}: {{ entry.description | safe }}"
    echo "Usage: ctp {{ entry.command }} <subcommand>{% if entry.hosts_as_arguments %} [hosts]{% endif %}"
    echo
    echo "Subcommands:"
    {% for subcommand in entry.subcommands %}
    _ctp_make_display '{{ subcommand.subcommand_name }}' $'{{ subcommand._desc_zsh | safe }}' {{ entry._sub_max_len }}
    echo "$_ctp_display_result"
    {% endfor %}
    {% endfor %}
else
    ctp
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

        if [[ -s "/tmp/$hosts_completion_file" ]]; then
			_ansible_hosts=( ${(f)"$(cat "/tmp/$hosts_completion_file")"} )
			compadd -M 'l:|=* r:|=*' -qS: -a _ansible_hosts
        else
            (( _ctp_completion_warned )) || {
                _ctp_completion_warned=1
                echo -e "\nProject inventory missing! Use \\x1b[96mctp project select\\x1b[0m to generate it."
            }
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

{% raw %}
_ctp_make_display() {
    local _cmd="$1" _desc="$2" _max_len="$3"
    local _prefix="${(r:${_max_len}:: :)_cmd} --- "
    local _indent="${(l:${#_prefix}:: :)}"
    local _avail=$(( ${COLUMNS:-80} - ${#_prefix} - 1 ))
    local _nl=$'\n'
    (( _avail < 20 )) && _avail=20
    if (( ${#_desc} <= _avail )); then
        _ctp_display_result="${_prefix}${_desc}"
        return
    fi
    local -a _words=("${(@s: :)_desc}")
    local _line='' _result='' _w
    for _w in "${_words[@]}"; do
        if (( ${#_line} == 0 )); then
            _line=$_w
        elif (( ${#_line} + 1 + ${#_w} <= _avail )); then
            _line+=" $_w"
        else
            _result+="${_result:+${_nl}${_indent}}${_line}"
            _line=$_w
        fi
    done
    _result+="${_result:+${_nl}${_indent}}${_line}"
    _ctp_display_result="${_prefix}${_result}"
}
{% endraw %}

# Based on https://clarifiedsecurity.github.io/catapult-docs/catapult/02-how-to-use/
_{{ autocomplete.function_name }}() {

    _arguments \\
        '1:command:->commands' \\
        '*:: :->args'

    case $state in
        commands)
            local -a _ctp_cmd_names _ctp_raw_descs _ctp_cmd_disps
            _ctp_cmd_names=(
                {% for entry in autocomplete.commands %}
                '{{ entry.command }}'
                {% endfor %}
            )
            _ctp_raw_descs=(
                {% for entry in autocomplete.commands %}
                $'{{ entry._desc_zsh | safe }}'
                {% endfor %}
            )
            local _i=1 _ctp_display_result
            _ctp_cmd_disps=()
            for _ctp_cmd in "${_ctp_cmd_names[@]}"; do
                _ctp_make_display "$_ctp_cmd" "${_ctp_raw_descs[$_i]}" {{ autocomplete._cmd_max_len }}
                _ctp_cmd_disps+=("$_ctp_display_result")
                (( _i++ ))
            done
            compadd -M 'l:|=* r:|=*' -ld _ctp_cmd_disps -a _ctp_cmd_names
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
                    {% if entry.hosts_as_arguments %}
                        _arguments \\
                            '1:mode:->mode' \\
                            "*:host:_host_completion"
                    {% else %}
                        _arguments \\
                            '1:mode:->mode'
                    {% endif %}
                        case $state in
                            mode)
                                local -a _modes _raw_descs _disps
                                _modes=(
                                    {% for subcommand in entry.subcommands %}
                                    '{{ subcommand.subcommand_name }}'
                                    {% endfor %}
                                )
                                _raw_descs=(
                                    {% for subcommand in entry.subcommands %}
                                    $'{{ subcommand._desc_zsh | safe }}'
                                    {% endfor %}
                                )
                                local _i=1 _ctp_display_result
                                _disps=()
                                for _m in "${_modes[@]}"; do
                                    _ctp_make_display "$_m" "${_raw_descs[$_i]}" {{ entry._sub_max_len }}
                                    _disps+=("$_ctp_display_result")
                                    (( _i++ ))
                                done
                                compadd -M 'l:|=* r:|=*' -ld _disps -a _modes
                                ;;
                        esac
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

_ctp_precmd_reset_warned() { _ctp_completion_warned=0 }
autoload -Uz add-zsh-hook
add-zsh-hook precmd _ctp_precmd_reset_warned
"""

template = jinja2.Template(jinja_template, lstrip_blocks=True, trim_blocks=True, autoescape=True)

rendered_script = template.render(autocomplete=data['autocomplete'])

with open(autocomplete_script_path, 'w') as file:
    file.write(rendered_script)
