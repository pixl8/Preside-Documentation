---
id: datamanager-customization-getadditionalquerystringforbuildajaxlistinglink
title: "Data Manager customization: getAdditionalQueryStringForBuildAjaxListingLink"
---

## Data Manager customization: getAdditionalQueryStringForBuildAjaxListingLink

The `getAdditionalQueryStringForBuildAjaxListingLink` customization allows you to supply extra query string parameters to the AJAX URL endpoint that fetches records for an object's record listing screen. It must return a string representing the additional query string parameters and takes the `objectName` in the `args` struct.

You may wish to do this so that you can provide extra filters on the results using the [[datamanager-customization-prefetchrecordsforgridlisting|preFetchRecordsForGridListing]] customization, for example.

e.g.

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
