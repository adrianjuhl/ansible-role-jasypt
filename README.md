# Ansible role: jasypt

Installs the [jasypt](https://github.com/jasypt/jasypt) shell scripts and provides a convinient way to call each of the jasypt scripts.

The installation places the jasypt shell scripts (and other resources contained in the jasypt archive) within a 'jasypt.d' directory within the chosen base install bin directory and sets up a symbolic link for each of the scripts.

Once installed, the following commands are available (assuming the base installation bin directory is on the path):
- jasypt-decrypt
- jasypt-digest
- jasypt-encrypt
- jasypt-listAlgorithms

For more information on each of these commands, see [Jasypt - Encrypting from the command line](https://github.com/jasypt/jasypt/blob/master/jasypt-dist/src/site/apt/cli.apt)

## Requirements

None.

## Role Variables

Role variables and their defaults.

**version**

    adrianjuhl__jasypt__jasypt_version: "1.9.3"

The version of jasypt to install.

**install_bin_directory**

    adrianjuhl__jasypt__install_bin_directory: "/usr/local/bin"

The base directory in which to install the jasypt scripts and supporting resources.

jasypt could alternatively be installed into a user's directory, for example: `adrianjuhl__jasypt__install_bin_directory: "{{ ansible_env.HOME }}/.local/bin"`, in which case the role will not need root access.

## Dependencies

None.

## Example Playbook
```
- name: "Install jasypt"
  hosts: "localhost"
  roles:
    - { role: "adrianjuhl.jasypt", become: true }

- name: "Install jasypt"
  hosts: "localhost"
  tasks:
    - name: "Install jasypt"
      include_role:
        name: "adrianjuhl.jasypt"
        apply:
          become: true

or (install into the user's ~/.local/bin directory)

- name: "Install jasypt"
  hosts: "localhost"
  tasks:
    - name: "Install jasypt"
      include_role:
        name: "adrianjuhl.jasypt"
      vars:
        adrianjuhl__jasypt__install_bin_directory: "{{ ansible_env.HOME }}/.local/bin"
```

## Extras

### Install script

For convenience, a bash script is also supplied that facilitates easy installation of jasypt on localhost (the script executes ansible-galaxy to install the role and then executes ansible-playbook to run a playbook that includes the jasypt role).

The script can be run like this:
```
$ git clone git@github.com:adrianjuhl/ansible-role-jasypt.git
$ cd ansible-role-jasypt
$ ./.extras/bin/install_jasypt.sh
```

## License

MIT

## Author Information

[Adrian Juhl](http://github.com/adrianjuhl)
