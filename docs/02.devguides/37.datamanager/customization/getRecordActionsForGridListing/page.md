---
id: datamanager-customization-getrecordactionsforgridlisting
title: "Data Manager customization: getRecordActionsForGridListing"
---

## Data Manager customization: getRecordActionsForGridListing

The `getRecordActionsForGridListing` allows you to override the grid actions that display for each record in your object's record listing view. It is expected to return an array of structs representing the actions and receives two arguments in the `args` struct:

* `objectName`: the name of the object
* `record`: a struct representing the current record whose grid actions you are to return

Each item can/should have the following keys:

* `link`: Link for the action
* `icon`: Font awesome icon class for the action, e.g. `fa-pencil`
* `class`: Additional css classes for the action
* `contextKey`: Optional keyboard shortcut that will activate the action when the row is in focus
* `title`: Optional title that will be used in the title attribute of the link
* `target`: Link target, e.g. "\_blank" to open in a new tab

For example:

```luceescript
// /application/handlers/admin/datamanager/blog_post.cfc

component {

	private array function getRecordActionsForGridListing( event, rc, prc, args={} ) {
		var objectName = args.objectName ?: "";
		var record     = args.record     ?: {};
		var recordId   = record.id       ?: "";

		return [ {
			  link = event.buildAdminLink( objectName=objectName, operation="download", recordid=recordId )
			, icon = "fa-download"
		} ];
	}

}
```

>>> This customization is very similar to the [[datamanager-customization-getactionsforgridlisting|getActionsForGridListing]] customization. The key difference is that this customization operates on individual rows and may be a better option for situations where you need to run business logic per row.
>>>
>>> You may also consider the [[datamanager-customization-extrarecordactionsforgridlisting|extraRecordActionsForGridListing]] customization that allows you to add/modify the actions so that you can re-use existing core funcionality and logic for the actions rather than completely rewriting the logic.