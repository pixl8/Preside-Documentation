---
id: datamanager-customization-preeditrecordaction
title: "Data Manager customization: preEditRecordAction"
---

## Data Manager customization: preEditRecordAction

The `preEditRecordAction` customization allows you to run logic _before_ the core Data Manager edit record logic is run. It is not expected to return a value and is supplied the following in the `args` struct:

* `objectName`: name of the object
* `formData`: struct containing the form submission
* `existingRecord`: struct containing the data from the current record
* `validationResult`: validation result from general form validation

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	property name="blogService" inject="blogService";

	private void function preEditRecordAction( event, rc, prc, args={} ) {
		rc.clearance_level = blogService.calculateClearanceLevel( argumentCollection=args.formData ?: {} );
	}
}

```

See also: [[datamanager-customization-posteditrecordaction|postEditRecordAction]] and [[datamanager-customization-editrecordaction|editRecordAction]].


