---
id: datamanager-customization-postQuickEditrecordaction
title: "Data Manager customization: postQuickEditRecordAction"
---

## Data Manager customization: postQuickEditRecordAction

The `postQuickEditRecordAction` customization allows you to run logic _after_ the core Data Manager add record logic is run. It is not expected to return a value and is supplied the following in the `args` struct:

* `objectName`: name of the object
* `formData`: struct containing the form submission
* `validationResult`: validation result from general form validation

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private void function postQuickEditRecordAction( event, rc, prc, args={} ) {
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

See also: [[datamanager-customization-prequickeditrecordaction|preQuickEditRecordAction]] and [[datamanager-customization-quickeditrecordaction|quickEditRecordAction]].


