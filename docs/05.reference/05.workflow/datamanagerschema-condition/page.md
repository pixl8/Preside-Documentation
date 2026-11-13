---
id: datamanagerworkflowschema-condition
title: "Datamanager flow JSON Schema: Condition"
---

## Condition

The condition object is used in various places throughout data manager workflows. This condition object is a [CfFlow condition object](https://pixl8.github.io/cfflow/reference/schema/condition.html) and you should familiarize yourself with the [CfFlow condition concepts](https://pixl8.github.io/cfflow/guides/concepts.html).

### Summary

```yaml
ref: string
meta: object
args: object
not: boolean
and:
- # {condition}
- # {condition}
or
- # {condition}
- # {condition}
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
                <td><code>ref</code></td>
                <td><code>true</code></td>
                <td><code>string</code></td>
                <td>Identifier of the registered condition class to use</td>
            </tr>
            <tr>
                <td><code>meta</code></td>
                <td><code>false</code></td>
                <td><code>object</code></td>
                <td>Arbitrary data to help describe your condition. Not used by the engine.</td>
            </tr>
            <tr>
                <td><code>args</code></td>
                <td><code>false</code></td>
                <td><code>object</code></td>
                <td>Arbitrary data to pass to the condition class when evaluating the condition</td>
            </tr>
            <tr>
                <td><code>not</code></td>
                <td><code>false</code></td>
                <td><code>boolean</code></td>
                <td>Whether or not the condition result should be inveresed.</td>
            </tr>
            <tr>
                <td><code>and</code></td>
                <td><code>false</code></td>
                <td><code>array</code></td>
                <td>Array of condition objects that must also be true.</td>
            </tr>
            <tr>
                <td><code>or</code></td>
                <td><code>false</code></td>
                <td><code>array</code></td>
                <td>Array of condition objects that may alternatively be true.</td>
            </tr>
        </tbody>
    </table>
</div>


### JSON schema

```json
{
    "$schema": "http://json-schema.org/draft-07/schema#",
    "$id": "datamanager.condition.schema.json",
    "type": "object",
    "title": "Datamanager flow condition",
    "additionalProperties": false,
    "description":"A condition represents a decision and will evaluate to either true or false when executed.",
    "required":[ "ref"],
    "properties":{
        "ref":{ "type":"string", "description":"Unique identifier for a condition evaluator that has been registered with the workflow engine." },
        "args":{ "type":"object","description":"Arbitrary set of arguments that will be passed to the condition handler." },
        "meta":{ "type":"object", "description": "Abitrary metadata that you may use to describe the condition." },
        "not":{ "type":"boolean", "description": "If set to true (default is false), condition must be false." },
        "and":{
            "type":"array",
            "description": "Optional array of conditions that also must evaluate true for the parent condition to be true",
            "items": {
                "type":"object",
                "$ref":"datamanager.condition.schema.json"
            }
        },
        "or":{
            "type":"array",
            "description": "Optional array of conditions that alternatively can evaluate true for the parent condition to be true",
            "items": {
                "type":"object",
                "$ref":"datamanager.condition.schema.json"
            }
        }
    }
}
```