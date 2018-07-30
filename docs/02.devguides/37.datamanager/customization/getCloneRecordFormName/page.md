---
id: datamanager-customization-getclonerecordformname
title: "Data Manager customization: getCloneRecordFormName"
---

## Data Manager customization: getCloneRecordFormName

The `getCloneRecordFormName` customization allows you to use a different form name than the Data Manager default for cloneing records. The method should return the form name (see [[presideforms]]) and is provided `args.objectName` should you need to use it. For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function getCloneRecordFormName( event, rc, prc, args={} ) {
		return "admin.blogs.cloneblog";
	}

}
```

