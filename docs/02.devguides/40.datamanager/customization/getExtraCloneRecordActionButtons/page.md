---
id: datamanager-customization-getextraclonerecordactionbuttons
title: "Data Manager customization: getExtraCloneRecordActionButtons"
---

## Data Manager customization: getExtraCloneRecordActionButtons

The `getExtraCloneRecordActionButtons` customization allows you to modify the set of buttons and links that appears below the clone record form. It is expected _not_ to return a value and receives the following in the `args` struct:

* `objectName`: The name of the object
* `recordId`: The id of the current record
* `actions`: the array of button "actions"

Note, if you want to completely override the buttons, you may wish to use [[datamanager-customization-getclonerecordactionbuttons]].

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private array function getExtraCloneRecordActionButtons( event, rc, prc, args={} ) {
		var actions = args.actions ?: [];

		actions.append({
			  type      = "button"
			, class     = "btn-plus"
			, iconClass = "fa-save"
			, name      = "_saveAction"
			, value     = "publishAndClone"
			, label     = translateResource( uri="cms:presideobjects.blog:clonerecord.and.clone.btn", data=[ prc.objectTitle ?: "" ] )
		} );
	}

}
```

>>> See [[datamanager-customization-actionbuttons]] for detailed documentation on the format of the action items.

