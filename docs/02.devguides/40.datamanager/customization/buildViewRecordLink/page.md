---
id: datamanager-customization-buildviewrecordlink
title: "Data Manager customization: buildViewRecordLink"
---

## Data Manager customization: buildViewRecordLink

The `buildViewRecordLink` customization allows you to customize the URL for viewing an object's record. It is expected to return the URL as a string and is provided the `objectName` and `recordId` in the `args` struct along with any other arguments passed to `event.buildAdminLink()`. In addition, it may also be given `version` and `language` keys in the `args` struct should versioning and/or multilingual be enabled. e.g.

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function buildViewRecordLink( event, rc, prc, args={} ) {
		var recordId    = args.recordId ?: "";
		var version     = Val( args.version ?: "" );
		var qs          = "id=" & recordId;

		if ( version ) {
			qs &= "&version=" & version;
		}

		if ( Len( Trim( args.queryString ?: "" ) ) {
			qs &= "&" & args.queryString;
		}

		return event.buildAdminLink( linkto="admin.blogmanager.viewrecord", queryString=qs );
	}

}
```

