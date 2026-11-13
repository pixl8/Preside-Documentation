---
id: datamanagerworkflowschema-handler
title: "Datamanager flow JSON Schema: Handler"
---

## Handler

The handler object is used in various places throughout datamanager flows to define a Coldbox handler that will be run.

### Summary

```yaml
event: string
args: object
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
                <td><code>event</code></td>
                <td><code>true</code></td>
                <td><code>string</code></td>
                <td>Coldbox <code>event</code> identifier of the handler</td>
            </tr>
            <tr>
                <td><code>args</code></td>
                <td><code>false</code></td>
                <td><code>object</code></td>
                <td>Arbitrary <code>args</code> to pass to the handler</td>
            </tr>
        </tbody>
    </table>
</div>

### JSON schema

```json
{
    "$schema": "http://json-schema.org/draft-07/schema#",
    "$id": "datamanager.handler.schema.json",
    "type": "object",
    "additionalProperties": false,
    "title":"Webflow coldbox handler definition",
    "description":"Defines the use of a coldbox handler within an element of the datamanager flow",
    "required":[ "event" ],
    "properties": {
        "event": { "type": "string", "description": "The coldbox event to run." },
        "args": { "type": "object", "description": "Arbitrary set of arguments to send to the handler" }
    }
}
```