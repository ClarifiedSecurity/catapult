# Installation

Catapult can run in `Linux`, `Windows (WSL)` or `MacOS`. Recommended host OS is Ubuntu 22.04 LTS.

## Prerequisites

### Ubuntu/Debian

```sh
sudo apt update && \
sudo apt install git make jq curl sudo -y
```

### Arch

```sh
sudo pacman -S git make curl sudo jq
```

### Windows Subsystem for Linux

Log in interactively (over RDP or locally) to your Windows machine with an account that has admin rights and run the following commands in PowerShell. The first login needs to be with an admin account because the WSL installation needs to be done with admin rights. After the first installation you can use a non-admin account to log in.

```powershell
Enable-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online -NoRestart
wsl --install
```

- Restart Windows
- If your user account **IS** in the Administrators just log in, start Ubuntu from the start menu and follow the instructions to finalize the setup.
- If your user account **IS NOT** in the Administrators group you need to run the following commands in non-admin PowerShell after your login:

```powershell
wsl --update
wsl --install -d Ubuntu
```

- After that follow the instructions to finalize the setup.

- When your Ubuntu shell is ready. Run the following commands to install the needed dependencies:

```sh
sudo apt update && \
sudo apt install git make jq curl sudo keychain -y
```

- Make sure all needed SSH keypairs are in `~/.ssh` folder in the WSL Ubuntu and ssh-agent is started. For easy-to-use SSH Agent you can follow this [guide](https://esc.sh/blog/ssh-agent-windows10-wsl2/). You can use this method to add multiple keys to the SSH Agent.

When WSL is configured successfully then I'll show up in Windows Explorer as a network drive. You can use it to copy files between your host and the WSL system. On Windows we suggest using [VSCode](https://code.visualstudio.com/) with the [Remote - WSL](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl) extension to edit the files in WSL and [Windows Terminal](https://learn.microsoft.com/en-us/windows/terminal/install) for easy connection to WSL.

### MacOS

- Install brew and after installing brew make sure to add it to path with the commands it provides.

```zsh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

- Install required packaes with brew:

```zsh
brew install git make jq curl
```

## Install

- Make sure you have a working [KeePass](https://keepassxc.org/) database with a key file. Catapult will not work without the KeePass key file so make sure your database is configured to use one.
- Make sure all of the SSH keypairs you need are loaded ssh-agent, because Catapult will use them to connect to the VMs.
- Clone the project from GitHub with:

```sh
git clone https://github.com/ClarifiedSecurity/catapult --depth 1
cd catapult
```

- Create your own variables file based on the example but don't delete the example:

```sh
cp .makerc-vars.example .makerc-vars
```

- Fill out all of the required vars in `.makerc-vars`, To avoid any syntax errors don't leave a space after the `:=` sign. **Read the comments for each variable for more information.** All of the `KEEPASS_*` variables are case sensitive.

- Install all of the required dependencies for your host with:

```sh
make prepare
```

- Start the Catapult container and connect to it with:

```sh
make start
```

- Connect to an already started Catapult container with:

```sh
make shell
```

## Caveats

If you are using a Linux VM with a user ID that is not 1000 (you can check it with the `id` command) you need to build the Catapult Docker image yourself with the `make build` command.
