---
id: webflowschema-step
title: "Webflow JSON Schema: Step"
---

## Step

The `step` object is a child of the [[webflowschema-webflow|webflow object]] and is used to define in detail a step of your webflow. This schema is also used for globally registered independent steps.

### Summary

#### Minimum definitions

One of:

```yaml
id: string
```

```yaml
$ref: string
```

```yaml
$subflowref: string
```

#### Full definitions

All options for a step (without `$ref` or `$subflowref`):

```yaml
id: string
feature: string
configform: string
config: object
condition: # { condition }
preactions:
- handler: # { handler }
  condition: # { condition }
- handler: # { handler }
  condition: # { condition }
postactions:
- handler: # { handler }
  condition: # { condition }
- handler: # { handler }
  condition: # { condition }
display:
  form: string
  layout: # { handler }
  viewlet: # { handler }
submission:
  handler: # { handler }
  autovalidateforms: boolean
  ignoretimeout: boolean
next: string # or array of strings
prev: string # or array of strings
start: boolean
finish: boolean
canCancel: boolean
subflowEntryPoint: boolean
subflowExitPoint: boolean
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
                <td><code>true</code> (if no <code>$ref</code> or <code>$subflowref</code>)</td>
                <td><code>string</code></td>
                <td>Unique identifier for the step within this webflow or, if a global step, within the Preside application.</td>
            </tr>
            <tr>
                <td><code>$ref</code></td>
                <td><code>true</code> (if no <code>id</code> or <code>$subflowref</code>)</td>
                <td><code>string</code></td>
                <td>Unique identifier of a globally registered step to pull into this webflow.</td>
            </tr>
            <tr>
                <td><code>$subflowref</code></td>
                <td><code>true</code> (if no <code>id</code> or <code>$ref</code>)</td>
                <td><code>string</code></td>
                <td>Unique identifier of a globally registered <em>subflow</em> to pull into this webflow.</td>
            </tr>
            <tr>
                <td><code>feature</code></td>
                <td><code>false</code></td>
                <td><code>string</code></td>
                <td>Preside feature that must be enabled in order for this step to be registered</td>
            </tr>
            <tr>
                <td><code>configform</code></td>
                <td><code>false</code></td>
                <td><code>string</code></td>
                <td>Preside form ID that will be used by administrators when configuring this step.</td>
            </tr>
            <tr>
                <td><code>config</code></td>
                <td><code>false</code></td>
                <td><code>object</code></td>
                <td>Arbitrary object of configuration that will be merged with editorial config when getting the step configuration for rendering / submitting, etc.</td>
            </tr>
            <tr>
                <td><code>condition</code></td>
                <td><code>false</code></td>
                <td><code>object</code></td>
                <td>Optional cfflow [[datamanagerworkflowschema-condition|condition]] object that must evaluate to true in order for this step to be transitioned to active from the previous step.</td>
            </tr>
            <tr>
                <td><code>preactions</code></td>
                <td><code>false</code></td>
                <td><code>array</code></td>
                <td>Array of "pre-actions" that will be executed before this step is transitioned to active.</td>
            </tr>
            <tr>
                <td><code>preactions.handler</code></td>
                <td><code>false</code></td>
                <td><code>object</code></td>
                <td>Coldbox [[datamanagerworkflowschema-handler|handler]] that will be run to execute this preaction.</td>
            </tr>
            <tr>
                <td><code>preactions.condition</code></td>
                <td><code>false</code></td>
                <td><code>object</code></td>
                <td>Optional cfflow [[datamanagerworkflowschema-condition|condition]] object that must evaluate to true in order for this action to run.</td>
            </tr>
            <tr>
                <td><code>postactions</code></td>
                <td><code>false</code></td>
                <td><code>array</code></td>
                <td>Array of "post-actions" that will be executed after this step has successfully submitted and before the next step is transitioned to active.</td>
            </tr>
            <tr>
                <td><code>postactions.handler</code></td>
                <td><code>false</code></td>
                <td><code>object</code></td>
                <td>Coldbox [[datamanagerworkflowschema-handler|handler]] that will be run to execute this postaction.</td>
            </tr>
            <tr>
                <td><code>postactions.condition</code></td>
                <td><code>false</code></td>
                <td><code>object</code></td>
                <td>Optional cfflow [[datamanagerworkflowschema-condition|condition]] object that must evaluate to true in order for this action to run.</td>
            </tr>
            <tr>
                <td><code>display</code></td>
                <td><code>false</code></td>
                <td><code>object</code></td>
                <td>Optional object defining specifics of how to display this step</td>
            </tr>
            <tr>
                <td><code>display.form</code></td>
                <td><code>false</code></td>
                <td><code>string</code></td>
                <td>Optional Preside form ID to render when displaying this step</td>
            </tr>
            <tr>
                <td><code>display.layout</code></td>
                <td><code>false</code></td>
                <td><code>object</code></td>
                <td>Optional Coldbox [[datamanagerworkflowschema-handler|handler]] to use to display the <em>layout</em> for this step</td>
            </tr>
            <tr>
                <td><code>display.viewlet</code></td>
                <td><code>false</code></td>
                <td><code>object</code></td>
                <td>Optional Coldbox [[datamanagerworkflowschema-handler|handler]] to use to display the <em>content</em> of this step</td>
            </tr>
            <tr>
                <td><code>submission</code></td>
                <td><code>false</code></td>
                <td><code>object</code></td>
                <td>Optional object defining specific of how submission of this step is handled</td>
            </tr>
            <tr>
                <td><code>submission.handler</code></td>
                <td><code>false</code></td>
                <td><code>object</code></td>
                <td>Optional Coldbox [[datamanagerworkflowschema-handler|handler]] to run as part of submission</td>
            </tr>
            <tr>
                <td><code>submission.autovalidateforms</code></td>
                <td><code>false</code></td>
                <td><code>boolean</code></td>
                <td>Whether or not to automatically validate any preside forms that have been submitted with the step (default is <code>true</code>)</td>
            </tr>
            <tr>
                <td><code>submission.ignoretimeout</code></td>
                <td><code>false</code></td>
                <td><code>boolean</code></td>
                <td>Whether or not to ignore any timeouts set on the flow. Useful for critical steps such as payments.</td>
            </tr>
            <tr>
                <td><code>next</code></td>
                <td><code>false</code></td>
                <td><code>string</code> or <code>array</code></td>
                <td>Defines which step(s) can be transitioned to after this step. Used only when sequence is not necessarily in a straight order (i.e. conditional paths)</td>
            </tr>
            <tr>
                <td><code>prev</code></td>
                <td><code>false</code></td>
                <td><code>string</code> or <code>array</code></td>
                <td>Defines which step(s) can be transitioned to when going 'back' from this step. Used only when sequence is not necessarily in a straight order (i.e. conditional paths)</td>
            </tr>
            <tr>
                <td><code>start</code></td>
                <td><code>false</code></td>
                <td><code>boolean</code></td>
                <td>Whether or not this step can be the start of the flow (useful only when a step is not the first step in the flow, but may be the first step to be active due to previous steps having conditions). The first step in the array of steps is always a start step.</td>
            </tr>
            <tr>
                <td><code>finish</code></td>
                <td><code>false</code></td>
                <td><code>boolean</code></td>
                <td>Whether or not this step finishes the flow. The last step in the array is always a finish step, but you may additionally have other steps that can finish the flow.</td>
            </tr>
            <tr>
                <td><code>canCancel</code></td>
                <td><code>false</code></td>
                <td><code>boolean</code></td>
                <td>Whether or not a user is able to cancel the entire flow at this step. Default is <code>false</code></td>
            </tr>
            <tr>
                <td><code>subflowEntryPoint</code></td>
                <td><code>false</code></td>
                <td><code>boolean</code></td>
                <td><strong>For subflows only</strong>: whether or not this step is the first step within the subflow - works the same as <code>start</code> but for subflows.</td>
            </tr>
            <tr>
                <td><code>subflowExitPoint</code></td>
                <td><code>false</code></td>
                <td><code>boolean</code></td>
                <td><strong>For subflows only</strong>: whether or not this step is a final step within the subflow - works the same as <code>finish</code> but for subflows.</td>
            </tr>
        </tbody>
    </table>
</div>

### JSON Schema

```json
{
    "$schema": "http://json-schema.org/draft-07/schema#",
    "$id": "webflow.step.schema.json",
    "type": "object",
    "title":"Webflow step definition",
    "description":"Container object for a webflow step",
    "additionalProperties": false,
    "properties": {
        "id": { "type": "string", "description": "Unique id of the step"},
        "feature":{ "type":"string", "description":"Preside feature that must be enabled in order for this step to be registered" },
        "$ref": { "type": "string", "description": "Reference to a pre-registered step in the webflow step library." },
        "$subflowref": { "type": "string", "description": "Reference to a pre-registered subflow in the webflow spec library." },
        "configform":{ "type":"string", "description": "Optional preside form for configuring the step in an instance of this webflow." },
        "config":{ "type":"object", "description": "Optional hardcoded configuration that will be passed to the step (useful for re-usable steps and subflows)." },
        "canCancel":{ "type":"boolean", "description":"Whether or not the flow can be cancelled when on this step (always false on final steps)." },
        "condition":{
            "type":"object",
            "description":"Optional condition object that will determine whether or not the step is skipped",
            "$ref":"webflow.condition.schema.json"
        },
        "preactions":{
            "type": "array",
            "description": "Array of handlers to execute before transitioning to this step",
            "items": {
                "type":"object",
                "$ref":"webflow.prepostaction.schema.json"
            }
        },
        "postactions":{
            "type": "array",
            "description": "Array of handlers to execute before transitioning to the next or previous step",
            "items": {
                "type":"object",
                "$ref":"webflow.prepostaction.schema.json"
            }
        },
        "display":{
            "type":"object",
            "description":"Describes how the step will be displayed to the end-user",
            "additionalProperties": false,
            "properties":{
                "form":{ "type":"string", "description":"Preside form that will be rendered" },
                "layout":{ "type": "object", "$ref":"webflow.handler.schema.json", "description":"Explicit webflow layout in which to display the step" },
                "viewlet":{
                    "type":"object",
                    "description":"Coldbox viewlet used to render the step",
                    "$ref":"webflow.handler.schema.json"
                }
            }
        },
        "submission":{
            "type":"object",
            "description": "Describes what happens when the step is submitted",
            "additionalProperties": false,
            "required":[ "handler" ],
            "properties":{
                "handler":{
                    "type":"object",
                    "$ref":"webflow.handler.schema.json",
                    "description":"Action to perform when submitting this step."
                },
                "backHandler":{
                    "type":"object",
                    "$ref":"webflow.handler.schema.json",
                    "description":"Action to run when performing the 'back' action from this step. If the action returns false, the back trigger will be aborted and the step will remain active."
                },
                "autovalidateforms":{ "type":"boolean", "description":"Whether or not to automatically validate submitted preside forms (defaults to true)." },
                "ignoretimeout":{ "type":"boolean", "description":"Whether or not to ignore any timeouts set on the flow. Useful for critical steps such as payments." }
            }
        },
        "next":{
            "anyOf": [
                {
                  "type": "array",
                  "description": "Array of step IDs that will be the next possible steps for this step",
                  "items": {"type": "string"}
                },
                { "type": "string", "description": "Step ID that will be the next step after this step." }
            ]
        },
        "prev":{
            "anyOf": [
                {
                  "type": "array",
                  "description": "Array of step IDs that will be the previous possible steps for this step",
                  "items": {"type": "string"}
                },
                { "type": "string", "description": "Step ID that will be the previous step after this step." }
            ]
        },
        "start":{ "type": "boolean", "description":"Whether or not this step can be used to start the flow. Default is false, or true if it is the first step in the array of steps." },
        "finish":{ "type": "boolean", "description":"Whether or not this step terminates the flow. Default is false, or true if it is the last step in the array of steps." },
        "subflowEntryPoint":{ "type":"boolean", "description":"For steps in subflows, whether or not this step is to be considered an entry point for the subflow. This effects any 'prev' steps defined on the parent step including this subflow." },
        "subflowExitPoint":{ "type":"boolean", "description":"For steps in subflows, whether or not this step is to be considered an exit point for the subflow. This effects any 'next' steps defined on the parent step including this subflow."}
    },
    "anyOf": [
        { "required": [ "id" ] },
        { "required": [ "$ref" ] },
        { "required": [ "$subflowref" ] }
    ]
}
```