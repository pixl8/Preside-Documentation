---
id: dataexports
title: Data exports
---

## Overview

As of **10.8.7**, Preside comes with a data export API with a simple UI built in to admin data tables. This export UI has been implented for all data manager grids, website users and redirect rules grids. The feature is turned off by default but we expect to enable it by default in a future version.

The platform also offers a concept of custom data exporters. A data exporter consists of a single handler action and an i18n `.properties` file to describe it.

As of **10.19.0**, the platform also offers the ability for developers to define custom "Export templates". See [[data-export-templates]]

### Enabling the feature

Enable the feature in your application's `Config.cfc` with:

```
settings.features.dataexport.enabled = true;
```

*Note: `read` operation must be allowed for the object*

### Define default exporter

Add `settings.dataExport.defaultExporter` in your application's `Config.cfc`. Example:

```
settings.dataExport.defaultExporter = "Excel";
```

### Configure save export permission key

As of Preside **10.16.0**, the save export permission key can be configure by `dataManagerSaveExportPermissionKey` annotation (Default value is set to `read`)

```luceescript
/**
 * @dataManagerSaveExportPermissionKey    saveExport
 */
component {
	// ...
}
```


### Customizing default export fields per object

Add the `@dataExportFields` annotation to your preside objects to supply an ordered list of fields that will be used as the _default_ list of fields for exports:

```luceescript
/**
 * @dataExportFields id,title,comment_count,datecreated,datemodifed
 *
 */
component {
	// ...
}
```

### Adding the export feature to your custom admin grids

If you are making use of the core object based data grids (i.e. `renderView( view="/admin/datamanager/_objectDataTable",...`), you can add the `allowDataExport` flag to the passed args to allow default export behaviour:

```luceescript
#renderView( view="/admin/datamanager/_objectDataTable", args={
	  objectName      = "event_delegate"
	, useMultiActions = false
	, datasourceUrl   = event.buildAdminLink( linkTo="ajaxProxy", queryString="action=delegates.getDelegatesForAjaxDataTables", queryString="eventId=" & eventId )
	, gridFields      = [ "active", "login_id", "display_name", "email_address", "last_request_made" ]
	, allowDataExport = true
	, dataExportUrl   = event.buildAdminLink( linkTo="delegates.exportAction", queryString="eventId=" & eventId )
} )#
```

Notice also the `dataExportUrl` argument. Use this to set custom permissions checks and additional filters before proxying to the core `admin.datamanager._exportDataAction` method:

```luceescript
// in /handlers/admin/Delegates.cfc ...

function exportAction( event, rc, prc ) {
	var eventId = rc.eventId ?: "";

	_checkPermissions( event=event, key="export" );

	runEvent(
		  event          = "admin.DataManager._exportDataAction"
		, prePostExempt  = true
		, private        = true
		, eventArguments = {
			  objectName   = "event_delegate"
			, extraFilters = [ { filter={ event=eventId } } ]
		  }
	);
}
```

### Using the export APIs directly

The [[api-dataexportservice]] provides an API to generate a data export file. See the [[dataexportservice-exportData]] method for details. In addition to the documented arguments, the method will also accept any arguments that are acceptable by the [[presideobjectservice-selectdata|PresideObjectService.selectData()]] method. For example:

```luceescript
var exporterDetail = dataExportService.getExporterDetails( "excel" );
var filename       = "Myexport." & exporterDetail.fileExtension;
var filePath       = dataExportService.exportData(
	  exporter     = "excel" // or "csv", or your customer exporter
	, objectName   = "event_booking"
	, selectFields = selectFieldsArray
	, fieldTitles  = { eventName="Event name", ... }
	, filter       = { booked_event=eventId }
	, autogroupby  = true
);

header name="Content-Disposition" value="attachment; filename=""#filename#""";
content reset=true file=filePath deletefile=true type=exporterDetail.mimeType;
abort;
```

The idea here is that you export a preside data object [[presideobjectservice-selectdata]] call directly to a file, using any fields and filters that you desire.

### Creating custom data exporters

The core system comes with a CSV exporter and an Excel exporter. The exporter logic is responsible for accepting data and some metadata about the export and for then producing a file.

#### Step 1: Create exporter handler

All exporter handlers must live under `/handlers/dataExporters/` folder. The name of the handler is considered the ID of the exporter. The CSV exporter, for example, lives at `/handlers/dataExporters/CSV.cfc`.

The handler must declare mime type and file extension in its component attributes and implement an `export` method. For example:

