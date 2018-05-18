---
id: datamanager-customization-gettoprightbuttonsforaddrecord
title: "Data Manager customization: getTopRightButtonsForAddRecord"
---

## Data Manager customization: getTopRightButtonsForAddRecord

The `getTopRightButtonsForAddRecord` customization allows you to _completely override_ the set of buttons that appears at the top right hand side of the add record screen. It must _return an array_ of structs that describe the buttons to display and is provided the `objectName` in the `args` struct.

Note, if you simply want to add, or tweak, the top right buttons, you may wish to use [[datamanager-customization-extratoprightbuttonsforaddrecord]].

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private array function getTopRightButtonsForAddRecord( event, rc, prc, args={} ) {
		var actions    = [];
		var objectName = args.objectName ?: "";

		actions.append({
			  link      = event.buildAdminLink( objectName=objectName, operation="reports" )
			, btnClass  = "btn-default"
			, iconClass = "fa-bar-chart"
			, globalKey = "r"
			, title     = translateResource( "preside-objects.blog:reports.btn" )
		} );

		return actions;
	}

}
```

>>> See [[datamanager-customization-toprightbuttonsformat]] for detailed documentation on the format of the action items.

