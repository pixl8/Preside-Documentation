---
id: datamanager-customization-preQuickEditRecordForm
title: "Data Manager customization: preQuickEditRecordForm"
---

## Data Manager customization: preQuickEditRecordForm

The `preQuickEditRecordForm` customization allows you to add javascript _before_ the rendering of the core edit record form.

For example:


```luceescript
// /application/handlers/admin/datamanager/faq.cfc

component {

	private void function preQuickEditRecordForm( event, rc, prc, args={} ) {
		event.include( assetId="/js/admin/specific/appointment/" );
	}

}
```

See also: [[datamanager-customization-quickeditrecordaction|quickEditRecordAction]]

