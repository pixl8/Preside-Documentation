---
id: webflowsubmittedfields
title: "Webflows: Choosing which submitted fields are saved"
---

## Choosing which submitted fields are saved

>>> Available from **10.29.74**, **10.30.63** and **10.31.10**.

A submitted step saves keys into the webflow instance state. Later steps and your submission handlers read that state back. These releases let a flow decide which submitted keys are allowed into that state.

Existing flows keep the previous behaviour until you opt in. A definition that uses the new properties fails schema validation on an older Preside release.

### What gets saved

By default, the saved set is the submitted request, without ColdBox system variables, with the processed form data copied over the top. Any key the visitor posts is saved, including keys that are not fields on the step form.

A key written by an earlier step, or by your own code, can be replaced by a value posted with a later submission. Review any flow whose later steps trust a value your code wrote into state, such as an address, an identifier, or a decision made on an earlier step.

### Limiting a step

`submission.persistFields` lists the extra request keys that step may save, on top of the fields on `display.form`. Those form fields are saved when they were submitted.

The property being present is what turns the limit on. An empty list saves the form fields and nothing else. A step that declares the list always uses it, including when the flow or the application still allows undeclared fields.

```yaml
submission:
  handler:
    event: webflow.myflow.detailsAction
  persistFields:
    - chosen_action
```

```yaml
submission:
  handler:
    event: webflow.myflow.confirmAction
  persistFields: []
```

System request keys are not copied from the request, even when they are named in the list.

### Limiting a whole flow

`webflow.persistUndeclaredFields` is the default for steps in that flow that do not declare `submission.persistFields`.

* `false`: those steps save form fields only.
* `true`: those steps save the whole request.
* omitted: the application setting is used.

```yaml
version: 1.0.0
webflow:
  id: myflow
  persistUndeclaredFields: false
  steps:
    # ...
```

The application setting is `settings.webflow.state.persistUndeclaredFields` in `Config.cfc`. It defaults to `true`, which is the behaviour from before these releases. Leave that default in place until the flows you ship have declared the keys they intend to keep. Setting it to `false` changes every flow that does not set its own value.

Set `persistUndeclaredFields: false` on a flow once every step that posts extra keys has a `persistFields` list.

### Forms rendered by convention

A step can render the form `webflow.{webflowId}.{stepId}` without setting `display.form`. The fields saved from a form are taken from `display.form` only. Once a step or flow stops saving undeclared keys, set `display.form` to that form name so its fields are still saved.
