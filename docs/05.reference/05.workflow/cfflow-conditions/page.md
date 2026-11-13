---
id: cfflow-conditions
title: "Workflow reference: CfFlow Conditions"
---

## CfFlow Conditions

Preside registers several conditions with the CfFlow library that can be used throughout both your CfFlow _and_ [[webflow|webflow]] definitions, i.e.

```yaml
steps:
- id: mystep
  condition:
    ref: preside.IsLoggedIn
```

This page gives details of all the conditions made available by Preside.

## Conditions

### Coldbox conditions

#### coldbox.Handler

The `coldbox.Handler` condition allows you to run an arbitrary Coldbox handler that should return a boolean value indicating the success or failure of the condition.

In addition to the optionally provided `args`, your handler will receive the `wfInstance` on which the condition is operating.

##### Args

<div class="table-resp">
    <table class="table">
        <thead>
            <tr>
                <th>Name</th>
                <th>Description</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td><code>event</code></td>
                <td>Required. The coldbox <code>event</code> id to execute</td>
            </tr>
            <tr>
                <td><code>args</code></td>
                <td>Optional. The <code>args</code> struct to send to the handler</td>
            </tr>
        </tbody>
    </table>
</div>

##### Example


```yaml
condition:
  ref: coldbox.Handler
  args:
    event: events.isPublic
    args:
      testmode: $testmode
```

```luceescript
// /handlers/Events.cfc
component {

	// ...

	private boolean function isPublic( event, rc, prc, args={}, wfInstance ) {
		var state = wfInstance.getState();

		return eventsService.eventIsPublic(
			  eventId  = state.event_id
			, testMode = IsTrue( args.testMode ?: "" )
		);
	}

}
```

### Preside conditions

#### preside.IsLoggedIn

The `preside.IsLoggedIn` condition returns whether or not the current website visitor is a logged in website user.

##### Args

This condition takes no arguments.

##### Example

```yaml
steps:
## ...
- id: login
  condition:
    ref: preside.IsLoggedIn
    not: true
```
