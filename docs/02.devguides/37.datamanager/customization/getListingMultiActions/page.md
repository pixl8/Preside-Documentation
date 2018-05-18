---
id: datamanager-customization-getlistingmultiactions
title: "Data Manager customization: getListingMultiActions"
---

## Data Manager customization: getListingMultiActions

The `getListingMultiActions` customization allows you to completely override the array of buttons that gets rendered as part of the listing screen (displayed when a user selects rows from the grid). It should return an array of button definitions as defined in [[datamanager-customization-multi-action-buttons]].

Note, if you only want to modify the buttons, or add / remove to them, look at: [[datamanager-customization-getextralistingmultiactions|getExtraListingMultiActions]]. Overriding the generated buttons string entirely can be achieved with: [[datamanager-customization-listingmultiactions|listingMultiActions]].


For example:


```luceescript
// /application/handlers/admin/datamanager/GlobalDefaults.cfc
component {

    private array function getListingMultiActions( event, rc, prc, args={} ) {
        return [{
              label     = "Archive selected entities"
            , name      = "archive"
            , prompt    = "Archive the selected entities"
            , globalKey = "d"
            , class     = "btn-danger"
            , iconClass = "fa-trash-o"
        }];
    }

}
```