---
id: 10-9-upgrade-notes
title: Upgrade notes for 10.8 -> 10.9
---

## General notes

The 10.9 release has a small number of changes that require special consideration for upgrade:

* Coldbox 4
* Admin interfaces that have been built with the "crudadmin" tool


## Coldbox 4

Preside 10.9 upgrades to Coldbox 4 which has some backward compatibility issues. We have provided backward compatible workarounds/polyfills for as much as possible but a single compatibility issue remains to do with `Async` log appenders in logbox. These appenders were removed from the coldbox codebase in favour of configuring the non-async appenders with an `async=true` flag and we cannot reasonably produce a workaround for this. If your applications and extensions are using any `Async` log appenders, they will need changing. For example:

*old Config.cfc*
```luceescript
config.logbox.appenders.syncAppender = {
	  class      = 'coldbox.system.logging.appenders.AsyncRollingFileAppender'
	, properties = { filePath=logsMapping, filename="sync.log" }
}
```

*upgraded Config.cfc*
```luceescript
var coldboxMajorVersion = Val( ListFirst( settings.coldboxVersion ?: "", "." ) );

if ( coldboxMajorVersion < 4 ) {
	config.logbox.appenders.syncAppender = {
		  class      = 'coldbox.system.logging.appenders.AsyncRollingFileAppender'
		, properties = { filePath=logsMapping, filename="sync.log" }
	}
} else {
	config.logbox.appenders.syncAppender = {
		  class      = 'coldbox.system.logging.appenders.RollingFileAppender'
		, properties = { filePath=logsMapping, filename="sync.log", async=true }
	}
}
```

## Admin interfaces that have been built with the "crudadmin" tool

This objects would required to add attributes:
```
@datamanagerEnabled          true
```
This is to ensure that all new custom functions added to Data Manager would still work correctly.
