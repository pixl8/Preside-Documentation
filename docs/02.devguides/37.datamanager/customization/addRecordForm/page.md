---
id: datamanager-customization-addrecordform
title: "Data Manager customization: addRecordForm"
---

## Data Manager customization: addRecordForm

The `addRecordForm` customization allows you to completely overwrite the view for rendering the add record form page. The crumb trail, permissions checks and page title will be taken care of, but the rest is up to you.

The handler should return a string (the rendered add record form page) and expects `objectName` in the passed `args` struct. For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc
component {

	private string function addRecordForm( event, rc, prc, args={} ) {
		return renderView( view="/admin/my/custom/addrecordForm", args=args );
	}

}
```

