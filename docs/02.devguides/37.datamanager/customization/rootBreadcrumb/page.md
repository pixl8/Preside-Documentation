---
id: datamanager-customization-rootbreadcrumb
title: "Data Manager customization: rootBreadcrumb"
---

## Data Manager customization: rootBreadcrumb

The `rootBreadcrumb` customization allows you to override what happens for the "root" breadcrumb of an object. The default core behaviour for this is to add a "Data manager" link for any objects that are managed in the Data manager homepage. An alternative may be to build the crumbtrail of a parent object (think blog post / blog) so that the root breadcrumb for your object becomes something like: `Blogs > My Awesome blog` for a `blog_post` object. For example:

```luceescript
// /application/handlers/admin/datamanager/blog_post.cfc

component {

	private string function rootBreadcrumb() {
		var blogId          = prc.record.blog ?: ( rc.blogId ?: "" )
		var blogLabel       = renderLabel( "blog", blogId );
		var blogListingLink = event.buildAdminLink( objectName="blog" );

		if ( !Len( Trim( blogId ) ) || !Len( Trim( blogLabel ) ) ) {
			setNextEvent( url=blogListingLink );
		}

		blogLink  = event.buildAdminLink( objectName="blog", recordId=blogId );

		event.addAdminBreadCrumb( title="Blogs"  , link=blogListingLink );
		event.addAdminBreadCrumb( title=blogLabel, link=blogLink        );
	}
}
```

