---
id: datamanager-customization-prefetchrecordsforgridlisting
title: "Data Manager customization: preFetchRecordsForGridListing"
---

## Data Manager customization: preFetchRecordsForGridListing

The `preFetchRecordsForGridListing` customization can be used to modify the arguments sent to [[datamanagerservice-getrecordsforgridlisting]] method. The `args` struct sent to the customization action represents the arguments to be sent to [[datamanagerservice-getrecordsforgridlisting]]. No return value is expected.

A common example might be to add an extra filter to the the query. For example:

```luceescript
// /application/handlers/admin/datamanager/blog_post.cfc
component {

	private void function preFetchRecordsForGridListing( event, rc, prc, args={} ) {
		var category = rc.category ?: "";

		if ( !IsEmpty( category ) ) {
			args.extraFilters = args.extraFilters ?: [];
			
			args.extraFilters.append( { filter={ category=category } } );		
		}

	}

}
```

Note, that this example would rely on `rc.category` somehow being present in the _ajax_ request that fetches the record set. One method of achieving this would be to make use of [[datamanager-customization-getadditionalquerystringforbuildajaxlistinglink]]. For example:


```luceescript
// /application/handlers/admin/datamanager/blog_post.cfc
component {

	// this is run when building the ajax link, i.e. in the main
	// request for the listing page
	private string function getAdditionalQueryStringForBuildAjaxListingLink( event, rc, prc, args={} ) {
		// category here could have been placed in the URL
		// by a category drop down button, for example
		
		var category = rc.category ?: "";

		return "category=#category#";
	}


	// this is run during the ajax fetch of records
	private void function preFetchRecordsForGridListing( event, rc, prc, args={} ) {
		var category = rc.category ?: "";

		if ( !IsEmpty( category ) ) {
			args.extraFilters = args.extraFilters ?: [];
			
			args.extraFilters.append( { filter={ category=category } } );		
		}

	}

}
```