Ansible role: jasypt
=========

Installs [jasypt](http://www.jasypt.org).

Requirements
------------

None.

Role Variables
--------------

None.

Dependencies
------------

None.

Example Playbook
----------------
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

License
-------

MIT

Author Information
------------------

[Adrian Juhl](http://github.com/adrianjuhl)
