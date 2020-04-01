# registry: 
#
# This task will get, add, or remove registry keys and values..
#
# Parameters
# ----------
#
# * `action`
#   ENUM[get, set, delete]
#   When set to set the registry key or vlaue is created.
#   When set to get, the registry key contents or the value of a registry key is returned.
#   When set to delete the registry key or registry value is removed.
#
# * `key`
#   String[1]
#   The key to create or add a value to.
#
# * `property`
#   Optional[String[1]]
#   The property to add to a key.
#
# * `type`
#   Optional[ENUM[string, expandstring, binary, dword, multistring, qword]]
#   The type of the value.
#
# * `value`
#   Optional[String[1]]
#   The value of the property.
#
#   * `recurse`
#   Optional[Boolean]
#   Indicates to delete the items in the specified locations and in all child items of the locations. Defaults to False.
#
#   * `force`
#   Optional[Boolean]
#   Indicates to overwrite the current value of the key if it already exists. Defaults to False.
#
# @example Bolt run from Command Line
#   bolt task run registry -n localhost 
#     --params '{
#        "action": "set", 
#        "key": "HKLM:\Software\MyCompany",
#        "property": "hardened",
#        "type": "string",
#        "value": "true",
#        "force": true
#      }'
#
# Authors
# -------
#
# * Falor, Frank    <ffalorjr@outlook.com>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $True)]
    $action,

    [Parameter(Mandatory = $True)]
    $key,

    [Parameter(Mandatory = $False)]
    $property = $null,

    [Parameter(Mandatory = $False)]
    $type = $null,

    [Parameter(Mandatory = $False)]
    $value = $null,
    
    [Parameter(Mandatory = $False)]
    $recurse = $False,

    [Parameter(Mandatory = $False)]
    $force = $False
)

function WriteFailure($message) {


    $error_payload = @"
{
    "_error": {
        "msg": $message,
        "kind": "puppetlabs.tasks/task-error",
        "details": {
            "action": "${action}",
            "key": "${key}",
            "property": "${property}",
            "type": "${type}",
            "value": "${value}",
            "exitcode": 1
        }
    },
    "_output": "Something went wrong with task",
}
"@

    Write-Output $error_payload
}

function WriteSuccess($message) {

    $msg = ConvertTo-Json -InputObject $message -Depth 1

    $success_payload = @"
{
        "msg": ${msg}
}
"@
    Write-Output $success_payload

}

function ValidateParams {
    param (
        [Parameter(Mandatory = $False)]
        $params
    )
    foreach ( $param in $params ) {
        if (!$param) {
            return $False
        }
    }
    return $True
}

try {
    $args = @{
        path        = $key
        ErrorAction = "Stop"
    }
    if ($action -eq "get") {
        if ($property) {
            $args.add("name", $property)
            $msg = Get-ItemProperty @args
        }
        else {
            $msg = Get-Item @args
        }

        WriteSuccess -message $msg
    }
    elseif ($action -eq "set") {
        if (!(Test-Path -Path $key)) {
            New-Item -Path $key -Force | Out-Null
            $msg = "Key: ${key} created."
        }
        if ($property) {
            if (ValidateParams(@($type, $value))) {
                $args.Add("name", $property)
                $args.Add("type", $type)
                $args.Add("value", $value)
                if ($force) {
                    $msg = New-ItemProperty @args -Force
                }
                else {
                    $msg = New-ItemProperty @args
                }
            }
            else {
                WriteFailure("When creating a registry entry Type and Value parameters are required when a value for property is provided.")
            }
        }
        WriteSuccess -message $msg
    }
    elseif ($action -eq "delete") {
        if ($property) {
            $args.add("name", $property)
            Remove-ItemProperty @args
            $msg = "Registry property: ${property} removed from key: ${key}."
        }
        else {
            if ($recurse) {
                Remove-Item @args -Recurse
            }
            else {
                if ((Get-ChildItem $key | Measure-Object).Count -eq 0) {
                    Remove-Item @args
                }
                else {
                    WriteFailure("Key: ${key} has children and the Recurse parameter was not specified. Please add the recurse parameter with the value true if you want to delete this key and all children.")
                }
            }
            $msg = "Registry key: ${key} removed."
        }
        WriteSuccess -message $msg
    }
}
catch {
    $error_message = $_.Exception.Message
    WriteFailure -message $error_message
}