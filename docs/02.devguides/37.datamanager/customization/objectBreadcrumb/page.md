---
id: datamanager-customization-objectbreadcrumb
title: "Data Manager customization: objectBreadcrumb"
---

## Data Manager customization: objectBreadcrumb

The `objectBreadcrumb` customization allows you to override what happens for the "object" breadcrumb of an object. This defaults to a title that is the object, and a link that goes to the listing page for the object. For example:

```luceescript
// /application/handlers/admin/datamanager/blog_post.cfc

component {

	private string function objectBreadcrumb() {
		var blogId          = prc.record.blog ?: ( rc.blogId ?: "" )

		if ( !Len( Trim( blogId ) ) ) {
			setNextEvent( url=blogListingLink );
		}

		event.addAdminBreadCrumb( 
			  title = "Posts"
			, link  = event.buildAdminLink( objectName="blog", recordId=blogId, operation="posts" )
		);
	}
}
```

