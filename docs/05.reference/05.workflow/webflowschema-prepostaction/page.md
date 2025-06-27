---
id: webflowschema-prepostaction
title: "Webflow JSON Schema: Pre/Post Action"
---

## Pre or Post Action JSON Schema

Schema for an action that can be used in pre or post action arrays on steps

### Summary

```yaml
handler: # {handler}
condition: # {condition}
direction: forward # either forward (default), back or both
```

### Properties

| Name | Required | Type | Description |
|-------|--------|--------|
| `handler` | `true` | `object` | The [[datamanagerworkflowschema-handler|handler]] object to execute |
| `condition` | `false` | `object` | Optional cfflow [[datamanagerworkflowschema-condition|condition]] object that must evaluate to true in order for this action to be triggered. |
| `direction` | `false` | `string` | Direction of webflow travel that will trigger the action. Default is `forward`. Valid options: `forward`, `back` or `both` |

### JSON Schema

```json
{
    "$schema": "http://json-schema.org/draft-07/schema#",
    "$id": "webflow.prepostfunction.schema.json",
    "type": "object",
    "title":"Webflow coldbox handler definition",
    "description":"Defines the use of a coldbox handler within an element of the webflow",
    "additionalProperties": false,
    "required":["handler"],
    "properties":{
        "handler":{
            "type": "object",
            "$ref":"webflow.handler.schema.json",
            "description":"Handler to execute"
        },
        "condition":{
            "type": "object",
            "$ref": "webflow.condition.schema.json",
            "description": "Condition that must be true for this handler to execute"
        },
        "direction":{
            "type": "string",
            "description": "Direction of flow travel that will trigger the action. Default is 'forward', options are 'forward', 'back' or 'both'",
            "enum": [
                "forward",
                "back",
                "both"
            ]
        }
    }
}
```