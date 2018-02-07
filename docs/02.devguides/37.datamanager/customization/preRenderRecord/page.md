---
id: datamanager-customization-prerenderrecord
title: "Data Manager customization: preRenderRecord"
---

## Data Manager customization: preRenderRecord

The `preRenderRecord` customization allows you to add additional HTML above the core rendering of a view record screen for an object. The action is expected to return a string containing the HTML and is provided the following in the `args` struct:

* `objectName`: The object name
* `recordId`: ID of the record
* `version`: Version number of the record (if the object is versioned)

>>>>>> You can also make use of variables in the `prc` scope, such as `prc.record`, that will allow you to potentially not duplicate calls to the database.

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function preRenderRecord() {
		args.blog = prc.record ?: "";

		return renderView( view="/admin/blogs/viewRecordHeader", args=args );
	}

}
```

See also: [[datamanager-customization-postrenderrecord|postRenderRecord]].


