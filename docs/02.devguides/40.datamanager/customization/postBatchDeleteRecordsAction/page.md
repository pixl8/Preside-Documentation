---
id: datamanager-customization-postbatchdeleterecordsaction
title: "Data Manager customization: postBatchDeleteRecordsAction"
---

## Data Manager customization: postBatchDeleteRecordsAction

As of **Preside 10.16.0**, the `postBatchDeleteRecordsAction` customization allows you to run logic _after_ the core Data Manager logic batch deletes a number of records. It is not expected to return a value and is supplied the following in the `args` struct:

* `object`: name of the object
* `records`: query containing the records that will be deleted
* `logger`: logger object - used to output logs to an end user following the batch delete process
* `progress`: progress object - used to update progress bar for the end user following the batch delete process

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	property name="blogService" inject="blogService";

	private void function postBatchDeleteRecordsAction( event, rc, prc, args={} ) {
		var canLog = StructKeyExists( args, "logger" );
		var canInfo = canLog && args.logger.canInfo();

		for( var record in records ) {
			blogService.notifyServicesOfDeletedBlog( record.id );
			if ( canInfo ) {
				args.logger.info( "Did something with [#record.label#]" );
			}
		}
	}
}

```

See also: [[datamanager-customization-prebatchdeleterecordsaction|preBatchDeleteRecordsAction]]



