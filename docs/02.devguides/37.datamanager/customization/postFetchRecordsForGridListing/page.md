---
id: datamanager-customization-postfetchrecordsforgridlisting
title: "Data Manager customization: postFetchRecordsForGridListing"
---

## Data Manager customization: postFetchRecordsForGridListing

The `postFetchRecordsForGridListing` customization allows you to modify the result set that will be used to fill an object's record listing table. It receives `objectName` and `records` (query result set) in the `args` struct and is not expected to return a result.

This customization is run before the [[datamanager-customization-decoraterecordsforgridlisting|decorateRecordsForGridListing]] customization and appears to do the same thing. However, you can use _this_ customization to make changes before using the _core_ Data Manager implementation of [[datamanager-customization-decoraterecordsforgridlisting|decorateRecordsForGridListing]] that will add grid fields, checkboxes, etc. to the result set.

For example, here we use a fictional injected service to add values to each record that we may wish to use later (there would probably be a more efficient way to do this, but perhaps this could be the only way for you to achieve it):

```luceescript
// /application/handlers/admin/datamanager/blog_post.cfc

component {

	property name="myCustomSecurityService" inject="myCustomSecurityService";

	private void function postFetchRecordsForGridListing( event, rc, prc, args={} ) {
		var records = args.records ?: QueryNew( '' );
		var secureCol = [];

		for( var r in records ){
			secureCol.append( myCustomSecurityService.isSecure( r.id ?: "" ) );
		}

		QueryAddColumn( records, "isSecure", secureCol );
	}

}
```

