---
id: datamanager-customization-listingviewlet
title: "Data Manager customization: listingViewlet"
---

## Data manager customization: listingViewlet

The `listingViewlet` customization allows you to completely override the _entire_ viewlet for rendering a listing view for an object (i.e. the view that normally shows the data table listing records).

The customization handler should return a string of the rendered viewlet and is supplied an `args` structure. At minimum this includes `objectName`. When you call the core listing (or `objectDataTable()`), the same `args` also carry listing toolbar flags such as `allowColumnPicker`, `allowColumnFilter`, `allowSavedViews`, `compact`, `listingContextKey` / `listingContextLabel` and `listingPreferenceKey` — see [[datamanagerlistings]] and [[customizingdatamanager]].

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc
component {

	private string function listingViewlet( event, rc, prc, args={} ) {
		return renderView( view="/admin/datamanager/blog/listing", args=args );
	}

}
```



