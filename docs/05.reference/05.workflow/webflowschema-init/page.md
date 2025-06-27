---
id: webflowschema-init
title: "Webflow JSON Schema: Init"
---

## Init

The `init` object is a child of the [[webflowschema-webflow|webflow object]] and allows you to define initialization and configuration options for your webflow.

### Summary

```yaml
state:
  handler: # {handler}
  configform: string
  args: object
instanceargs:
  handler: # {handler}
  args: object
condition: # {condition}

```

### Properties

| Name | Required | Type | Description |
|-------|--------|--------|
| `state` | `false` | `object` | Object to define how initial state of any workflow instance is set. |
| `state.handler` | `false` | `object` | Optional [[datamanagerworkflowschema-handler|handler]] that will be run to generate initial state args. |
| `state.configform` | `false` | `string` | Preside form ID of a form that will be used to configure this webflow. |
| `state.args` | `false` | `object` | Optional and arbitrary object that will be added to the initial state of any webflow instance on creation. |
| `instanceargs` | `false` | `object` | Optional object that describes how cfflow 'instanceArgs' are generated for this webflow. |
| `instanceargs.handler` | `false` | `object` | Optional [[datamanagerworkflowschema-handler|handler]] that will be run to generate instance args for this webflow. |
| `instanceargs.args` | `false` | `object` | Optional arbitrary object that will be appended to the cfflow 'instanceArgs' for this webflow |
| `condition` | `false` | `object` | Optional cfflow [[datamanagerworkflowschema-condition|condition]] object that must evaluate to true in order for an instance of this webflow to be instantiated. |

### JSON Schema

```json
{
    "$schema": "http://json-schema.org/draft-07/schema#",
    "$id": "webflow.init.schema.json",
    "type": "object",
    "title":"Webflow initialization definition",
    "additionalProperties": false,
    "description":"The init definition describes items such as pre-conditions for the flow, initial state and handler for extracting instance arguments.",
    "properties": {
        "state":{
            "type":"object",
            "description":"Definition The starting state for an instance of the flow.",
            "additionalProperties": false,
            "properties":{
                "handler":{ "type":"string", "description":"Coldbox handler that will return instance state in a struct." },
                "args":{ "type":"object", "description":"Hardcoded properties that will be returned as instance args" },
                "configform":{ "type":"string", "description":"Preside form ID that will be used to configure initial state for an instance of this flow. (i.e. an admin user will use this form to configure a specific instance of the flow)" }
            }
        },
        "instanceargs":{
            "type":"object",
            "description":"Definition of unique set of args that will identify an instance of this flow. These can be generated from a handler or hardcoded as a set of args here.",
            "additionalProperties": false,
            "properties":{
                "handler":{ "type": "object", "$ref":"webflow.handler.schema.json", "description":"Coldbox handler that will return instance args in a struct. It will be passed initialState struct with any initial state." },
                "args":{ "type":"object", "description":"Hardcoded properties that will be returned as instance args" }
            }
        },
        "condition": {
            "type": "object",
            "description":"CFFlow condition that must evaluate true in order for the flow to be able to be instantiated / worked through.",
            "$ref": "webflow.condition.schema.json"
        },
    }
}
```