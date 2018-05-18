---
id: datamanager-customization-buildeditrecordactionlink
title: "Data Manager customization: buildEditRecordActionLink"
---

## Data Manager customization: buildEditRecordActionLink

The `buildEditRecordActionLink` customization allows you to customize the URL used to submit the edit record form. It is expected to return the action URL as a string and is provided the `objectName` in the `args` struct along with any other arguments passed to `event.buildAdminLink()` (the record ID is expected to be posted with the form). e.g.

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function buildEditRecordActionLink( event, rc, prc, args={} ) {
		var queryString = args.queryString ?: "";

		return event.buildAdminLink( linkto="admin.blogmanager.editRecordAction", queryString=queryString );
	}

}
```
