---
id: datamanager-customization-buildmultirecordactionlink
title: "Data Manager customization: buildMultiRecordActionLink"
---

## Data Manager customization: buildMultiRecordActionLink

The `buildMultiRecordActionLink` customization allows you to customize the URL used to submit the multi-record modification action (i.e. multi edit or delete). It is expected to return the URL as a string and is provided the `objectName` in the `args` struct along with any other arguments passed to `event.buildAdminLink()`. e.g.

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function buildMultiRecordActionLink( event, rc, prc, args={} ) {
		var queryString = args.queryString ?: "";

		return event.buildAdminLink( linkto="admin.blogmanager.multiAction", queryString=queryString );
	}

}
```

