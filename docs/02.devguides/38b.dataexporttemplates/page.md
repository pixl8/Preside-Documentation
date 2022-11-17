---
id: data-export-templates
title: Data export templates
---

## Overview

As of **10.19.0**, the platform offers the ability for developers to define custom "Export templates". The intention of these templates is to allow developers to hard-code export selectData arguments and column titles for specific export scenarios. These templates can then be used seamlessly with the [[dataexports|Data Export system]] in Preside.

<iframe width="560" height="315" src="https://www.youtube.com/embed/gBlMyEcIhdQ" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Creating a data export template

There are three key elements to creating your own template:

1. A convention based handler, implementing a number of interface methods of your choosing
2. Optional preside form definitions to allow users to configure their export for your template
3. Optional i18n entry to have your template appear nicely to end users when browsing saved exports

### Convention based handler

The convention based handler is the only required element in creating a custom data export template. The handler must live under `/handlers/dataExportTemplates/` and the name of the file will be the ID of the template.

The following code snippet provides documentation on all of the available methods that you can choose to use to define your custom behaviour of your export template:

```luceescript
component {

	/**
	 * Optionally return an array of exporters that your template
	 * supports. Preside comes with "csv" and "excel" exporters out
	 * of the box. You can and may wish to develop further custom
	 * exporters for your template.
	 * 
	 * @objectName The name of the object whose export is being configured
	 */
	private array function getAllowedExporters( event, rc, prc, objectName ) {
		return [ "csv" ];
	}

	/**
	 * Optionally return an array of selectFields to pass to selectData()
	 * 
	 * @objectName     The name of the object whose export is being configured
	 * @templateConfig A struct containing user chosen custom config options for your template
	 */
	private array function getSelectFields( event, rc, prc, objectName, templateConfig, suppliedFields ) {
		
	}

	/**
	 * Optionally return a field to title mapping (struct) for our export
	 *
	 * @objectName     The name of the object whose export is being configured
	 * @templateConfig A struct containing user chosen custom config options for your template
	 * @selectFields   Array of the select fields that will be passed to selectData call
	 */
	private struct function prepareFieldTitles( event, rc, prc, objectName, templateConfig, selectFields ) {
		// e.g.

		return {
			  field_name_a = "Field A"
			, field_name_b = "Field B"
			, // etc.
		}
	}

	/**
	 * Optional method to dynamically get the form name to use when configuring
	 * the export after user hits the "Export" button
	 *
	 * @objectName   The name of the object whose export is being configured
	 * @baseFormName The name of the base form being used. i.e. you should create a form based on this one
	 */
	private string function getConfigFormName( event, rc, prc, objectName, baseFormName ){

	}

	/**
	 * Optional method to dynamically set any renderForm arguments for the
	 * export config form
	 *
	 * @objectName     The name of the object whose export is being configured
	 * @renderFormArgs Struct of arguments for the renderForm() method. Modify this struct to dynamically effect the rendering of the form
	 *
	 */
	preRenderConfigForm( event, rc, prc, objectName, renderFormArgs ){

	}

	/**
	 * Optional method to return user supplied config from any custom
	 * save/configure form submissions for your template.
	 *
	 * @objectName The name of the object whose configuration is being set/saved
	 */
	private struct function getSubmittedConfig( event, rc, prc, objectName ) {
		// e.g.

		return { my_custom_option=rc.my_custom_option ?: "" };
	}

	/**
	 * Optional method to return a struct of data that will be passed
	 * as "meta" to the data exporter. i.e. Excel exporter may use this to 
	 * set meta data on the document.
	 * 
	 * @objectName     The name of the object whose export is being run
	 * @templateConfig A struct containing user chosen custom config options for your template
	 *
	 */
	private struct function getExportMeta( event, rc, prc, objectName, templateConfig ){

	}
	
	/**
	 * Optional method to dynamically effect selectData arguments
	 * just before the data is selected from the db.
	 *
	 * @objectName     The name of the object whose export is being run
	 * @templateConfig A struct containing user chosen custom config options for your template
	 * @selectDataArgs A struct containing the arguments that are about to be sent to selectData(). Modify this struct to effect the outcome
	 *
	 */
	private void function prepareSelectDataArgs( event, rc, prc, objectName, templateConfig, selectDataArgs ){
		// e.g.
		selectDataArgs.savedFilters = selectDataArgs.savedFilters ?: [];
		ArrayAppend( selectDataArgs.savedFilters, "customSavedFilterForMyExportTemplate" );
	}
	
	/**
	 * Optional method to takeover rendering raw records for the export
	 *
	 * @objectName     The name of the object whose export is being run
	 * @templateConfig A struct containing user chosen custom config options for your template
	 * @records        Query containing the records that will be exported. To effect the rendering, loop over these and change the values for any columns you wish to transform
	 */
	private any function renderRecords( event, rc, prc, objectName, templateConfig, records ){
		// e.g.
		for( var i=1; i<=records.recordCount; i++ ) {
			records.my_column[ i ] = renderContent( "renderer", records.my_column[ i ] ); // or something simpler - important to make this as efficient as possible if expecting large data sets
		}
	}
	
	/**
	 * If you have multiple optional exporters, you may implement this optional
	 * method to state the default exporter to set when a user first triggers
	 * the export config form.
	 *
	 * @objectName The name of the object whose export is being configured
	 */
	private string function getDefaultExporter( event, rc, prc, objectName ){

	}
	
	/**
	 * Optional method to return a *default* filename for exporting/saving an export
	 * for your template. If you do not implement this, the system will use the
	 * object name combined with date of the export.
	 *
	 * @objectName The name of the object whose export is being configured
	 *
	 */
	private any function getDefaultFilename( event, rc, prc, objectName ){
		return "my-custom-export";
	}
}
```

