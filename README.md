# registry

![Puppet Forge downloads](https://img.shields.io/puppetforge/dt/ffalor/registry.svg)
![GitHub issues](https://img.shields.io/github/issues/ffalor/ffalor-registry.svg)
![Puppet Forge version](https://img.shields.io/puppetforge/v/ffalor/registry.svg)
![Puppet Forge – PDK version](https://img.shields.io/puppetforge/pdk-version/ffalor/registry.svg)

## Table of Contents

1.  [Description](#description)
2.  [Requirements](#Requirements)
3.  [Usage - Configuration options and additional functionality](#usage)
    -   [Puppet Tasks and Bolt](#Puppet-Task-and-Bolt)
    -   [Puppet Task API](#Puppet-Task-Api)
4.  [Development - Guide for contributing to the module](#development)

## Description

This module includes a puppet task to help manage registry keys.

This task can be used to:

-   Get current registry keys/values (get)
-   Create new or overwrite registry keys/values (set)
-   Delete registry keys/values (delete)

## Requirements

Any Powershell Version

## Usage

### Puppet Task and Bolt

To run an registry task, use the task command, specifying the command to be executed.

-   With PE on the command line, run `puppet task run registry action=<set|delete|get> key=<key_path>`.
-   With Bolt on the command line, run `bolt task run registry action=<set|delete|get> key=<key_path>`.

For example, to add to create a key `HKLM:\SOFTWARE\Example` with a property `example_property` with a value of `example_value` of type `string` while overwriting current values, run:

-   With PE, run `puppet task run registry action=set key="HKLM:\SOFTWARE\Example" property="example_property" value="example_value" type=string force=true --nodes saturn`.
-   With Bolt, run `bolt task run registry action=set key="HKLM:\SOFTWARE\Example" property="example_property" value="example_value" type=string force=true --nodes saturn`.

### Puppet Task API

endpoint: `https://<puppet>:8143/orchestrator/v1/command/task`

method: `post`

body:

```json
{
  "environment": "production",
  "task": "registry",
  "params": {
    "action": "present",
    "key": "HKLM:\\SOFTWARE\\Example",
    "property": "example_property",
    "value": "example_value",
    "type": "string",
    "force": true
  },
  "description": "Description for task",
  "scope": {
    "nodes": ["saturn.example.com"]
  }
}
```

You can also run tasks in the PE console. See PE task documentation for complete information.

## Limitations

None

## Development

Feel free to open issues or create pull requests on Github.
