---
id: dmflowquickstart
title: Datamanager Workflow Quick Start
---


# Data manager workflow quick start tutorial

**NOTE:** The following tutorial assumes you have a running Preside application using Preside **10.29** or above

# 1. Create an object

Create a test object named `dm_workflow_example` with i18n and a datamanager handler as below:


**/preside-objects/dm_workflow_example.cfc**
```luceescript
/**
 * @versioned                  false
 * @datamanagerEnabled         true
 * @datamanagerGridFields      label,datamanager_workflow_status,published,datemodified
 * @datamanagerWorkflowEnabled true
 *
 */
component {
    property name="label" uniqueindexes="label";

    property name="published" type="boolean" dbtype="boolean" required=true default=false control="none"; // not related to workflow, but useful for demonstrating a concept
}
```

**/i18n/preside-objects/dm_workflow_example.properties**
```properties
title=Workflow examples
title.singular=Workflow example
iconClass=fa-exclamation-circle
description=Dummy test object for testing workflow. Nothing to see here!

field.published.title=Published
```

**/handlers/admin/datamanager/dm_workflow_example.cfc**
```luceescript
component extends="preside.system.base.EnhancedDataManagerBase" {
    // as a starting point. All DM workflow objects will need
    // to use EnhancedDataManagerBase
}
```

## 2. Define a workflow

In our object definition, we added the annotation `@datamanagerWorkflowEnabled true` and this enables workflow. The critical next step is having the system marry a workflow definition (yaml file) with an object record. This can be done in three ways:

1. Single workflow for your object, convention based. Create `/workflows/datamanager/{your_object_name}.yml`
2. Single workflow for your object, explicitly defined. Annotate your object with `@datamanagerWorkflowDefaultFlow nameOfFlow` where there is a corresponding yml file at `/workflows/datamanager/{nameOfFlow}.yml`
3. Multiple workflows, dynamically set per record. Implement handler at `/admin/datamanager/{your_object}.cfc$getWorkflowForRecord()` to return the id of the workflow to use given the record ID. All workflows are defined under `/workflows/datamanager/*.yml`.

For our quick start, we will use approach 1 and create a yaml file at `/workflows/datamanager/dm_workflow_example.yml`:

```yaml
version: 1.0.0
workflow:
  id: dm_workflow_example

  initialActions:
  - id: startup
    result:
      activateSteps: [ "workqueued" ]

  steps:
  - id: workqueued
    actions:
    - id: start
      result:
        activateSteps: [ "started" ]

  - id: started
    actions:
    - id: complete
      result:
        skipSteps: [ "cancelled" ]
        activateSteps: [ "completed" ]
    - id: cancel
      result:
        skipSteps: [ "completed" ]
        activateSteps: [ "cancelled" ]

  - id: completed
  - id: cancelled

```

At this point, you should be able to reload your application and then:

1. browse to your object listing at `/admin/datamanager/object/?id=dm_workflow_example`
2. add a record
3. see that you have a new record in the listing with a 'workqueued' status
4. click to view the record
5. see that there is a workflow UI for the record that you can use to complete the flow

## 3. Add some i18n

Data manager workflows should have a corresponding i18n file. If your flow is named, `my_flow.yml`, you should have a corresponding i18n file at `/i18n/datamanagerWorkflow/my_flow.properties`, and so on.

With this in mind, create a new file, `/i18n/datamanagerWorkflow/dm_workflow_example.properties`:

```properties
# overall title of the flow
title=My awesome workflow

# title and icon for the startup action(s)
# these will be seen when viewing the flow change history
initial.action.startup.title=Workflow created
initial.action.startup.iconClass=fa-magic

# step properties, title + decription
step.workqueued.title=Work queued
step.workqueued.description=Ready for the ops team to kick off whenever they feel there is capacity.

# action properties are then a subset of the step uri
step.workqueued.action.start.title=Start work
step.workqueued.action.start.iconClass=fa-rocket

step.started.title=Work started
step.started.description=Work is in progress...

step.started.action.complete.title=Complete work
step.started.action.complete.iconClass=fa-check

step.started.action.cancel.title=Cancel work
step.started.action.cancel.iconClass=fa-ban

step.completed.title=Completed
step.cancelled.title=Cancelled
```

