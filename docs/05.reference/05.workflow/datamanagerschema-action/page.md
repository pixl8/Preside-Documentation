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

| Name | Required | Type | Description |
|-------|--------|--------|--------|
| `id`  | `true` | `string` | Unique identifier for the action within the step |
| `auto`  | `false` | `boolean` | Default: `false`. Whether or not the action should run/be attempted to run automatically as soon as the step becomes active. If `auto: true`, then the action will not be available in the manual actions dropdown list in datamanager. |
| `form`  | `false` | `string` | ID of a preside form definition that will be auto rendered for you on trigger of the action. Form must be submitted and validated in order for the action to then be triggered. |
| `permission`  | `false` | `string` | A [[datamanagerworkflowschema-permission|permission]] object that defines whether or not this manual action can be triggered by the logged in admin user. |
| `condition`  | `false` | `array` | A [[datamanagerworkflowschema-condition|condition]] object. If defined, the condition must evaluate to true before the action may be triggered. |
| `result`  | `true` | `object` | A [[datamanagerworkflowschema-result|default result]] object specifying what step transitions to execute |
| `conditionalResults`  | `false` | `array` | Array of [[datamanagerworkflowschema-conditionalresult|conditionalResult]] objects |


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