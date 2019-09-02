---
id: config
title: Configuring Preside
---

## Introduction

Preside is a Coldbox application. Configuration is performed in the same way as a Coldbox application. A Preside application's root configuration directory is located at `/application/config/` and will contain, at a mininum, a `Config.cfc` file. It may additionally contain `Wirebox.cfc`, `Cachebox.cfc` and `Routes.cfm` files (all standard Coldbox configuration files).

## Config.cfc

Your application's `Config.cfc` should extend Preside's Config and ensure the `super.configure()` method is called before any of your site's configuration is made:


```luceescript
// /application/config/Config.cfc
component extends="preside.system.config.Config" {

	public void function configure() {
		super.configure();

		// your settings here
	}

	// ...
}
```

### Coldbox settings

You may override any Coldbox settings in your `Config.cfc`. For a full reference of Coldbox configuration, see: [Coldbox Config CFC Documentation](https://coldbox.ortusbooks.com/getting-started/configuration/coldbox.cfc). However, be sure to check Preside's `/system/config/Config.cfc` for any settings made there and be sure to know what you're doing before changing anything set there!

>>> In Coldbox 4.0, the file was renamed to `Coldbox.cfc`. However, for backward compatibility, we continue to use `Config.cfc`.

### TODO Lots more documentation of Config.cfc!

### TODO Cachebox.cfc

### TODO Wirebox.cfc

### TODO Routes.cfm

## Injecting Environment variables

Environment variables can be made available to Preside in two ways. **In each instance**, the environment variables will be available to you in the struct: `settings.injectedConfig`. For example, if a variable 'fu=bar' was injected, you would be able to access and use it with:

```
settings.fu = settings.injectedConfig.fu;
```

### Method one: Environment file

Supply a json file at `/application/config/.injectedConfiguration` that contains any settings that you wish to inject. For example:

```json
{
	  "syncDb"         : false
	, "forceSsl"       : true
	, "allowedDomains" : "www.mysite.com,api.mysite.com"
}
```

### Method two: OS environment vars

Any operating system environment variables that are prefixed with `PRESIDE_` will automatically be available in your `settings.injectedConfig` struct. For example, you may have the following environment vars available to your server/container:

```
PRESIDE_syncDb=false
PRESIDE_forceSsl=true
PRESIDE_allowedDomains=www.mysite.com,api.mysite.com
```

These would be available in your application + Config.cfc as (i.e. the `PRESIDE_` prefix is stripped):

```luceescript
settings.injectedConfig = {
	  syncDb         = false
	, forceSsl       = true
	, allowedDomains = "www.mysite.com,api.mysite.com"
};
```
