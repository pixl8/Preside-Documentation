---
id: webflowglobalsteps
title: "Webflows: Defining and working with global steps"
---

## Defining and working with global steps

**NOTE:** It is expected that you have worked through the [[webflowquickstart|quick start tutorial]] before preceeding to work through this guide.

### Introduction

Global steps allow you to define and register a single step that can be used in one or _more_ webflows and subflows. This has two benefits:

1. Prevent code copying
2. Allow editors to define _default_ step configuration that can be tweaked or overwritten in individual scenarios

The principles and [[webflowschema-step|schema]] of the steps are identical to steps defined within a webflow definition.

![Figure 1: Global steps admin listing screen](images/screenshots/webflow-admin-configure-global-steps.png)

### Step-by-step guide

#### 1. Define a re-usable step

##### YAML definition

Copy and paste the following yaml into a file at `{webroot}/application/workflow/webflowSteps/tutorialStep.yml`:

```yml
id: tutorialstep
configform: webflow.steps.tutorialstep.config
display:
  form: webflow.steps.tutorialstep
  viewlet:
    event: webflow.steps.tutorialstep.screen
submission:
  handler:
    event: webflow.steps.tutorialstep.action
```

**NOTE:** Notice how we are explicitly defining the display form, viewlet and submission handlers. We can also do this for steps within webflows, but we _must_ do it for global steps.

##### Properties file for labelling

Next, copy and paste the following into an i18n properties file at `{webroot}/application/i18n/webflow/step/tutorialstep.properties`:

```properties
label=TUTORIAL: Global step
description=A step to demonstrate global step configuration
```

##### Forms, handlers and views

Finally, create the forms at `/forms/webflow/steps/tutorialstep.xml` and `/forms/webflow/steps/tutorialstep.config.xml` and implement the handlers `/handlers/webflow/TutorialStep.cfc$screen()` + `/handlers/webflow/TutorialStep.cfc$action()`. I will leave what these contain to your imagination :)

#### 2. Use step in a webflow


Using our `webflowtutorial` webflow from the [[webflowquickstart|quick start guide]], modify it to include the global step by using the `$ref` property in place of `id`:

```yml
version: 1.0.0
webflow:
  id: webflowtutorial
  singleton: true
  steps:
  - id: introduction
  - id: aform
  - $ref: tutorialstep
  - id: alternativeending
    finish: true
    condition:
      ref: bool.IsTruthy
      args:
        value: $aformfield
  - id: ending
```

Reload your application and test:

1. Editing the global step configuration
2. Running through the flow in the frontend
3. Overriding the global step configuration in the webflow (admin)

#### 3. Supply config and add a condition to included step

When referencing a global step from within a webflow definition, you can override any of the step definition properties as well as pass in hardcoded stepConfig. For example, let's add a condition and set some config:

```yml
version: 1.0.0
webflow:
  id: webflowtutorial
  singleton: true
  steps:
  - id: introduction
  - id: aform
    next: # we now need to define which steps can be travelled to from here
    - tutorialstep
    - ending

  # Add custom config and a condition
  - $ref: tutorialstep
    config:
       activateSomeCustomFeature: true
    condition:
      ref: bool.IsTruthy
      args:
        value: $aformfield
  - id: alternativeending
    finish: true

  - id: ending
```

Reload the application and **play** with making use of the stepConfig added here.

**TIP** Note also the addition of the `next` property. This allows us to shape the flow of our webflow. By default, the webflow will calculate which steps are possible to travel forwards and backwards to. However, when using conditions on steps, it is sometimes necessary to specify explicit `next` and `prev` step/s that are possible to travel to.