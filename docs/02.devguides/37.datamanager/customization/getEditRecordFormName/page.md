---
id: datamanager-customization-geteditrecordformname
title: "Data Manager customization: getEditRecordFormName"
---

## Data Manager customization: getEditRecordFormName

The `getEditRecordFormName` customization allows you to use a different form name than the Data Manager default for editing records. The method should return the form name (see [[presideforms]]) and is provided `args.objectName` should you need to use it. For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function getEditRecordFormName( event, rc, prc, args={} ) {
		return "admin.blogs.editblog";
	}

}
```

