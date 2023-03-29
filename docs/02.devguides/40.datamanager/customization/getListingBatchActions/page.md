---
id: datamanager-customization-getlistingbatchactions
title: "Data Manager customization: getListingBatchActions"
---

## Data Manager customization: getListingBatchActions

The `getListingBatchActions` customization allows you to prepare the array of buttons that gets rendered as part of the listing screen (displayed when a user selects rows from the grid). The element should at least contain a `label`, `iconClass` and `name` (most important and must be unique), along with a public function named `{name}BatchAction`.


For example:


```luceescript
// /application/handlers/admin/datamanager/GlobalDefaults.cfc
component {

    private array function getListingBatchActions( event, rc, prc, args={} ) {
        return [{
              label     = "Archive selected entities"
            , iconClass = "fa-trash-o"
            , name      = "archiveEntity"
        }];
    }

    private array function multiRecordAction( event, rc, prc, args={} ) {
        // ...
        if ( args.action == "archiveEntity" ) {
            // ... your logic here
        }
    }

}
```

See [[datamanager-customization-multirecordaction]] for a full guide to implementing batch record actions.