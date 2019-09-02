---
id: datamanager-customization-clonerecordform
title: "Data Manager customization: cloneRecordForm"
---

## Data Manager customization: cloneRecordForm

The `cloneRecordForm` customization allows you to completely overwrite the view for rendering the clone record form page. The crumb trail, permissions checks and page title will be taken care of, but the rest is up to you.

The handler should return a string (the rendered clone record form page) and is provided the following in the `args` struct.

* `objectName`: The name of the object
* `recordId`: The ID of the record being cloneed
* `record`: Struct of the record being cloneed
* `cloneRecordAction`: URL for submitting the form
* `draftsEnabled`: Whether or not drafts are enabled
* `canSaveDraft`: Whether or not the current user can save drafts (for drafts only)
* `canPublish`: Whether or not the current user can publish (for drafts only)
* `cancelAction`: URL that any rendered 'cancel' link should use

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc
component {

	private string function cloneRecordForm( event, rc, prc, args={} ) {
		return renderView( view="/admin/my/custom/clonerecordForm", args=args );
	}

}
```


