---
id: datamanager-customization-getaddrecordactionbuttons
title: "Data Manager customization: getAddRecordActionButtons"
---

## Data Manager customization: getAddRecordActionButtons

The `getAddRecordActionButtons` customization allows you to _completely override_ the set of buttons and links that appears below the add record form. It must _return an array_ of structs that describe the buttons to display and is provided the `objectName` in the `args` struct.

Note, if you simply want to add, or tweak, the buttons, you may wish to use [[datamanager-customization-getextraaddrecordactionbuttons]].

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private array function getAddRecordActionButtons( event, rc, prc, args={} ) {
		var actions = [{
			  type      = "link"
			, href      = event.buildAdminLink( objectName="blog" )
			, class     = "btn-default"
			, globalKey = "c"
			, iconClass = "fa-reply"
			, label     = args.cancelLabel
		}];

		actions.append({
			  type      = "button"
			, class     = "btn-info"
			, iconClass = "fa-save"
			, name      = "_saveAction"
			, value     = "publish"
			, label     = translateResource( uri="cms:datamanager.addrecord.btn", data=[ prc.objectTitle ?: "" ] )
		} );

		actions.append({
			  type      = "button"
			, class     = "btn-plus"
			, iconClass = "fa-save"
			, name      = "_saveAction"
			, value     = "publishAndEdit"
			, label     = translateResource( uri="cms:presideobjects.blog:addrecord.and.edit.btn", data=[ prc.objectTitle ?: "" ] )
		} );

		return actions;
	}

}
```

>>> See [[datamanager-customization-actionbuttons]] for detailed documentation on the format of the action items.

