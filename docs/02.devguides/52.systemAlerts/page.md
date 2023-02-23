---
id: systemalerts
title: System Alerts
---

## Overview

System alerts were introduced in Preside **10.20** and allow developers to alert users of the admin system to problems that require resolving. For example, when there is missing system config such as the "Default from email address" that will lead to errors with the full working of the system.

Developers register alerts by providing a convention based handler with an accompanying i18n properties file.

## Implementation

### The system alert handler

System Alert handlers are stored by convention in the `admin.systemAlerts` directory, and are discovered automatically. For example, if I wish to create a "checkDataMappings" alert, I would create a handler file at `/handlers/admin/systemAlerts/CheckDataMappings.cfc`.

The following is a self-documenting example of a system alert handler:

```luceescript
component {

  /**
   * Required. The runCheck( check ) method is used to perform your health
   * check. Use the passed `check` object to report failure or success
   */
  private void function runCheck( required systemAlertCheck check ) {
    var type      = check.getType(); // optional
    var reference = check.getReference(); // optional, used for context specific checks

    if ( _someLogicFails( reference ) ) {
      check.fail(); // required to mark as failed
      check.setLevel( "critical" ); // not required
      check.setData( { customData="canBeAdded" } ); // not required
    } else {
      check.pass();
    }
  }

  /**
   * Optional, but recommended. Renders the alert in the admin
   * Should provide detail for the user about how to resolve the
   * issue
   *
   * args struct contains any data passed to check.setData() in runCheck
   */
  private string function render( event, rc, prc, args={} ) {
    return renderView( view="/admin/systemAlerts/myAlert/render", args=args );
  }


// CONFIG SETTINGS
  /**
   * Optional. Implement this method and return true to have the check run at startup
   *
   */
  private boolean function runAtStartup() {
    return true;
  }

  /**
   * Optional. Implement this method to have your check run on a schedule.
   * Must return a valid 6 point cron expression.
   *
   */
  private string function schedule() {
    return "0 0 */2 * * *"; // every two hours
  }

  /**
   * Optional. Implement this method to return an array of system category settings
   * to watch. If the settings change, then the check is run.
   *
   */
  private array function watchSettingsCategories() {
    return [ "email" ];
  }

  /**
   * Optional (default is warning). Implement this method to set
   * the default level of alert for all alerts raised using this check
   *
   */
  private string function defaultLevel() {
    return "info";
  }

  /**
   * Optional (default to empty, meaning 'global'). should return
   * a string, denoting the area of the application for which the
   * alert is relevant. If not specified, the system alert will
   * relate to the application as a whole.
   */
  private string function context() {
    return "events";
  }

  /**
   * Optional. should return an array of reference values, which
   * will be passed in turn to the `runCheck()` function to run
   * multiple checks. This will be done IF the `references()` method
   * is defined AND the `runCheck()` method is called without otherwise
   * specifying a reference. So, as an example, the method might return
   * an array of IDs of all events set to take place in the future, and
   * the check can then be run against each in turn.
   *
   */
  private array function references(){
    return _getEventIdsToCheckForGlobalRecheck();
  }

}
```

### i18n properties file

In addition to the handler, you should supply a `.properties` file to match at `/i18n/systemAlerts/{alertName}.properties`. It is only required to provide a title key (but you can use the file to provide any additional text for your alert rendering). For example:

```properties
# /i18n/systemAlerts/eventSetup.properties
title=Event setup
```


## Running a check

Aside from running checks automatically, they may also be called programmatically with the `runSystemAlertCheck()` helper method or `$runSystemAlertCheck()` superclass method, which proxy to the [[systemalertsservice-runcheck]] method of the [[api-systemalertsservice]].

The first argument, `type`, is required and is the handler name of the system alert.

The second argument, `reference` is optional. If a check specifies a `references()` method, then omitting this argument will run the check against all of those references.

The third argument, `async`, is a boolean that defaults to true. If true, the check will be run asynchronously in the background; if false, it will run immediately.

If being run globally or against a single reference, the return value is the resulting `systemAlertCheck` object, to help you provide feedback to the user (any alert will have been raised or cleared automatically by the function). Otherwise, null is returned.

## The systemAlertCheck object

For each check that is run, a `systemAlertCheck` object is instantiated and passed into the `runCheck()` method. It is initialised with the type of the system alert, the default level, and any reference that was passed in.

You may call the following methods to update its status:

- `setLevel( string )`: one of `critical`, `warning` or `advisory`
- `setData( struct )`: any useful data to be stored with a raised alert, useful for rendering a message later
- `pass()` or `fail()`: sets whether the check passes or fails

You can retrieve data from the object with the following methods:

- `getType()`
- `getReference()`
- `getLevel()`
- `getData()`
- `passes()` and `fails()`: booleans denoting the current passing state of the check

These methods should be used to manipulate the check object when running a check. Based on the result passed back to the service, an alert will either be raised or cleared.