### Convention based form definitions

**Note:** when implementing custom configuration fields in convention based forms, you will also want to implement the `getSubmittedConfig()` method in your handler (above).

#### Configure export form

This form is used to render configuration options for the admin user when they first hit the "Export" button from a data table. You can implement this override simply by creating a form at `/forms/dataExportTemplate/{templateId}/config.xml`.

**Note: The form will be merged with the base form provided by the system**: [[form-dataexportexportconfigurationbase]]. 

For example, the "default", system export template implements it as follows:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form i18nBaseUri="cms:dataexport.config.form.">
	<tab id="default">
		<fieldset id="default">
			<field name="exportFields" control="dataExportPanelPicker" required="true" sortorder="20" />
		</fieldset>
	</tab>
</form>
```

#### Save export form

This form is used to render configuration options for the admin user when they are _saving_ an export for scheduling or repeat usage. You can implement this override simply by creating a form at `/forms/dataExportTemplate/{templateId}/save.xml`.

**Note: The form will be merged with the base form provided by the system**: [[form-dataexportsaveexportconfigurationbase]]. 

For example, the "default", system export template implements it as follows:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form>
	<tab id="filters">
		<fieldset id="fields" sortorder="10">
			<field binding="saved_export.fields" control="dataExportPanelPicker" required="true" sortorder="10" />
		</fieldset>
	</tab>
</form>
```

### I18n entries

The system automatically creates an [enum](/devguides/dataobjects.html#enum-properties), `dataExportTemplate` and populates it with the templates available to the system. You can therefore add an entry for each of your templates under `/enum/dataExportTemplate.properties`. For example:

```properties
myExportTemplate.label=My Custom Export Template
```

## Using data export templates

At this point in time, a data export template will only be used when explicitly passed to the `#objectDataTable()#` helper. If you do not specify an export template, the default template will be used (i.e. the system will continue as before). To specify a non-default template, set the `exportTemplate` arg. For example:

```luceescript
#objectDataTable( objectName="invoice", args={ exportTemplate="financeExportTemplate" } )#
```

**Note: A single data table can only use a single export template**. 