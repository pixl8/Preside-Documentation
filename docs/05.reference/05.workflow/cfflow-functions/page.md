---
id: cfflow-functions
title: "Workflow reference: CfFlow Functions"
---

## CfFlow Functions

Preside registers several functions with the CfFlow library that can be used throughout your CfFlow workflow definitions, i.e.

```yaml
actions:
  pre:
  - ref: coldbox.Handler
    args:
      event: my.custom.action
```

This page gives details of all the functions made available by Preside.

## Functions

### Coldbox functions

#### coldbox.Handler

The `coldbox.Handler` function allows you to trigger an arbitrary Coldbox handler.

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
actions:
  post:
    ref: coldbox.Handler
    args:
      event: email.Send
      args:
        template: registrationNotification
```

```luceescript
// /handlers/Email.cfc
component {

	// ...

	private void function send( event, rc, prc, args={}, wfInstance ) {
		var state = wfInstance.getState();

		sendEmail( template=args.template ?: "", args=state );
	}

}
```
