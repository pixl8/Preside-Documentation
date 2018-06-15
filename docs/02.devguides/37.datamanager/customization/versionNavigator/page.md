---
id: datamanager-customization-versionnavigator
title: "Data Manager customization: versionNavigator"
---

## Data Manager customization: versionNavigator

The `versionNavigator` customization allows you to override the 'version navigator' that shows at the top of view, edit and translate record screens. The customization is expected to return the rendered HTML of the navigator and is provided the following in the `args` struct:

* `object`: The object name
* `id`: The current record ID
* `version`: The current version number
* `isDraft`: Whether or not the current version is a draft
* `baseUrl`: The "base" URL for version navigation. This URL will have the token `{version}` in the string and this should be replaced with the previous/next version numbers when building version navigation links

For example:

```luceescript
// /application/handlers/admin/datamanager/GlobalCustomizations.cfc

component {

	property name="versioningService"    inject="versioningService";
	property name="presideObjectService" inject="presideObjectService";

	private void function versionNavigator( event, rc, prc, args={} ) {
		var selectedVersion = Val( args.version ?: "" );
		var objectName      = args.object ?: "";
		var id              = args.id     ?: "";

		args.latestVersion          = versioningService.getLatestVersionNumber( objectName=objectName, recordId=id );
		args.latestPublishedVersion = versioningService.getLatestVersionNumber( objectName=objectName, recordId=id, publishedOnly=true );
		args.versions               = presideObjectService.getRecordVersions(
			  objectName = objectName
			, id         = id
		);

		if ( !selectedVersion ) {
			selectedVersion = args.latestVersion;
		}

		args.isLatest    = args.latestVersion == selectedVersion;
		args.nextVersion = 0;
		args.prevVersion = args.versions.recordCount < 2 ? 0 : args.versions._version_number[ args.versions.recordCount-1 ];

		for( var i=1; i <= args.versions.recordCount; i++ ){
			if ( args.versions._version_number[i] == selectedVersion ) {
				args.nextVersion = i > 1 ? args.versions._version_number[i-1] : 0;
				args.prevVersion = i < args.versions.recordCount ? args.versions._version_number[i+1] : 0;
			}
		}

		return renderView( view="/admin/datamanager/globalcustomizations/versionNavigator", args=args );
	}

}
```

