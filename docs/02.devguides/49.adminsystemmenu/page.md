---
id: adminsystemmenu
title: Modifying the administrator system menu
---

## Overview

Preside provides a simple mechanism for configuring the "System" menu of the admin interface, either to add new main navigational items, take existing ones away or to modify the order of menu items.

## Configuration

Each item of the menu is stored in an array that is set in `settings.adminConfigurationMenuItems` in `Config.cfc`. The core implementation looks like this:

```luceescript
component {

    public void function configure() {

        // ... other settings ...

        settings.adminConfigurationMenuItems = [
              "usermanager"
            , "notification"
            , "passwordPolicyManager"
            , "systemConfiguration"
            , "rulesEngine"
            , "links"
            , "urlRedirects"
            , "errorLogs"
            , "auditTrail"
            , "maintenanceMode"
            , "taskmanager"
            , "savedexport"
            , "apiManager"
            , "systemInformation"
        ];

        // ... other settings ...

    }
}
```

## Menu items

As of **10.17.0** each menu item should have a corresponding entry in the `settings.adminMenuItems` struct.

See [[adminmenuitems]] for documentation on specificying a menu item.

### Pre 10.17.0 implementation (still supported)

Prior to 10.17.0, all menu items are then implemented as a view that lives under a `/views/admin/layout/configurationMenu/` folder. For example, for the 'errorLogs' item, there existed a view at `/views/admin/layout/configurationMenu/errorLogs.cfm` that looked like this:

```lucee
<!--- /views/admin/layout/configurationMenu/errorLogs.cfm --->

<cfif ( isFeatureEnabled( "errorlogs" ) && hasCmsPermission( "errorlogs.navigate" ) )>
    <cfoutput>
        <li>
            <a href="#event.buildAdminLink( linkTo="errorlogs" )#">
                <i class="fa fa-fw fa-exclamation-circle"></i>
                #translateResource( 'cms:errorlogs' )#
            </a>
        </li>
    </cfoutput>
</cfif>
```

## Formatting

Each item in the list should fit in a Twitter Bootstrap 3 drop down menu and should render its own `<li>` element. We recommend the following markup for consistency:

```html
<li>
    <a href="#"> <!-- a real link -->
        <i class="fa fa-fw fa-your-icon"></i>
        Title of item
    </a>
</li>
```