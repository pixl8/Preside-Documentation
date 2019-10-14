---
id: datamanager-customization-buildmanagepermslink
title: "Data Manager customization: buildManagePermsLink"
---

## Data Manager customization: buildManagePermsLink

The `buildManagePermsLink` customization allows you to customize the link for the manage permissions screen for an object. It is expected to return the URL as a string and is provided the `objectName` in the `args` struct along with any other arguments passed to `event.buildAdminLink()`. e.g.

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function buildManagePermsLink( event, rc, prc, args={} ) {
		var queryString = args.queryString ?: "";

		return event.buildAdminLink( linkto="admin.blogmanager.manageperms", queryString=queryString );
	}

}
```

