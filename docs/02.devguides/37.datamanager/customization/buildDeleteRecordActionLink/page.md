---
id: datamanager-customization-builddeleterecordactionlink
title: "Data Manager customization: buildDeleteRecordActionLink"
---

## Data Manager customization: buildDeleteRecordActionLink

The `buildDeleteRecordActionLink` customization allows you to customize the URL for deleting an object's record. It is expected to return the URL as a string and is provided the `objectName` and `recordId` in the `args` struct along with any other arguments passed to `event.buildAdminLink()`. e.g.

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function buildDeleteRecordActionLink( event, rc, prc, args={} ) {
		var recordId    = args.recordId ?: "";
		var version     = Val( args.version  ?: "" );
		var qs          = "id=" & recordId;
		
		if ( Len( Trim( args.queryString ?: "" ) ) {
			qs &= "&" & args.queryString;
		}

		return event.buildAdminLink( linkto="admin.blogmanager.deleteRecordAction", queryString=qs );
	}

}
```



