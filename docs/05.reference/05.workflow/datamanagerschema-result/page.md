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
                <td><code>thisStep</code></td>
                <td><code>false</code></td>
                <td><code>string</code></td>
                <td>Status to migrate this step to. Either, 'pending', 'skipped', 'complete' (default if not specified)</td>
            </tr>
            <tr>
                <td><code>activateSteps</code></td>
                <td><code>false</code></td>
                <td><code>array</code></td>
                <td>Array of step IDs to transition to an active status</td>
            </tr>
            <tr>
                <td><code>skipSteps</code></td>
                <td><code>false</code></td>
                <td><code>array</code></td>
                <td>Array of step IDs to transition to a skipped status</td>
            </tr>
            <tr>
                <td><code>completeSteps</code></td>
                <td><code>false</code></td>
                <td><code>array</code></td>
                <td>Array of step IDs to transition to a complete status</td>
            </tr>
            <tr>
                <td><code>pendingSteps</code></td>
                <td><code>false</code></td>
                <td><code>array</code></td>
                <td>Array of step IDs to transition to a pending status</td>
            </tr>
            <tr>
                <td><code>skipIncompleteSteps</code></td>
                <td><code>false</code></td>
                <td><code>array</code></td>
                <td>Array of step IDs to transition to a skipped status if they are currently either active or pending</td>
            </tr>
            <tr>
                <td><code>activateIncompleteSteps</code></td>
                <td><code>false</code></td>
                <td><code>array</code></td>
                <td>Array of step IDs to transition to a active status when they are currently in a pending status (i.e. excludes skipped and completed steps)</td>
            </tr>
            <tr>
                <td><code>joins</code></td>
                <td><code>false</code></td>
                <td><code>array</code></td>
                <td>Array of join IDs to be evaluated with this result</td>
            </tr>
            <tr>
                <td><code>appendState</code></td>
                <td><code>false</code></td>
                <td><code>array</code></td>
                <td>Arbitrary object of data to append to the workflow state (by default, this will append to the object's database record for any matching columns)</td>
            </tr>
            <tr>
                <td><code>preHandlers</code></td>
                <td><code>false</code></td>
                <td><code>array</code></td>
                <td>Array of [[datamanagerworkflowschema-handler|handler]] objects that will be executed <em>before</em> any steps are transitioned</td>
            </tr>
            <tr>
                <td><code>postHandlers</code></td>
                <td><code>false</code></td>
                <td><code>array</code></td>
                <td>Array of [[datamanagerworkflowschema-handler|handler]] objects that will be executed <em>after</em> any steps are transitioned</td>
            </tr>
        </tbody>
    </table>
</div>


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