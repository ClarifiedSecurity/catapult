<div align="center">
<p>Clarified Security built <a href="https://clarifiedsecurity.com/tools/">tools</a>:</p>
<h3>
  <a href="https://catapult.sh">Catapult</a> &bull;
  <a href="https://providentia.sh">Providentia</a> &bull;
  EXPO
</h3>
</div>

# Catapult

Catapult is an infrastructure **development** tool using infrastructure-as-code (IaC) approach to build, deploy and (re)configure different types of environments, such as Cyber Exercises, Trainings, Labs or even Production environments. It is designed to be used by people with some experience with Ansible, but it's a force multiplier for experienced Ansible users. Catapult does the heavy lifting in dependency management, virtual machine creation or remote/cloud service configuration so the developer can focus on the actual content of the machine or service.

Catapult is **definitely** the tool for you if you have have one or more of the following problems:

- It's becoming increasingly difficult to manage Ansible dependencies and requirements for different users.
- You have been using Ansible for a while and have a lot of playbooks, roles and inventories but you are struggling to manage them and keep ending up copying similar code between different projects.
- You'd rather use pre-built and maintained Ansible roles and collections instead of building your own from scratch.
- You have multiple projects with different infrastructure environments and you want to manage them in parallel from the same place and with the same codebase.
- You are just starting the with the infrastructure-as-code approach and you **don't want to spend years** building your own tool, instead you need to start building your own projects and content right away.

Catapult comes with a lot of pre-built and maintained Ansible roles that you can use in your projects. They are in an Ansible collection called [nova.core](https://github.com/ClarifiedSecurity/nova.core).

Catapult supports VM creation and configuration on:

- AWS EC2
- Azure
- Linode
- Proxmox
- vSphere
- OpenStack (limited and experimental support)

If Catapult does not support VM creation for your needed environment, you can either:

- Write it yourself (as a separate Ansible role to include) directly into your project and still be able to use all of the other features of Catapult.
- Create the VM by other means and then use Catapult to configure the already existing virtual (or physical) machines.

Refer to [Catapult Docs](https://clarifiedsecurity.github.io/catapult-docs/catapult/00-overview.html) for full documentation.

## TLDR (Quickstart)

### Install

```sh
git clone https://github.com/ClarifiedSecurity/catapult && \
cd catapult && \
./install.sh
```

### Run

```sh
make start
```

### Clone a test project

```sh
cd /srv/inventories
git clone https://github.com/ClarifiedSecurity/catapult-project-example.git
```

### Test that the project is working

```sh
cd /srv/inventories/catapult-project-example
ctp host list all
```

### Start developing your own project

Create or clone your own project in `/srv/inventories` and start developing.
