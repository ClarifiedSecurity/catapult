# VM Template Requirements

When using Catapult with a cloud provider you can just use the VM templates provided by the cloud provider. When using Catapult in your own private cloud you need to make sure that the VM templates your create are compatible with Catapult.

One great tool for template generation is [Packer](https://www.packer.io/). Packer can be used to create base images for all major cloud providers and also for local virtualization solutions like VirtualBox or VMWare. We recommend using Packer for creating base images for yourself and then using Catapult to create per-environment/project/datacenter etc. templates based on the base images. Alternatively you can just install the base templates manually.

## Base template requirements

However you install your base templates make sure that they meet the following requirements. These configurations need to be present for initial configuration to the VMs to work. After the initial configuration is done you can change these configurations to whatever you want.

### Windows

- Latest stable OpenSSH installed and running -- Catapult does all of its work over SSH. Don't use the built-in Windows SSH server it's versions are different per OS version and you will start getting random connection errors.

- `MaxAuthTries` set to `20` in `C:/ProgramData/ssh/sshd_config` -- A lot of users will have more than 6 keys in their SSH agent and the default `MaxAuthTries` of 6 will cause Catapult to fail to connect to the VM. The value must not be 20 but it most likely must be higher than 6.

- (Optional) [Chocolatey](https://chocolatey.org/install) installed -- It's not a hard requirement but it's really useful to have Chocolatey installed on your Windows VMs. Catapult can use Chocolatey to install the required software on the VMs. Chocolatey can also be used to install the OpenSSH server on the base template with `choco install openssh -params /SSHServerFeature -y`

### Linux

- SSH server installed and running -- Catapult does all of its work over SSH.

- `MaxAuthTries` set to `20` in `/etc/ssh/sshd_config` -- Same as with Windows.

- `PermitRootLogin` set to `yes` in `/etc/ssh/sshd_config` -- Catapult needs to be able to login as root to the VMs the first time. After that Catapult can be used to create new accounts and disable root login.

- `PasswordAuthentication` set to `yes` in `/etc/ssh/sshd_config` -- It is usually set to yes for most Linux distributions but it's good to check.

- `sudo` package needs to be installed for your distribution.

- `python3` package needs to be installed for your distribution.

- `open-vm-tools` package might need to be installed for your distribution depending on your virtualization platform.

## Per-environment/project/datacenter etc. template requirements

We recommend applying the [template_os_configuration](https://github.com/ClarifiedSecurity/nova.core/tree/main/nova/core/roles/template_os_configuration) to the specific project templates. It contains some prerequisites for different `nova.core` roles that you might otherwise need to install before using those roles.
