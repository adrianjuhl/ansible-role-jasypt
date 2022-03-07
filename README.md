# Ansible role: jasypt

Installs [jasypt](http://www.jasypt.org).

The installation places the jasypt shell scripts (and other resources contained in the jasypt archive) within /usr/local/bin/jasypt.d/ and then creates symbolic links (to the jasypt shell scripts) within /usr/local/bin/.

Once installed, the following commands are available:
- jasypt-decrypt
- jasypt-digest
- jasypt-encrypt
- jasypt-listAlgorithms

For more information on each of these, see [jasypt CLI tools](http://www.jasypt.org/cli.html).

## Requirements

None.

## Role Variables

None.

## Dependencies

None.

## Example Playbook
```
- hosts: servers
  roles:
    - { role: adrianjuhl.jasypt }

or

- hosts: servers
  tasks:
    - name: Install jasypt
      include_role:
        name: adrianjuhl.jasypt
```

## Extras

### Install script

For convenience, a bash script is also supplied that facilitates easy installation of jasypt on localhost (the script executes ansible-galaxy to install the role and then executes ansible-playbook to run a playbook that includes the jasypt role).

The script can be run like this:
```
$ git clone git@github.com:adrianjuhl/ansible-role-jasypt.git
$ cd ansible-role-jasypt
$ .extras/bin/install_jasypt.sh
```

## License

MIT

## Author Information

[Adrian Juhl](http://github.com/adrianjuhl)
