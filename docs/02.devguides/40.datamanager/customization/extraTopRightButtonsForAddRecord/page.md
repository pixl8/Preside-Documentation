---
id: datamanager-customization-extratoprightbuttonsforaddrecord
title: "Data Manager customization: extraTopRightButtonsForAddRecord"
---

## Data Manager customization: extraTopRightButtonsForAddRecord

The `extraTopRightButtonsForAddRecord` customization allows you to add to, or modify, the set of buttons that appears at the top right hand side of the add record screen. It is provided an `actions` array along with the `objectName` in the `args` struct and is not expected to return a value.

Modifying `args.actions` is required to make changes to the top right buttons.


>>> See [[datamanager-customization-toprightbuttonsformat]] for detailed documentation on the format of the action items.


For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private void function extraTopRightButtonsForAddRecord( event, rc, prc, args={} ) {
		var objectName = args.objectName ?: "";

		args.actions = args.actions ?: [];

		args.actions.append({
			  link      = event.buildAdminLink( objectName=objectName, operation="reports" )
			, btnClass  = "btn-default"
			, iconClass = "fa-bar-chart"
			, globalKey = "r"
			, title     = translateResource( "preside-objects.blog:reports.btn" )
		} );
	}

}
```





