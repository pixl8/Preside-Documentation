---
id: datamanager-customization-decoraterecordsforgridlisting
title: "Data Manager customization: decorateRecordsForGridListing"
---

## Data Manager customization: decorateRecordsForGridListing

The `decorateRecordsForGridListing` customization allows you to modify the result set that will be used to fill an object's record listing table. The core implementation of this customization adds columns for action links, checkboxes for multi row actions, etc.

>>>> Unless you know that you want to completely override all this logic, you are likely better off using the [[datamanager-customization-postfetchrecordsforgridlisting|postFetchRecordsForGridListing]] customization.

The customization is not expected to return a value and receives the following in the `args` struct:

* `records`: Query result set
* `objectName`: Object name
* `gridFields`: Array of grid fields used by the current table
* `useMultiActions`: Whether or not to use multi actions (i.e. whether or not to include checkbox per row)
* `isMultilingual`: Whether or not the object is multilingual (i.e. whether or not to add translation status column to the table)
* `draftsEnabled`: Whether or not drafts are enabled for the object (i.e. whether or not to include drafts status column)

For example, here we use a fictional injected service to add values to each record that we may wish to use later (there would probably be a more efficient way to do this, but perhaps this could be the only way for you to achieve it):

```luceescript
// /application/handlers/admin/datamanager/blog_post.cfc

component {

	property name="myCustomSecurityService" inject="myCustomSecurityService";

	private void function decorateRecordsForGridListing( event, rc, prc, args={} ) {
		var records = args.records ?: QueryNew( '' );
		var secureCol = [];

		for( var r in records ){
			secureCol.append( myCustomSecurityService.isSecure( r.id ?: "" ) );
		}

		QueryAddColumn( records, "isSecure", secureCol );
	}

}
```

