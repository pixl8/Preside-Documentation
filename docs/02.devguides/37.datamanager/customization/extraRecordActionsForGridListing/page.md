---
id: datamanager-customization-extrarecordactionsforgridlisting
title: "Data Manager customization: extraRecordActionsForGridListing"
---

## Data Manager customization: extraRecordActionsForGridListing

The `extraRecordActionsForGridListing` allows you to add actions to the object's record listing rows, or modify the existing actions. It is not expected to return a value and is passed the following in the `args` struct:


* `objectName`: Name of the object.
* `record`: Struct representing the record for the current row.
* `actions`: Array containing the already calculated actions for the row. Modify this array to add/remove/edit the actions as per your requirements.

Each "action" in the `args.actions` array is a struct with the following possible keys:

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

	private void function extraRecordActionsForGridListing( event, rc, prc, args={} ) {
		var objectName = args.objectName ?: "";
		var record     = args.record     ?: {};
		var recordId   = record.id       ?: "";

		args.actions = args.actions ?: [];
		args.actions.append( {
			  link       = event.buildAdminLink( objectName=objectName, operation="download", recordid=recordId )
			, icon       = "fa-download"
			, contextKey = "d"
			, target     = "_blank"
		} );
	}

}
```

>>> If you need to complete make a new set of actions and disregard the core defaults, you should use [[datamanager-customization-getrecordactionsforgridlisting]] or [[datamanager-customization-getactionsforgridlisting]].