---
id: datamanager-customization-extratoprightbuttons
title: "Data Manager customization: extraTopRightButtons"
---

## Data Manager customization: extraTopRightButtons

The `extraTopRightButtons` customization allows you to run additional button logic for _all_ data manager pages. For example, you may wish to always add a 'reports' button. It is expected _not_ to return a value and receives the following in the `args` struct:

* `objectName`: The name of the object
* `action`: the current coldbox action, e.g. `editRecord`, `viewRecord`, `
* `actions`: the array of button "actions"

Modifying `args.actions` is required to make changes to the top right buttons.

>>> See [[datamanager-customization-toprightbuttonsformat]] for detailed documentation on the format of the action items.

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private void function extraTopRightButtons( event, rc, prc, args={} ) {
		var action = args.action ?: "";
		var actionsWithButtons = [ "editRecord", "viewRecord" ];

		if ( actionsWithButtons.findNoCase( action ) ) {
			args.actions = args.actions ?: [];
			args.actions.append({
				  link      = event.buildAdminLink( objectName="blog", operation="reports" )
				, btnClass  = "btn-default"
				, iconClass = "fa-bar-chart"
				, globalKey = "r"
				, title     = translateResource( "preside-objects.blog:reports.btn" )
			} );
		}
	}

}
```

