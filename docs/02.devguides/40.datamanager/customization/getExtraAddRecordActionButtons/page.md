---
id: datamanager-customization-getextraaddrecordactionbuttons
title: "Data Manager customization: getExtraAddRecordActionButtons"
---

## Data Manager customization: getExtraAddRecordActionButtons

The `getExtraAddRecordActionButtons` customization allows you to modify the set of buttons and links that appears below the add record form. It is expected _not_ to return a value and receives the following in the `args` struct:

* `objectName`: The name of the object
* `actions`: the array of button "actions"

Note, if you want to completely override the buttons, you may wish to use [[datamanager-customization-getaddrecordactionbuttons]].

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private array function getExtraAddRecordActionButtons( event, rc, prc, args={} ) {
		var actions = args.actions ?: [];

		actions.append({
			  type      = "button"
			, class     = "btn-plus"
			, iconClass = "fa-save"
			, name      = "_saveAction"
			, value     = "publishAndEdit"
			, label     = translateResource( uri="cms:presideobjects.blog:addrecord.and.edit.btn", data=[ prc.objectTitle ?: "" ] )
		} );
	}

}
```

>>> See [[datamanager-customization-actionbuttons]] for detailed documentation on the format of the action items.

