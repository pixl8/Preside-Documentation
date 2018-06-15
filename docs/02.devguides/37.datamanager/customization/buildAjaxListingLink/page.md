---
id: datamanager-customization-buildajaxlistinglink
title: "Data Manager customization: buildAjaxListingLink"
---

## Data Manager customization: buildAjaxListingLink

The `buildAjaxListingLink` customization allows you to customize the URL used to fetch records via ajax to be displayed in the listing screen. It is expected to return the URL as a string and is provided the `objectName` in the `args` struct along with any other arguments passed to `event.buildAdminLink()`. e.g.

>>> You may also wish to look at [[datamanager-customization-getadditionalquerystringforbuildajaxlistinglink]] should you simply wish to add some query parameters to the core URL.

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function buildAjaxListingLink( event, rc, prc, args={} ) {
		var queryString = args.queryString ?: "";

		return event.buildAdminLink( linkto="admin.blogmanager.ajaxRecordsForDataTable", queryString=queryString );
	}

}
```

