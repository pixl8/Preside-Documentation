---
id: datamanager-customization-getclonerecordactionbuttons
title: "Data Manager customization: getCloneRecordActionButtons"
---

## Data Manager customization: getCloneRecordActionButtons

The `getCloneRecordActionButtons` customization allows you to _completely override_ the set of buttons and links that appears below the clone record form. It must _return an array_ of structs that describe the buttons to display and is provided `objectName` and `recordId` in the `args` struct.

Note, if you simply want to add, or tweak, the buttons, you may wish to use [[datamanager-customization-getextraclonerecordactionbuttons]].

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private array function getCloneRecordActionButtons( event, rc, prc, args={} ) {
		var actions = [{
			  type      = "link"
			, href      = event.buildAdminLink( objectName="blog" )
			, class     = "btn-default"
			, globalKey = "c"
			, iconClass = "fa-reply"
			, label     = translateResource( uri="cms:cancel.btn" )
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
			, value     = "publishAndClone"
			, label     = translateResource( uri="cms:presideobjects.blog:addrecord.and.clone.btn", data=[ prc.objectTitle ?: "" ] )
		} );

		return actions;
	}

}
```

>>> See [[datamanager-customization-actionbuttons]] for detailed documentation on the format of the action items.

