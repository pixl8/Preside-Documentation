---
id: datamanager-customization-multi-action-buttons
title: "Data Manager customization: Multi-action button definitions"
---

## Data Manager customization: Multi-action button definitions

The record listing screen allows you modify the action button set that appear beneath the listing table when a user selects one or more records in the table. See:

* [[datamanager-customization-listingmultiactions|listingMultiActions]]
* [[datamanager-customization-getlistingmultiactions|getListingMultiActions]]
* [[datamanager-customization-getextralistingmultiactions|getExtraListingMultiActions]]


These modififications expect to either return an array of structs and/or strings, or are passed this array of structs/strings for modification / appending to.

### Keys

Each "action" struct can/must have the following keys:

* `name` _(required)_: The name of the action
* `label` _(required)_: Label to show on the button
* `class` _(optional)_: Twitter bootstrap button class for the button. e.g. `btn-info`, `btn-warning`, `btn-success`, `btn-danger`, etc.
* `iconClass` _(optional)_: Font awesome icon class to use. Icon will be displayed before the label on the button.
* `globalKey` _(optional)_: Global keyboard key shortcut for the button.

>>> Note: alternatively, a button in the array can be a fully rendered string representing the button (should you require something a bit different)

### Example


```luceescript
{
      name      = "share"
    , class     = "btn-info"
    , label     = translateResource( "preside-objects.blog:preview.btn" )
    , iconClass = "fa-share"
    , globalKey = "s"
}
```