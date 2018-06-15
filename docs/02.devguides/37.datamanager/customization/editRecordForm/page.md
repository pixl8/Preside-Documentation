---
id: datamanager-customization-editrecordform
title: "Data Manager customization: editRecordForm"
---

## Data Manager customization: editRecordForm

The `editRecordForm` customization allows you to completely overwrite the view for rendering the edit record form page. The crumb trail, permissions checks and page title will be taken care of, but the rest is up to you.

The handler should return a string (the rendered edit record form page) is provided the following in the `args` struct.

* `objectName`: The name of the object
* `recordId`: The ID of the record being edited
* `record`: Struct of the record being edited
* `editRecordAction`: URL for submitting the form
* `useVersioning`: Whether or not to use versioning
* `version`: Version number (for versioning only) of the record in `args.record`
* `draftsEnabled`: Whether or not drafts are enabled
* `canSaveDraft`: Whether or not the current user can save drafts (for drafts only)
* `canPublish`: Whether or not the current user can publish (for drafts only)
* `cancelAction`: URL that any rendered 'cancel' link should use

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc
component {

	private string function editRecordForm( event, rc, prc, args={} ) {
		return renderView( view="/admin/my/custom/editrecordForm", args=args );
	}

}
```


