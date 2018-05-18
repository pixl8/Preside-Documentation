---
id: datamanager-customization-buildgetnodesfortreeviewlink
title: "Data Manager customization: buildGetNodesForTreeViewLink"
---

## Data Manager customization: buildGetNodesForTreeViewLink

The `buildGetNodesForTreeViewLink` customization allows you to customize the ajax URL for fetching child nodes for tree view. It is expected to return the listing URL as a string and is provided the `objectName` in the `args` struct along with any other arguments passed to `event.buildAdminLink()`. e.g.


```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function buildGetNodesForTreeViewLink( event, rc, prc, args={} ) {
		var queryString = args.queryString ?: "";

		return event.buildAdminLink( linkto="admin.blogmanager.ajaxTreeViewNodes", queryString=queryString );
	}

}
```

>>> See [[datamanagerbasics]] for information regarding setting up a tree view for your object.
