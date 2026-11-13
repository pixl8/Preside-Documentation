---
id: datamanagerworkflowschema-action
title: "Datamanager flow JSON Schema: Action"
---

## Action

The action object represents an action that may be triggered either automatically, or by an admin in datamanager. Actions are available to perform for any active steps in the workflow.

### Summary

```yaml
initialActions:
  - id: next
    auto: false
    form: some.preside.form
    permission:
      # optional action permission object
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
                <td>Unique identifier for the action within the step</td>
            </tr>
            <tr>
                <td><code>auto</code></td>
                <td><code>false</code></td>
                <td><code>boolean</code></td>
                <td>Default: <code>false</code>. Whether or not the action should run/be attempted to run automatically as soon as the step becomes active. If <code>auto: true</code>, then the action will not be available in the manual actions dropdown list in datamanager.</td>
            </tr>
            <tr>
                <td><code>form</code></td>
                <td><code>false</code></td>
                <td><code>string</code></td>
                <td>ID of a preside form definition that will be auto rendered for you on trigger of the action. Form must be submitted and validated in order for the action to then be triggered.</td>
            </tr>
            <tr>
                <td><code>permission</code></td>
                <td><code>false</code></td>
                <td><code>string</code></td>
                <td>A [[datamanagerworkflowschema-permission|permission]] object that defines whether or not this manual action can be triggered by the logged in admin user.</td>
            </tr>
            <tr>
                <td><code>condition</code></td>
                <td><code>false</code></td>
                <td><code>array</code></td>
                <td>A [[datamanagerworkflowschema-condition|condition]] object. If defined, the condition must evaluate to true before the action may be triggered.</td>
            </tr>
            <tr>
                <td><code>result</code></td>
                <td><code>true</code></td>
                <td><code>object</code></td>
                <td>A [[datamanagerworkflowschema-result|default result]] object specifying what step transitions to execute</td>
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
    "$id": "datamanager.action.schema.json",
    "type": "object",
    "title": "Action",
    "additionalProperties": false,
    "required":[ "id", "result" ],
    "properties":{
        "id"                 : { "type":"string" , "description":"Unique ID of the action (unique to the parent step)" },
        "auto"               : { "type":"boolean", "description":"Default is false. If true, the action will be auto triggered when its step becomes active, provided any conditions on the action are met." },
        "form"               : { "type":"string" , "description":"Identifier of a preside form to render and validate when triggering this action. Form must be submitted and valid before the action will be triggered." },
        "permission"         : { "type":"object" , "description":"For manual actions, optional permission check for the active logged in user to decide whether or not the action can be performed", "$ref":"datamanager.permission.schema.json" },
        "condition"          : { "type":"object" , "description":"Optional condition that must be true in order for the action to be run/or available to run", "$ref":"datamanager.condition.schema.json"},
        "result"             : { "type":"object" , "description":"The default result to run if no conditional results are defined or matched", "$ref":"datamanager.result.schema.json"},
        "conditionalResults" : { "type":"array"  , "description":"Optional array of conditional results to run should their condition be matched. First matching result wins.", "items":{ "type":"object", "$ref":"datamanager.conditionalresult.schema.json" } }
    }
}
```