---
id: datamanager-customization-buildaddrecordlink
title: "Data Manager customization: buildAddRecordLink"
---

## Data Manager customization: buildAddRecordLink

The `buildAddRecordLink` customization allows you to customize the URL used to show the add record form. It is expected to return the URL as a string and is provided the `objectName` in the `args` struct along with any other arguments passed to `event.buildAdminLink()`. e.g.

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function buildAddRecordLink( event, rc, prc, args={} ) {
		var queryString = args.queryString ?: "";

		return event.buildAdminLink( linkto="admin.blogmanager.addRecordScreen", queryString=queryString );
	}

}
```

