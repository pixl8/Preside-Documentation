---
id: datamanager-customization-multirecordaction
title: "Data Manager customization: multiRecordAction"
---

## Data Manager customization: multiRecordAction

The `multiRecordAction` customization allows you customize the processing of a multi row action submission from the listing screen. It is not expected to return a value. However, if it processes the request and does not want any further core processing to take place, it **must redirect the user to a success page** (i.e. send the user back to the listing page and add a success message). It recieves the following in the `args` struct:

* `objectName`: The name of the object
* `action`: the name of the action that was performed (the button/link selected in the listing screen)
* `ids`: an array of record IDs that the action should be performed on (empty if `batchAll` is `true`)
* `batchAll`: as of **10.16.0**, a boolean flag to indicate that the user picked the "Select all records matching the current filter"
* `batchSrcArgs`: as of **10.16.0**, a struct of args that were used in a `selectData` call to fetch the records using the current datatable filters. Only needed when `batchAll` is `true`

See also:

* [[datamanager-customization-listingmultiactions|listingMultiActions]]
* [[datamanager-customization-getlistingmultiactions|getListingMultiActions]]
* [[datamanager-customization-getextralistingmultiactions|getExtraListingMultiActions]]

For example:


```luceescript
// /application/handlers/admin/datamanager/GlobalDefaults.cfc
component {

    property name="myCustomArchiveService" inject="myCustomArchiveService";
    property name="batchOperationService"  inject="datamanagerBatchOperationService";
    property name="messageBox"             inject="messagebox@cbmessagebox";

    private array function multiRecordAction( event, rc, prc, args={} ) {
        var objectName   = args.objectName ?: "";
        var action       = args.action     ?: "";
        var ids          = args.ids        ?: [];
        var batchAll     = IsTrue( args.batchAll ?: "" );
        var batchSrcArgs = args.batchSrcArgs ?: {};

        if ( args.action == "archive" ) {
            if ( !batchAll ) {
                myCustomArchiveService.archiveRecords( objectName=objectName, ids=ids );
                messageBox.info( "Archive success message here.." );
                setNextEvent( url=event.buildAdminLink( objectName=objectName ) );               
            }

            // batch all, let's do in a bg thread
            // first, queue the batch operation using the "batchSrcArgs"
            var queueId = batchOperationService.queueBatchOperation( objectName, batchSrcArgs );

            // next, create adhoc task
            var taskId = createTask(
                  event                = "admin.datamanager.globaldefaults.batchArchiveInBgThread"
                , runNow               = true
                , adminOwner           = event.getAdminUserId()
                , title                = "cms:datamanager.batcharchive.task.title"
                , returnUrl            = event.buildAdminLink( objectName=objectName, operation="listing" )
                , discardAfterInterval = CreateTimeSpan( 0, 0, 5, 0 )
                , args       = {
                      objectName   = objectName
                    , batchQueueId = queueId
                }
            );

            // finally, redirect to the task progress screen to allow user to watch progress
            setNextEvent( url=event.buildAdminLink(
                  linkTo      = "adhoctaskmanager.progress"
                , queryString = "taskId=" & taskId
            ) );
        }

        // otherwise, do nothing, core will process the multi action
        // submission
    }


    /**
     * Implementation of background thread batch archive using batch operation queue
     *
     */
    private boolean function batchArchiveInBgThread( event, rc, prc, args={}, logger, progress ) {
        var objectName        = args.objectName ?: "";
        var queueId           = args.batchQueueId ?: "";
        var canLog            = StructkeyExists( arguments, "logger" );
        var canInfo           = canLog && arguments.logger.canInfo();
        var canReportProgress = StructKeyExists( arguments, "progress" );
        var queueSize         = canReportProgress ? batchOperationService.getBatchOperationQueueSize( queueId ) : 0;
        var processed         = 0;
        var ids               = [];
        
        do {
            ids = batchOperationService.getNextBatchRecordsFromQueue(
                  queueId          = queueId
                , maxRows          = 100  // default
                , clearImmediately = true // default
            );

            if ( !ArrayLen( ids ) ) {
                break;
            }

            myCustomArchiveService.archiveRecords( objectName=objectName, ids=ids );

            if ( canReportProgress ) {
                processed += ArrayLen( ids );
                arguments.progress.setProgress( Int( ( 100 / queueSize ) * processed ) );
            }

            if ( canInfo ) {
                arguments.logger.info( "Archived [#ArrayLen( ids )#] records. Next..." );
            }

        } while( ArrayLen( ids ) == 100 )
        
        return true;
    }

}
```