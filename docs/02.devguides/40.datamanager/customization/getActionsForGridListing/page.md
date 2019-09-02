---
id: datamanager-customization-getactionsforgridlisting
title: "Data Manager customization: getActionsForGridListing"
---

## Data Manager customization: getActionsForGridListing

The `getActionsForGridListing` customization allows you to completely rewrite the logic for adding grid actions to an object's listing table (by grid actions, we mean the list of links to the right of each row in the table).

The method must return _an array_. Each item in the array should be a rendered set of actions for the corresponding row in the recordset passed in `args.records`. For example:

```luceescript
// /application/handlers/admin/datamanager/blog_post.cfc
component {

	private array function getActionsForGridListing( event, rc, prc, args={} ) {
		var records = args.records ?: QueryNew('');
		var actions = [];

		if ( records.recordCount ) {
			// This is a condensed example of a useful general approach.
			// Render *outside* of the loop and use placeholders.
			// Then just replace placeholders when looping the records
			// for much better efficiency
			var template = renderView( view="/admin/my/custom/gridActions", args={ id="{id}" } );

			for( var record in records ) {
				actions.append( template.replace( "{id}", record.id, "all" ) );
			}
		}


		return actions;
	}

}
```