Reload your i18n (`reload i18n` in dev console) and try out the flow again. Things should look a little nicer :)

## 4. Using i18n to add prompts to manual actions

Edit your i18n file, adding the following entries in the appropriate place:

```properties
step.started.action.complete.prompt=Complete the flow

step.started.action.cancel.prompt=Cancel the flow
step.started.action.cancel.match=CANCEL
```

Reload your i18n and try out the flow again. You should now observe that you get a prompt dialog when performing actions and that the cancel action asks you to type the phrase CANCEL in order to trigger the action.

## 5. Adding permissions to actions

We may want to add permissioning to the execution of workflow actions. We can do this with basic Preside admin permission keys and/or handler logic to dynamically decide whether or not the logged in user has permission.

Edit your workflow yml file (`/workflows/datamanager/dm_workflow_example.yml`) to add the following `permission` object to the `started -> complete` action:

```yaml
- id: started
  actions:
  - id: complete
    permission:
      key: some.nonexistant.key
      handler:
        event: admin.datamanager.dm_workflow_example.canComplete
    result:
      skipSteps: [ "cancelled" ]
      activateSteps: [ "completed" ]
```

Next, in your `/admin/datamanager/dm_workflow_example.cfc` handler, add:

```luceescript
private function canComplete( event, rc, prc, args={} ) {
    return true;
}
```

Do a full application reload. Now, login as a non-superadmin user and have them try to complete a flow. You should find that they are unable to do so because they do not have the `some.nonexistant.key` permission. Next, log back in as a super user and play with your permission handler to return true/false and see the effect on your flow.

### 5b Add some permissioning i18n

You can alter the message that shows on hover of inactive actions that the user does not have permission to. Edit your workflow i18n file and add:

```properties
step.started.action.complete.access.denied=You do not have permission because you are not l33t.
```

Reload your i18n and test the effect.

## 6. Add conditions to your handlers

In addition to permissions, you are also able to set a condition that must evaluate to true before an action may be triggered. For example, you may wish to prevent publishing when certain content is not filled in, or a certain length.
We will edit our `.yml` workflow file, add a handler to perform our `coldbox.handler` condition and edit our i18n file to add a custom message on hover of a disabled action:

```yaml
- id: started
  actions:
  - id: complete
    condition: # this is a cfflow condition object
      ref: coldbox.handler
      args:
        event: admin.datamanager.dm_workflow_example.isReadyForCompleting
    permission:
      key: some.nonexistant.key
      handler:
        event: admin.datamanager.dm_workflow_example.canComplete
    result:
      skipSteps: [ "cancelled" ]
      activateSteps: [ "completed" ]
```

```luceescript
private function isReadyForCompleting( event, rc, prc, args={}, wfInstance ) {
    var state = wfInstance.getState();

    return Len( state.label ?: "" ) > 4;
}
```

```properties
step.started.action.complete.condition.failed=This record cannot be completed until the label is at least four characters long.
```

Reload the application and try out your new modifications.

## 7. Adding form screens to actions

You may wish to add user input forms that must be filled in order to proceed with an action. Let's add a new field to our object, 'cancellation_reason':

```luceescript
property name="cancellation_reason" type="string" dbtype="varchar" maxlength=200 control="none";
```

Add i18n if you like. Next we'll add a form at `/forms/preside-objects/dm_workflow_example/cancel.xml` (could be anywhere):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form i18nBaseUri="preside-objects.dm_workflow_example:">
  <tab id="default">
    <fieldset id="default" sortorder="10">
      <field binding="dm_workflow_example.cancellation_reason" control="textarea" />
    </fieldset>
  </tab>
</form>
```

Next, we'll add the form to our action in the workflow yaml:

```yaml
- id: started
  actions:
  - id: complete
    # ...,
  - id: cancel
    form: preside-objects.dm_workflow_example.cancel
    result:
      skipSteps: [ "completed" ]
      activateSteps: [ "cancelled" ]
