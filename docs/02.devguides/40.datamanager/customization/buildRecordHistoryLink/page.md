---
id: datamanager-customization-buildrecordhistorylink
title: "Data Manager customization: buildRecordHistoryLink"
---

## Data Manager customization: buildRecordHistoryLink

The `buildRecordHistoryLink` customization allows you to customize the URL for viewing an object record's version history. It is expected to return the URL as a string and is provided the `objectName` and `recordId` in the `args` struct along with any other arguments passed to `event.buildAdminLink()`. e.g.

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function buildRecordHistoryLink( event, rc, prc, args={} ) {
		var recordId    = args.recordId ?: "";
		var qs          = "id=" & recordId;

		if ( Len( Trim( args.queryString ?: "" ) ) {
			qs &= "&" & args.queryString;
		}

		return event.buildAdminLink( linkto="admin.blogmanager.viewrecordhistory", queryString=qs );
	}

}
```


