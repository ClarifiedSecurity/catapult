# VM Template Requirements

When using Catapult with a cloud provider you can just use the VM templates provided by the cloud provider. When using Catapult in your own private cloud you need to make sure that the VM templates your create are compatible with Catapult.

One really good tool for template generation is [Packer](https://www.packer.io/). Packer can be used to create base images for all major cloud providers and also for local virtualization solutions like VirtualBox or VMWare. We recommend using Packer or manually creating base images for yourself and then using Catapult to create per-environment/project/datacenter etc. VM templates from those base images.

## Base template requirements

### Windows

- Latest stable OpenSSH installed and running -- Catapult does all of its work over SSH. Don't use the built-in Windows SSH server it's versions are different per OS version and you will start getting random connection errors.

- `MaxAuthTries` set to `20` in `C:/ProgramData/ssh/sshd_config` -- A lot of users will have more than 6 keys in their SSH agent and the default `MaxAuthTries` of 6 will cause Catapult to fail to connect to the VM. The value must not be 20 but it most likely must be higher than 6.

- (Optional) [Chocolatey](https://chocolatey.org/install) installed -- It's not a hard requirement but it's really useful to have Chocolatey installed on your Windows VMs. Catapult can use Chocolatey to install the required software on the VMs. Chocolatey can also be used to install the OpenSSH server on the base template with `choco install openssh -params /SSHServerFeature -y`

### Linux

- SSH server installed and running -- Catapult does all of its work over SSH.

- `MaxAuthTries` set to `20` in `/etc/ssh/sshd_config` -- Same as with Windows.

- `PermitRootLogin` set to `yes` in `/etc/ssh/sshd_config` -- Catapult needs to be able to login as root to the VMs the first time. After that Catapult can be used to create new accounts and disable root login.
