---
id: datamanager-customization-preQuickAddrecordaction
title: "Data Manager customization: preQuickAddRecordAction"
---

## Data Manager customization: preQuickAddRecordAction

The `preQuickAddRecordAction` customization allows you to run logic _before_ the core Data Manager Add record logic is run. It is not expected to return a value and is supplied the following in the `args` struct:

* `objectName`: name of the object
* `formData`: struct containing the form submission

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	property name="blogService" inject="blogService";

	private void function preQuickAddRecordAction( event, rc, prc, args={} ) {
		rc.clearance_level = blogService.calculateClearanceLevel( argumentCollection=args.formData ?: {} );
	}
}

```

See also: [[datamanager-customization-postquickaddrecordaction|postQuickAddRecordAction]] and [[datamanager-customization-quickaddrecordaction|quickAddRecordAction]].


