---
id: datamanager-customization-buildeditrecordlink
title: "Data Manager customization: buildEditRecordLink"
---

## Data Manager customization: buildEditRecordLink

The `buildEditRecordLink` customization allows you to customize the URL for viewing an object's edit form. It is expected to return the URL as a string and is provided the `objectName` and `recordId` in the `args` struct along with any other arguments passed to `event.buildAdminLink()`. In addition, it may also be given `resultAction` and `version` keys in the `args` struct.

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function buildEditRecordLink( event, rc, prc, args={} ) {
		var recordId    = args.recordId ?: "";
		var version     = Val( args.version  ?: "" );
		var qs          = "id=" & recordId;

		if ( version ) {
			qs &= "&version=" & version;
		}
		
		if ( Len( Trim( args.queryString ?: "" ) ) {
			qs &= "&" & args.queryString;
		}

		return event.buildAdminLink( linkto="admin.blogmanager.editrecord", queryString=qs );
	}

}
```

