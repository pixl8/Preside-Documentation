---
id: datamanager-customization-getrecordlinkforgridlisting
title: "Data Manager customization: getRecordLinkForGridListing"
---

## Data Manager customization: getRecordLinkForGridListing

The `getRecordLinkForGridListing` allows you to override the default record link that is given to each record node in a **tree view**. The customization is expected to return a string (the link), and receives the following arguments in the `args` struct:

* `objectName`: the name of the object
* `record`: a struct representing the current record whose link you are to return

For example:

```luceescript
// /application/handlers/admin/datamanager/blog_post.cfc

component {

	private string function getRecordLinkForGridListing( event, rc, prc, args={} ) {
		var objectName = args.objectName  ?: "";
		var record     = args.record      ?: {};
		var postType   = args.record.type ?: "";
		var recordId   = record.id        ?: "";

		if ( postType == "fancy" ) {
			return event.buildAdminLink( objectName=objectName, recordId=recordId, operation="viewFancyPost" );
		}

		return event.buildAdminLink( objectName=objectName, recordId=recordId );
	}

}
```