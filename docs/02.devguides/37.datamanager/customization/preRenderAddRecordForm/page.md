---
id: datamanager-customization-prerenderaddrecordform
title: "Data Manager customization: preRenderAddRecordForm"
---

## Data Manager customization: preRenderAddRecordForm

The `preRenderAddRecordForm` customization allows you to add rendered HTML _before_ the rendering of the core add record form. The HTML will live _inside_ the html `<form>` tags, so that you are able to add form fields into the form.

The handler is provided with `args.objectName` and is expected to return a string that is the rendered HTML. For example:


```luceescript
// /application/handlers/admin/datamanager/faq.cfc

component {

	private string function preRenderAddRecordForm( event, rc, prc, args={} ) {
		return '<p class="alert alert-warning">Remember: double check existing records before adding a new FAQ.</p>';
	}

}
```

See also: [[datamanager-customization-postrenderaddrecordform|postRenderAddRecordForm]]