```luceescript
/**
 * @exportFileExtension csv
 * @exportMimeType      text/csv
 *
 */
component {

	property name="csvWriter" inject="csvWriter";

	private string function export(
		  required array  selectFields
		, required struct fieldTitles
		, required any    batchedRecordIterator
		,          struct meta
	) {
		// create a tmp file and instantiate TAB delimited CSV writer
		var tmpFile = getTempFile( getTempDirectory(), "CSVEXport" );
		var writer  = csvWriter.newWriter( tmpFile, Chr( 9 ) );
		var row     = [];
		var data    = "";

		try {
			// create title row
			for( var field in arguments.selectFields ) {
				row.append( arguments.fieldTitles[ field ] ?: "?" );
			}
			writer.writeNext( row );

			// repeatedly call batchedRecordIterator until
			// no data left, adding rows to our CSV
			do {
				data = arguments.batchedRecordIterator();
				for( var record in data ) {
					row  = [];
					for( var field in arguments.selectFields ) {
						row.append( record[ field ] ?: "" );
					}
					writer.writeNext( row );
				}
				writer.flush();
			} while( data.recordCount );

		} catch ( any e ) {
			rethrow;
		} finally {
			writer.close();
		}

		// return filepath of file containing our CSV
		return tmpFile;
	}
}
```

##### Arguments to the EXPORT method

**batchedRecordIterator**

An anonymous function that can be called repeatedly to get the next batch of data (a CFML query object). The function accepts no arguments. Example usage:

```luceescript
var data = "";
do {
	data = batchedRecordIterator();
	// ... your exporter logic for data
} while( data.recordCount );
```

**selectFields**

An array of fieldnames in the data. The order of this array should be respected for table based exports.

**fieldTitles**

A struct of human readable field _titles_ that correspond to the field _names_ in the `selectFields` array. For example:

```luceescript
selectFields = [ "field1", "field2", "field3" ];
fieldTitles  = {
	  field1 = "Field 1"
	, field2 = "Field 2"
	, field3 = "Field 3"
};
```

**meta**

A struct of arbitrary metadata to do with the export. This may be used to embed in a document for example. Keys may include `title`, `author`, `datecreated` and so on. Individual exporters may wish to use this metadata in their exported documents.

#### Step 2: Create exporter .properties file

A corresponding `.properties` file should live at `/i18n/dataExporters/{exporterId}.properties`. Three keys are required, `title`, `description` and `iconClass`. e.g.

```properties
title=CSV File
description=Download data in plain text CSV (Character Separated Values)
iconClass=fa-table
```

## Configuring CSV Export delimiter

The default delimiter used for CSV export is a comma. You can change this in `Config.cfc` by setting `settings.dataExports.csv.delimiter`:

```luceescript
// /application/config/Config.cfc
...
settings.dataExports.csv.delimiter = Chr( 9 ); // tab
...
```

## Configuring Export Fields Permission

As of Preside **10.16.0**, the export fields' permission can be controlled by `limitToAdminRoles` property attribute. It accepts multiple roles by comma delimiter list.

```luceescript
// /preside-objects/my_object.cfc
component {

    // ...
    property name="my_object_field" ... limitToAdminRoles="sysadmin,contentadmin";
    // ...

}
```

## Configuring default exclude fields

As of Preside 10.25.0, you are able to configure default global fields to be excluded for data export by `settings.dataExports.defaults.excludeFields`:

```luceescript
// /application/config/Config.cfc
...
settings.dataExport.defaults.excludeFields = [ "id", "datecreated" ];
...
```

You also able to set the include or exclude fields for data export in the object attributes by setting `dataExportDefaultIncludeFields` or `dataExportDefaultExcludeFields`:

```luceescript
// /preside-objects/foo.cfc
/**
 * @dataExportDefaultIncludeFields    label,datecreated,datemodified
 */
component {
    ...
}
```

```luceescript
// /preside-objects/bar.cfc
/**
 * @dataExportDefaultExcludeFields    id,datecreated
 */
component {
    ...
}
```

## Configuring "expandable" many-to-one fields

![Screenshot showing example of a expanded many-to-one relationship field in export](images/screenshots/export-expanded-field-example.png)

As of Preside 10.25.0, you are able to configure `many-to-one` relationship fields to be expanded and available when exporting an object. You able to configure this in the object level or object property level as below.

### Configure at object level

Enable or disable for all many-to-one fields on an individual object using the `dataExportExpandManytoOneFields` annotation:

```luceescript
// /preside-objects/foo.cfc
/**
 * @dataExportExpandManytoOneFields    true
 */
component {
    ...
}
```

### Configure at object property level

Two property attributes control the expansion behaviour:

1. Set `dataExportExpandFields` attribute to `true` on a `many-to-one` property to allow related object fields to be included in a data export, or a set of fields list of related object also allowed.
2. Set `excludeNestedDataExport` attribute to `true` on any property to prevent that property from being included as an option when the object is nested. Note that `excludeDataExport` still applies and excludes a property from any data export.

```luceescript
// /preside-objects/foo.cfc
component {

    // ...
    property name="bar"         relationship="many-to-one" relatedto="bar" dataExportExpandFields="true";
    property name="another_bar" relationship="many-to-one" relatedto="bar" dataExportExpandFields="bar_1,bar_2,bar_3";
    // ...

}


// /preside-objects/bar.cfc
component {

    // ...
    property name="bar_1" ... excludeNestedDataExport="true";
    property name="bar_2" ...;
    property name="bar_3" ...;
    // ...

}
```