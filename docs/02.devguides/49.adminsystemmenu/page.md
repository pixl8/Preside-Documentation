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

Each of these menu items is then implemented as a view that lives under a `/views/admin/layout/configurationMenu/` folder. For example, for the 'errorLogs' item, there exists a view at `/views/admin/layout/configurationMenu/errorLogs.cfm` that looks like this:

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