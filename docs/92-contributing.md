# Contributing guidelines

When seeking to [contribute](https://github.com/ClarifiedSecurity/catapult/blob/main/.github/CONTRIBUTING.md) to this project, please keep the following in mind:

- When something is is not working as expected and you don't know how to fix it, please [open an issue](https://github.com/ClarifiedSecurity/catapult/issues). The project(s) are under active development and we might miss something but will try to fix all of the issues we are aware of.

- When you see something that could be improved and you know how to do it you can create fork of the project, make the required changes and create a pull request. We might not accept all pull requests, or we might ask you to make some changes before we do. This is not a reflection on you as a developer, but rather a reflection on the direction of the project.

- When committing code, please make it in small, logical chunks. This makes it easier for us to review and accept your changes. Also make sure that your commit messages are clear and concise. The goal of the commit messages is to create a readable changelog. The commit messages must contain the following three components:
  - What was changed
  - Where it was changes
  - Why it was changed (when applicable)

Examples:

- Updated the default Ansible version in pyproject.toml file.

- Updated the docker-entrypoint.sh script to avoid race condition for certificate updates.
