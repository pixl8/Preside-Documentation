---
id: datamanagerworkflowschema-join
title: "Datamanager flow JSON Schema: Join"
---

## Join

A join object represents a juncture in the flow where multiple active steps must become complete or skipped
before the flow can continue. The join object defines the steps to wait for, and the result definition that should
be triggered once those steps are completed.

### Summary

```yaml
joins:
  - id: myjoin
    waitForSteps:
      - step3
      - step4
    result:
        # default result object
    conditionalResults:
        # optional array of conditional results
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
                <td>Unique identifier for the join within the flow</td>
            </tr>
            <tr>
                <td><code>waitForSteps</code></td>
                <td><code>true</code></td>
                <td><code>array</code></td>
                <td>Array of step IDs. When the join is triggered, the results will only fire once all the steps here are either skipped or completed.</td>
            </tr>
            <tr>
                <td><code>result</code></td>
                <td><code>true</code></td>
                <td><code>object</code></td>
                <td>A default [[datamanagerworkflowschema-result|result]] object that defines step transitions and optional pre/post functions</td>
            </tr>
            <tr>
                <td><code>conditionalResults</code></td>
                <td><code>false</code></td>
                <td><code>array</code></td>
                <td>Optional array of [[datamanagerworkflowschema-conditionalresult|conditionalResult]] objects. First matching result will be executed when the join is triggered and all steps are complete or skipped.</td>
            </tr>
        </tbody>
    </table>
</div>


### JSON schema

```json
{
    "$schema": "http://json-schema.org/draft-07/schema#",
    "$id": "datamanager.join.schema.json",
    "type": "object",
    "title": "Join",
    "additionalProperties": false,
    "required":[ "id", "waitForSteps", "result" ],
    "properties":{
        "id"                 : { "type":"string", "description":"Unique ID of the step (unique to the workflow)" },
        "waitForSteps"       : { "type":"array" , "description":"Array of Step IDs. These steps must all be complete or skipped in order for this join action to execute." , "items":{"type":"string"} },
        "result"             : { "type":"object", "description":"The default result to run if no conditional results are defined or matched", "$ref":"datamanager.result.schema.json"},
        "conditionalResults" : { "type":"array" , "description":"Optional array of conditional results to run should their condition be matched. First matching result wins.", "items":{ "type":"object", "$ref":"datamanager.conditionalresult.schema.json" } }
    }
}
```