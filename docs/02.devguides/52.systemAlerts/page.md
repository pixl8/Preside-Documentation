---
id: systemalerts
title: System Alerts
---

## Overview

Introduced in **10.20.0**, System Alerts ...

## Implementation



### Anatomy of a system alert handler

System Alert handlers are stored by convention in the `admin.systemAlerts` directory, and are discovered automatically.

At its most basic, a system alert handler will contain a `runCheck()` method. This will be called either via automation, or manually in code (see below).

The method is passed `systemAlertCheck` object as the `check` argument, which has various methods and properties, and which will receive the outcome of any tests. If the object is told to fail, then a system alert will be raised. Additional supporting data may also be stored with the system alert.

It may also be passed a `reference` argument, which is a string to identify a particular record or other thing that the check can be run against (so the same check can be run for multiple instances).

A handler should also have (but does not require) a `render()` method. This viewlet receives as its `args` the record data of a system alert and should respond with a rendered description of the alert. It may explain exactly what the error is, suggest how to resolve it, and even provide a link to go directly to the appropriate part of the application.

### Configuring the handler

Configuration is done via a number of optional methods:

`defaultLevel()` should return a string, denoting the default severity of an alert raised by the handler. This can be one of `critical`, `warning` or `advisory` (in decreasing order of severity). The default is `warning`. Ths default can be overridden by calling `setLevel()` on the `systemAlertCheck` object.

`context()` should return a string, denoting the area of the application for which the alert is relevant. If not specified, the system alert will relate to the application as a whole.

`runAtStartup()` should return a boolean, and if true the check will run every time the application starts up.

`watchSettingsCategories()` should return an array of one or more strings, each of which is a system settings category. When settings in any of the listed categories are saved, the check will be run.

`schedule()` should return a string, which should be a valid crontab expression. The check will be run regularly according to this schedule.

`references()` should return an array of reference values, which will be passed in turn to the `runCheck()` function to run multiple checks. This will be done IF the `references()` method is defined AND the `runCheck()` method is called without otherwise specifying a reference. So, as an example, the method might return an array of IDs of all events set to take place in the future, and the check can then be run against each in turn.

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