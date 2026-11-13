---
id: datamanagerworkflowschema-initialaction
title: "Datamanager flow JSON Schema: Initial action"
---

## InitialAction

The initialAction object represents an action that is triggered as soon as a record's workflow state is created. These actions are used to activate relevant starting steps for the flow and execute any other result logic that you need to fire.

### Summary

```yaml
initialActions:
  - id: defaultAction
    result:
      # default result object
    condition:
      # optional condition option
    conditionalResults:
      # optional array of conditional results, first matching result will be fired
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
                <td><code>result</code></td>
                <td><code>true</code></td>
                <td><code>object</code></td>
                <td>A [[datamanagerworkflowschema-result|default result]] object specifying what step transitions to execute</td>
            </tr>
            <tr>
                <td><code>condition</code></td>
                <td><code>false</code></td>
                <td><code>array</code></td>
                <td>A [[datamanagerworkflowschema-condition|condition]] object. If defined, the condition must evaluate to true before any other conditional initial actions for this action to be executed.</td>
            </tr>
            <tr>
                <td><code>conditionalResults</code></td>
                <td><code>false</code></td>
                <td><code>array</code></td>
                <td>Array of [[datamanagerworkflowschema-conditionalresult|conditionalResult]] objects</td>
            </tr>
        </tbody>
    </table>
</div>


### JSON schema

```json
{
    "$schema": "http://json-schema.org/draft-07/schema#",
    "$id": "datamanager.initialaction.schema.json",
    "type": "object",
    "title": "Action",
    "additionalProperties": false,
    "required":[ "id", "result" ],
    "properties":{
        "id"                 : { "type":"string", "description":"Unique ID of the action (unique to the set of initial actions)" },
        "condition"          : { "type":"object", "description":"Optional condition that must be true in order for the action to be run", "$ref":"datamanager.condition.schema.json"},
        "result"             : { "type":"object", "description":"The default result to run if no conditional results are defined or matched", "$ref":"datamanager.result.schema.json"},
        "conditionalResults" : { "type":"array" , "description":"Optional array of conditional results to run should their condition be matched. First matching result wins.", "items":{ "type":"object", "$ref":"datamanager.conditionalresult.schema.json" } }
    }
}
```