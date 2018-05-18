---
id: datamanager-customization-renderrecord
title: "Data Manager customization: renderRecord"
---

## Data Manager customization: renderRecord

The `renderRecord` customization allows you to completely override the rendering of a single record for your object. Permissions checking, crumbtrails and page titles will all be taken care of; but the rest is up to you.

The action is expected to return the rendered HTML of the record as a string and is provided the following in the args struct:

* `objectName`: The object name
* `recordId`: ID of the record
* `version`: Version number of the record (if the object is versioned)

>>>>>> You can also make use of variables in the `prc` scope, such as `prc.record`, that will allow you to potentially not duplicate calls to the database.

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function renderRecord() {
		args.blog = prc.record ?: QueryNew(''); // Data Manager will have already fetched the record for you. Check out the prc scope for other commonly fetched goodies that you can make use of

		return renderView( view="/admin/blogs/customRecordView", args=args );
	}

}
```

