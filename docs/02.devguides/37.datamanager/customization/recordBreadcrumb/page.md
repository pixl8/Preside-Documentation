---
id: datamanager-customization-recordbreadcrumb
title: "Data Manager customization: recordBreadcrumb"
---

## Data Manager customization: recordBreadcrumb

The `recordBreadcrumb` customization allows you to override what happens for the breadcrumb that represents a record. This defaults to a title that is the record label, and a link that goes to the view or edit page for the object (depending on permissions and what operations are available). For example:

```luceescript
// /application/handlers/admin/datamanager/blog_post.cfc

component {

	private string function recordBreadcrumb() {
		var recordLabel = prc.recordLabel ?: "";
		var recordId    = prc.recordId    ?: "";
		var record      = prc.record      ?: {};

		if ( IsTrue( record.special ?: "" ) ) {
			event.addAdminBreadCrumb( 
				  title = recordLabel
				, link  = event.buildAdminLink( objectName="blog_post", recordId=recordId, operation="specialview" )
			);
		} else {
			event.addAdminBreadCrumb( 
				  title = recordLabel
				, link  = event.buildAdminLink( objectName="blog_post", recordId=recordId )
			);
		}
	}
	
}
```