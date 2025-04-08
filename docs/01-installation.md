# Installation

Catapult can run in `Linux`, `Windows (WSL)` or `MacOS`. For Windows follow the [Windows Subsystem for Linux](#windows-subsystem-for-linux) section to pre-configure WSL and then return to [Quickstart](#quickstart).

## Quickstart

- Make sure all of the SSH keypairs you need are loaded into your ssh-agent. Catapult will use them to connect to the VMs.
- Make sure you have `git` installed.
- Run the following commands to install and configure Catapult:

```sh
git clone https://github.com/ClarifiedSecurity/catapult && \
cd catapult && \
./install.sh
```

- You can run `./install.sh` multiple times until it finishes without errors.
- You can also add use `./install.sh AUTOINSTALL` for unattended installation.
- For Linux that requires sudo password or MacOS you can use this command for unattended installation: `echo "YourSudoPassword" | ./install.sh AUTOINSTALL` Leave a space before the command to prevent it from being saved in the shell history.

### Windows Subsystem for Linux

Log in interactively (over RDP or locally) to your Windows machine with an account that is in the **Administrators** group and run the following commands in PowerShell. The first login needs to be with an administrative account because the WSL installation needs to be done with admin rights. After the first installation you can use a non-admin account to log in.

```powershell
Enable-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online -NoRestart
wsl --install
```

- Restart Windows
- If your user account **IS** in the Administrators group just log in, start Ubuntu from the start menu and follow the instructions to finalize the setup.
- If your user account **IS NOT** in the Administrators group you need to run the following commands in **non-admin** PowerShell after your login:

```powershell
wsl --update
wsl --install -d Ubuntu
```

- After that follow the instructions on screen to finalize the setup.

- Make sure all needed SSH keypairs are in `~/.ssh` folder in the WSL Ubuntu and ssh-agent is started. For easy-to-use SSH Agent you can follow this [guide](https://esc.sh/blog/ssh-agent-windows10-wsl2/). You can use this method to add multiple keys to the SSH Agent. **If you don't have SSH agent up and running the installation script will fail**

When WSL is configured successfully then I'll show up in Windows Explorer as a network drive. You can use it to copy files between your host and the WSL system. On Windows we suggest using [VSCode](https://code.visualstudio.com/) with the [Remote - WSL](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl) extension to edit the files in WSL and [Windows Terminal](https://learn.microsoft.com/en-us/windows/terminal/install) for easy connection to WSL.

- When your Ubuntu shell is ready, return to [Quickstart](#quickstart)

## Caveats

If you are using a Linux VM with a user ID that is not 1000 (you can check it with the `id` command) the Catapult Docker image will be built locally during each update. This means that the updates will just take a bit longer.
