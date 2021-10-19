---
id: datamanager-customization-prebatchdeleterecordsaction
title: "Data Manager customization: preBatchDeleteRecordsAction"
---

## Data Manager customization: preBatchDeleteRecordsAction

As of **Preside 10.16.0**, the `preBatchDeleteRecordsAction` customization allows you to run logic _before_ the core Data Manager logic batch deletes a number of records. It is not expected to return a value and is supplied the following in the `args` struct:

* `object`: name of the object
* `records`: query containing the records that will be deleted
* `logger`: logger object - used to output logs to an end user following the batch delete process
* `progress`: progress object - used to update progress bar for the end user following the batch delete process

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	property name="blogService" inject="blogService";

	private void function preBatchDeleteRecordsAction( event, rc, prc, args={} ) {
		var records = args.records ?: QueryNew('');
		var canLog = StructKeyExists( args, "logger" );
		var canWarn = canLog && args.logger.canWarn();

		for( var i=records.recordCount; i>0; i-- ) {
			if ( blogService.cannotHardDelete( records.id[ i ] ) ) {
				blogService.moveRecordToRecycleBinTable( records.id[ i ] );
				QueryRowDelete( records, i );
				if ( canWarn ) {
					args.logger.warn( "Soft deleting blog [#records.label[i]#] because it contains posts that are of the greatest historical and cultural significance..." );
				}
			}
		}
	}
}

```

See also: [[datamanager-customization-postbatchdeleterecordsaction|postBatchDeleteRecordsAction]]



