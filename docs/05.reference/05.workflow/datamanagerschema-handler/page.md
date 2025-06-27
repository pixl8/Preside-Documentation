---
id: datamanagerworkflowschema-handler
title: "Datamanager flow JSON Schema: Handler"
---

## Handler

The handler object is used in various places throughout datamanager flows to define a Coldbox handler that will be run.

### Summary

```yaml
event: string
args: object
```

### Properties

| Name | Required | Type | Description |
|-------|--------|--------|
| `event` | `true` | `string` | Coldbox `event` identifier of the handler  |
| `args` | `false` | `object` | Arbitrary `args` to pass to the handler |

### JSON schema

```json
{
    "$schema": "http://json-schema.org/draft-07/schema#",
    "$id": "datamanager.handler.schema.json",
    "type": "object",
    "additionalProperties": false,
    "title":"Webflow coldbox handler definition",
    "description":"Defines the use of a coldbox handler within an element of the datamanager flow",
    "required":[ "event" ],
    "properties": {
        "event": { "type": "string", "description": "The coldbox event to run." },
        "args": { "type": "object", "description": "Arbitrary set of arguments to send to the handler" }
    }
}
```