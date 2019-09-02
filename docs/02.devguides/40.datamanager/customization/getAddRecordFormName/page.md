---
id: datamanager-customization-getaddrecordformname
title: "Data Manager customization: getAddRecordFormName"
---

## Data Manager customization: getAddRecordFormName

The `getAddRecordFormName` customization allows you to use a different form name than the Data Manager default for adding records. The method should return the form name (see [[presideforms]]) and is provided `args.objectName` should you need to use it. For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function getAddRecordFormName( event, rc, prc, args={} ) {
		return "admin.blogs.addblog";
	}

}
```

