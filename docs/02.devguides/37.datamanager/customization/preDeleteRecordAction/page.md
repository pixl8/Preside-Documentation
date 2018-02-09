---
id: datamanager-customization-predeleterecordaction
title: "Data Manager customization: preDeleteRecordAction"
---

## Data Manager customization: preDeleteRecordAction

The `preDeleteRecordAction` customization allows you to run logic _before_ the core Data Manager delete record(s) logic is run. It is not expected to return a value and is supplied the following in the `args` struct:

* `object`: name of the object
* `records`: query containing the records that will be deleted

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	property name="blogService" inject="blogService";

	private void function preDeleteRecordAction( event, rc, prc, args={} ) {
		var records = args.records ?: QueyNew('');

		for( var record in records ) {
			blogService.moveRecordToRecycleBinTable( record.id );
		}
	}
}

```

See also: [[datamanager-customization-postdeleterecordaction|postDeleteRecordAction]] and [[datamanager-customization-deleterecordaction|deleteRecordAction]].




