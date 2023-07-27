# Installation

Catapult can run in `Linux`, `Windows (WSL)` or `MacOS`. Recommended host OS is Ubuntu 22.04 LTS.

## Prerequisites

### Ubuntu/Debian

```sh
sudo apt update && \
sudo apt install git make jq -y
```

### Arch

```sh
sudo pacman -S git make jq
```

### Windows Subsystem for Linux

From an admin PowerShell run:

```powershell
wsl --install
```

- Restart Windows
- After restart Ubuntu setup should automatically run, if no then run Ubuntu manually from the start menu and finalize the setup.
- From Ubuntu terminal run:

  ```sh
  sudo apt update && \
  sudo apt install git make jq keychain -y
  ```

- Make sure all needed SSH keypairs are in `~/.ssh` folder in the WSL Ubuntu and ssh-agent is started. For easy-to-use SSH Agent you can follow this [guide](https://esc.sh/blog/ssh-agent-windows10-wsl2/). You can use this method to add multiple keys to the SSH Agent.

**PS - On Windows we suggest using [VSCode](https://code.visualstudio.com/) with the [Remote - WSL](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl) extension to edit the files in WSL and [Windows Terminal](https://learn.microsoft.com/en-us/windows/terminal/install) for easy connection to WSL.**

### MacOS

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install git make jq
```

## Install

- Make sure you have a working [KeePass](https://keepassxc.org/) database with a key file. Catapult will not work without the KeePass key file so make sure your database is configured to use one.
- Make sure all of the SSH keypairs you need are loaded ssh-agent, because Catapult will use them to connect to the VMs.
- Clone the project from GitHub with:

```sh
git clone https://github.com/ClarifiedSecurity/catapult
cd catapult
```

- Create your own variables file based on the example:

```sh
cp .makerc-vars.example .makerc-vars
```

- Fill out all of the required vars in `.makerc-vars`, To avoid any syntax errors don't leave a space after the `:=`, follow the instructions in the comments for each variable. All of the `KEEPASS_*` paths are case sensitive.
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
