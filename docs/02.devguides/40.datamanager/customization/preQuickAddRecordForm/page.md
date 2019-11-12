---
id: datamanager-customization-preQuickAddRecordForm
title: "Data Manager customization: preQuickAddRecordForm"
---

## Data Manager customization: preQuickAddRecordForm

The `preQuickAddRecordForm` customization allows you to add javascript _before_ the rendering of the core edit record form.

For example:


```luceescript
// /application/handlers/admin/datamanager/faq.cfc

component {

	private void function preQuickAddRecordForm( event, rc, prc, args={} ) {
		event.include( assetId="/js/admin/specific/appointment/" );
	}

}
```

See also: [[datamanager-customization-quickaddrecordaction|quickAddRecordAction]]

