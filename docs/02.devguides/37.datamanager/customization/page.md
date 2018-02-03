---
id: customizingdatamanager
title: Customizing Data Manager
---

## Introduction

As of Preside 10.9.0, [[datamanager]] comes with a customization system that allows you to customize many aspects of the Data Manager both globally and per object. In addition, you are able to use all the features of Data Manager for your object **without needing to list your object in the Data Manager homepage**. This means that you can create your own custom navigation to your object and not need to write any further code to create your CRUD admin interface - perfect for building custom admin interfaces with dedicated navigation.

## Customization system overview

Customizations are implementing as convention based ColdBox _handlers_. Customizations that should be applied globally belong in `/handlers/admin/datamanager/GlobalCustomizations.cfc`. Customizations that should be applied to a specific object go in `/handlers/admin/datamanager/objectname.cfc`. For example, if you wish to supply customizations for a `blog_author` object, you would create a handler file: `/handlers/admin/datamanager/blog_author.cfc`.

The Data Manager implements a large number of customizations. Each customization will be implemented in your handlers as a **private** handler action. The return type (if any) and arguments supplied to the action will depend on the specific customization.

For example, you may wish to do some extra processing after saving an `employee` record using the `postEditRecordAction` customization:

```luceescript
// /application/handlers/datamanager/employee.cfc

component {

	// as this is a regular coldbox handler
	// we can use wirebox to inject and access our service layer
	property name="notificationService" inject="notificationService";

	private void function postEditRecordAction( event, rc, prc, args={} ) {
		// the args struct values will vary depending on the customization point.
		// in this case, we get new and old data (as well as many other fields)
		var newData    = args.formData       ?: {};
		var oldData    = args.existingRecord ?: {};
		var employeeId = args.recordId       ?: {}

		// here, as an example, we use the notification service to 
		// raise a "Date of birth change" notification when the DOB changes
		if ( newData.keyExists( "dob" ) && newData.dob != oldData.dob ) {
			notificationService.createNotification( topic="DOBChange", type="info", data={ employeeId=employeeId } )
		}

		// of course, we could do anything we like here. For instance,
		// we could redirect the user to a different screen than the 
		// normal "post-edit" behaviour for Data Manager.
	}

}
```

## Building and customizing links to objects and records

With the new 10.9.0 customization system, comes a new method of building data manager links for objects. Use `event.buildAdminLink( objectName=objectName )` along with optional arguments, `operation` and `recordId` to build various links. For example, to link to the data manager listing page for an object, use the following:

```luceescript
event.buildAdminLink( objectName=objectName );
```

To link to the default view for a record (insert ref for customizing this), use:

```luceescript
event.buildAdminLink( objectName=objectName, recordId=recordId );
```

To link to a specific page or action URL for an object or record, add the `operation` argument, e.g.

```luceescript
event.buildAdminLink( objectName=objectName, operation="addRecord" );
event.buildAdminLink( objectName=objectName, operation="editRecord", recordId=recordId );
// etc.
```

The core, "out-of-box", operations are:

* `listing`
* `viewRecord`
* `addRecord`
* `addRecordAction`
* `editRecord`
* `editRecordAction`
* `deleteRecordAction`
* `translateRecord`
* `sortRecords`
* `managePerms`
* `ajaxListing`
* `multiRecordAction`
* `exportDataAction`
* `dataExportConfigModal`
* `recordHistory`
* `getNodesForTreeView`


>>>>>> You can pass extra query string parameters to any of these links with the `queryString` argument. For example:
>>>>>>
```
event.buildAdminLink( 
	  objectName  = objectName
	, operation   = "addRecord"
	, queryString = "categoryId=#categoryId#"
);
```

### Providing a custom link builder for an operation

There is a naming convention for providing a custom link builder for an operation: `build{operation}Link`. There are therefore Data Manager customizations named, `buildListingLink`, `buildViewRecordLink`, and so on. For example, to provide a completely different link for a view record screen for your object, you could do:

```luceescript
// /application/handlers/admin/datamanager/blog_author.cfc

component {

	private string function buildViewRecordLink( event, rc, prc, args={} ) {
		var recordId = args.recordId    ?: "";
		var extraQs  = args.queryString ?: "";
		var qs       = "id=#recordId#";

		if ( extraQs.len() ) {
			qs &= "&#extraQs#";
		}

		// e.g. here we would have a coldbox handler /admin/BlogAuthors.cfc 
		// with a public 'view' method for completely controlling the entire 
		// view record request outside of Data Manager
		return event.buildAdminLink( linkto="blogauthors.view", querystring=qs );
	}
}
```

### Adding your own operations

If you are extending Data Manager to add extra pages for a particular object (for example), you can create new operations by following the same link building convention above. For example, say we wanted to build a "preview" link for an article, we can use the following:

```luceescript
// /handlers/admin/datamanager/article.cfc
component {

	private string function buildPreviewLink( event, rc, prc, args={} ) {
		var articleId = args.recordId ?: "";
		
		return "https://preview.mysite.com/?articleId=#articleId#";
	}

}
```

Linking to the "preview" "operation" can then be done with:

```luceescript
event.buildAdminLink( objectName="article", operation="preview", id=recordId );
```
