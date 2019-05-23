---
id: fullpagecaching
title: Full page caching
---

## Introduction

In Preside 10.9.0, we introduced the concept of **full page caching**. This allows the caching of whole pages based on their URL and whether or not a user is logged in.

One of the problems faced with this heavy-handed caching is that you often have regions in the page that should not be cached, such as user names and other private details. Preside offers a solution to this in the form of "**delayed viewlets**". These are viewlets that are marked as non cacheable and are rendered _after_ the whole page layout has been fetched from cache.

## Enabling the feature

The feature is disabled by default. To enable, add the following to your Config.cfc file:

```
settings.features.fullPageCaching.enabled = true;
```

By default, this will cache _everything_ except:

* Conditional content widgets
* System page types (just the body of the page type will not be cached, the layout around it will be)
* Permissions checking for pages with access restrictions
* Navigational menu items that are shown conditionally (see below)

Each page will potentially have two cached entries - one for logged in users and one for anonymous visitors.

## Configuration

The following additional settings are available as of **10.11.0** (the default preside settings are show below):

```luceescript
// whether or not to limit  data cached with
// each page to a specified list of keys (below)
settings.fullPageCaching.limitCacheData = false;

// when limitCacheData = true allowed list 
// of keys in rc scope that will be cached
settings.fullPageCaching.limitCacheDataKeys.rc = [];

// when limitCacheData = true allowed list 
// of keys in prc scope that will be cached
settings.fullPageCaching.limitCacheDataKeys.prc = [ "_site", "presidePage", "__presideInlineJs", "_presideUrlPath", "currentLayout", "currentView", "slug", "viewModule" ];
};
```

>>> Recommendation: always set `settings.settings.fullPageCaching.limitCacheData = true` and cache as little data from `prc` scope as possible. This will limit the memory requirements of the cache which otherwise can grow large depending on your application.

>>> The settings above control the variables that are available to any **delayed (non-cacheable) viewlets**, so try to make those viewlets rely on as little outside data as possible.

## Auto non-cacheable viewlets

To mark a `viewlet` as not being cacheable, add the `@cacheable false` annotation to the viewlet's handler:

```
/**
 * @cacheable false
 */
private string function myViewlet( ... ) {
// ...
}
```

## Navigation menus

If you are overriding the views for the core navigation viewlets, you may want to add the following lines to your views so that menu items that have conditional access rules are not cached:

```
<cfloop array="#menuItems#" index="i" item="item">
	<cfif IsTrue( item.hasRestrictions ?: "" )>
		#renderViewlet(
			  event   = "core.navigation.restrictedMenuItem"
			, args    = { menuItem=item, view="/core/navigation/mainNavigation" }
			, delayed = IsTrue( args.delayRestricted ?: true )
		)#
		<cfcontinue />
	</cfif>
	<!-- ... -->
```

## Explicit delayed viewlet render

Add `delayed=true` to `renderViewlet()` to explicitly render a viewlet that will not be included in the full page cache (it will get rendered after the rest of the page).

```
#event.renderViewlet( event="my.event", args=viewletArgs, delayed=true )#
```

## Request context helpers

```
event.cachePage(); // returns true/false for whether the page is going to be cached
event.cachePage( false ); // instruct the system that this page should not be cached
event.setPageCacheTimeout( 24000 ); // set a non-default cache timeout for the cache
```

## Configuring the cache store

We are using cachebox to configure caches. The cache used for full page caching is named `PresidePageCache` and looks like this right now:

```
PresidePageCache = {
	  provider   = "preside.system.coldboxModifications.cachebox.CacheProvider"
	, properties = {
		  objectDefaultTimeout           = 1200
		, objectDefaultLastAccessTimeout = 0
		, useLastAccessTimeouts          = false
		, reapFrequency                  = 20
		, freeMemoryPercentageThreshold  = 0
		, evictionPolicy                 = "LFU"
		, evictCount                     = 200
		, maxObjects                     = 2000
		, objectStore                    = "ConcurrentSoftReferenceStore"
	}
}
```

You can override this configuration in your application by adding `/application/config/Cachebox.cfc` and tweaking the setting you want to tweak. For example, to change the `maxObject` and `defaultTimeout`:

```
component extends="preside.system.config.Cachebox" {
	function configure(){
		super.configure( argumentCollection=arguments );

		cacheBox.caches.PresidePageCache.properties.maxObjects           = 50000;
		cacheBox.caches.PresidePageCache.properties.objectDefaultTimeout = 60 * 60; // 1hr
	}
}
```

## Considerations

Obviously, if your site has a login functionality and displays personal information in pages to the logged in user - you need to ensure that these parts of the page are _not_ cached. Use either the `renderViewlet( ..., delayed=true )` technique, and/or, mark your personal info/non-cacheable viewlets with `@cacheable false`. The fact that system page types are _not_ cached by default should help with this also.