```

Finally, let's also have the cancellation display in the view record screen by editing the datamanager handler by adding:

```luceescript
variables.infoCol1 = [ "cancellation_reason" ];
```

Reload your application and try a flow using the cancel action. See that the form gets in the way of submitting the action and that the state is automatically saved to the object.

## 8. Performing logic on actions

In addition to transitioning flows, you can also declare handlers to run pre/post action and also append arbitrary state to your object on triggering of an action.

Edit your flow yaml, adding the following to the 'complete' action of the 'started' step:

```yaml
- id: started
  actions:
  - id: complete
    condition: # this is a cfflow condition object
      ref: coldbox.handler
      args:
        event: admin.datamanager.dm_workflow_example.isReadyForCompleting
    permission:
      key: some.nonexistant.key
      handler:
        event: admin.datamanager.dm_workflow_example.canComplete
    result:
      skipSteps: [ "cancelled" ]
      activateSteps: [ "completed" ]
      appendState: # adding these lines to append state to the record
        published: true
```

Reload and perform a full flow with completion on a record. See that published becomes true at the end.

Next, we'll add pre and post handler actions to the result. These are just coldbox handlers and you can perform any logic that you want here:

```yaml
- id: started
  actions:
  - id: complete
    condition: # this is a cfflow condition object
      ref: coldbox.handler
      args:
        event: admin.datamanager.dm_workflow_example.isReadyForCompleting
    permission:
      key: some.nonexistant.key
      handler:
        event: admin.datamanager.dm_workflow_example.canComplete
    result:
      skipSteps: [ "cancelled" ]
      activateSteps: [ "completed" ]
      appendState:
        published: true
      # adding these arrays of pre/post handlers to run arbitrary logic
      preHandlers:
      - event: admin.datamanager.dm_workflow_example.preComplete
        args:
          append: $label # as with webflow, we reference state variables with $ to pass in to various aspects
      postHandlers:
      - event: admin.datamanager.dm_workflow_example.postComplete
        args:
          append: $label
```

Then add the following handler actions to your datamanager handler cfc to complete the implementation:

```luceescript
private function preComplete( event, rc, prc, args={}, wfInstance ) {
    var state = wfInstance.getState();
    var suffix = args.append ?: "";

    wfInstance.appendState( { label=( state.label & ":prehandler:" & suffix ) } )
}

private function postComplete( event, rc, prc, args={}, wfInstance ) {
    var state = wfInstance.getState();
    var suffix = args.append ?: "";

    wfInstance.appendState( { label=( state.label & ":posthandler:" & suffix ) } )
}
```

Reload the application and complete a flow and figure out what on earth we just did in those pre/post action handlers.

## 9. Splitting and joining flows

Unlike JIRA, data manager workflows support split flows! This means that you can have multiple active steps at the same time. Lets setup our flow to add a new step that will be active at the same time as the started step:

```yaml
steps:
  - id: workqueued
    actions:
    - id: start
      result:
        activateSteps: [ "started", "legal" ] # we activate multiple steps

  # our new "legal" step (oversimplified for example)
  - id: legal
    actions:
      - id: complete
        result:
          activateSteps: [ "complete" ]

  - id: started
  # ...
```

Add some i18n to our workflow properties file:

```properties
step.legal.title=Legal checks

step.legal.action.complete.title=Complete legal checks
step.legal.action.complete.iconClass=fa-gavel
```

If we reload and start a new flow and then play with it - you'll notice that we can start a flow and get it into a split state. However, the "Completed" step will become active as soon as either the "started" or "legal" steps is completed and we don't really want that. To solve this we will define a new **join**:

```yaml
workflow:
  id: dm_workflow_example
  # ...
  joins:
  - id: completionjoin
    waitForSteps: [ "started", "legal" ]
    result:
      skipSteps: [ "cancelled" ]
      activateSteps: [ "completed" ]

  steps:
  # ...
```

At this point **this join will not be automatically used**. To trigger the potential join result, we must edit the results of our two completion action results on the started and legal steps:

```yaml
  steps:
  # ...
  - id: legal
    actions:
      - id: complete
        result:
          joins: [ "completionjoin" ] # specify joins, instead of step transitions

  - id: started
    actions:
    - id: complete
      condition:
        # ...
      permission:
        # ...
      result:
        joins: [ "completionjoin" ] # replaces the activateSteps + skipSteps arrays
        # ...
  # ...
```

Reload your application and try the flow. The complete step should only become active after both steps are completed - no matter which order they come in.

## 10. Further reading

* [[datamanagerworkflowhelpers]]
* [[cfflowreference]]