---
id: datamanager-customization-editrecordaction
title: "Data Manager customization: editRecordAction"
---

## Data Manager customization: editRecordAction

The `editRecordAction` allows you to override the core action logic for adding a record when a form is submitted. The core will have already checked permissions for editing records, but all other logic will be up to you to implement (including audit trails, validation, etc.).

The method is not expected to return a value and is provided with `args.objectName` and `args.recordId`. _The expectation is that the method will redirect the user after processing the request._

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	property name="blogService" inject="blogService";

	private void function editRecordAction( event, rc, prc, args={} ) {
		var formName         = "my.custom.editrecord.form";
		var recordId         = args.recordId ?: "";
		var formData         = event.getDataForForm( formName );
		var validationResult = validateForm( formName, formData );

		if ( validationResult.validated ) {
			blogService.saveBlog( argumentCollection=formData, id=recordId );

			setNextEvent( url=event.buildAdminLink(
				  objectName = "blog"
				, recordId   = recordId
			) );
		}

		var persist = formData;
		persist.validationResult = validationResult;

		setNextEvent( url=event.buildAdminLink(
			  objectName = "blog"
			, operation  = "editRecord"
			, recordId   = recordId
		), persistStruct=persist );

	}

}


```

>>> If you wish to still use core logic for editing records but need to add additional logic to the process, use [[datamanager-customization-preeditrecordaction|preEditRecordAction]] or [[datamanager-customization-posteditrecordaction|postEditRecordAction]] instead.

