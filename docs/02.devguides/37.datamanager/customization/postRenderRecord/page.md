---
id: datamanager-customization-postrenderrecord
title: "Data Manager customization: postRenderRecord"
---

## Data Manager customization: postRenderRecord

The `postRenderRecord` customization allows you to add additional HTML _below_ the core rendering of a view record screen for an object. The action is expected to return a string containing the HTML and is provided the following in the `args` struct:

* `objectName`: The object name
* `recordId`: ID of the record
* `version`: Version number of the record (if the object is versioned)

>>>>>> You can also make use of variables in the `prc` scope, such as `prc.record`, that will allow you to potentially not duplicate calls to the database.

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function postRenderRecord() {
		args.blog = prc.record ?: QueryNew('');

		return renderView( view="/admin/blogs/viewRecordFooter", args=args );
	}

}
```

See also: [[datamanager-customization-prerenderrecord|preRenderRecord]].

