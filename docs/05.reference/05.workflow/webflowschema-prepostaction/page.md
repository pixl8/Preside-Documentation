---
id: webflowschema-prepostaction
title: "Webflow JSON Schema: Pre/Post Action"
---

## Pre or Post Action JSON Schema

Schema for an action that can be used in pre or post action arrays on steps

### Summary

```yaml
handler: # {handler}
condition: # {condition}
direction: forward # either forward (default), back or both
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
                <td><code>handler</code></td>
                <td><code>true</code></td>
                <td><code>object</code></td>
                <td>The [[datamanagerworkflowschema-handler|handler]] object to execute</td>
            </tr>
            <tr>
                <td><code>condition</code></td>
                <td><code>false</code></td>
                <td><code>object</code></td>
                <td>Optional cfflow [[datamanagerworkflowschema-condition|condition]] object that must evaluate to true in order for this action to be triggered.</td>
            </tr>
            <tr>
                <td><code>direction</code></td>
                <td><code>false</code></td>
                <td><code>string</code></td>
                <td>Direction of webflow travel that will trigger the action. Default is <code>forward</code>. Valid options: <code>forward</code>, <code>back</code> or <code>both</code></td>
            </tr>
        </tbody>
    </table>
</div>

### JSON Schema

```json
{
    "$schema": "http://json-schema.org/draft-07/schema#",
    "$id": "webflow.prepostfunction.schema.json",
    "type": "object",
    "title":"Webflow coldbox handler definition",
    "description":"Defines the use of a coldbox handler within an element of the webflow",
    "additionalProperties": false,
    "required":["handler"],
    "properties":{
        "handler":{
            "type": "object",
            "$ref":"webflow.handler.schema.json",
            "description":"Handler to execute"
        },
        "condition":{
            "type": "object",
            "$ref": "webflow.condition.schema.json",
            "description": "Condition that must be true for this handler to execute"
        },
        "direction":{
            "type": "string",
            "description": "Direction of flow travel that will trigger the action. Default is 'forward', options are 'forward', 'back' or 'both'",
            "enum": [
                "forward",
                "back",
                "both"
            ]
        }
    }
}
```