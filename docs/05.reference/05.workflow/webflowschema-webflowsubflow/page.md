---
id: webflowschema-webflowsubflow
title: "Webflow JSON Schema: Webflow Subflow"
---

## Webflow subflow JSON Schema

This is the top level schema for a **subflow** definition. This definition is very similar to a [[webflowschema-webflow|webflow]] definition, but is designed exclusively for re-usable subflows that can be inserted into full webflows.

### Summary

```yaml
id: string
feature: string
meta: object
steps:
- # {step}
- # {step}
```

### Properties

| Name | Required | Type | Description |
|-------|--------|--------|
| `id` | `true` | `string` | Unique identifier for the subflow. This will be used to include the subflow in webflows with `$subflowref` |
| `feature` | `false` | `string` | Preside feature that must be enabled in order for this subflow to be registered |
| `steps` | `true` | `array` | Array of [[webflowschema-step|step]] objects. Must have one or more steps. |
| `meta` | `false` | `object` | Arbitrary data to help describe your subflow. Not used by the engine. |

### JSON Schema

```json
{
    "$schema": "http://json-schema.org/draft-07/schema#",
    "$id": "webflow.subflow.schema.json",
    "type": "object",
    "title":"Subflow definition",
    "additionalProperties": false,
    "description":"Container object for a 'sub' flow that is really just a named array of steps that can be inserted into other flows",
    "required": [ "id", "steps" ],
    "properties": {
        "id":{ "type":"string", "description":"Unique identifier for the webflow template" },
        "meta":{ "type":"object", "description":"Abitrary struct of metadata to describe/enhance the webflow definition" },
        "feature":{ "type":"string", "description":"Preside feature that must be enabled in order for this subflow to be registered" },
        "steps": {
            "type": "array",
            "minItems": 1,
            "description": "The steps of the subflow. Any subflow must have at least one step.",
            "items": {
                "$ref": "webflow.step.schema.json"
            }
        }
    }
}
```