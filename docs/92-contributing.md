# Contributing guidelines

When seeking to [contribute](https://github.com/ClarifiedSecurity/catapult/blob/main/.github/CONTRIBUTING.md) to this project, please keep the following in mind:

- When something is is not working as expected and you don't know how to fix it, please [open an issue](https://github.com/ClarifiedSecurity/catapult/issues). The project(s) are under active development and we might miss something but will try to fix all of the issues we are aware of.

- When you see something that could be improved and you know how to do it you can create fork of the project, make the required changes and create a pull request. We might not accept all pull requests, or we might ask you to make some changes before we do. This is not a reflection on you as a developer, but rather a reflection on the direction of the project. If you are unsure about whether or not to make a pull request, you can always [open an issue](https://github.com/ClarifiedSecurity/catapult/issues) first and ask.

- When committing Ansible code make sure to lint it with [ansible-lint](https://ansible.readthedocs.io/projects/lint/) before committing. This will help us to keep the code clean and consistent. Use the [ansible-lint.yml](https://github.com/ClarifiedSecurity/catapult/blob/main/ansible-lint.yml) as the configuration file.

- When committing code, please make it in small, logical chunks. This makes it easier for us to review and accept your changes. Also make sure that your commit messages (titles) are clear and concise. Commit messages (titles) will also be used to automatically generate an understandable changelog when releasing new versions of the project.

The commit messages (titles) must contain the following three components:

- What was changed
- Where it was changes
- Why it was changed (when applicable)

Examples:

- Updated the default Ansible version in requirements file.

- Updated the docker-entrypoint.sh script to avoid race condition for certificate updates.
