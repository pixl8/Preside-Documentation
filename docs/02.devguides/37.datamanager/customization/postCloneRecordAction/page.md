---
id: datamanager-customization-postclonerecordaction
title: "Data Manager customization: postCloneRecordAction"
---

## Data Manager customization: postCloneRecordAction

The `postCloneRecordAction` customization allows you to run logic _after_ the core Data Manager clone record logic is run. It is not expected to return a value and is supplied the following in the `args` struct:

* `objectName`: name of the object
* `newId`: ID of the newly cloned record
* `formData`: struct containing the form submission
* `existingRecord`: struct containing the data from the current record
* `validationResult`: validation result from general form validation


For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private void function postCloneRecordAction( event, rc, prc, args={} ) {
		// redirect to a different than default page
		setNextEvent( event.buildAdminLink(
			  objectName = "blog"
			, recordId   = ( args.formData.id ?: "" )
			, operation  = "preview"
		) );
	}
}
```

See also: [[datamanager-customization-preclonerecordaction|predCloneRecordAction]] and [[datamanager-customization-clonerecordaction|cloneRecordAction]].

