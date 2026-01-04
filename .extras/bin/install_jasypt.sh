#!/usr/bin/env bash

# Install jasypt utilities.

usage()
{
  cat <<USAGE_TEXT
Usage:  ${THIS_SCRIPT_NAME}
            [--install_bin_directory=<directory>]
            [--jasypt_version=<version>]
            [--requires_become=<true|false>]
            [--dry_run]
            [--show_diff]
            [--help | -h]
            [--script_debug]

Install the jasypt utilities.

Available options:
    --install_bin_directory=<directory>
        The directory where the jasypt utilities are to be installed. Defaults to "/usr/local/bin".
    --jasypt_version=<version>
        The version of the jasypt utilities to install.
        Defaults to "1.9.3".
    --requires_become=<true|false>
        Is privilege escalation required? Defaults to true.
    --dry_run
        Run the role without making changes.
    --show_diff
        Run the role in diff mode.
    --help, -h
        Print this help and exit.
    --script_debug
        Print script debug info.
USAGE_TEXT
}

main()
{
  initialize
  parse_script_params "${@}"
  install_jasypt
}

install_jasypt()
{
  export ANSIBLE_ROLES_PATH="${THIS_SCRIPT_DIRECTORY}/../.ansible/roles/:${HOME}/.ansible/roles/"

  # Install the dependencies of the playbook:
  ANSIBLE_ROLES_PATH="${HOME}/.ansible/roles/" \
      ansible-galaxy \
      role \
      install \
      "--role-file=${THIS_SCRIPT_DIRECTORY}/../.ansible/roles/requirements_jasypt.yml" \
      --force
  last_command_return_code="$?"
  if [ "${last_command_return_code}" -ne 0 ]; then
    msg "Error: ansible-galaxy role installations failed."
    abort_script
  fi

  #ANSIBLE_VERBOSE_ARGUMENT="-vvv"

  ASK_BECOME_PASS_OPTION=""
  if [ "${REQUIRES_BECOME}" = "${TRUE_STRING}" ]; then
    ASK_BECOME_PASS_OPTION="--ask-become-pass"
  fi

  construct_command_options_array \
    "playbook_command_options_array" \
    "${ANSIBLE_CHECK_MODE_ARGUMENT}" \
    "${ANSIBLE_DIFF_MODE_ARGUMENT}" \
    "${ANSIBLE_VERBOSE_ARGUMENT}" \
    "${ASK_BECOME_PASS_OPTION}" \
    "--inventory=localhost," \
    "--connection=local" \
    "--extra-vars=adrianjuhl__jasypt__install_bin_directory=${INSTALL_BIN_DIRECTORY}" \
    "--extra-vars=adrianjuhl__jasypt__jasypt_version=${JASYPT_VERSION}" \
    "--extra-vars=install_jasypt_playbook__install_jasypt__requires_become=${REQUIRES_BECOME}"

  ansible-playbook \
    "${playbook_command_options_array[@]}" \
    ${THIS_SCRIPT_DIRECTORY}/../.ansible/playbooks/install_jasypt.yml
}

parse_script_params()
{
  #msg "script params (${#}) are: ${@}"
  # default values of variables set from params
  INSTALL_BIN_DIRECTORY="/usr/local/bin"
  JASYPT_VERSION="1.9.3"
  REQUIRES_BECOME="${TRUE_STRING}"
  REQUIRES_BECOME_PARAM=""
  ANSIBLE_CHECK_MODE_ARGUMENT=""
  ANSIBLE_DIFF_MODE_ARGUMENT=""
  SCRIPT_DEBUG_OPTION="${FALSE_STRING}"
  while [ "${#}" -gt 0 ]
  do
    case "${1-}" in
      --install_bin_directory=*)
        INSTALL_BIN_DIRECTORY="${1#*=}"
        ;;
      --jasypt_version=*)
        JASYPT_VERSION="${1#*=}"
        ;;
      --requires_become=*)
        REQUIRES_BECOME_PARAM="${1#*=}"
        ;;
      --dry_run)
        ANSIBLE_CHECK_MODE_ARGUMENT="--check"
        ;;
      --show_diff)
        ANSIBLE_DIFF_MODE_ARGUMENT="--diff"
        ;;
      --help | -h)
        usage
        exit
        ;;
      --script_debug)
        set -x
        SCRIPT_DEBUG_OPTION="${TRUE_STRING}"
        ;;
      -?*)
        msg "Error: Unknown parameter: ${1}"
        msg "Use --help for usage help"
        abort_script
        ;;
      *) break ;;
    esac
    shift
  done
  case "${REQUIRES_BECOME_PARAM}" in
    "true")
      REQUIRES_BECOME="${TRUE_STRING}"
      ;;
    "false")
      REQUIRES_BECOME="${FALSE_STRING}"
      ;;
    "")
      REQUIRES_BECOME="${TRUE_STRING}"
      ;;
    *)
      msg "Error: Invalid requires_become param value: ${REQUIRES_BECOME_PARAM}, expected one of: true, false"
      abort_script
      ;;
  esac
  #echo "REQUIRES_BECOME_PARAM is: ${REQUIRES_BECOME_PARAM}"
  #echo "REQUIRES_BECOME is: ${REQUIRES_BECOME}"
}

