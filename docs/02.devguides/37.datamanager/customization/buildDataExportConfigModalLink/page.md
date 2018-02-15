---
id: datamanager-customization-builddataexportconfigmodallink
title: "Data Manager customization: buildDataExportConfigModalLink"
---

## Data Manager customization: buildDataExportConfigModalLink

The `buildDataExportConfigModalLink` customization allows you to customize the ajax URL used to fetch the data export config form for an object. It is expected to return the URL as a string and is provided the `objectName` in the `args` struct along with any other arguments passed to `event.buildAdminLink()`. e.g.

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function buildDataExportConfigModalLink( event, rc, prc, args={} ) {
		var queryString = args.queryString ?: "";

		return event.buildAdminLink( linkto="admin.blogmanager.exportConfigModal", queryString=queryString );
	}

}
```

