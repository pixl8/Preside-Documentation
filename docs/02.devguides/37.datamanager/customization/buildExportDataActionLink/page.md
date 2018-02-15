---
id: datamanager-customization-buildexportdataactionlink
title: "Data Manager customization: buildExportDataActionLink"
---

## Data Manager customization: buildExportDataActionLink

The `buildExportDataActionLink` customization allows you to customize the URL used to submit data export forms. It is expected to return the URL as a string and is provided the `objectName` in the `args` struct along with any other arguments passed to `event.buildAdminLink()`. e.g.

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function buildExportDataActionLink( event, rc, prc, args={} ) {
		var queryString = args.queryString ?: "";

		return event.buildAdminLink( linkto="admin.blogmanager.dataExportAction", queryString=queryString );
	}

}
```

