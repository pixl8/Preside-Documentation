---
id: editablesystemsettings
title: Editable system settings
---

## Overview

Editable system settings are settings that effect the working of your entire system and that are editable through the CMS admin GUI.

They are stored against a single data object, `system_config`, and are organised into categories.

![Screenshot showing system settings with two categories, "General" and "Hipchat integration"](images/screenshots/system_settings_menu.png)


## Categories

A category groups configuration options into a single form. To define a new category, you must:

1. Create a new form layout file at `/forms/system-config/my-category.xml`. For example:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form>
    <tab>
        <fieldset>
            <field name="hipchat_api_key"               control="textinput"   required="true" label="system-config.hipchat-settings:api_key.label" maxLength="50" />
            <field name="hipchat_room_name"             control="textinput"   required="true" label="system-config.hipchat-settings:room_name.label" maxLength="50" />
            <field name="hipchat_use_html_notification" control="yesNoSwitch" required="true" label="system-config.hipchat-settings:use_html_notification.label" />
        </fieldset>
    </tab>
</form>
```

2. Create an i18n resource bundle file at `/i18n/system-config/my-category.properties`. This should at least contain `name`, `description` and `iconClass` properties to describe the category. For example:

```properties
name=Hipchat integration
description=Configure notifications from Preside into your Hipchat rooms
iconClass=fa-comment

api_key.label=API Key
room_name.label=Room name
use_html_notification.label=Use HTML notifications
```

## Delegating access to a single category

By default, the entire system settings area - the index of categories, and viewing or saving any individual category - requires the `systemConfiguration.manage` permission, which is granted wholesale to the sysadmin role.

As of Preside **10.31.0**, an individual category can additionally be delegated to a domain specific role by declaring a `permissionKey` attribute on the root `form` element of its configuration form (see [[presideforms-permissioning]]):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form i18nBaseUri="system-config.payments:" permissionKey="payments.settings.manage">
    <tab id="default">
        <fieldset id="default" sortorder="10">
            <field name="my_setting" />
        </fieldset>
    </tab>
</form>
```

A user is then able to view and save that category if they hold **either** `systemConfiguration.manage` **or** the category's declared permission key. This is useful where a settings link has been moved out of the *System > Settings* menu into a domain specific admin menu (see [[adminmenuitems]]) and needs to be usable by the role that owns that menu, without granting that role access to every other settings category.

The rules are:

* Categories that do **not** declare a `permissionKey` behave exactly as before: only `systemConfiguration.manage` grants access.
* Users with `systemConfiguration.manage` always retain access to every category, whether or not it declares a key.
* A user who holds only a category's declared key can view and save that category (including its tenanted variants), but cannot reach the settings index or any other category. The settings breadcrumb, which links to that index, is omitted for them.
* The category menu viewlet lists only the categories the current user can access.
* Saving is unaffected in every other respect: the `preSaveSystemConfig` and `postSaveSystemConfig` interception points, the audit trail entry and any watched-settings system alert checks (see [[systemalerts]]) all run as normal.

Because form definitions are merged across core, extensions and your application, an application can override an extension's declared key by redeclaring the attribute in its own copy of the form definition.

>>> Remember to define the permission key itself - and grant it to the relevant roles - in your `Config.cfc`. See [[cmspermissioning]].

## Multiple sites & custom tenancy

As of Preside 10.7.0, if you have multiple sites, each configuration form can now be configured globally and then per-site if you wish to override global defaults in a particular site.

As of Preside **10.13.0**, this behaviour can be overwritten in two ways:

1. Disable site tenancy altogether
2. Specify an alternative tenant (see [[data-tenancy]])

### Disabling site tenancy for a category

Disabling site tenancy for a system configuration category can be done by adding a `noTenancy="true"` attribute to the configuration form xml:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form i18nBaseUri="system-config.my_category:" noTenancy="true">
    <tab id="default">
        <fieldset id="default" sortorder="10">
            <field name="my_setting" />
        </fieldset>
    </tab>
</form>
```

### Using a custom tenancy

Custom tenancy (see [[data-tenancy]]) allows automatic filtering of data based on some configured current request record. As of **10.13.0**, you can specify a custom tenant for any configuration form by adding a `tenancy="my_custom_tenant"` attribute to your setting category's xml form.

For example, if you had defined a special `account` tenancy, you could add this to your settings form:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form i18nBaseUri="system-config.my_category:" tenancy="account">
    <tab id="default">
        <fieldset id="default" sortorder="10">
            <field  />
        </fieldset>
    </tab>
</form>
```

