# KeePassXC setup

## Installation

Catapult uses [KeePassXC](https://keepassxc.org/) to store your personal secrets. Keepass is needed to store your LDAP/AD credentials, your personal API keys, your SSH keypairs etc. Catapult will not work without a KeePass database.

Follow these steps to set up your KeePass database:

- Install KeePassXC on your computer, it's available for all major platforms, just check your package manager or download it directly from the [KeePassXC website](https://keepassxc.org/download/).
- Run the KeePassXC application and create a new database.
- When you get to the `Database Credentials` part make sure to add a password and also click the `Add additional protection...` button and generate a key file and save it in your host.
- As a final step also save your database file to your host.
- When unlocking your database make sure to also point the the generated key file.
