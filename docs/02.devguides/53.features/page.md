---
id: features
title: Feature flagging
---

## Overview

Preside has a concept of feature flags that can be used to turn on and off various features of the core platform and of your extensions. It is important to note, that these are designed to be specified **in code**  and effect the fundamental makeup of your application including its database structure. They are **not** feature flags that can be turned on and off for a running application.

## Definition

Feature flags are defined in your application/extension's `Config.cfc` file in a `settings.features` struct. The keys of this struct are the IDs of the feature flags. Each feature flag value is a structure with the following keys:

```luceescript
settings.features.myfeature = {
    enabled       = true                     // the only required key, whether or not the feature is enabled
  , dependsOn     = [ "featurex" ]           // as of Preside 10.27, features can depend on other features. If any parent is disabled, this feature will be disabled
  , widgets       = [ "widgetx", "widgety" ] // an array of widget IDs that should only be available when this feature is enabled
  , siteTemplates = [ "*" ]                  // if using site templates, can specify which site templates have this feature enabled
};
```

## Disabling/enabling a feature

If Preside core, or any extension defines a feature that you would like to override, then you will need to override the enabled property for that feature in your _application's_ Config.cfc file. e.g.

```luceescript
settings.features.admin.enabled        = false;
settings.features.websiteUsers.enabled = false;

settings.features.somneExtensionFeature.enabled  = true;
```

## Checking whether or not a feature is enabled

From handlers and views, Preside offers a helper function, `isFeatureEnabled( feature )`. In services that make use of the [[presidesuperclass]], you have a `$isFeatureEnabled( feature )` helper. Examples:

```luceescript
// in a handler or view
if ( isFeatureEnabled( "myFeature"  ) ) {
  // something
}

// in a service
if ( $isFeatureEnabled( "myCoolFeature" ) ) {
  // something
}

// as of Preside 10.26
if ( isFeatureEnabled( "feature1 or ( feature2 and feature3 )" ) ) {
  // something
}
```

## Limiting functionality using features

The general approach to applying feature flags is to decorate your code with `@feature` annotations. Depending on the source code file type, the way you annotate will differ. The core Preside platform allows you to flag the following resource types:

* Preside objects
* Preside object properties
* Forms, tabs, fieldsets and fields
* Widgets
* Handlers (as of Preside 10.27)
* Views (as of Preside 10.27)
* Services (as of Preside 10.27)

_Note: Various extensions may also use their own feature flagging approaches to their resources._

### Preside objects & their properties

To feature flag a Preside object, annotate the `component` directive with either of the following approaches:

```luceescript
/**
 * Approach one. Using @ in javadoc style block
 *
 * @feature somefeature
 */
component {
  // ...
}
```

```luceescript
component feature="approach2Feature" {
  // ...
}
```

Feature flagging properties is a case of adding a `feature` attribute to the property:


```luceescript
component {
  property name="asset" relationship="many-to-one" relatedto="asset" feature="assetManager";
}
```

### Forms, tabs, fieldsets and fields

Documentation for feature flagging forms can be found here: [[presideforms-features]]. In essence, however, you can add `feature` attributes to the `form`, `tab`, `fieldset` and `field` elements:

```xml
<form feature="myfeature">
  <tab id="tab1" feature="myfeaturex">
    <fieldset id="fs1" feature="myfeaturey">
      <field name="somefield" feature="myfeaturez" />
      <!-- ... -->
    </fieldset>
    <!-- ... -->
  </tab>
  <!-- ... -->
</form>
```

### Widgets

Due to widgets being definable in multiple ways, widgets must be specified in the feature flag struct in Config.cfc. i.e.

```luceescript
settings.features.someFeature = { enabled=true, widgets=[ "widget1", "widget3" ] };
```

Note: if you want to add a widget to a feature that is defined elsewhere, you should use something like the following approach:

```luceescript
// ensure widgets array exists and then *append* to it
// rather than overwriting it completely which may destroy existing
// feature widget definitions
settings.features.featurex.widgets = settings.features.featurex.widgets ?: [];
ArrayAppend( settings.features.featurex.widgets, "my-new-widget" );
```

### Handlers & services

As of Preside 10.27, handlers and services may be feature flagged. If the feature is disabled, the service/handler will then not be enabled. The benefit of this, is that handlers and services will not be loaded into memory if their feature flag is disabled. Annotating a handler CFC is the same as annotating a preside object, i.e.

```luceescript
/**
 * Approach 1, javadoc comment style
 *
 * @feature        someFeature || anotherfeature
 * @presideservice true
 * @singletone
 */
component {
  // ...
}
```

Or:

```luceescript
component feature="someFeature || anotherfeature" {
  // ...
}
```

#### Wirebox injections

If you have a service that depends on another service that is feature flagged, you may use the `featureInjection` dsl to avoid issues. For example:


```luceescript
/**
 * @singleton      true
 * @presideService true
 */
component {

  // featureInjection allows injection of a singleton without
  // any errors when the feature is disabled
  property name="aFeatureSpecificService" inject="featureInjection:myfeature:AFeatureSpecificService";

  // ...
  function someFunction() {
    // always do a feature check before attempting
    // to use the service - otherwise you will get errors
    // when the feature is not enabled and the service does not exist
    if ( $isFeatureEnabled( "myFeature" ) ) {
      aFeatureSpecificService.doSomething();
    }
  }


}
```

### Views

As of Preside 10.27, a view may be feature flagged. This has the benefit of avoiding loading the view into memory when it is not used. To feature flag a view **the first line** of the `.cfm` file must add an annotation in the following form:

```lucee
<!---@feature myFeature--->
```

## .presideIgnore.json file

As of Preside 10.27, you may find that you have a `.presideIgnore.json` file in the root of your project. This file is used by Preside in production to ignore files that are feature flagged with features that are disabled. This avoids the system ever having to read the files and can be a useful strategy to improve startup times and resource usage of your applications when running with a lot of disabled features.

### Controlling use of the feature

By _default_, the application will **write** to this file in local mode and **read** from the file in production mode. This allows you to optimize production and have your local development environment maintain the content of the file.

To control this feature, use the following in your application's Config.cfc file:

```luceescript
// local mode
settings.ignoreFile.read  = false;
settings.ignoreFile.write = true;

// production mode
settings.ignoreFile.read  = true;
settings.ignoreFile.write = false;

// completely disabled
settings.ignoreFile.read  = false;
settings.ignoreFile.write = false;
```

### Strategy for use

If using this feature, you should have your application run with "local mode" at least once to generate the ignore file **before** the code makes it to production. This could be simply running the application locally in your production branch and committing the resultant `.presideIgnore.json` file, or having this run as a warmup routine in a docker build in a pipeline or similar.

If in doubt and experiencing issues with this feature, you are perfectly safe to disable it.