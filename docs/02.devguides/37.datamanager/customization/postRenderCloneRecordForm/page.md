---
id: datamanager-customization-postrenderclonerecordform
title: "Data Manager customization: postRenderdCloneRecordForm"
---

## Data Manager customization: postRenderdCloneRecordForm

The `postRenderdCloneRecordForm` customization allows you to add rendered HTML _after_ the rendering of the core clone record form. The HTML will live _inside_ the html `<form>` tags, so that you are able to add form fields into the form.

The handler is expected to return a string that is the rendered HTML and is provided the following in the `args` struct:

* `objectName`: The name of the object
* `recordId`: The ID of the record being cloned
* `record`: Struct of the record being cloned
* `cloneRecordAction`: URL for submitting the form
* `useVersioning`: Whether or not to use versioning
* `version`: Version number (for versioning only) of the record in `args.record`
* `draftsEnabled`: Whether or not drafts are enabled
* `canSaveDraft`: Whether or not the current user can save drafts (for drafts only)
* `canPublish`: Whether or not the current user can publish (for drafts only)
* `cancelAction`: URL that any rendered 'cancel' link should use

For example:

```luceescript
// /application/handlers/admin/datamanager/faq.cfc

component {

	private string function postRenderdCloneRecordForm( event, rc, prc, args={} ) {
		return '<p class="alert alert-warning">Before hitting submit, below - triple-chek your speling and grama!</p>';
	}

}
```

See also: [[datamanager-customization-prerenderaddrecordform|preRenderAddRecordForm]]

