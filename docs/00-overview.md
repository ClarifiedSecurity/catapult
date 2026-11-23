# Overview

This page aims to provide a **basic** overview of Catapult, what it is. On a very simple level it's Ansible running in a Docker container with some extra features to make it easier to use and manage. But it's much more than that. Catapult is a tool that helps you manage your Ansible projects and environments in a way that is scalable, maintainable and reusable. Once you have installed Catapult and set up your project, you can keep coming back here to better understand how Catapult works and how to use it effectively.

## Simple Deployment Tree

Catapult (like Ansible) is host driven, meaning that you target your deployment either against a remote host or delegate it to the local machine (when interacting with APIs instead of VMs).

When deploying a remote host it's important to understand what steps Catapult goes through when configuring the host. The simple deployment tree is as follows:

| #   | Step                                                                                                                              | Description                                                                                                                                                          |
| --- | --------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 0   | loading variables                                                                                                                 | Loading variables for the host, this includes host/group_vars, Catapult defaults, module defaults, etc. This is default Ansible behavior.                            |
| 1   | [deploy_vars](https://github.com/ClarifiedSecurity/nova.core/tree/main/nova/core/roles/deploy_vars)                               | Loading custom Catapult specific defaults and running early stage tasks                                                                                              |
| 2   | [machine_operations](https://github.com/ClarifiedSecurity/nova.core/tree/main/nova/core/roles/machine_operations)                 | Creating a virtual machine                                                                                                                                           |
| 3   | [configure_networking](https://github.com/ClarifiedSecurity/nova.core/tree/main/nova/core/roles/configure_networking)             | Configuring the network settings for the virtual machine                                                                                                             |
| 4   | [connection](https://github.com/ClarifiedSecurity/nova.core/tree/main/nova/core/roles/connection)                                 | Setting correct network connection parameters to connect and configure the machine (mostly over SSH)                                                                 |
| 5   | [accounts](https://github.com/ClarifiedSecurity/nova.core/tree/main/nova/core/roles/accounts)                                     | Creating required accounts defined in the `admin_accounts`, `user_accounts` or `domain_user_accounts` variables with the project                                     |
| 6   | [os_configuration](https://github.com/ClarifiedSecurity/nova.core/tree/main/nova/core/roles/os_configuration)                     | Running basic OS configurations like setting hostname, timezone, NTP settings, etc.                                                                                  |
| 7   | [customization_pre_vm_role](https://github.com/ClarifiedSecurity/nova.core/tree/main/nova/core/roles/customization_pre_vm_role)   | Including pre-VM customization role if it exists. This can be used to apply something to some group or all hosts of the project before starting the VM configuration |
| 8   | [customization](https://github.com/ClarifiedSecurity/nova.core/tree/main/nova/core/roles/customization)                           | Including machine specific role if it exists. Turning a blank VM into an application.                                                                                |
| 9   | [customization_post_vm_role](https://github.com/ClarifiedSecurity/nova.core/tree/main/nova/core/roles/customization_post_vm_role) | Including post-VM customization role if it exists. Same as `customization_pre_vm_role` but runs after the VM configuration.                                          |
| 10  | [finalize](https://github.com/ClarifiedSecurity/nova.core/tree/main/nova/core/roles/finalize)                                     | Running finalization tasks like running tests, updates, cleanup, etc.                                                                                                |
| 11  | [get_ip](https://github.com/ClarifiedSecurity/nova.core/tree/main/nova/core/roles/get_ip)                                         | Printing out the connection info of the VM                                                                                                                           |

## Deployment Tree with deploy modes

The diagram below shows the logical start and end of each command, using the step numbers from the [Simple Deployment Tree](#simple-deployment-tree).

```text
                      1     2     3     4     5     6     7     8     9     10    11
                      vars  VM    net   conn  acct  OS    pre   cust  post  fin   IP

deploy                ●━━━━━●━━━━━●━━━━━●━━━━━●━━━━━●━━━━━●━━━━━●━━━━━●━━━━━●━━━━━●
redeploy              ●━━━━━↻━━━━━●━━━━━●━━━━━●━━━━━●━━━━━●━━━━━●━━━━━●━━━━━●━━━━━●
remove                ●━━━━━✕
deploy-to-clone       ●━━━━━●━━━━━●
deploy-to-base        ●━━━━━●━━━━━●━━━━━●━━━━━●━━━━━◆
deploy-with-network   ●━━━━━●━━━━━◎━━━━━●━━━━━●━━━━━●━━━━━●━━━━━●━━━━━●━━━━━●━━━━━●
deploy-with-mid-snap  ●━━━━━●━━━━━●━━━━━●━━━━━●━━━━━◆━━━━━●━━━━━●━━━━━●━━━━━●━━━━━●
deploy-from-clone                       ●━━━━━●━━━━━●━━━━━●━━━━━●━━━━━●━━━━━●━━━━━●
deploy-from-base                                          ●━━━━━●━━━━━●━━━━━●━━━━━●
deploy-role           ●┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄●┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄●
```

| Symbol | Meaning                                                                     |
| ------ | --------------------------------------------------------------------------- |
| `●`    | Step runs                                                                   |
| `↻`    | Existing VM is removed and a new one is created (all `redeploy-*` commands) |
| `✕`    | VM is removed and the play stops                                            |
| `◎`    | Network settings are reconfigured even if the VM already exists             |
| `◆`    | `Pre-customization` snapshot is created after the step                      |
| `┄`    | Steps in between are skipped                                                |

### Running any role on its own

`deploy-single-role` and `deploy-pre-role` don't follow the deploy flow. Instead of the numbered steps they run one role of your choice, given as the first (tab-completable) argument, and then stop. The role can come from the project, from installed collection like `nova.core`. The two commands differ in where that role is included:

```text
deploy-pre-role       vars ━━▶ <any role> ■
deploy-single-role    vars ━━▶ conn ━━▶ <any role> ■
```

| Command              | Where the role is included                          | Typical use                                                                                                 |
| -------------------- | --------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| `deploy-pre-role`    | Right after **1 - deploy_vars**, before any VM work | Roles that don't need a connection to the VM and run on localhost, like snapshots, power state or API calls |
| `deploy-single-role` | After **4 - connection**                            | Running or developing one role against an existing VM                                                       |

`■` means the play stops.
