---
id: datamanagerworkflowschema-permission
title: "Datamanager flow JSON Schema: Permission"
---

## Permission

The permission object represents a permission check that will be performed to evaluate whether or not the currently logged in admin user is able to trigger the action.

### Summary

```yaml
permission:
  key: admin.permission.key
  handler: # handler object, call to the handler should return a boolean to indicate permission
    event: my.handler
    args:
      abitraryArg1: $statevariable
```

### Properties

| Name | Required | Type | Description |
|-------|--------|--------|--------|
| `key`  | `false` | `string` | Preside admin permission key (i.e. `hasCmsPermission( key )`). Required if `handler` not supplied. |
| `handler`  | `false` | `object` | A [[datamanagerworkflowschema-handler|handler]] object specifying a handler to run for a permission check. Required if `key` is not supplied. |


### JSON schema

```json
{
    "$schema": "http://json-schema.org/draft-07/schema#",
    "$id": "datamanager.permission.schema.json",
    "type": "object",
    "title": "Permission",
    "additionalProperties": false,
    "anyOf": [
        {"required": ["key"]},
        {"required": ["handler"]}
    ],
    "properties":{
        "key" : { "type":"string", "description":"Preside admin permission key to use to control access" },
        "handler" : { "type":"object", "$ref":"datamanager.handler.schema.json", "description":"Handler that returns a truthy result to indicate whether or not permission is granted to the current logged in user" }
    }
}
```