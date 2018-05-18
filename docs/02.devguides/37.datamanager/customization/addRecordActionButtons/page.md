---
id: datamanager-customization-addrecordactionbuttons
title: "Data Manager customization: addRecordActionButtons"
---

## Data Manager customization: addRecordActionButtons

The `addRecordActionButtons` customization allows you to completely override the form action buttons (e.g. "Cancel", "Add record") for the add record form. The handler should return the rendered HTML for the buttons and will be supplied `args.objectName` in the `args` struct.


For example:


```luceescript
// /application/handlers/admin/datamanager/GlobalDefaults.cfc
component {

	private string function addRecordActionButtons( event, rc, prc, args={} ) {
		var objectName = args.objectName ?: "";
		
		args.cancelAction = event.buildAdminLink( objectName=objectName );

		return renderView( view="/admin/datamanager/globaldefaults/addRecordActionButtons", args=args );
	}

}
```

```lucee
<!--- /application/views/admin/datamanager/globaldefaults/addRecordActionButtons.cfm --->

<cfoutput>
	<div class="col-md-offset-2">
		<a href="#args.cancelAction#" class="btn btn-default" data-global-key="c">
			<i class="fa fa-reply bigger-110"></i>
			Cancel
		</a>
		
		<button type="submit" class="btn btn-info" tabindex="#getNextTabIndex()#">
				<i class="fa fa-save bigger-110"></i> Add record
		</button>
	</div>
</cfoutput>
```

>>>> The core implementation has logic for showing different buttons for drafts and dynamically building labels for buttons, etc. Be sure to know what you're missing out on when overriding this (or any) customization!
