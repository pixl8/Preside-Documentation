---
id: reloadingtheapplication
title: "Reloading the application"
---

## Introduction

By default, Preside is run in production mode. This means that large parts of the codebase, configuration and even data queries are cached once for the life of the application. This is great for live performance but there are times when you want to either:

* Reload the entire application - perhaps you've just deployed to live
* Reload individual parts of the application - you've deployed a small change to live and can get by just reloading a bit of it
* Configure the site to reload everything on every request - you have a really fast laptop and you are developing on your local machine so want to see your code changes take effect every request
* Configure the site to reload parts of the application on every request - same as above but that reloading everything is too slow and you only need to reload parts of the application

## Reloading all or part of the application

You can reload all or part of the application by supplying a reload token in the URL along with the reload password set in your application's config. The following table details the options you have:

* `fwReinitCaches` Clears out all the caches - this includes cached handlers, query caches and any other cache box caches configured in your site
* `fwReinitStatic` Rechecks and compiles the site's static assets (CSS, JS and static images)
* `fwReinitTemplates` Reloads / rediscovers the list of registered page templates
* `fwReinitWidgets` Reloads / rediscovers the list of registered widgets
* `fwReinitObjects` Reloads preside object definitions (but does not sync with the database)
* `fwreinit` Reloads the entire application
* `fwReinitI18n` Reloads the resource bundle definitions
* `fwReinitForms` Reloads your application's form definitions
* `fwReinitDbSync` Syncs preside object definitions with the database and reloads the object definitions in the process

e.g. `http://www.mysite.com/?fwreinitForms=true`

## Configuring the reload password

By default, the reload password is set to "true" (hence the examples above). This can be made slightly more secure by setting it in your site's `Config.cfc`. e.g.

```luceescript
component extends="preside.system.config.Config" {
    public void function configure() {
        super.configure();
         
        coldbox.reinitPassword = "myS3cureP455w0rd15L33t";
  
        // etc. (more config settings here...)
         
    }
} 
```

## Configuring reloads on every request

In your local development environment, you may wish to configure parts or all of the application to reload on every request. The developerMode setting can be used in your Config.cfc or LocalConfig.cfc file to control this behaviouir. The setting can be set to true to turn on a total reload on every request, false to turn off all per-request reloading (default) or set to a structure with individual options for the different areas of the application that can be reloaded. The individual options are:

* `dbSync` Syncs preside object definitions with the database and reloads the object definitions in the process
* `flushCaches` Clears out all the caches - this includes cached handlers, query caches and any other cache box caches configured in your site
* `reloadStatic` Rechecks and compiles the site's static assets (CSS, JS and static images)
* `reloadI18n` Reloads the resource bundle definitions
* `reloadPresideObjects` Reloads preside object definitions (but does not sync with the database)
* `reloadWidgets` Reloads / rediscovers the list of registered widgets
* `reloadForms` Reloads your application's form layout definitions
* `reloadPageTemplates` Reloads / rediscovers the list of registered page templates


The following code gives examples of how you can configure these options:

```luceescript
component extends="preside.system.config.Config" {
    public void function configure() {
        super.configure();
        // ...
    }
       
    public void function local() {  
        // reload the entire application on every request
        settings.developerMode = true;
  
        // turns off all per-request reloading (default)
        settings.developerMode = false;
  
        // turn on / off individual per request reload options
        settings.developerMode = {
              dbSync               = true // or false,    
            , flushCaches          = true // or false,         
            , reloadForms          = true // or false,            
            , reloadStatic         = true // or false,          
            , reloadI18n           = true // or false,        
            , reloadPresideObjects = true // or false,                   
            , reloadWidgets        = true // or false,
            , reloadPageTemplates  = true // or false,
        };
    }
}
```