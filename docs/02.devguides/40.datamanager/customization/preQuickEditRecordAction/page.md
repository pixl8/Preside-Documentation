---
id: datamanager-customization-preQuickeditrecordaction
title: "Data Manager customization: preQuickEditRecordAction"
---

## Data Manager customization: preQuickEditRecordAction

The `preQuickEditRecordAction` customization allows you to run logic _before_ the core Data Manager edit record logic is run. It is not expected to return a value and is supplied the following in the `args` struct:

* `objectName`: name of the object
* `formData`: struct containing the form submission

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	property name="blogService" inject="blogService";

	private void function preQuickEditRecordAction( event, rc, prc, args={} ) {
		rc.clearance_level = blogService.calculateClearanceLevel( argumentCollection=args.formData ?: {} );
	}
}

```

See also: [[datamanager-customization-postquickeditrecordaction|postQuickEditRecordAction]] and [[datamanager-customization-quickeditrecordaction|quickEditRecordAction]].


