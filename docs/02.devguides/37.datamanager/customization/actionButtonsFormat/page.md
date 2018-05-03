---
id: datamanager-customization-actionbuttons
title: "Reference: Data Manager action buttons array for add and edit forms"
---

## Reference: Data Manager action buttons array for add and edit forms

The add and edit record forms allow you modify the action button set that appear beneath the form. These modififications expect to either return an array of structs, or are passed this array of structs for modification / appending to.

### Keys

Each "action" struct can/must have the following keys:

* `type` _(required)_: Must be either 'link' or 'button'
* `label` _(required)_: Label to show on the button
* `href` _(optional)_: Required  when `type=link` - href of the link
* `name` _(optional)_: For `type=button` only. Name of the field that is sent with the form submission.
* `value` _(optional)_: For `type=button` only. Value of the field that is sent with the form submission.
* `class` _(optional)_: Twitter bootstrap button class for the button. e.g. `btn-info`, `btn-warning`, `btn-success`, `btn-danger`, etc.
* `iconClass` _(optional)_: Font awesome icon class to use. Icon will be displayed before the label on the button.
* `globalKey` _(optional)_: Global keyboard key shortcut for the button.

### Examples

A link button

```luceescript
{
      type      = "link"
    , href      = event.buildAdminLink( objectName=objectName, operation="preview" )
    , class     = "btn-info"
    , label     = translateResource( "preside-objects.blog:preview.btn" )
    , iconClass = "fa-eye"
}
```

A regular button:

```luceescript
{
      type      = "button"
    , name      = "_postAction"
    , value     = "saveDraftAndPreview"
    , class     = "btn-info"
    , label     = translateResource( "preside-objects.blog:preview.btn" )
    , iconClass = "fa-eye"
}
```