---
id: datamanager-customization-getquickeditrecordformname
title: "Data Manager customization: getQuickEditRecordFormName"
---

## Data Manager customization: getQuickEditRecordFormName

>>> This customization was added in Preside 10.13.0

The `getQuickEditRecordFormName` customization allows you to use a different form name than the Data Manager default for "quick editing" records. The method should return the form name (see [[presideforms]]) and is provided `args.objectName` should you need to use it. For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function getQuickEditRecordFormName( event, rc, prc, args={} ) {
		return "admin.blogs.editblog";
	}

}
```

