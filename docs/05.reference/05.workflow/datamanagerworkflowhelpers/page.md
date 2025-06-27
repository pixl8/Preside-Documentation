---
id: datamanagerworkflowhelpers
title: Datamanager workflow helpers
---

# Datamanager workflow helpers

The data manager workflow system provides helper functions for your handlers/views/services that allow you to query the workflow state of a record (defaulting to the current record and object for datamanager pages). See below for a full reference of those functions.

**Note:** for all the methods below, you are able to pass an `objectName` and `recordId` argument. However, these arguments will default to the current object and record for any admin pages that have been initialized with `event.initializeDatamanagerPage( objectName, recordId )` (i.e. any view/edit pages of your records).

## getDatamanagerWorkflowInstance()

Returns a cfflow workflow instance object for the given/current record:

```luceescript
var wfInstance = getDatamanagerWorkflowInstance();

wfInstance.appendState( { something="test" } );
```

## getDatamanagerWorkflowStepStatus( stepId )

Returns the status (either 'pending', 'active', 'skipped' or 'completed') of the given step for the given/current record:

```luceescript
if ( getDatamanagerWorkflowStepStatus( "review" ) == "complete" ) {
	// do stuff
}
```

## isDatamanagerWorkflowStepActive( stepId )

Returns whether or not the given step for the given/current record is active:

```luceescript
if ( isDatamanagerWorkflowStepActive( "review" ) ) {
	// do stuff
}
```

## isDatamanagerWorkflowStepPending( stepId )

Returns whether or not the given step for the given/current record is pending:

```luceescript
if ( isDatamanagerWorkflowStepPending( "review" ) ) {
	// do stuff
}
```


## isDatamanagerWorkflowStepComplete( stepId )

Returns whether or not the given step for the given/current record is complete:

```luceescript
if ( isDatamanagerWorkflowStepComplete( "review" ) ) {
	// do stuff
}
```

## isDatamanagerWorkflowStepSkipped( stepId )

Returns whether or not the given step for the given/current record has been skipped:

```luceescript
if ( isDatamanagerWorkflowStepSkipped( "review" ) ) {
	// do stuff
}
```

## isDatamanagerWorkflowStepCompletedOrSkipped( stepId )

Returns whether or not the given step for the given/current record has either been skipped or is completed:

```luceescript
if ( isDatamanagerWorkflowStepCompletedOrSkipped( "review" ) ) {
	// do stuff
}
```

## getDatamanagerWorkflowActiveSteps()

Returns an array of step IDs that are active for the given/current record:

```luceescript
var stepIds = getDatamanagerWorkflowActiveSteps();

if ( ArrayFind( stepIds, "review" ) ) {
	// do stuff
}
```


## getDatamanagerWorkflowStepStatuses()

Returns a structure whose keys are step IDs and whose values are the corresponding status of those steps.

```luceescript
var stepStatuses = getDatamanagerWorkflowStepStatuses();

if ( stepStatuses.review == "active" ) {
	// do stuff
}
```