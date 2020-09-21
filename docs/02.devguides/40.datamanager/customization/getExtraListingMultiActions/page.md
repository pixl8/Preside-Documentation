---
id: datamanager-customization-getextralistingmultiactions
title: "Data Manager customization: getExtraListingMultiActions"
---

## Data Manager customization: getExtraListingMultiActions

The `getExtraListingMultiActions` customization allows you to modify the array of buttons that gets rendered as part of the listing screen (displayed when a user selects rows from the grid). It is expected _not_ to return a value and receives the following in the `args` struct:

* `objectName`: The name of the object
* `actions`: the array of button "actions"


Items in the array should match button definitions as defined in [[datamanager-customization-multi-action-buttons]].

Also note, that you can use the [[datamanager-customization-multirecordaction|multiRecordAction]] to process any custom actions that you add.

For example:


```luceescript
// /application/handlers/admin/datamanager/GlobalDefaults.cfc
component {

    private void function getExtraListingMultiActions( event, rc, prc, args={} ) {
        args.actions = args.actions ?: [];
        args.actions.append( {
              label     = "Archive selected entities"
            , name      = "archive"
            , prompt    = "Archive the selected entities"
            , class     = "btn-danger"
            , iconClass = "fa-clock-o"
        } );
    }

}
```
