---
id: datamanager-customization-listingviewlet
title: "Data Manager customization: listingViewlet"
---

## Data manager customization: listingViewlet

The `listingViewlet` customization allows you to completely override the _entire_ viewlet for rendering a listing view for an object (i.e. the view that normally shows the data table listing records).

The customization handler should return a string of the rendered viewlet and is supplied an args structure with an `objectName` key.

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc
component {

	private string function listingViewlet( event, rc, prc, args={} ) {
		return renderView( view="/admin/datamanager/blog/listing", args=args );
	}

}
```



