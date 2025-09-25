---
id: datamanagerworkflowschema-workflow
title: "Datamanager flow JSON Schema: Workflow"
---

## Workflow

The workflow object is the top level definition of your workflow. A simple object with required id, initialActions and steps + optional feature flag and join definitions.

### Summary

```yaml
version: 1.0.0
workflow:
  id: my_workflow
  feature: mycoolfeature
  initialActions:
    # array of initialAction objects...
  steps:
    # array of step objects...
  joins:
    # optional array of join objects...
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
                <td>Global identifier for the flow</td>
            </tr>
            <tr>
                <td><code>feature</code></td>
                <td><code>false</code></td>
                <td><code>string</code></td>
                <td>Optional feature flag for the flow. If the feature is disabled, the flow will not be loaded by the system.</td>
            </tr>
            <tr>
                <td><code>initialActions</code></td>
                <td><code>true</code></td>
                <td><code>array</code></td>
                <td>Array of [[datamanagerworkflowschema-initialaction|initialAction]] objects</td>
            </tr>
            <tr>
                <td><code>steps</code></td>
                <td><code>true</code></td>
                <td><code>array</code></td>
                <td>Array of [[datamanagerworkflowschema-step|step]] objects</td>
            </tr>
            <tr>
                <td><code>joins</code></td>
                <td><code>false</code></td>
                <td><code>array</code></td>
                <td>Array of [[datamanagerworkflowschema-join|join]] objects</td>
            </tr>
        </tbody>
    </table>
</div>


### JSON schema

```json
{
    "$schema": "http://json-schema.org/draft-07/schema#",
    "$id": "datamanager.workflow.schema.json",
    "type": "object",
    "title": "Workflow",
    "additionalProperties": false,
    "required":[ "version", "workflow" ],
    "properties":{
        "version":{ "type":"string", "enum":[ "1.0.0" ] },
        "workflow":{
            "type":"object",
            "required":[ "id", "initialActions", "steps" ],
            "properties":{
                "id"      : { "type":"string", "description":"Unique ID of the workflow (unique to the engine)" },
                "steps"   : { "type":"array" , "description":"Array of steps", "items":{ "type":"object", "$ref":"datamanager.step.schema.json" }, "minItems":2 },
                "joins"   : { "type":"array" , "description":"Array of joins", "items":{ "type":"object", "$ref":"datamanager.join.schema.json" } },
                "feature" : { "type":"string", "description":"Optional preside feature flag to control whether or not this flow is loaded and available." },
                "initialActions":{
                    "type": "array",
                    "minItems": 1,
                    "description": "Array of initial actions for the workflow. At least one must be specified to set the first step and perform any other functions and checks.",
                    "items": { "$ref": "datamanager.initialaction.schema.json" }
                }
            }
        }
    }
}
```