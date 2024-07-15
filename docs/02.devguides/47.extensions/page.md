---
id: extensions
title: "Writing Extensions for Preside"
---

## Introduction

Extensions are a fundamental feature of Preside development that enable you to package and share Preside features with other developers and users.

You can find publicly available extensions on [Forgebox](https://forgebox.io/type/preside-extensions).

## Anatomy of an extension

Extensions live under the `/application/extensions` folder within your Preside application, each extension with its own folder, e.g.

_(as of Preside 10.27, you are also able to create extensions in an `/extensions_app`. Great for separating locally committed extensions for organising your application's code.)_

```
/application
    ...
    /extensions
        /my-extension-1
        /my-extension-2
        /my-extension-3
        ...
    /extensions_app
        /my-app-extension-1
        ...
```


Each extension can then contain *all of the valid convention-based folders that your application can contain*, i.e. `/handlers`, `/services`, `/i18n`, `/preside-objects`, etc.:

```
/my-extension-1
    /config
        Config.cfc
        Wirebox.cfc
        Cachebox.cfc
    /forms
        /preside-objects
            my_extension_object.xml
    /handlers
        MyExtensionHandler.cfc
    /i18n
        /preside-objects
            my_extension_object.properties
    /layouts
        MyExtensionLayout.cfm
    /preside-objects
        my_extension_object.cfc
    /services
        MyExtensionService.cfc
    box.json
    manifest.json
    ModuleConfig.cfc

```

### Extension metadata

#### manifest.json (required)

The `manifest.json` file is a Preside specific file that tells the system about your extension. It is a simple json object with five keys:

```json
{
      "id"        : "preside-ext-my-cool-extension"
    , "title"     : "My Cool Extension"
    , "author"    : "Pixl8 Group"
    , "version"   : "1.0.0+0001"
    , "dependsOn" : [ "preside-ext-another-cool-extension", "preside-ext-calendar-view" ]
}
```

* `id`: Extension ID / slug. Used to identify the extension to other extension's `dependsOn` directives
* `title`: A human readable title of the extension
* `author`: The author, e.g. you
* `version`: Current version
* `dependsOn`: An array of string extension IDs (optional). This informs Preside that your extension should be loaded AFTER any extensions listed here.

#### box.json (optional, recommended)

The `box.json` file is used by [CommandBox](https://www.duckduckgo.com/?q=CommandBox) package management to understand how to publish and install your extension. There are several key attributes that relate to Preside extensions and an additional section that is designed purely to handle Preside specific dependencies of your extension:

```json
{

    // important for Preside extensions
    "type":"preside-extensions",
    "directory":"application/extensions",

    // regular CommandBox package management meta
    "name":"PresideCMS Extension: Calendar View",
    "slug":"preside-ext-calendar-view",
    "version":"1.2.0+4958",
    // etc...

    // Preside dependency specific meta
    // used during 'box install' process
    // to validate/autoinstall dependencies
    // (optional)
    "preside" : {
        "minVersion" : "10.6.19",// optional minimum version of Preside the extension works with
        "maxVersion" : "10.10",// optional maximum version of Preside the extension works with
        
        // list of preside *extension* dependencies
        // to auto-install if not already installed
        "dependencies":{
            "preside-ext-saml2-sso":{
                "installVersion":"preside-ext-saml2-sso@^4.0.5", // version to auto-install if not already installed (required)
                "minVersion":"3", // (optional) minimum allowed version of dependency
                "maxVersion":"4", // (optional) maximum allowed version of dependency
            }
        },

        // list of preside *extension* compatibility issues
        // block install if compatibility issues are found
        "compatibility":{
            "preside-ext-old-ext":{
                "compatible":false, // if completely incompatible
                "message":"Custom message to show if compatibility issue is found"
            },
            "preside-ext-another-old-ext":{
                "minVersion":"1.0.0", // i.e. if another-old-ext is installed, it must be at least 1.0.0 to be compatible with this extension
                "maxVersion":"^1.2.0", // i.e. if another-old-ext is installed, it must be no greater than 1.2.x to be compatible with this extension
                "message":"Custom message to show if compatibility issue is found"
            }
        }
    }
}
```

>>> The `preside` section of `box.json` will only do anything if you have the latest version of [Preside CommandBox Commands](https://www.github.com/pixl8/Preside-CMS-Commandbox-Commands) (v4.0.0 at time of writing). Install with: `box install preside-commands`.

#### ModuleConfig.cfc (optional)

Preside extensions can act as ColdBox modules! This allows you to:

* Install private module dependencies for your extension. e.g. there may be a specific version of a Module in forgebox that you want to come bundled explicitly with your extension
* Set an independent mapping for your extension
* Use any other Coldbox Module features from within your extension

In order to register your extension as a module, simply create a `ModuleConfig.cfc` file in the root directory of the extension. A minimal example might look like:

```luceescript
component {
    this.title     = "My Awesome Extension";
    this.author    = "Pixl8 Group";
    this.cfmapping = "myawesomeextension";

    function configure(){}
}
```

### Config

Coldbox and Wirebox config files that can appear in your application's `/application/config` folder can also appear in your extension's own `/config` folder. Be aware however, that they are defined slightly differently from those of your application. The key difference is that they do not extend any components and receive special references to their methods to use (rather than setting configuration in the scope of the CFCs). See docs below for each file:

#### Config.cfc

This file is for core Preside and Coldbox configuration and configuration overrides. The CFC must define a `configure( required struct config )` method. This method accepts a `config` argument that must be used to augment and modify the application configuration. For example:

```luceescript
component {

    public void function configure( required struct config ) {
        var conf         = arguments.config;
        var settings     = conf.settings ?: {};

        // settings specific to my extension
        settings.features.mynewfeature = { enabled=true };
        settings.myExtensionSettings = settings.myExtensionSettings ?: {
            settingOne = true,
            settingTwo = false
        };

        // registering a Coldbox interceptor
        conf.interceptors.append( { class="app.extensions.my-extension.interceptors.MyCoolInterceptor", properties={} } );

        // overriding/modifying existing settings:
        settings.adminConfigurationMenuItems.append( "mySystemMenuItem" );
        
        // ... etc
    }
}
```

#### Wirebox.cfc

Define this file in order to register custom model files (services) that require manual registration. The CFC must define a `configure( binder )` method that accepts the Wirebox `binder` object that can be used to register instances. For example:

```luceescript
component {

    public void function configure( required any binder ) {
        var settings = arguments.binder.getColdbox().getSettingStructure();

        arguments.binder.map( "applePassKeyStorageProvider" ).to( "preside.system.services.fileStorage.FileSystemStorageProvider" )
            .initArg( name="rootDirectory"    , value=settings.uploads_directory & "/applePassKeys" )
            .initArg( name="trashDirectory"   , value=settings.uploads_directory & "/.trash" )
            .initArg( name="privateDirectory" , value=settings.uploads_directory & "/applePassKeys" )
            .initArg( name="rootUrl"          , value="" );
    }

}
```

>>> Any CFC files that are placed beneath the `/services` directory in the root of your extension will *automatically* be registered with Wirebox and do not need to be manually registered.


### ColdBox and Preside folders

#### /forms

Define `.xml` form files here in accordance with the [[presideforms|Forms system]]. Any files that match the relative path of forms defined in core Preside, other extensions, or the application, *will be merged* (see [[presideforms]]).

#### /handlers

Define ColdBox handlers here. The system will mix and match handler **actions** from handler files in extensions, core preside and the application. This allows you to augment existing handlers with new actions in your extension.

#### /helpers

Define coldbox UDF helper `.cfm` files in here that will be available to handlers and views throughout the application.

#### /i18n

Define i18n `.properties` file here in accordance with the [[i18n|i18n system]]. Files whose path matches those defined elsewhere will have their property keys merged.

This allows you to supply our own files and also override specific key translations from Preside core/other extensions.

#### /layouts

Define ColdBox layout files here. Any layouts that match the filename of a layout in core Preside, or a layout file in a preceding extension, will override their counterpart. This means you can, for example, create an extension that completely overrides the Preside admin layout (not necessarily advised, but possible!).

#### /preside-objects

Define Preside objects as per the documentation [[dataobjects]] here. If the object name matches that of an already defined object, its properties will be mixed in. This allows you to decorate pre-defined objects in core Preside and other extensions, adding, modifying and removing properties as well as adding annotations to the object itself.

#### /services

Any CFC files in the services directory will be automatically added to Wirebox by name. i.e. if you create `/services/MyService.cfc`, you will be able to retrieve an instance of it with `getModel( 'myService' )`.

Warning: if you create a service with the same name as a service in core Preside or a preceding extension, your extension's service will *replace* it. This can be a useful feature, but should be used with caution.

#### /views

Define ColdBox view files here. Any views that match the relative path and filename of a view in core Preside, or a view file in a preceding extension, will override their counterpart. This means you can, for example, create an extension that completely overrides the Preside admin view for 'add record'.