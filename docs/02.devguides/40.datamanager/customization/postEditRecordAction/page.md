---
id: datamanager-customization-posteditrecordaction
title: "Data Manager customization: postEditRecordAction"
---

## Data Manager customization: postEditRecordAction

The `postEditRecordAction` customization allows you to run logic _after_ the core Data Manager edit record logic is run. It is not expected to return a value and is supplied the following in the `args` struct:

* `objectName`: name of the object
* `formData`: struct containing the form submission
* `existingRecord`: struct containing the data from the current record
* `validationResult`: validation result from general form validation


For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private void function postEditRecordAction( event, rc, prc, args={} ) {
		// redirect to a different than default page
		setNextEvent( event.buildAdminLink(
			  objectName = "blog"
			, recordId   = ( args.formData.id ?: "" )
			, operation  = "preview"
		) );
	}
}
```

See also: [[datamanager-customization-preeditrecordaction|preEditRecordAction]] and [[datamanager-customization-editrecordaction|editRecordAction]].

