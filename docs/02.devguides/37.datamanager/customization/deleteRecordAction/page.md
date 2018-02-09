---
id: datamanager-customization-deleterecordaction
title: "Data Manager customization: deleteRecordAction"
---

## Data Manager customization: deleteRecordAction

The `deleteRecordAction` allows you to override the core action logic for deleting a record through the Data Manager. The core will have already checked permissions for deleting records, but all other logic will be up to you to implement (including audit trails, etc.).

The method is not expected to return a value and is provided with `args.objectName` and `args.recordId`. _The expectation is that the method will redirect the user after processing the request._

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	property name="blogService" inject="blogService";
	property name="messageBox" inject="messagebox@cbmessagebox";

	private void function deleteRecordAction( event, rc, prc, args={} ) {
		blogService.archiveBlog( args.recordId ?: "" );

		messageBox.info( translateResource( uri="preside-objects.blog:archived.message", data=[ prc.recordLabel ?: "" ] ) );
		
		setNextEvent( url=event.buildAdminLink( objectName = "blog" ) );
	}

}
```