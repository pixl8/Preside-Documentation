---
id: webflowschema-instrefconfig
title: "Webflow JSON Schema: Instance reference configuration"
---

## instance reference configuration JSON Schema

Schema for the configuration of the instance reference in a webflow

### Summary

```yaml
rendererViewlet: # {handler}
groupingConfigViewlet: # {handler}
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
            <tr><td>rendererViewlet</td><td>false</td><td>string</td><td>The coldbox event to run to render the instance reference value</td></tr>
            <tr><td>groupingConfigViewlet</td><td>false</td><td>string</td><td>The coldbox event to provide custom admin grouping configuration for the instance.</td></tr>
        </tbody>
    </table>
</div>

### JSON Schema

```json
{
    "$schema": "http://json-schema.org/draft-07/schema#",
    "$id": "webflow.instrefconfig.schema.json",
    "type": "object",
    "additionalProperties": false,
    "title":"Webflow instance reference configuration",
    "description":"Defines the configuration of the instance reference used within an element of the webflow",
    "required":[],
    "properties": {
        "rendererViewlet": { "type": "string", "description": "The coldbox event to run to render the instance reference value" },
        "groupingConfigViewlet": { "type": "string", "description": "The coldbox event to provide custom admin grouping configuration for the instance." }
    }
}
```