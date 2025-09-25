---
id: webflowschema-webflow
title: "Webflow JSON Schema: Webflow"
---

## Webflow JSON Schema

This is the top level schema for a webflow definition. Follow links in the spec table to read specifications for sub-objects.

### Summary

```yaml
version: 1.0.0
webflow:
  id: string
  feature: string
  singleton: boolean
  meta: object
  init: # {init}
  layout: # {handler}
  preCancelHandler: # {handler}
  postCancelHandler: # {handler}
  steps:
  - # {step}
  - # {step}
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
                <td><code>version</code></td>
                <td><code>true</code></td>
                <td><code>string</code></td>
                <td>Version of the schema. Must be <code>1.0.0</code>.</td>
            </tr>
            <tr>
                <td><code>webflow</code></td>
                <td><code>true</code></td>
                <td><code>object</code></td>
                <td>Object containing the webflow definition.</td>
            </tr>
            <tr>
                <td><code>webflow.id</code></td>
                <td><code>true</code></td>
                <td><code>string</code></td>
                <td>Unique identifier for the webflow.</td>
            </tr>
            <tr>
                <td><code>webflow.feature</code></td>
                <td><code>false</code></td>
                <td><code>string</code></td>
                <td>Preside feature that must be enabled in order for this flow to be registered</td>
            </tr>
            <tr>
                <td><code>webflow.steps</code></td>
                <td><code>true</code></td>
                <td><code>array</code></td>
                <td>Array of [[webflowschema-step|step]] objects. Must have two or more steps.</td>
            </tr>
            <tr>
                <td><code>webflow.meta</code></td>
                <td><code>false</code></td>
                <td><code>object</code></td>
                <td>Arbitrary data to help describe your flow. Not used by the engine.</td>
            </tr>
            <tr>
                <td><code>webflow.init</code></td>
                <td><code>false</code></td>
                <td><code>object</code></td>
                <td>Optional [[webflowschema-init|init]] object that can be used to definie initialisation and configuration options for the flow.</td>
            </tr>
            <tr>
                <td><code>webflow.layout</code></td>
                <td><code>false</code></td>
                <td><code>object</code></td>
                <td>Optional [[webflowschema-handler|handler]] object defining coldbox handler event and args to be used to render the layout for this webflow.</td>
            </tr>
            <tr>
                <td><code>webflow.preCancelHandler</code></td>
                <td><code>false</code></td>
                <td><code>object</code></td>
                <td>Optional [[webflowschema-handler|handler]] object defining coldbox handler event that is triggered before a webflow instance is cancelled.</td>
            </tr>
            <tr>
                <td><code>webflow.postCancelHandler</code></td>
                <td><code>false</code></td>
                <td><code>object</code></td>
                <td>Optional [[webflowschema-handler|handler]] object defining coldbox handler event that is triggered after a webflow instance is canncelled.</td>
            </tr>
        </tbody>
    </table>
</div>

### JSON Schema

```json
{
    "$schema": "http://json-schema.org/draft-07/schema#",
    "$id": "webflow.schema.json",
    "type": "object",
    "title":"Webflow definition",
    "additionalProperties": false,
    "description":"Container object for a complete Preside webflow definition",
    "required": [
        "version",
        "webflow"
    ],
    "properties": {
        "version": {
            "type": "string",
            "description": "Version number of the schema to validate against (i.e. this document)",
            "enum": [
                "1.0.0"
            ]
        },
        "webflow": {
            "type": "object",
            "description": "Container object for the webflow definition",
            "required":[ "id", "steps" ],
            "additionalProperties": false,
            "properties":{
                "id":{ "type":"string", "description":"Unique identifier for the webflow template" },
                "feature":{ "type":"string", "description":"Preside feature that must be enabled in order for this flow to be registered" },
                "singleton":{ "type":"boolean", "description":"Whether or not more than one configured instance of this flow can exist, or not." },
                "meta":{ "type":"object", "description":"Abitrary struct of metadata to describe/enhance the webflow definition" },
                "init":{ "type":"object", "$ref": "webflow.init.schema.json" },
                "layout":{ "type": "object", "$ref":"webflow.handler.schema.json", "description":"Explicit webflow layout viewlet in which to display steps" },
                "preCancelHandler":{ "type": "object", "$ref":"webflow.handler.schema.json", "description":"Handler action that is triggered before a webflow instance is cancelled." },
                "postCancelHandler":{ "type": "object", "$ref":"webflow.handler.schema.json", "description":"Handler action that is triggered after a webflow instance is cancelled." },
                "steps": {
                    "type": "array",
                    "minItems": 2,
                    "description": "The steps of the flow. Any webflow must have at least two steps.",
                    "items": {
                        "$ref": "webflow.step.schema.json"
                    }
                }
            }

        }
    }
}
```