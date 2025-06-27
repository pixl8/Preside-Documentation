---
id: webflowcancellation
title: "Webflows: Allowing users to cancel"
---

## Allowing users to cancel

**NOTE:** It is expected that you have worked through the [[webflowquickstart|quick start tutorial]] before preceeding to work through this guide.

### Introduction

Oftentimes, it makes sense to allow a user to cancel a journey before they have reached the end. The webflow system allows you to specify steps that can be cancelled and to specify coldbox handler actions to run when the flow is cancelled.

### Configuring pre/post cancel handlers

To configure custom code to run both before and after the flow cancellation occurs, you can add the `preCancelHandler` and `postCancelHandler` properties to your webflow definition. e.g.

```yaml
version: 1.0.0
webflow:
  id: webflowtutorial
  singleton: true
  preCancelHandler:
    event: myCustom.preCancelHandler
    args:
      someArg: true
  postCancelHandler:
    event: myCustom.postCancelHandler
    args:
      someArg: true
  steps:
    # ...
```

The `preCancelHandler` can be useful for tidying up any custom data that you may have stored while the `postCancelHandler` can be useful for redirecting your user to a sensible page.

### Allowing steps to be cancelled

By _default_, you cannot cancel in any steps. In addition, you can _never_ cancel in a _final_ step (the flow has already completed). In order to configure a step to be able to be cancelled, add the `canCancel` flag to the step. e.g.


```yaml
version: 1.0.0
webflow:
  id: webflowtutorial
  singleton: true
  preCancelHandler:
    event: myCustom.preCancelHandler
    args:
      someArg: true
  postCancelHandler:
    event: myCustom.postCancelHandler
    args:
      someArg: true
  steps:
  - id: introduction
    canCancel: true # allow cancellation, even on the intro!
  - id: aform
    canCancel: true # allow cancellation on the form step
  - id: alternativeending
    finish: true
    condition:
      ref: bool.IsTruthy
      args:
        value: $aformfield
  - id: ending
```