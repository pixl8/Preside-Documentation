---
id: datamanager-customization-buildlistinglink
title: "Data Manager customization: buildListingLink"
---

## Data Manager customization: buildListingLink

The `buildListingLink` customization allows you to customize the link for the listing screen for an object. It is expected to return the listing URL as a string and is provided the `objectName` in the `args` struct along with any other arguments passed to `event.buildAdminLink()`. e.g.

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function buildListingLink( event, rc, prc, args={} ) {
		var queryString = args.queryString ?: "";

		return event.buildAdminLink( linkto="admin.blogmanager", queryString=queryString );
	}

}
```