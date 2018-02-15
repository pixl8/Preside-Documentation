---
id: datamanager-customization-buildaddrecordactionlink
title: "Data Manager customization: buildAddRecordActionLink"
---

## Data Manager customization: buildAddRecordActionLink

The `buildAddRecordActionLink` customization allows you to customize the URL used to submit the add record form. It is expected to return the action URL as a string and is provided the `objectName` in the `args` struct along with any other arguments passed to `event.buildAdminLink()`. e.g.

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function buildAddRecordActionLink( event, rc, prc, args={} ) {
		var queryString = args.queryString ?: "";

		return event.buildAdminLink( linkto="admin.blogmanager.addRecordAction", queryString=queryString );
	}

}
```

