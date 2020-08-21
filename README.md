[![Build Status](https://travis-ci.com/enr0s/ansible-role-bootstrap.svg?branch=master)](https://travis-ci.com/enr0s/ansible-role-bootstrap)
[![quality](https://img.shields.io/ansible/quality/49604)](https://galaxy.ansible.com/enr0s/ansible-role-bootstrap)
![LICENSE](https://img.shields.io/github/license/enr0s/ansible-role-bootstrap)

Ansible Role Bootstrap
=========
Prepare your Raspberry PI (64 bit architecture) to be managed by Ansible.


Role Variables
--------------

bootstrap_packages: list of initial packages to be installed

bootstrap_kernel_parameters: enable/disable kernel parameters

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

```
  ---
  - hosts: all
    roles:
      - { role: enr0s.ansible-role-bootstrap }
```

License
-------

Apache-2.0


Author Information
------------------

[https://blog.enros.me]
