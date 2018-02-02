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