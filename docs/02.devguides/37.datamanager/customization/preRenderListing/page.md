---
id: datamanager-customization-prerenderlisting
title: "Data Manager customization: preRenderListing"
---

## Data Manager customization: preRenderListing

The `preRenderListing` customization allows you to add your own output _above_ the default object listing screen.

The customization handler should return a string of the rendered viewlet and is supplied an args structure with an `objectName` key.

For example:

```luceescript
// /application/handlers/admin/datamanager/sensitive_data.cfc
component {

	private string function preRenderListing( event, rc, prc, args={} ) {
		return '<p class="alert alert-danger">Warning: use this listing with extreme caution.</p>';
	}

}
```

