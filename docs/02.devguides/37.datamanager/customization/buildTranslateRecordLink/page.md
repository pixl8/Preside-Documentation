---
id: datamanager-customization-buildtranslaterecordlink
title: "Data Manager customization: buildTranslateRecordLink"
---

## Data Manager customization: buildTranslateRecordLink

The `buildTranslateRecordLink` customization allows you to customize the URL for displaying an object's translate record form. It is expected to return the URL as a string and is provided the following in the `args` struct:

* `objectName`: Name of the object
* `recordId`: ID of the record to be translated
* `language`: ID of the language
* `version`: If versioning enabled, specific version number to load
* `fromDataGrid`: Whether or not this link was built for data grid (can be used to direct back to grid, rather than edit/view record)

e.g.

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function buildTranslateRecordLink( event, rc, prc, args={} ) {
		var recordId    = args.recordId ?: "";
		var language    = args.language ?: "";
		var version     = Val( args.version ?: "" );
		var qs          = "id=#recordId#&language=#language#";

		if ( version ) {
			qs &= "&version=" & version;
		}

		if ( Len( Trim( args.queryString ?: "" ) ) {
			qs &= "&" & args.queryString;
		}

		return event.buildAdminLink( linkto="admin.blogmanager.translate", queryString=qs );
	}

}
```



