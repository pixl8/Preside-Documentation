---
id: admingritternotifications
title: "Configuring admin 'gritter' notifications"
---

## Introduction

Gritter notifications appear in the admin after successful inserting, saving and deleting of records, or when an error happens. Up until Preside 10.11.0, these notifications appeared at the top right hand side of the admin UI and this was not configurable.

As of Preside 10.11.0, the default position of these notifications is at the bottom right hand side of the screen and two new configuration options were added that you can set in your application or extension's `Config.cfc$configure()` method:


```luceescript
component {
    
    function configure() {
        // ...
        settings.adminNotificationsSticky    = true;           // default
        settings.adminNotificationsPosition  = "bottom-right"; // default
        // ...
    }
}
```

**Sticky** notifications require the user to dismiss the notification before it disappears (default). If set to false, the notification will disappear after some time.

Valid positions for the `adminNotificationsPosition` setting are:

* `top-left`
* `top-right`
* `bottom-left`
* `bottom-right` (default)