This would result in admin users being able to supply a global set of default settings for your category and then being able to override the settings for each `account` tenant.
## Retrieving settings

### From handlers and views

Settings can be retrieved from within your handlers and views with the `getSystemSetting()` method. For example:

```luceescript
function myHandler( event, rc, prc ) {
    prc.hipchatApiKey = getSystemSetting(
          category = "hipchat-integration"
        , setting  = "hipchat_api_key"
        , default  = "someDefaultApiKey"
    );
}
```

### From within your service layer

#### Preside Super Class

The preferred method of retrieving settings through the service layer is through use of the [[presidesuperclass-$getpresidesetting]] and [[presidesuperclass-$getpresidecategorysettings]] methods that can be injected into your service as part of the [[api-presidesuperclass]] (see [[presidesuperclass]]). For example:

```luceescript
/**
 * presideService
 *
 */
component {

    public void function doSomething() {
        var settings    = $getPresideCategorySettings( category="email" );
        var emailServer = $getPresideSetting( category="email", setting="server", default="127.0.0.1" );
    }

}
```

#### Wirebox

Settings can alternatively be injected into your service layer components using the Preside custom WireBox DSL. For example:

```luceescript
component {
    property name="hipchatApiKey" inject="presidecms:systemsetting:hipchat-integration.hipchat_api_key";

    ...
}
```

>>>> If you inject settings this way into a singleton, any changes to the settings through the admin will not be reflected in your service object until it is reinstantiated (i.e. a full application reload). In this case, you may wish to use the method described below.

You can also inject the [[api-systemconfigurationservice]] object itself into your services and use its [[systemconfigurationservice-getsetting]] method directly. For example:

```luceescript
component {
    property name="systemConfigurationService" inject="systemConfigurationService";

    ...

    private string function _getApiKey() {
        return systemConfigurationService.getSetting(
              category = "hipchat-integration"
            , setting  = "hipchat_api_key"
            , default  = "nokeyselected"
        );
    }
}
```

## Interceptors and custom validation

When you save the settings through the admin UI, two interception points are raised, `preSaveSystemConfig` and `postSaveSystemConfig`. These events allow your systems to perform custom validation and any other logic your need to perform once a category's settings have been saved.

>>>>>> See the [ColdBox Interceptors documentation](https://coldbox.ortusbooks.com/the-basics/interceptors) for in depth instructions on setting up interceptors.

Both interception points receive `category` and `configuration` arguments in the `interceptData` struct and, in addition, the `preSaveSystemConfig` interception point receives a `validationResult` object with which to record any custom validation (see [[api-validationresult]]).

For example, the core email settings form uses an interceptor to validate the email server configuration:

```luceescript
component extends="coldbox.system.Interceptor" {

    property name="emailService" inject="delayedInjector:emailService";

// PUBLIC
    public void function configure() {}

    public void function preSaveSystemConfig( event, interceptData ) {
        // interception point data
        var category         = interceptData.category         ?: "";
        var configuration    = interceptData.configuration    ?: {};
        var validationResult = interceptData.validationResult ?: "";

        // check that we are the email category and that the
        // form contains all the server configuration variables
        // we need to check
        if ( category == "email" && configuration.keyExists( "server" ) && configuration.keyExists( "port" ) && configuration.keyExists( "username" ) && configuration.keyExists( "password" ) && !IsSimpleValue( validationResult ) ) {

            var errorMessage = emailService.validateConnectionSettings(
                  host     = configuration.server
                , port     = configuration.port
                , username = configuration.username
                , password = configuration.password
            );

            if ( Len( Trim( errorMessage ) ) ) {
                if ( errorMessage == "authentication failure" ) {
                    // adding an error to the validation result with a
                    // translatable error message
                    validationResult.addError( "username", "system-config.email:validation.server.authentication.failure" );
                } else {
                    // adding an error to the validation result with a
                    // translatable error message
                    validationResult.addError( "server", "system-config.email:validation.server.details.invalid", [ errorMessage ] );
                }
            }
        }
    }
}
```
