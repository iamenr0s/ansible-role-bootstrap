[![Build Status](https://travis-ci.com/enr0s/ansible-role-bootstrap.svg?branch=master)](https://travis-ci.com/enr0s/ansible-role-bootstrap)
![.github/workflows/molecule.yml](https://github.com/enr0s/ansible-role-bootstrap/workflows/.github/workflows/molecule.yml/badge.svg)
[![quality](https://img.shields.io/ansible/quality/49604)](https://galaxy.ansible.com/enr0s/ansible_role_bootstrap)
![LICENSE](https://img.shields.io/github/license/enr0s/ansible-role-bootstrap)

Anible Role Bootstrap
=========
Prepare your Raspberry PI (64 bit architecture) to be managed by Ansible.


Role Variables
--------------

run_not_in_container - the variable is used to skip some tasks during molecule test. For example, the /etc/hosts file is crucial for Docker's linking system and it should only be manipulated manually at the image level, rather than the container level.

[https://docs.docker.com/network/links/#updating-the-etchosts-file]

bootstrap_packages: list of initial packages to be installed

bootstrap_kernel_parameters: enable/disable kernel parameters

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

```
  ---
  - hosts: all
    roles:
      - {role: ansible-role-bootstra, run_not_in_container: True }
```

License
-------

Apache-2.0


Author Information
------------------

[https://blog.enros.me]
