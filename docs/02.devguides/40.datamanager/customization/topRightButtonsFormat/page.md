---
id: datamanager-customization-toprightbuttonsformat
title: "Reference: Data Manager top right buttons array"
---

## Reference: Data Manager top right buttons array

Several [[customizingdatamanager|Data Manager customizations]] allow you modify the top right buttons that appear for a particular screen in the Data Manager. These modififications expect to either return an array of structs and/or strings, or are passed this array of structs/strings for modification / appending to.

### Keys

Each "action" struct can/must have the following keys:

* `title` _(required)_: Title/label to display on the button.
* `link` _(optional)_: Required when there are no child actions.
* `btnClass` _(optional)_: Twitter bootstrap button class for the button. e.g. `btn-success`, `btn-danger`, etc.
* `iconClass` _(optional)_: Font awesome icon class to use. Icon will be displayed before the title.
* `globalKey` _(optional)_: Global keyboard key shortcut for the button.
* `prompt` _(optional)_: Prompt for the action should you want a modal dialog to appear to confirm the action.
* `target` _(optional)_: e.g. "\_blank" to have the button link open in a new tab.
* `children` _(optional)_: Array of child actions that will appear in a drop-down menu on button click.

>>> Note: alternatively, a button in the array can be a fully rendered string representing the button (should you require something a bit different)

### Children

If you wish your button to be a drop down menu, use the `children` array. Each item in the array is a struct with the following possible keys:

* `title` _(required)_: Title/label for the item
* `link` _(required)_: Link of the item
* `target` _(optional)_: Optional link target, e.g. "\_blank" to open in a new tab
* `icon` _(optional)_: Font awesome icon class for the item. Icon will appear before the title

### Examples

A minimal button item:

```luceescript
{
      link      = event.buildAdminLink( objectName=objectName, operation="preview" )
    , title     = translateResource( "preside-objects.blog:preview.btn" )
    , iconClass = "fa-eye"
}
```

A button with children:

```luceescript
{
      title     = translateResource( "preside-objects.blog:options.btn" )
    , iconClass = "fa-wrench"
    , children  = [
          { title="Stats"   , link=statsLink   , icon="fa-bar-chart" }
        , { title="Download", link=downloadLink, icon="fa-download"  }
      ]
}
```