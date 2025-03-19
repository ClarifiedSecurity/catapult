<div align="center">
<p>Clarified Security built <a href="https://clarifiedsecurity.com/tools/">tools</a>:</p>
<h3>
  <a href="https://catapult.sh">Catapult</a> &bull;
  <a href="https://providentia.sh">Providentia</a> &bull;
  EXPO
</h3>
</div>

# Catapult

Catapult is a tool to build, deploy and (re)configure different types of environments, such as Cyber Exercises, Trainings, Labs or even Production environments. It is designed to be used by people with some experience with Ansible, but it's a force multiplier for experienced Ansible users. Catapult does the heavy lifting in dependency management, virtual machine creation or remote/cloud service configuration so the developer can focus on the actual content of the machine or service. Catapult supports VM creation and configuration on vSphere, Proxmox, AWS and Linode. Alternatively you can use Catapult to configure an already existing virtual or physical machines.

Refer to [Catapult Docs](https://clarifiedsecurity.github.io/catapult-docs/catapult/01-installation/) for full documentation.

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
