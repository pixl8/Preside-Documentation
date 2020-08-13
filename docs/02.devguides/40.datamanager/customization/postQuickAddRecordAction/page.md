---
id: datamanager-customization-postQuickaddrecordaction
title: "Data Manager customization: postQuickAddRecordAction"
---

## Data Manager customization: postQuickAddRecordAction

The `postQuickAddRecordAction` customization allows you to run logic _after_ the core Data Manager add record logic is run. It is not expected to return a value and is supplied the following in the `args` struct:

* `objectName`: name of the object
* `formData`: struct containing the form submission
* `newId`: ID of the newly created record


For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private void function postQuickAddRecordAction( event, rc, prc, args={} ) {
		var newId = args.newId ?: "";

		// redirect to a different than default page
		setNextEvent( url=event.buildAdminLink(
			  objectName = "blog"
			, recordId   = newId
			, operation  = "preview"
		) );
	}
}
```

See also: [[datamanager-customization-prequickaddrecordaction|preQuickAddRecordAction]] and [[datamanager-customization-quickaddrecordaction|quickAddRecordAction]].


