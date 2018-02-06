---
id: datamanager-customization-postrenderaddrecordform
title: "Data Manager customization: postRenderAddRecordForm"
---

## Data Manager customization: postRenderAddRecordForm

The `postRenderAddRecordForm` customization allows you to add rendered HTML _after_ the rendering of the core add record form. The HTML will live _inside_ the html `<form>` tags, so that you are able to add form fields into the form.

The handler is provided with `args.objectName` and is expected to return a string that is the rendered HTML. For example:


```luceescript
// /application/handlers/admin/datamanager/faq.cfc

component {

	private string function postRenderAddRecordForm( event, rc, prc, args={} ) {
		return '<p class="alert alert-warning">Before hitting submit, below - triple-chek your speling and grama!</p>';
	}

}
```

See also: [[datamanager-customization-prerenderaddrecordform|preRenderAddRecordForm]]
