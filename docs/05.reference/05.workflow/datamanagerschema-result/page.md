---
id: datamanagerworkflowschema-result
title: "Datamanager flow JSON Schema: Result"
---

## Result

The result object represents the default result for an action/initial action/join. It should define step transitions and optional pre/post functions and state to append to your record.

### Summary

```yaml
result:
  thisStep: complete
  activateSteps: [ step1, step2 ]
  skipSteps: [ step3 ]
  completeSteps: [ step4 ]
  pendingSteps: [ step5 ]
  skipIncompleteSteps: [ step6 ]
  activateIncompleteSteps: [ step7, step8 ]
  joins: [ joinx ]
  appendState:
    # abitrary object of data to append to state (supports state variable substitution)
  preHandlers:
    # optional array of handler objects
  postHandlers:
    # optional array of handler objects
```

### Properties

| Name | Required | Type | Description |
|-------|--------|--------|--------|
| `thisStep`                | `false` | `string` | Status to migrate this step to. Either, 'pending', 'skipped', 'complete' (default if not specified) |
| `activateSteps`           | `false` | `array`  | Array of step IDs to transition to an active status |
| `skipSteps`               | `false` | `array`  | Array of step IDs to transition to a skipped status |
| `completeSteps`           | `false` | `array`  | Array of step IDs to transition to a complete status |
| `pendingSteps`            | `false` | `array`  | Array of step IDs to transition to a pending status |
| `skipIncompleteSteps`     | `false` | `array`  | Array of step IDs to transition to a skipped status if they are currently either active or pending |
| `activateIncompleteSteps` | `false` | `array`  | Array of step IDs to transition to a active status when they are currently in a pending status (i.e. excludes skipped and completed steps) |
| `joins`                   | `false` | `array`  | Array of join IDs to be evaluated with this result |
| `appendState`             | `false` | `array`  | Arbitrary object of data to append to the workflow state (by default, this will append to the object's database record for any matching columns) |
| `preHandlers`             | `false` | `array`  | Array of [[datamanagerworkflowschema-handler|handler]] objects that will be executed *before* any steps are transitioned |
| `postHandlers`            | `false` | `array`  | Array of [[datamanagerworkflowschema-handler|handler]] objects that will be executed *after* any steps are transitioned |


### JSON schema

```json
{
    "$schema": "http://json-schema.org/draft-07/schema#",
    "$id": "datamanager.result.schema.json",
    "type": "object",
    "title": "Action result",
    "additionalProperties": false,
    "anyOf": [
        { "required": [ "joins"                   ]},
        { "required": [ "activateSteps"           ]},
        { "required": [ "skipSteps"               ]},
        { "required": [ "completeSteps"           ]},
        { "required": [ "pendingSteps"            ]},
        { "required": [ "skipIncompleteSteps"     ]},
        { "required": [ "activateIncompleteSteps" ]}
    ],
    "properties":{
        "thisStep"                : { "type":"string", "description":"The status to set this state to. Default is 'complete' if not defined. Cannot be 'active'.", "enum":[ "pending","complete","skipped" ] },
        "activateSteps"           : { "type":"array" , "description":"Optional array of step IDs to transition to an active state" , "items":{"type":"string"} },
        "skipSteps"               : { "type":"array" , "description":"Optional array of step IDs to transition to a skipped state" , "items":{"type":"string"} },
        "completeSteps"           : { "type":"array" , "description":"Optional array of step IDs to transition to a complete state", "items":{"type":"string"} },
        "pendingSteps"            : { "type":"array" , "description":"Optional array of step IDs to transition to a pending state" , "items":{"type":"string"} },
        "skipIncompleteSteps"     : { "type":"array" , "description":"Optional array of step IDs to transition to a skipped state (if not already skipped or complete)" , "items":{"type":"string"} },
        "activateIncompleteSteps" : { "type":"array" , "description":"Optional array of step IDs to transition to an active state (if not already skipped or complete)" , "items":{"type":"string"} },
        "appendState"             : { "type":"object", "description":"Abitrary data to append to the flow state."},
        "joins"                   : { "type":"array" , "description":"Optional array of join IDs to execute after this result (if all join steps are complete)" , "items":{"type":"string"} },
        "preHandlers"             : { "type":"array" , "description":"Array of handlers to run before steps are transitioned.", "items":{"type":"object", "$ref":"datamanager.handler.schema.json"} },
        "postHandlers"            : { "type":"array" , "description":"Array of handlers to run before steps are transitioned.", "items":{"type":"object", "$ref":"datamanager.handler.schema.json"} }
    }
}
```