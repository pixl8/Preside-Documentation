---
id: datamanager-customization-multirecordaction
title: "Data Manager customization: multiRecordAction"
---

## Data Manager customization: multiRecordAction

The `multiRecordAction` customization allows you customize the processing of a multi row action submission from the listing screen. It is not expected to return a value. However, if it processes the request and does not want any further core processing to take place, it **must redirect the user to a success page** (i.e. send the user back to the listing page and add a success message). It recieves the following in the `args` struct:

* `objectName`: The name of the object
* `action`: the name of the action that was performed (the button/link selected in the listing screen)
* `ids`: an array of record IDs that the action should be performed on

See also:

* [[datamanager-customization-listingmultiactions|listingMultiActions]]
* [[datamanager-customization-getlistingmultiactions|getListingMultiActions]]
* [[datamanager-customization-getextralistingmultiactions|getExtraListingMultiActions]]

For example:


```luceescript
// /application/handlers/admin/datamanager/GlobalDefaults.cfc
component {

    property name="myCustomArchiveService" inject="myCustomArchiveService";
    property name="messageBox"             inject="messagebox@cbmessagebox";

    private array function multiRecordAction( event, rc, prc, args={} ) {
        var objectName = args.objectName ?: "";
        var action     = args.action     ?: "";
        var ids        = args.ids        ?: [];

        if ( args.action == "archive" ) {
            myCustomArchiveService.archiveRecords( objectName=objectName, ids=ids );
            messageBox.info( "Archive success message here.." );
            setNextEvent( url=event.buildAdminLink( objectName=objectName ) );
        }

        // otherwise, do nothing, core will process the multi action
        // submission
    }

}
```