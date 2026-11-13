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

<div class="table-resp">
    <table class="table">
        <thead>
            <tr>
                <th>Name</th>
                <th>Required</th>
                <th>Type</th>
                <th>Description</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td><code>id</code></td>
                <td><code>true</code></td>
                <td><code>string</code></td>
                <td>Unique identifier for the step within the flow</td>
            </tr>
            <tr>
                <td><code>actions</code></td>
                <td><code>false</code></td>
                <td><code>array</code></td>
                <td>Array of [[datamanagerworkflowschema-action|action]] objects</td>
            </tr>
        </tbody>
    </table>
</div>


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