construct_command_options_array()
  # Creates an array as named with the first parameter and populates it with the
  # non-blank/non-empty values of the remaining parameters.
  # Parameters:
  #   ${1}     - the name of the array
  #   ${2}...  - the values to populate the array with (the blank/empty values will be ignored)
  # For example:
  #   construct_command_options_array "command_options_array" "value1" "value2"
  #   declare -p command_options_array
  #   echo "command_options_array: ${command_options_array[*]}"
  #   for value in "${command_options_array[@]}"; do echo "value is: ${value}"; done
  #   mvn \
  #     "${command_options_array[@]}"
{
  # shellcheck disable=SC2064
  trap "$(shopt -p extglob)" RETURN  # Restores the extglob shopt when this fuction returns.
  shopt -s extglob
  local -n __construct_command_options_array__command_options_array="${1}"
  shift
  __construct_command_options_array__command_options_array=()
  for element in "${@}"
  do
    trimmed_element="${element}"
    trimmed_element="${trimmed_element##+([[:space:]])}" # trim leading whitespace
    trimmed_element="${trimmed_element%%+([[:space:]])}" # time trailing whitespace
    if [ -n "${trimmed_element}" ]; then
      __construct_command_options_array__command_options_array+=("${trimmed_element}")
    fi
  done
}

initialize()
{
  set -o pipefail
  THIS_SCRIPT_PROCESS_ID=$$
  initialize_abort_script_config
  initialize_this_script_directory_variable
  initialize_this_script_name_variable
  initialize_true_and_false_strings
}

initialize_abort_script_config()
{
  # Exit shell script from within the script or from any subshell within this script - adapted from:
  # https://cravencode.com/post/essentials/exit-shell-script-from-subshell/
  # Exit with exit status 1 if this (top level process of this script) receives the SIGUSR1 signal.
  # See also the abort_script() function which sends the signal.
  trap "exit 1" SIGUSR1
}

initialize_this_script_directory_variable()
{
  # Determines the value of THIS_SCRIPT_DIRECTORY, the absolute directory name where this script resides.
  # See: https://www.binaryphile.com/bash/2020/01/12/determining-the-location-of-your-script-in-bash.html
  # See: https://stackoverflow.com/a/67149152
  local last_command_return_code
  THIS_SCRIPT_DIRECTORY=$(cd "$(dirname -- "${BASH_SOURCE[0]}")" || exit 1; cd -P -- "$(dirname "$(readlink -- "${BASH_SOURCE[0]}" || echo .)")" || exit 1; pwd)
  last_command_return_code="$?"
  if [ "${last_command_return_code}" -gt 0 ]; then
    # This should not occur for the above command pipeline.
    msg
    msg "Error: Failed to determine the value of this_script_directory."
    msg
    abort_script
  fi
}

initialize_this_script_name_variable()
{
  local path_to_invoked_script
  local default_script_name
  path_to_invoked_script="${BASH_SOURCE[0]}"
  default_script_name=""
  if grep -q '/dev/fd' <(dirname "${path_to_invoked_script}"); then
    # The script was invoked via process substitution
    if [ -z "${default_script_name}" ]; then
      THIS_SCRIPT_NAME="<script invoked via file descriptor (process substitution) and no default name set>"
    else
      THIS_SCRIPT_NAME="${default_script_name}"
    fi
  else
    THIS_SCRIPT_NAME="$(basename "${path_to_invoked_script}")"
  fi
}

initialize_true_and_false_strings()
{
  # Bash doesn't have a native true/false, just strings and numbers,
  # so this is as clear as it can be, using, for example:
  # if [ "${my_boolean_var}" = "${TRUE_STRING}" ]; then
  # where previously 'my_boolean_var' is set to either ${TRUE_STRING} or ${FALSE_STRING}
  TRUE_STRING="true"
  FALSE_STRING="false"
}

abort_script()
{
  echo >&2 "aborting..."
  kill -SIGUSR1 ${THIS_SCRIPT_PROCESS_ID}
  exit
}

msg()
{
  echo >&2 -e "${@}"
}

# Main entry into the script - call the main() function
main "${@}"
