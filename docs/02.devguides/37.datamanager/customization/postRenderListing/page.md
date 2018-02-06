---
id: datamanager-customization-postrenderlisting
title: "Data Manager customization: postRenderListing"
---

## Data Manager customization: postRenderListing

The `postRenderListing` customization allows you to add your own output _below_ the default object listing screen.

The customization handler should return a string of the rendered viewlet and is supplied an args structure with an `objectName` key.

For example:

```luceescript
// /application/handlers/admin/datamanager/sensitive_data.cfc
component {

	private string function postRenderListing( event, rc, prc, args={} ) {
		return '<p class="alert alert-success">Tip: use this listing with extreme caution.</p>';
	}

}
```

