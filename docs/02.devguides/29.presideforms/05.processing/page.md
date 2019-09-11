---
id: presideforms-processing
title: Processing Preside form definitions
---

## Processing Preside form definitions

Once an HTML form has been submitted that contains one or more instances of Preside form definitions, you will likely want to process that submitted data. A typical example follows:

```luceescript
public void function myHandlerAction( event, rc, prc ) {
	var formName         = "my.form.definition";
	var formData         = event.getCollectionForForm( formName );
	var validationResult = validateForm( formName, formData );

	if ( !validationResult.validated() ) {
		var persist = formData;
		persist.validationResult = validationResult;

		setNextEvent(
			  url           = myEditViewUrl
			, persistStruct = persist
		);
	}
}
```

## Getting data from the request

It can be useful to get a structure of data from the request (i.e. the ColdBox `rc` scope) that contains purely the fields for your form. The `event.getCollectionForForm()` helper method is there for that purpose.

The helper can be called in two ways:

```luceescript
// 1. No arguments - system will detect the preside
// form(s) that have been submitted and get the data
// for those
var formData = event.getCollectionForForm();

// 2. Supplied form name
var formData = event.getCollectionForForm( "my.form.definition" );
```

As well as filtering out the request data, the method will also ensure that each field in the form definition exists. If the field was not in the submitted request (for example, a checkbox was left unticked), the field will be defaulted as an empty string.

## Getting the form(s) that were submitted

In usual circumstances, you will know the ID of the form that has been submitted. You may, however, find yourself in a situation where you have multiple dynamic form definitions creating a single HTML form and being submitted. In this scenario, you can use the `event.getSubmittedPresideForms()` method. For example:

```luceescript
// event.getSubmittedPresideForms(): returns array of
// submitted form names
var formNames = event.getSubmittedPresideForms();
var formData  = {};

for( var formName in formNames ) {
	formData[ formName ] = event.getCollectionForForm( formName );
}
```

## Validating submissions

There are two helper methods that you can use to quickly validate a submission, `validateForm()` and `validateForms()`. The first method is a proxy to the [[formsservice-validateform]] method of the [[api-formsservice]], the second is a helper to validate multiple forms at once. e.g.

```luceescript
// example one - explicit
var formName         = "my.form";
var formData         = event.getCollectionForForm( formName );
var validationResult = validateForm( formName, formData );

// example two - multiple dynamic forms
// the following validates all forms that were
// submitted
var validationResult = validateForms();
```

See [[presideforms-validation]] for more details of how the [[validation-framework]] is integrated with the form system.


## Auto-trimming submitted values

As of 10.11.0, it is possible to configure form submissions so all data returned by `event.getCollectionForForm()` is automatically stripped of leading and trailing whitespace. Application-wide configuration is set in `Config.cfc`:

```luceescript
// default settings in core Config.cfc
settings.autoTrimFormSubmissions = { admin=false, frontend=false };
```

By default, this is turned off for both admin and front-end applications, to maintain the existing behaviour. However, you can enable these in your own application's `Config.cfc`:

```luceescript
// This will auto-trim all submissions via the front-end of the website
settings.autoTrimFormSubmissions.frontend = true;
```

Your application can also override these settings on an individual basis, by specifying an `autoTrim` argument to `event.getCollectionForForm()`. For example:

```luceescript
var formData = event.getCollectionForForm( formName="my.form", autoTrim=true );
```

This will auto-trim the submitted data, even if the application default is not to do so. The reverse also applies: you may set `autoTrim=false` even if it is turned on for the application as a whole.

Finally, you can configure this on a per-property basis, either in your object definition or in your form definition. A property with an `autoTrim` setting will *always* obey that setting, regardless of what is defined in the application or in `event.getCollectionForForm()`. For example:

```luceescript
component {
	property name="a_field_with_preserved_spaces" type="string" dbtype="varchar" autoTrim=false;
}
```

or:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form>
	<tab>
		<fieldset>
			<field name="always_trim_this_field" autoTrim="true" />
		</fieldset>
	</tab>
</form>
```