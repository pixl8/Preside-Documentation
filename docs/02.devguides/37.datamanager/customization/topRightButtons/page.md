---
id: datamanager-customization-toprightbuttons
title: "Data Manager customization: topRightButtons"
---

## Data Manager customization: topRightButtons

The `topRightButtons` customization allows you to completely customize the logic that outputs top right buttons for _all_ data manager admin pages for your object. It should return the rendered HTML of the buttons and receives the following in the `args` struct:

* `objectName`: the name of the object
* `action`: the current coldbox action, e.g. `editRecord`, `viewRecord`, `object`, etc.


For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function topRightButtons( event, rc, prc, args={} ) {
		switch( args.action ?: "" ) {
			case "object":
			case "viewrecord":
			case "editrecord":
				return renderViewlet( "blogmanager.topRightButtonsFor#args.action#" );
		}
		
		return "";
	}
}
```