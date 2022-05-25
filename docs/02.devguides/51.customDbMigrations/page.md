---
id: customdbmigrations
title: Database Migrations
---

## Overview

Since the first release, Preside has supported automatic **schema** synchronisation with your Preside Object data model. It has also supported core Preside system data migrations for a long time. Now, as of **10.18.0**, Preside also supplies a straightforward framework for application and extension developers to supply their own one time data migration scripts.

## Implementation

The implementation involves developers supplying a convention-based coldbox handler with either `run()` or `runAsync()` methods that perform any database data migrations necessary with normal Preside/Coldbox code. The convention is `/handlers/dbmigrations/yourmigrationid.cfc`.

Any migrations are run in **name** order. It is recommended therefore that you name your migration handlers in a sensible order friendly way. For example, using the date of handler creation as a prefix.

### Example

```cfc
/**
 * Handler at /handlers/dbmigrations/2022-05-25_defaultEventModes.cfc
 *
 */
component {

	private void function run() {
		getPresideObject( "my_object" ).updateData(
			  filter = "my_new_flag is null"
			, data = { my_new_flag = true }
		);
	}

}
```

### Synchronous vs Asynchronous running

When you implement a `run()` method, your logic will run during application startup and application startup will not be complete until the migration completes. This is important for **critical** migrations where the application's data **must** be updated in order for correct operation of the application.

If your migration is not essential to the running of the application, you may wish to implement a `runAsync()` method instead. These migrations will be run in a background thread approximately 1 minute after application startup. Great for slow, non-essential migrations.

Both methods operate and are called in exactly the same way. Neither method receives any arguments other than core coldbox `event`, `rc` and `prc`.