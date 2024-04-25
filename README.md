# Catapult

Catapult is an infrastructure development tool built using Ansible to develop, deploy and (re)configure different types of environments, such as Cyber Exercises, Trainings, Labs or even Production environments. It is designed to be used by people with some experience with Ansible, but it's a force multiplier for experienced Ansible users. Catapult does the heavy lifting in dependency installation and management, virtual machine creation or remote/cloud service configuration so the developer can focus on the actual content of the machine or service.

This is the core version of Catapult that supports VM creation and configuration on vSphere, AWS, Linode and even VMware Workstation running on the developers own machine (VMware Workstation only tested on Linux). It is also possible to use Catapult to configure an already existing virtual or physical machines.

Catapult runs in a Docker container, so the developer only needs a few dependencies installed on their own machine.

Catapult also designed to be modifiable by the developer or the organization using it without the need to modify or fork this project itself.

Refer to [Catapult Docs](https://clarifiedsecurity.github.io/catapult-docs/catapult/01-installation/) for getting started and usage instructions.
