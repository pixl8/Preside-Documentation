---
id: datamanagerworkflowschema-step
title: "Datamanager flow JSON Schema: Step"
---

## Step

The step object represents a step in the workflow. Steps must each have a unique ID and an optional array of actions. Steps with no actions are used to terminate a workflow.

### Summary

```yaml
steps:
  - id: step1
    actions:
      # optional array of action objects
```

### Properties

| Name | Required | Type | Description |
|-------|--------|--------|--------|
| `id`  | `true` | `string` | Unique identifier for the step within the flow |
| `actions`  | `false` | `array` | Array of [[datamanagerworkflowschema-action|action]] objects |


### JSON schema

```json
{
    "$schema": "http://json-schema.org/draft-07/schema#",
    "$id": "datamanager.step.schema.json",
    "type": "object",
    "title": "Step",
    "additionalProperties": false,
    "required":[ "id" ],
    "properties":{
        "id"      : { "type":"string", "description":"Unique ID of the step (unique for the flow)" },
        "actions" : { "type":"array" , "description":"Optional array of actions that can be performed while the step is active (no actions = end of flow)", "items":{ "type":"object", "$ref":"datamanager.action.schema.json" } }
    }
}
```