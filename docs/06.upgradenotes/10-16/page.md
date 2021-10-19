---
id: 10-16-upgrade-notes
title: Upgrade notes for 10.15 -> 10.16
---

## Summary

The 10.16.0 release brings a number of improvements to the platform that should be bought to the attention of developers, in particular with regards to custom features that they may have developed. There are no known compatibility issues.

## Asset image alt text

There is now an out-of-the-box alt text field for assets. In addition, all of our default asset renderers now use this alternative text when it is available.

You should check your code-base for any customised asset renderers and update them to get the alt text from the `alt_text` field on the `asset` record. For example:

```lucee
<!--- /views/renderers/asset/image/default.cfm --->
<cfscript>
	imageUrl = event.buildLink( assetId=args.id ?: '', derivativ=args.derivative ?: "" );
	altText  = Len( Trim( args.alt_text ?: "" ) ) ? args.alt_text : ( args.title ?: "" );
</cfscript>
<cfoutput>
	<img src="#imageUrl#"
		<cfif Len( Trim( altText ) ) > alt="#( altText )#"</cfif>
		<cfif Len( Trim( args.label ?: "" ) ) > title="#( args.label )#"</cfif>
		<cfif Len( Trim( args.class ?: "" ) ) > class="#( args.class )#"</cfif>
	/>
</cfoutput>
```

## Datamanager delete record prompts

In 10.16.0, we added the ability to easily prompt users to type a confirmation text when deleting records from the Datamanager screens:

![Screenshot of a delete record prompt](images/screenshots/deleteprompt.png)

This feature is turned off by default for single record deletes, and turned _on_ by default for multi-record deletes.

See the INSERT-GUIDE-HERE guide for more details about configuring this feature.

## Datamanager listing batch operations

In Preside 10.16.0, two tickets brought some more robust handling of the batch edit and delete functionalities when triggered from datamanager listing tables. If you are customising the batch operations, or implementing pre/post delete record customisations, then you may need to take action:

* [PRESIDECMS-2213](https://presidecms.atlassian.net/browse/PRESIDECMS-2213) Batch edit/delete: perform in background thread and show progress bar
* [PRESIDECMS-2214](https://presidecms.atlassian.net/browse/PRESIDECMS-2214) Datamanager batch operations: allow option to select all records matching current filters

![Screenshot of "select all matching filter" feature in datatables](images/screenshots/batchselectall.png)

### Pre and post delete customisations

Previously, during the batch delete process, the [[datamanager-customization-predeleterecordaction]] and [[datamanager-customization-postdeleterecordaction]] customisations would be fired for objects that implemented them. 

**THIS IS NO LONGER THE CASE FOR BATCH DELETE**. Instead, we now execute the following new customisations for objects that implement them:

* [[datamanager-customization-prebatchdeleterecordsaction]]
* [[datamanager-customization-postbatchdeleterecordsaction]]

>>> You should search your code bases for handler implementations of the pre/postdeleteRecordAction customisations and update accordingly to support batch delete if needed.

### Custom batch record operations

If your codebase has supplied custom batch operations using one of the customisations below, you should consider supporting the new "Select all records matching the current filter" functionality. If you do nothing, this feature will not work for your batch operation:

* [[datamanager-customization-listingmultiactions|listingMultiActions]]
* [[datamanager-customization-getlistingmultiactions|getListingMultiActions]]
* [[datamanager-customization-getextralistingmultiactions|getExtraListingMultiActions]]

See [[datamanager-customization-multirecordaction]] for a guide to creating batch operations.

