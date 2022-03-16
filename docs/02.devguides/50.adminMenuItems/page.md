---
id: adminmenuitems
title: Configuring admin menu items
---

## Introduction

As of Preside **10.17.0**, the main navigation sytem was updated to introduce a core concept of configured admin menu items.

These are implemented in the side bar navigation and in the System drop down menu in the top navigation. See [[adminlefthandmenu]] and [[adminsystemmenu]].

## Config.cfc implementation

Each named menu item, e.g. "sitetree", must be specified in the `settings.adminMenuItems` struct in your `Config.cfc` file. An entry takes the following form:

```luceescript
settings.adminMenuItems.sitetree = {
    feature       = "sitetree"                                // optional feature flag. Only show menu item when feature is enabled
  , permissionKey = "sitetree.navigate"                       // optional admin perm key. Only show menu item if current user has access
  , activeChecks  = { handlerPatterns="^admin\.sitetree\.*" } // see 'Active checks' below
  , buildLinkArgs = { linkTo="sitetree" }                     // Structure of args to send to event.buildAdminLink
  , gotoKey       = "s"                                       // Optional global shortcut key for the nav item
  , icon          = "fa-sitemap"                              // Optional fontawesome icon
  , title         = "cms:sitetree"                            // Optional i18n uri for the title
  , subMenuItems  = [ "item1", "item2" ]                      // Optional array of child menu items (each referring to another menu item)
};
```

### Reference

<div class="table-responsive">
    <table class="table table-condensed">
        <thead>
            <tr>
                <th>Key</th>
                <th>Default</th>
                <th>Description</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>feature</td>
                <td><em class="text-hint">empty</em></td>
                <td>Optional feature flag. Only show menu item when feature is enabled</td>
            </tr>
            <tr>
                <td>permissionKey</td>
                <td><em class="text-hint">empty</em></td>
                <td>Optional admin permission key. Only show menu item if current user has access</td>
            </tr>
            <tr>
                <td>activeChecks</td>
                <td><em class="text-hint">empty</em></td>
                <td>Optional struct describing common checks to make to decide whether or not the item is active in any given request</td>
            </tr>
            <tr>
                <td>buildLinkArgs</td>
                <td><em class="text-hint">empty</em></td>
                <td>Structure of args to send to `event.buildAdminLink()`</td>
            </tr>
            <tr>
                <td>gotoKey</td>
                <td><em class="text-hint">empty</em></td>
                <td>Optional global shortcut key for the nav item</td>
            </tr>
            <tr>
                <td>icon</td>
                <td><code>admin.menu:{menuItemName}.iconClass</code></td>
                <td>Font awesome icon class name, or i18n URI that translates to one</td>
            </tr>
            <tr>
                <td>title</td>
                <td><code>admin.menu:{menuItemName}.title</code></td>
                <td>Title of the menu item, or i18n URI that translates to the title</td>
            </tr>
            <tr>
                <td>subMenuItems</td>
                <td><em class="text-hint">empty</em></td>
                <td>Optional array of child menu items (each referring to another menu item)</td>
            </tr>
        </tbody>
    </table>
</div>

### Active checks structure

Two keys can be used in the `activeChecks` structure to instruct the system to make common checks for the active state of the menu item: `handlerPatterns` and `datamanagerObject`.

#### handlerPatterns

Specify either a plain string regex pattern to match the current handler event, or supply an array of patterns. e.g.

```luceescript
settings.adminMenuItems.myItem = {
    // ...
    activeChecks  = { handlerPatterns="^admin\.myhandler\.myaction" }
}

// or
settings.adminMenuItems.myItem = {
    // ...
    activeChecks  = { handlerPatterns=[ "^admin\.myhandler\.myaction", "^admin\.anotherhandler\." ] }
}
```

#### datamanagerObject

Specify either a single object name (string), or array of object names. When any datamanager page using the specified object(s) is viewed, the item will be considered active. e.g.

```luceescript
settings.adminMenuItems.myItem = {
    // ...
    activeChecks  = { datamanagerObject="my_object" }
}

// or
settings.adminMenuItems.myItem = {
    // ...
    activeChecks  = { datamanagerObject=[ "my_object", "my_object_two" ] }
}
```

## Extending with dynamic functionality

At times, you may wish to have more dynamic control over the behaviour of your items. In addition to any configuration set above, you may also create a convention based handler to extend the item's behaviour. Create the handler at `/handlers/admin/layout/menuitem/{nameOfYourItem}.cfc`. It can then implement any of the methods below:

```luceescript
component {

    /**
     * System will run this once in application life-time
     * to ascertain whether or not to include the menu item.
     * Useful for more complex feature combination checks.
     */
    private boolean function neverInclude( args={} ) {
        return false;
    }

    /**
     * Implement this method to run more complex logic
     * to decide whether or not the current user has
     * access to the menu item. 
     *
     */
    private boolean function includeForUser( args={} ) {
        return true;
    }

    /**
     * Implement this method to run more complex logic
     * to decide whether or not the item is active for
     * the current request
     *
     */
    private boolean function isActive( args={} ) {
        return false;
    }

    /**
     * Implement this method to run more complex
     * / dynamic logic for building the link to the item
     *
     */
    private string function buildLink( args={} ) {
        return "";
    }

    /**
     * Run this method to dynamically decorate
     * the item configuration structure (passed in as args)
     *
     */
    private void function prepare( args={} ) {
        var dynamicChildren = [ /* ... */ ];
        ArrayAppend( args.subMenuItems, dynamicChildren, true );
    }


}
```