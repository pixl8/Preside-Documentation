---
id: datamanager-customization-postaddrecordaction
title: "Data Manager customization: postAddRecordAction"
---

## Data Manager customization: postAddRecordAction

The `postAddRecordAction` customization allows you to run logic _after_ the core Data Manager add record logic is run. It is not expected to return a value and is supplied the following in the `args` struct:

* `objectName`: name of the object
* `formData`: struct containing the form submission
* `newid`: ID of the newly created record


For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private void function postAddRecordAction( event, rc, prc, args={} ) {
		var newId = args.newId ?: "";

		// redirect to a different than default page
		setNextEvent( event.buildAdminLink(
			  objectName = "blog"
			, recordId   = newId
			, operation  = "preview"
		) );
	}
}
```

See also: [[datamanager-customization-pre	addrecordaction|pre	AddRecordAction]] and [[datamanager-customization-addrecordaction|addRecordAction]].


