---
id: datamanager-customization-quickAddRecordAction
title: "Data Manager customization: quickAddRecordAction"
---

## Data Manager customization: quickAddRecordAction

The `quickAddRecordAction` allows you to override the core action logic for adding a record when a form is submitted. The core will have already checked permissions for adding records, but all other logic will be up to you to implement (including audit trails, validation, etc.).

The method is not expected to return a value and is provided with `args.objectName`. _The expectation is that the method will redirect the user after processing the request._

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	property name="blogService" inject="blogService";

	private void function quickAddRecordAction( event, rc, prc, args={} ) {
		var formName         = "my.custom.addrecord.form";
		var formData         = event.getDataForForm( formName );
		var validationResult = validateForm( formName, formData );

		if ( validationResult.validated ) {
			var newRecordId = blogService.addBlog( argumentCollection=formData );

			setNextEvent( url=event.buildAdminLink(
				  objectName = "blog"
				, recordId   = newRecordId
			) );
		}

		var persist = formData;
		persist.validationResult = validationResult;

		setNextEvent( url=event.buildAdminLink(
			  objectName = "blog"
			, operation  = "addRecord"
		), persistStruct=persist );

	}

}


```

>>> If you wish to still use core logic for adding records but need to add additional logic to the process, use [[datamanager-customization-prequickaddrecordaction|preQuickAddRecordAction]] or [[datamanager-customization-postquickaddrecordaction|postQuickAddRecordAction]] instead.