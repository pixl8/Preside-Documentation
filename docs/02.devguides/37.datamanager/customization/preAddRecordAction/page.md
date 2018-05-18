---
id: datamanager-customization-preaddrecordaction
title: "Data Manager customization: preAddRecordAction"
---

## Data Manager customization: preAddRecordAction

The `preAddRecordAction` customization allows you to run logic _before_ the core Data Manager add record logic is run. It is not expected to return a value and is supplied the following in the `args` struct:

* `objectName`: name of the object
* `formData`: struct containing the form submission

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	property name="blogService" inject="blogService";

	private void function preAddRecordAction( event, rc, prc, args={} ) {
		var formName = "preside-objects.blog.admin.add";
		var formData = event.getDataForForm( formName );

		rc.clearance_level = blogService.calculateClearanceLevel( argumentCollection=formData );
	}
}

```

See also: [[datamanager-customization-postaddrecordaction|postAddRecordAction]] and [[datamanager-customization-addrecordaction|addRecordAction]].
