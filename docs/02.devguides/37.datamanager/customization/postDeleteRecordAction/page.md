---
id: datamanager-customization-postdeleterecordaction
title: "Data Manager customization: postDeleteRecordAction"
---

## Data Manager customization: postDeleteRecordAction

The `postDeleteRecordAction` customization allows you to run logic _after_ the core Data Manager delete record(s) logic is run. It is not expected to return a value and is supplied the following in the `args` struct:

* `object`: name of the object
* `records`: query containing the records that were deleted

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private void function postDeleteRecordAction( event, rc, prc, args={} ) {
		// redirect to a different than default page
		setNextEvent( url=event.buildAdminLink(
			  objectName = "blog"
			, operation  = "postDeleteWarning"
		), persistStruct=args );
	}
	
}
```

See also: [[datamanager-customization-predeleterecordaction|preDeleteRecordAction]] and [[datamanager-customization-deleterecordaction|deleteRecordAction]].


