---
id: datamanager-customization-prelayoutrender
title: "Data Manager customization: preLayoutRender"
---

## Data Manager customization: preLayoutRender

The `preLayoutRender` customization allows you fire off code just before the full admin page layout is rendered for a Data manager based page. The customization is **not** expected to return a value and can be used to set variables that effect the layout such as `prc.pageTitle`, `prc.pageIcon` and the breadcrumbs for the request.

In addition to this global customization, you can also implement customizations with the convention `preLayoutRenderFor{actionName}`, where `{actionName}` is the name of the current data manager action. For example `preLayoutRenderForViewRecord`.

The following attributes are available in the `args` struct but examining the `prc` scope is also useful for getting at already generated content such as `prc.record`, `prc.recordLabel`, etc.

* `objectName`: the name of the object
* `action`: the current coldbox action, e.g. `editRecord`, `viewRecord`, `object`, etc.


For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

    private void function preLayoutRender( event, rc, prc, args={} ) {
        prc.pageTitle = translateResource(
              uri          = "preside-objects.blog:#args.action#.page.title"
            , defaultValue = prc.pageTitle ?: ""
        );
    }

    private void function preLayoutRenderForEditRecord( event, rc, prc, args={} ) {
        prc.pageTitle = translateResource(
              uri  = "preside-objects.blog:editRecord.page.title"
            , data = [ prc.recordLabel ?: "" ]
        );

        // modify the title of the last breadcrumb
        var breadCrumbs = event.getAdminBreadCrumbs();
        breadCrumbs[ breadCrumbs.len() ].title = prc.pageTitle;
    }
}
```