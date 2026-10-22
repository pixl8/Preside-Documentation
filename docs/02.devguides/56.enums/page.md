---
id: enums
title: Enums
---

## Overview

An enum is a named, ordered list of string keys. Stored values are those keys. There is no mapping to integers.

The same enum is used by preside object properties, form controls and the `enum` validator. It does not matter whether the enum was declared in configuration or registered at application startup.

## Defining a fixed enum

Fixed lists are declared in `Config.cfc`. The array order is the display order:

```luceescript
settings.enum = {};
settings.enum.redirectType                = [ "301", "302" ];
settings.enum.pageAccessRestriction       = [ "inherit", "none", "full", "partial" ];
settings.enum.pageIframeAccessRestriction = [ "inherit", "block", "sameorigin", "allow" ];
```

Labels, and optional descriptions and icon classes, live in `/i18n/enum/{enumId}.properties`. Each key is a prefix:

```properties
# /i18n/enum/redirectType.properties
301.label=301 Moved Permanently
301.description=A 301 redirect indicates that the resource has been *permanently* moved to the new location. This is particularly important to use for moved content as it instructs search engines to index the new location, potentially without losing any SEO rankings. Browsers will aggressively cache these redirects to avoid wasted calls to a URL that it has been told is moved.

302.label=302 Found (Temporary redirect)
302.description=A 302 redirect indicates that the resource has been *temporarily* moved to the new location. Use this only when you know that you will/might reinstate the original source URL at some point in time.
```

The default translation URI for a property of a key is `enum.{enum}:{key}.{property}`. So `301.label` above is `enum.redirectType:301.label`.

## Using an enum

### Preside object properties

A property with an `enum` attribute is limited to the keys of that enum, and the `enum` validator enforces it. The database column stores the key as a plain string.

```luceescript
property name="redirect_type" type="string" dbtype="varchar" maxlength=3 enum="redirectType";
```

See [[dataobjects]] for the full property attribute list.

This also defaults the renderer for the property to the `enum` renderer which will show label and optional icon for the enum.

### Form controls

* [[formcontrol-enumSelect]] renders a select box of the enum's keys, labelled with `label`.
* The enum radio list control renders each key with its `label` and `description`. Set `multiple="true"` to allow several keys. Both reference pages currently share the id `formcontrol-enumSelect`.

```xml
<field name="redirect_type" control="enumSelect"    enum="redirectType" />
<field name="experiments"   control="enumRadioList" enum="labsExperiment" multiple="true" />
```

The `enum` argument is any enum from this guide, whether it was declared in `settings.enum` or registered at startup.

### Reading labels in code

`enumService` resolves labels through the same translation URIs the form controls use:

* `listItems( enum )` returns the keys in display order, each as a struct with `id`, `label` and `description`.
* `getLabelByKey( enum, key )` returns the translated label.
* `translate( enum, key, property )` returns any translated property. For `label`, a missing resource falls back to the key itself. For any other property it falls back to an empty string.

## Dynamic registering an enum at startup

>>> Available from **Preside 10.31**

Use `enumService.registerEnum()` when the keys are not known while `Config.cfc` is running. Typical cases are the list of preside objects, page types, [[labs|Labs]] experiments and data export templates; any arbitrary code system that might benefit from enum renderers and form controls.

```luceescript
enumService.registerEnum(
      enum         = "presideobjects"
    , keys         = objectNames
    , translations = {
          label       = "preside-objects.{key}:title"
        , iconClass   = "preside-objects.{key}:iconClass"
        , description = "preside-objects.{key}:description"
      }
);
```

`registerEnum()` replaces that enum's keys and its translation map. `keys` is the display order.

`translations` maps a property name (`label`, `description`, `iconClass`, or any other name you later pass to `translate()`) to an i18n URI template. `{key}` and `{enum}` in the template are replaced for each item. A property with no template uses the default URI, `enum.{enum}:{key}.{property}`, which is the same `/i18n/enum/{enum}.properties` file a fixed enum uses.

Call it once per application start, after the data the keys come from is available. Core registers its dynamic enums from `General._configureVariousServices()`. The `onApplicationStart` interception point is announced after that, so an interceptor on `onApplicationStart` is the place for an application or extension to register its own.

The [[labs]] framework registers a `labsExperiment` enum this way. Its templates are `labs:{key}.title` and `labs:{key}.description`, which is why each experiment's copy lives in `/i18n/labs.properties`.
