---
id: datamanager-customization-buildsortrecordslink
title: "Data Manager customization: buildSortRecordsLink"
---

## Data Manager customization: buildSortRecordsLink

The `buildSortRecordsLink` customization allows you to customize the link for the diplaying the sort records screen for an object. It is expected to return the URL as a string and is provided the `objectName` in the `args` struct along with any other arguments passed to `event.buildAdminLink()`. e.g.

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function buildSortRecordsLink( event, rc, prc, args={} ) {
		var queryString = args.queryString ?: "";

		return event.buildAdminLink( linkto="admin.blogmanager.sortblogs", queryString=queryString );
	}

}
```

