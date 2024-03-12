---
title: Download the docs
id: download
---

The documentation is available for offline browsing as a [zip file](presidecms-docs.zip) and also as a docset for [Dash](https://kapeli.com/dash)/[Zealdocs](http://zealdocs.org/).

## Dash / Zeal install

You can add the Preside documentation to your Dash or Zealdocs install by adding the following feed:

[https://docs.preside.org/dash/presidecms.xml](https://docs.preside.org/dash/presidecms.xml)
---
id: quickstart
title: Quick start guide
---

The quickest way to get started with Preside is to take it for a spin with our [CommandBox commands](https://github.com/pixl8/Preside-CMS-CommandBox-Commands). These commands give you the ability to:

* Create a new skeleton Preside application from the commandline
* Spin up an ad-hoc Preside server on your local dev machine that runs the Preside application in the current directory

## Install commandbox and Preside Commands

Before starting, you will need CommandBox installed. Head to [https://www.ortussolutions.com/products/commandbox](https://www.ortussolutions.com/products/commandbox) for instructions on how to do so. You will need at least version 5.9.0.

Once you have CommandBox up and running, you'll need to issue the following command to install our Preside specific commands:

```
CommandBox> install preside-commands
```
This adds our custom Preside commands to your box environment :)

## Usage

### Create a new site

From within the CommandBox shell, CD into an empty directory in which you would like to create the new site and type:

```
CommandBox> preside new site
```

Follow any prompts that you receive to scaffold a new Preside application with the Preside dependency installed.

### Start a server

From the webroot of your Preside site, enter the following command:

```
CommandBox> preside start
```

If it is the first time starting, you will be prompted to enter your database information, **you will need an empty database already setup - we recommend MariaDB or MySQL, though we have some support for PostgreSQL and SQL Server**.

Once started, a browser should open and you should be presented with your homepage. To navigate to the administrator, browse to `/admin/` and you will be prompted to setup the super user account. Complete that and you have a running Preside application and should be able to login to the admin!

>>>>>> The admin path setting is editable in your site's `/application/config/Config.cfc` file.

---
id: customerrorpages
title: Custom error pages & maintenance mode
---

## Overview

Preside provides a simple mechanism for creating custom `401`, `404` and `500` error pages while providing the flexibility to allow you to implement more complex systems should you need it.


## 404 Not found pages

### Creating a 404 template

The 404 template is implemented as a Preside Viewlet (see [[[viewlets]]) and a core implementation already exists. The name of the viewlet is configured in your application's Config.cfc with the `notFoundViewlet` setting. The default is "errors.notFound":

```luceescript
// /application/config/Config.cfc
component extends="preside.system.config.Config" {

    public void function configure() {
        super.configure();

        // other settings...
        settings.notFoundViewlet = "errors.notFound";
    }
}
```

For simple cases, you will only need to override the `/errors/notFound` view by creating one in your application's view folder, e.g.

```lucee
<!-- /application/views/errors/notFound.cfm -->
<h1>These are not the droids you are looking for</h1>
<p> Some pithy remark.</p>
```

#### Implementing handler logic

If you wish to perform some handler logic for your 404 template, you can simply create the Errors.cfc handler file and implement the "notFound" action. For example:

```luceescript
// /application/handlers/Errors.cfc
component {

    private string function notFound( event, rc, prc, args={} ) {
        event.setHTTPHeader( statusCode="404" );
        event.setHTTPHeader( name="X-Robots-Tag", value="noindex" );

        return renderView( view="/errors/notFound", args=args );
    }
}
```

#### Defining a layout template

The default layout template for the 404 is your site's default layout, i.e. "Main" (`/application/layouts/Main.cfm`). If you wish to configure a different default layout template for your 404 template, you can do so with the `notFoundLayout` configuration option, i.e.

```luceescript
// /application/config/Config.cfc
component extends="preside.system.config.Config" {

    public void function configure() {
        super.configure();

        // other settings...

        settings.notFoundLayout  = "404Layout";
        settings.notFoundViewlet = "errors.my404Viewlet";
    }
}
```

You can also programatically set the layout for your 404 template in your handler (you may wish to dynamically pick the layout depending on a number of variables):

```luceescript
// /application/handlers/Errors.cfc
component {

    private string function notFound( event, rc, prc, args={} ) {
        event.setHTTPHeader( statusCode="404" );
        event.setHTTPHeader( name="X-Robots-Tag", value="noindex" );
        event.setLayout( "404Layout" );

        return renderView( view="/errors/notFound", args=args );
    }
}
```

### Programatically responding with a 404

If you ever need to programatically respond with a 404 status, you can use the `event.notFound()` method to do so. This method will ensure that the 404 statuscode header is set and will render your configured 404 template for you. For example:

```luceescript
// someHandler.cfc
component {

    public void function index( event, rc, prc ) {
        prc.record = getModel( "someService" ).getRecord( rc.id ?: "" );

        if ( !prc.record.recordCount ) {
            event.notFound();
        }

        // .. carry on processing the page
    }
}
```

### Direct access to the 404 template

The 404 template can be directly accessed by visiting /404.html. This is achieved through a custom route dedicated to error pages (see [[routing]]).

This is particular useful for rendering the 404 template in cases where Preside is not producing the 404. For example, you may be serving static assets directly through Tomcat and want to see the custom 404 template when one of these assets is missing. To do this, you would edit your `${catalina_home}/config/web.xml` file to define a rewrite URL for 404s:

```xml
<!-- ... -->

        <welcome-file-list>
        <welcome-file>index.cfm</welcome-file>
    </welcome-file-list>

    <error-page>
        <error-code>404</error-code>
        <location>/404.html</location>
    </error-page>

</web-app>
```

Another example is producing 404 responses for secured areas of the application. In Preside's default urlrewrite.xml file (that works with Tuckey URL Rewrite), we block access to files such as Application.cfc by responding with a 404:

```xml
<rule>
    <name>Block access to certain URLs</name>
    <note>
        All the following requests should not be allowed and should return with a 404:

        * the application folder (where all the logic and views for your site lives)
        * the uploads folder (should be configured to be somewhere else anyways)
        * this url rewrite file!
        * Application.cfc
    </note>
    <from>^/(application/|uploads/|urlrewrite\.xml\b|Application\.cfc\b)</from>
    <set type="status">404</set>
    <to last="true">/404.html</to>
</rule>
```

## 401 Access denied pages

Access denied pages can be created and used in exactly the same way as 404 pages, with a few minor differences. The page can be invoked with `event.accessDenied( reason=deniedReason )` and will be automatically invoked by the core access control system when a user attempts to access pages and assets to which they do not have permission.

>>>>>> For a more in depth look at front end user permissioning and login, see [[websiteusersandpermissioning]].

### Creating a 401 template

The 401 template is implemented as a Preside Viewlet (see [[viewlets]]) and a core implementation already exists. The name of the viewlet is configured in your application's Config.cfc with the `accessDeniedViewlet` setting. The default is "errors.accessDenied":

```luceescript
// /application/config/Config.cfc
component extends="preside.system.config.Config" {

    public void function configure() {
        super.configure();

        // other settings...
        settings.accessDeniedViewlet = "errors.accessDenied";
    }
}
```

The viewlet will be passed an `args.reason` argument that will be either `LOGIN_REQUIRED`, `INSUFFICIENT_PRIVILEGES` or any other codes that you might make use of.

The core implementation sets the 401 header and then renders a different view, depending on the access denied reason:

```luceescript
// /preside/system/handlers/Errors.cfc
component {

    private string function accessDenied( event, rc, prc, args={} ) {
        event.setHTTPHeader( statusCode="401" );
        event.setHTTPHeader( name="X-Robots-Tag"    , value="noindex" );
        event.setHTTPHeader( name="WWW-Authenticate", value='Website realm="website"' );

        switch( args.reason ?: "" ){
            case "INSUFFICIENT_PRIVILEGES":
                return renderView( view="/errors/insufficientPrivileges", args=args );
            default:
                return renderView( view="/errors/loginRequired", args=args );
        }
    }
}
```

For simple cases, you will only need to override the `/errors/insufficientPrivileges` and/or `/errors/loginRequired` view by creating them in your application's view folder, e.g.

```lucee
<!-- /application/views/errors/insufficientPrivileges.cfm -->
<h1>Name's not on the door, you ain't coming in</h1>
<p> Some pithy remark.</p>
```

```lucee
<!-- /application/views/errors/loginRequired.cfm -->
#renderViewlet( event="login.loginPage", message="LOGIN_REQUIRED" )#
```

#### Implementing handler logic

If you wish to perform some handler logic for your 401 template, you can simply create the Errors.cfc handler file and implement the "accessDenied" action. For example:

```luceescript
// /application/handlers/Errors.cfc
component {
    private string function accessDenied( event, rc, prc, args={} ) {
        event.setHTTPHeader( statusCode="401" );
        event.setHTTPHeader( name="X-Robots-Tag"    , value="noindex" );
        event.setHTTPHeader( name="WWW-Authenticate", value='Website realm="website"' );

        switch( args.reason ?: "" ){
            case "INSUFFICIENT_PRIVILEGES":
                return renderView( view="/errors/my401View", args=args );
            case "MY_OWN_REASON":
                return renderView( view="/errors/custom401", args=args );
            default:
                return renderView( view="/errors/myLoginFormView", args=args );
        }
    }
}
```

#### Defining a layout template

The default layout template for the 401 is your site's default layout, i.e. "Main" (/application/layouts/Main.cfm). If you wish to configure a different default layout template for your 401 template, you can do so with the `accessDeniedLayout` configuration option, i.e.

```luceescript
// /application/config/Config.cfc
component extends="preside.system.config.Config" {

    public void function configure() {
        super.configure();

        // other settings...

        settings.accessDeniedLayout  = "401Layout";
        settings.accessDeniedViewlet = "errors.my401Viewlet";
    }
}
```

You can also programatically set the layout for your 401 template in your handler (you may wish to dynamically pick the layout depending on a number of variables):

```luceescript
// /application/handlers/Errors.cfc
component {
    private string function accessDenied( event, rc, prc, args={} ) {
        event.setHTTPHeader( statusCode="401" );
        event.setHTTPHeader( name="X-Robots-Tag"    , value="noindex" );
        event.setHTTPHeader( name="WWW-Authenticate", value='Website realm="website"' );

        event.setLayout( "myCustom401Layout" );

        // ... etc.
    }
}
```

### Programatically responding with a 401

If you ever need to programatically respond with a 401 access denied status, you can use the `event.accessDenied( reason="MY_REASON" )` method to do so. This method will ensure that the 401 statuscode header is set and will render your configured 401 template for you. For example:

```luceescript
// someHandler.cfc
component {

    public void function reservePlace( event, rc, prc ) {
        if ( !isLoggedIn() ) {
            event.accessDenied( reason="LOGIN_REQUIRED" );
        }
        if ( !hasWebsitePermission( "events.reserveplace" ) ) {
            event.accessDenied( reason="INSUFFICIENT_PRIVILEGES" );
        }

        // .. carry on processing the page
    }
}
```

## Choosing whether or not to redirect 404 and 401 pages

In `10.10.13`, a feature flag was added to make 404 and 401 pages _redirect_ rather show inline (the default behaviour). To turn on the redirection feature, use the following in your `Config.cfc$configure()` method:

```luceescript
settings.features.redirectErrorPages.enabled = true;
```

## 500 Error Pages

The implementation of 500 error pages is more straight forward than the 40x templates and involves only creating a flat `500.htm` file in your webroot. The reason behind this is that a server error may be caused by your site's layout code, or may even occur before Preside code is called at all; in which case the code to render your error template will not be available.

If you do not create a `500.htm` in your webroot, Preside will use its own default template for errors. This can be found at `/preside/system/html/500.htm`.

### Bypassing the error template

In your local development environment, you will want to be able see the details of errors, rather than view a simple error message. This can be achieved with the config setting, `showErrors`:

```luceescript
// /application/config/Config.cfc
component extends="preside.system.config.Config" {

    public void function configure() {
        super.configure();

        // other settings...

        settings.showErrors = true;
    }
}
```

In most cases however, you will not need to configure this for your local environment. Preside uses ColdBox's environment configuration to configure a "local" environment that already has `showErrors` set to **true** for you. If you wish to override that setting, you can do so by creating your own "local" environment function:

```luceescript
// /application/config/Config.cfc
component extends="preside.system.config.Config" {

    public void function configure() {
        super.configure();

        // other settings...
    }

    public void function local() {
        super.local();

        settings.showErrors = false;
    }
}
```

>>> Preside's built-in local environment configuration will map URLs like "mysite.local", "local.mysite", "localhost" and "127.0.0.1" to the "local" environment.

## 503 Maintenance mode page

The administrator interface provides a simple GUI for putting the site into maintenance mode (see figure below). This interface allows administrators to enter a custom title and message, turn maintenance mode on/off and also to supply custom settings to allow users to bypass maintenance mode.

![Screenshot of maintenance mode management GUI](images/screenshots/maintenance_mode.png)

### Creating a custom 503 page

The 503 template is implemented as a Preside Viewlet (see [[viewlets]]) and a core implementation already exists. The name of the viewlet is configured in your application's Config.cfc with the `maintenanceModeViewlet` setting. The default is "errors.maintenanceMode":

```luceescript
// /application/config/Config.cfc
component extends="preside.system.config.Config" {

    public void function configure() {
        super.configure();

        // other settings...
        settings.maintenanceModeViewlet = "errors.maintenanceMode";
    }
}
```

To create a custom template, you can choose either to provide your own viewlet by changing the config setting, or by overriding the view and/or handler of the `errors.maintenanceMode` viewlet.

For example, in your site's `/application/views/errors/` folder, you could create a `maintenanceMode.cfm` file with the following:

```html
<cfparam name="args.title"   />
<cfparam name="args.message" />

<cfoutput><!DOCTYPE html>
<html>
    <head>
        <title>#args.title#</title>
        <meta charset="utf-8">
        <meta name="robots" content="noindex,nofollow" />
    </head>
    <body>
        <h1>#args.title#</h1>
        #args.message#
    </body>
</html></cfoutput>
```

>>>>>> The maintenance mode viewlet needs to render the entire HTML of the page.

### Manually clearing maintenance mode

You may find yourself in a situation where you application is in maintenance mode and you have no means by which to access the admin because the password has been lost. In this case, you have two options:

#### Method 1: Set bypass password directly in the database

To find the current bypass password, you can query the database with:

```sql
select value
from   psys_system_config
where  category = 'maintenanceMode'
and    setting  = 'bypass_password';
```

If the value does not exist, create it with:

```sql
insert into psys_system_config (id, category, setting, `value`, datecreated, datemodified)
values( '{a unique id}', 'maintenancemode', 'bypass_password', '{new password}', now(), now() );
```

The bypass password can then be used by supplying it as a URL parameter to your site, e.g. `http://www.mysite.com/?thepassword`. From there, you should be able to login to the administrator and turn off maintenance mode.

#### Method 2: Delete the maintenance mode file

When maintenance mode is activated, a file is created at `/yoursite/application/config/.maintenance`. To clear maintenance mode, delete that file and restart the application.
---
id: presideforms
title: Forms system
---

## Introduction

Preside provides a built-in forms system which allows you to define user-input forms that can be used throughout the admin and in your application's front-end.

Forms are defined using xml files that live under a `/forms` directory. A typical form definition file will look like this:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form i18nBaseUri="form.my-form:">
    <tab id="basic" sortorder="10">
        <fieldset id="basic" sortorder="10">
            <field binding="my_obj.my_field"      sortorder="10" />
            <field binding="my_obj.another_field" sortorder="20" />
        </fieldset>
    </tab>
    <tab id="advanced" sortorder="20" permissionkey="advancedsettings.edit">
        <fieldset id="advanced" sortorder="10">
            <field binding="my_obj.advanced_option" sortorder="10" />
        </fieldset>
    </tab>
</form>
```

An example admin render of a form with multiple tabs and fields might look like this:

![Screenshot showing example of a rendered form in the admin](images/screenshots/formExample.png)

### Referencing forms

Forms are referenced relative to their location under the `/forms` directory of either your application or extension. Slashes in the relative path are replaced with dots (`.`) and the file extension is removed. For example:

```luceescript
// form definition location:
/application/forms/eventsmanager/create.event.xml

// form ID
"eventsmanager.create.event"

// example usage
var formData = event.getCollectionForForm( "eventsmanager.create.event" );
```


## Further reading

* [[presideforms-anatomy]]
* [[presideforms-controls]]
* [[presideforms-i18n]]
* [[presideforms-rendering]]
* [[presideforms-processing]]
* [[presideforms-validation]]
* [[presideforms-merging]]
* [[presideforms-dynamic]]
* [[presideforms-features]]
* [[presideforms-permissioning]]
* [[systemforms|Reference: System form definitions]]
* [[systemformcontrols|Reference: System form controls]]

>>>> The Preside forms system is not to be confused with the [[formbuilder|Preside Form builder]]. The form builder is a system in which content editors can produce dynamically configured forms and insert them into content pages. The Preside Forms system is a system of programatically defining forms that can be used either in the admin interface or hard wired into the application's front end interfaces.





---
id: presideforms-rendering
title: Rendering Preside form definitions
---

## Rendering Preside form definitions

Preside form definitions are generally rendered using `renderForm()`, a global helper method that is a proxy to the [[formsservice-renderform]] method of the [[api-formsservice]]. A minimal example might look something like:

```lucee
<form id="signup-form" action="#postAction#" class="form form-horizontal">
	#renderForm(
		  formName         = "events-management.signup"
		, context          = "admin"
		, formId           = "signup-form"
		, validationResult = rc.validationResult ?: ""
	)#

	<input type="submit" value="Go!" />
</form>
```

## Dynamic data

A common requirement is for dynamic arguments to be passed to the rendering of forms. For example, you may wish to supply editorially driven form field labels to a statically defined form. **As of 10.8.0**, this can be achieved by passing the `additionalArgs` argument to the `renderForm()` method:

```lucee
<cfscript>
    additionalArgs = {
    	  fields    = { firstname={ label=dynamicFirstnameLabel } }
    	, fieldsets = { personal={ description=dynamicPersonalFieldsetDescription } }
    	, tabs      = { basic={ title=dynamicBasicTabTitle } }
    };
</cfscript>

<form id="signup-form" action="#postAction#" class="form form-horizontal">
	#renderForm(
		  formName         = "events-management.signup"
		, context          = "admin"
		, formId           = "signup-form"
		, validationResult = rc.validationResult ?: ""
		, additionalArgs   = additionalArgs
	)#

	<input type="submit" value="Go!" />
</form>
```

The `additionalArgs` structure expects `fields`, `fieldsets` and `tabs` keys (all optional). To add args for a specific field, add a key under the `fields` struct that matches the field _name_. For fieldsets and tabs, use the _id_ of the entity to match.

## Rendering process and custom layouts

When a form is rendered using the [[formsservice-renderform]] method, its output string is built from the bottom up. At the bottom level you have field controls, followed by field layout, fieldset layouts, tab layouts and finally a form layout.

### Level 1: form control

The renderer for each individual field's _form control_ is calculated by the field definition and context supplied to the [[formsservice-renderform]] method, see [[presideforms-controls]] for more details on how form controls are rendered. 

Each field is rendered using its control and the result of this render is passed to the field layout (level 2, below).

### Level 2: field layout

Each rendered field control is passed to a field layout (defaults to `formcontrols.layouts.field`). This layout is generally responsible for outputting the field label and any error message + surrounding HTML to enable the field control to be displayed correctly in the current page.

The layout's viewlet is passed an `args.control` argument containing the rendered form control from "level 1" as well as any args defined on the field itself.

An alternative field layout can be defined either directly in the form definition or in the [[formsservice-renderform]] method. See examples below

```xml
...
<!-- alternative layout defined directly in form definition.
     custom 'twoColumnPosition' attribute will be passed 
     as arg to the layout -->
<field name="start_date" layout="formcontrols.layout.twoColumnFieldLayout" twoColumnPosition="left"  />
<field name="end_date"   layout="formcontrols.layout.twoColumnFieldLayout" twoColumnPosition="right" />
...
```

```lucee
<!-- alternative layout for entire form defined as argument -->
#renderForm(
	  formName         = "events-management.signup"
	, context          = "admin"
	, formId           = "signup-form"
	, validationResult = rc.validationResult ?: ""
	, fieldLayout      = "events-management.fieldLayout"
)#
```

#### Example viewlet

```lucee
<!-- /views/formcontrols/layout/field.cfm -->
<cfscript>
	param name="args.control"  type="string";
	param name="args.label"    type="string";
	param name="args.help"     type="string";
	param name="args.for"      type="string";
	param name="args.error"    type="string";
	param name="args.required" type="boolean";

	hasError = Len( Trim( args.error ) );
</cfscript>

<cfoutput>
	<div class="form-group<cfif hasError> has-error</cfif>">
		<label class="col-sm-2 control-label no-padding-right" for="#args.for#">
			#args.label#
			<cfif args.required>
				<em class="required" role="presentation">
					<sup><i class="fa fa-asterisk"></i></sup>
					<span>#translateResource( "cms:form.control.required.label" )#</span>
				</em>
			</cfif>

		</label>

		<div class="col-sm-9">
			<div class="clearfix">
				#args.control#
			</div>
			<cfif hasError>
				<div for="#args.for#" class="help-block">#args.error#</div>
			</cfif>
		</div>
		<cfif Len( Trim( args.help ) )>
			<div class="col-sm-1">
				<span class="help-button fa fa-question" data-rel="popover" data-trigger="hover" data-placement="left" data-content="#HtmlEditFormat( args.help )#" title="#translateResource( 'cms:help.popover.title' )#"></span>
			</div>
		</cfif>
	</div>
</cfoutput>
```

### Level 3: Fieldset layout

The fieldset layout viewlet is called for each fieldset in your form and is supplied with the following `args`:

* `args.content` containing all the rendered fields for the fieldset
* any args set directly on the fieldset element in the form definition

The default fieldset layout viewlet is "formcontrols.layouts.fieldset". You can define a custom viewlet either on the fieldset directly or by passing the viewlet to the [[formsservice-renderform]] method.

```xml
<!-- alternative layout defined directly in form definition.
     custom 'colour' attribute will be passed 
     as arg to the layout -->
<fieldset id="security" layout="formcontrols.layout.colouredFieldset" colour="blue">
	...
</fieldset>
...
```

```lucee
<!-- alternative layout for entire form defined as argument -->
#renderForm(
	  formName         = "events-management.signup"
	, context          = "admin"
	, formId           = "signup-form"
	, validationResult = rc.validationResult ?: ""
	, fieldsetLayout   = "events-management.fieldsetLayout"
)#
```

#### Example viewlet

```lucee
<!-- /views/formcontrols/layout/fieldset.cfm -->
<cfparam name="args.id"                 default="" />
<cfparam name="args.title"              default="" />
<cfparam name="args.description"        default="" />
<cfparam name="args.content"            default="" />

<cfoutput>
	<fieldset<cfif Len( Trim( args.id ) )> id="fieldset-#args.id#"</cfif>>
		<cfif Len( Trim( args.title ) )>
			<h3 class="header smaller lighter green">#args.title#</h3>
		</cfif>
		<cfif Len( Trim( args.description ) )>
			<p>#args.description#</p>
		</cfif>

		#args.content#
	</fieldset>
</cfoutput>
```

### Level 4: Tab layout

The tab layout viewlet is called for each tab in your form and is supplied with the following `args`:

* an `args.content` argument containing all the rendered fieldsets for the tab
* any args set directly on the tab element in the form definition

The default tab layout viewlet is "formcontrols.layouts.tab". You can define a custom viewlet either on the tab directly or by passing the viewlet to the [[formsservice-renderform]] method.

```xml
<!-- alternative layout defined directly in form definition.
     custom 'colour' attribute will be passed 
     as arg to the layout -->
<tab id="security" layout="custom.formlayouts.colouredTab" colour="blue">
	...
</tab>
...
```

```lucee
<!-- alternative layout for entire form defined as argument -->
#renderForm(
	  formName         = "events-management.signup"
	, context          = "admin"
	, formId           = "signup-form"
	, validationResult = rc.validationResult ?: ""
	, tabLayout        = "events-management.tabLayout"
)#
```

#### Example viewlet

```lucee
<!-- /views/formcontrols/layout/tab.cfm -->
<cfscript>
	id          = args.id          ?: CreateUUId();
	active      = args.active      ?: false;
	description = args.description ?: "";
	content     = args.content     ?: "";
</cfscript>

<cfoutput>
	<div id="tab-#id#" class="tab-pane<cfif active> active</cfif>">
		<cfif Len( Trim( description ) )>
			<p>#description#</p>
		</cfif>

		#content#
	</div>
</cfoutput>
```

### Level 4: Form layout

The form layout viewlet is called once per form and is supplied with the following `args`:

* an `args.content` argument containing all the rendered tabs for the form
* an `args.tabs` array of tabs for the form (can be used to render the tabs header for example)
* an `args.validationJs` argument containing validation JS string
* an `args.formId` argument, this will be the same argument passed to the [[formsservice-renderform]] method
* any args set directly on the form element in the form definition

The default form layout viewlet is "formcontrols.layouts.form". You can define a custom viewlet either on the form directly or by passing the viewlet to the [[formsservice-renderform]] method.

```xml
<!-- alternative layout defined directly in form definition  -->
<form layout="custom.formlayouts.formLayout">
	...
</form>
```

```lucee
<!-- alternative layout for entire form defined as argument -->
#renderForm(
	  formName         = "events-management.signup"
	, context          = "admin"
	, formId           = "signup-form"
	, validationResult = rc.validationResult ?: ""
	, formLayout       = "events-management.formLayout"
)#
```

#### Example viewlet

```lucee
<!-- /views/formcontrols/layout/form.cfm -->
<cfscript>
	tabs               = args.tabs         ?: [];
	content            = args.content      ?: "";
	validationJs       = args.validationJs ?: "";
	formId             = args.formId       ?: "";
</cfscript>

<cfoutput>
	<cfif ArrayLen( tabs ) gt 1>
		<div class="tabbable">
			<ul class="nav nav-tabs">
				<cfset active = true />
				<cfloop array="#tabs#" index="tab">
					<li<cfif active> class="active"</cfif>>
						<a data-toggle="tab" href="##tab-#( tab.id ?: '' )#">#( tab.title ?: "" )#</a>
					</li>
					<cfset active = false />
				</cfloop>
			</ul>

			<div class="tab-content">
	</cfif>

	#content#

	<cfif ArrayLen( tabs ) gt 1>
			</div>
		</div>
	</cfif>

	<cfif Len( Trim( formId ) ) and Len( Trim( validationJs ))>
		<cfsavecontent variable="validationJs">
			( function( $ ){
				$('###formId#').validate( #validationJs# );
			} )( presideJQuery );
		</cfsavecontent>
		<cfset event.includeInlineJs( validationJs ) />
	</cfif>
</cfoutput>
```---
id: presideforms-controls
title: Preside form controls
---

## Preside form controls

Form controls are named [[viewlets|viewlets]] that are used for rendering form fields with the [[presideforms|Preside forms system]]. All form controls are implemented as viewlets whose path follows the convention `formcontrols.{nameofcontrol}.{renderercontext}`.

For a full reference list of core form controls, see [[systemformcontrols]].

### Renderer context

The _renderer context_ is a string value passed to the `renderForm()` method (see [[presideforms-rendering]]). The purpose of this is to allow form controls to have different viewlets for different contexts; i.e. an "admin" context for rendering controls in the admin vs a "website" context for rendering controls in the front end of your application.

At a bare minimum, form controls should implement a default "index" context for when there is no special renderer for specific contexts passed to `renderForm()`.

### Arguments

The `args` struct passed to your form control's viewlet will be a combination of:

* All attributes defined on the associated form `field` definition
* A `defaultValue` string that will be either the previously saved value for the field if there is one, _or_ the value of the `default` attribute set on the field definition
* An `error` string, populated if there are validation errors
* A `savedData` structure representing any saved data for the entire form
* A `layout` string that contains the viewlet that will be used to render the layout around the form control (this viewlet will usually take care of error messages and field labels, etc. see [[presideforms-rendering]])

### Examples

#### Simple textinput

A simple 'textinput' form control implemented as just a view (a viewlet without a handler) and with just a default "index" context:

```lucee
<!-- /views/formcontrols/textinput/index.cfm -->
<cfscript>
	inputName    = args.name         ?: "";
	inputId      = args.id           ?: "";
	inputClass   = args.class        ?: "";
	defaultValue = args.defaultValue ?: "";
	placeholder  = args.placeholder  ?: "";
	placeholder  = HtmlEditFormat( translateResource( uri=placeholder, defaultValue=placeholder ) );

	value  = event.getValue( name=inputName, defaultValue=defaultValue );
	if ( not IsSimpleValue( value ) ) {
		value = "";
	}

	value = HtmlEditFormat( value );
</cfscript>

<cfoutput>
	<input type="text" id="#inputId#" placeholder="#placeholder#" name="#inputName#" value="#value#" class="#inputClass# form-control" tabindex="#getNextTabIndex()#">
</cfoutput>
```

#### Select with custom datasource

This example uses a handler based viewlet to retrieve data from a service with which to populate the standard `select` form control. The form control name is `derivativePicker`:


```luceescript
// /handlers/formcontrols/DerivativePicker.cfc
component {
	property name="assetManagerService"  inject="assetManagerService";

	public string function index( event, rc, prc, args={} ) {
		var derivatives = assetManagerService.listEditorDerivatives();

		if ( !derivatives.len() ) {
		    return ""; // do not render the control at all if no derivatives
		}

		// translate derivatives into labels and values for select control
		// including default 'none' derivative for picker
		args.labels       = [ translateResource( "derivatives:none.title" ) ];
		args.values       = [ "none" ];
		args.extraClasses = "derivative-select-option";

		for( var derivative in derivatives ) {
			args.values.append( derivative );
			args.labels.append( translateResource( uri="derivatives:#derivative#.title", defaultValue="derivatives:#derivative#.title" ) );
		}

		// render default select control using labels and values
		// calculated above
		return renderView( view="formcontrols/select/index", args=args );
	}
}
```---
id: presideforms-merging
title: Merging Preside form definitions
---

## Merging Preside form definitions

The [[presideforms]] provides logic for merging form definitions. This is used in three ways:

* Extending form definitions
* Automatic merging of forms that match the same form ID but live in different locations (i.e. core, extensions, your application and site templates)
* Manual merging of multiple form definitions. For example, site tree page forms are merged from the core page form and form definitions for the page type of the page

## Extending form definitions

Forms can extend one another by using the `extends` attribute. The child form can then make modifications and additions to elements in its parent. For example:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form extends="preside-objects.page.add">
	<tab id="main">
		<fieldset id="main">
			<field binding="page.rank" sortorder="45" />
			<field name="layout" deleted="true" />
		</fieldset>
	</tab>
	<tab id="dates" deleted="true" />
</form>
```

## Automatic merging

One of the key features of Preside is the ability to augment and override features defined in the core and in extensions. The forms system is no different and allows any form definition to be modified by extensions, your application and by site templates.

To modify an existing form definition, you must create a corresponding file under your application or extension's `/forms` directory. For example, if you wanted to modify the core [[form-assetaddform]] that lives at `/forms/preside-objects/asset/admin.add.xml`, you would create an xml file at `/application/forms/preside-objects/asset/admin.add.xml` within your application.

All form definitions that match by relative path will be merged to create a single definition.

## Manual merging

The [[api-formsservice]] provides several methods for dealing with combined form definitions. The key methods are:

* [[formsservice-mergeForms]], merges two forms and returns merged definition
* [[formsservice-getMergedFormName]], returns the registered name of two merged forms and optionally performs the merge if the merge has not already been made

## Merging techniques

### Adding form elements

Form elements can be added simply by defining distinct elements in the secondary form. For example:

```xml
<!-- form 1 -->
<?xml version="1.0" encoding="UTF-8"?>
<form>
	<tab id="default">
		<fieldset id="default" sortorder="10">
			<field name="myfield" />
		</fieldset>
	</tab>
</form>
```

```xml
<!-- form 2 -->
<?xml version="1.0" encoding="UTF-8"?>
<form>
	<tab id="default">
		<fieldset id="default">
			<!-- adds a new field in the pre-existing "default" fieldset and "default" tab -->
			<field name="newfield" />
		</fieldset>
		<!-- a new fieldset with field in the "default" tab -->
		<fieldset id="advanced">
			<field name="obscureSetting" />
		</fieldset>
	</tab>
	<!-- a new tab with fieldset and field -->
	<tab id="special">
		<fieldset id="special">
			<field name="isSpecial" control="yesNoSwitch" />
		</fieldset>
	</tab>
</form>
```

### Modifying existing elements

Tabs, fieldsets and fields that already exist in the primary form can be modified by defining elements that match `id` (fieldsets and tabs) or `name` (fields) and then defining new or different attributes. For example:

```xml
<!-- form 1 -->
<?xml version="1.0" encoding="UTF-8"?>
<form>
	<tab id="default" sortorder="10">
		<fieldset id="default" sortorder="10">
			<field name="myfield" control="textinput" required="false" />
		</fieldset>
	</tab>
</form>
```

```xml
<!-- form 2 -->
<?xml version="1.0" encoding="UTF-8"?>
<form>
	<!-- change the sortorder on the "default" tab -->
	<tab id="default" sortorder="20">
		<!-- add a layout attribute to the "default" fieldset -->
		<fieldset id="default" layout="custom.fieldsetLayout">
			<!-- make 'myfield' required and add a 'maxLength' rule -->
			<field name="myfield" required="true" maxlength="100" />
		</fieldset>
	</tab>
</form>
```

### Deleting elements

Elements that exist in the primary form definition can be deleted from the definition by adding a `deleted="true"` flag to element in the secondary form. For example:


```xml
<!-- form 1 -->
<?xml version="1.0" encoding="UTF-8"?>
<form>
	<tab id="default" sortorder="10">
		<fieldset id="default" sortorder="10">
			<field name="myfield" control="textinput" required="false" />
			<field name="another" control="textinput" required="false" />
		</fieldset>
		<fieldset id="special" sortorder="20">
			<field name="specialField" />
		</fieldset>
	</tab>
	<tab id="extra" sortorder="20">
		<fieldset id="extra" sortorder="10">
			<field name="extraField" />
		</fieldset>
	</tab>
</form>
```

```xml
<!-- form 2 -->
<?xml version="1.0" encoding="UTF-8"?>
<form>
	<tab id="default">
		<fieldset id="default">
			<!-- delete the "another" field -->
			<field name="another" deleted="true" />
		</fieldset>
		<!-- delete the entire "special" fieldset -->
		<fieldset id="special" deleted="true" />
	</tab>
	<!-- delete the entire "extra" tab -->
	<tab id="extra" deleted="true" />
</form>
```---
id: presideforms-i18n
title: Preside form definitions and i18n
---

## Preside form definitions and i18n

Labels, help and placeholders for form controls, tabs and fieldsets can all be supplied through i18n properties files using Preside's [[i18n|i18n]] system. Resource URIs can be supplied either directly in your form definitions or by using convention combined with the `i18nBaseUri` attribute on your `form` elements (see [[presideforms-anatomy]]).

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form>
	<!-- Example of direct supplying of i18n resource URI for tab title -->
	<tab id="default" title="system-config.mailchimp:tab.default.title">
		<!-- ... -->
	</tab>
</form>
```

## Convention based i18n URIs

### Tabs

Tabs can have translatable titles, descriptions and icon classes. Convention is as follows:

* **Title:** `{i18nBaseUri}`tab.`{id}`.title
* **Description:** `{i18nBaseUri}`tab.`{id}`.description
* **Icon class:** `{i18nBaseUri}`tab.`{id}`.iconClass

For example, given the form definition below, the following i18n properties file definition will supply title, description and icon class by convention:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form i18nBaseUri="system-config.mailchimp:">
	<tab id="credentials">
		<!-- -->
	</tab>
</form>
```

```properties
# /i18n/system-config/mailchimp.properties
tab.credentials.title=Credentials
tab.credentials.description=Supply your API credentials to connect with your MailChimp account
tab.credentials.iconClass=fa-key
```

### Fieldsets

Fieldsets can have translatable titles and descriptions. Convention is as follows:

* **Title:** `{i18nBaseUri}`fieldset.`{id}`.title
* **Description:** `{i18nBaseUri}`fieldset.`{id}`.description

For example, given the form definition below, the following i18n properties file definition will supply title and description of the fieldset by convention:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form i18nBaseUri="system-config.mailchimp:">
	<tab id="credentials">
		<fieldset id="credentials">
			<!-- -->
		</fieldset>
	</tab>
</form>
```

```properties
# /i18n/system-config/mailchimp.properties
fieldset.credentials.title=Credentials
fieldset.credentials.description=Supply your API credentials to connect with your MailChimp account
```

### Fields


Fields can have translatable labels, help and, for certain controls, placeholders. Convention is as follows:

* **Label:** `{i18nBaseUri}`field.`{name}`.title
* **Help:** `{i18nBaseUri}`field.`{name}`.help
* **Placeholder:** `{i18nBaseUri}`field.`{name}`.placeholder

For example, given the form definition below, the following i18n properties file definition will supply label, placeholder and help text:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form i18nBaseUri="event-management.schedule-form:">
	<tab id="basic">
		<fieldset id="basic">
			<!-- -->
			<field name="session_title" control="textinput" />
			<!-- -->
		</fieldset>
	</tab>
</form>
```

```properties
# /i18n/event-management/session-form.properties
field.session_title.title=Session title
field.session_title.placeholder=e.g. 'Coffee and code'
field.session_title.help=Title for your session, will be displayed in public event listing pages
```

## Page types and Preside objects

Forms for page types and preside objects will have a _default_ `i18nBaseUri` set for them:

* **Page types:** page-types.`{pagetype}`:
* **Preside objects:** preside-objects.`{objectname}`:
---
id: presideforms-processing
title: Processing Preside form definitions
---

## Processing Preside form definitions

Once an HTML form has been submitted that contains one or more instances of Preside form definitions, you will likely want to process that submitted data. A typical example follows:

```luceescript
public void function myHandlerAction( event, rc, prc ) {
	var formName         = "my.form.definition";
	var formData         = event.getCollectionForForm( formName );
	var validationResult = validateForm( formName, formData );

	if ( !validationResult.validated() ) {
		var persist = formData;
		persist.validationResult = validationResult;

		setNextEvent(
			  url           = myEditViewUrl
			, persistStruct = persist
		);
	}
}
```

## Getting data from the request

It can be useful to get a structure of data from the request (i.e. the ColdBox `rc` scope) that contains purely the fields for your form. The `event.getCollectionForForm()` helper method is there for that purpose.

The helper can be called in two ways:

```luceescript
// 1. No arguments - system will detect the preside
// form(s) that have been submitted and get the data
// for those
var formData = event.getCollectionForForm();

// 2. Supplied form name
var formData = event.getCollectionForForm( "my.form.definition" );
```

As well as filtering out the request data, the method will also ensure that each field in the form definition exists. If the field was not in the submitted request (for example, a checkbox was left unticked), the field will be defaulted as an empty string.

## Getting the form(s) that were submitted

In usual circumstances, you will know the ID of the form that has been submitted. You may, however, find yourself in a situation where you have multiple dynamic form definitions creating a single HTML form and being submitted. In this scenario, you can use the `event.getSubmittedPresideForms()` method. For example:

```luceescript
// event.getSubmittedPresideForms(): returns array of
// submitted form names
var formNames = event.getSubmittedPresideForms();
var formData  = {};

for( var formName in formNames ) {
	formData[ formName ] = event.getCollectionForForm( formName );
}
```

## Validating submissions

There are two helper methods that you can use to quickly validate a submission, `validateForm()` and `validateForms()`. The first method is a proxy to the [[formsservice-validateform]] method of the [[api-formsservice]], the second is a helper to validate multiple forms at once. e.g.

```luceescript
// example one - explicit
var formName         = "my.form";
var formData         = event.getCollectionForForm( formName );
var validationResult = validateForm( formName, formData );

// example two - multiple dynamic forms
// the following validates all forms that were
// submitted
var validationResult = validateForms();
```

See [[presideforms-validation]] for more details of how the [[validation-framework]] is integrated with the form system.


## Auto-trimming submitted values

As of 10.11.0, it is possible to configure form submissions so all data returned by `event.getCollectionForForm()` is automatically stripped of leading and trailing whitespace. Application-wide configuration is set in `Config.cfc`:

```luceescript
// default settings in core Config.cfc
settings.autoTrimFormSubmissions = { admin=false, frontend=false };
```

By default, this is turned off for both admin and front-end applications, to maintain the existing behaviour. However, you can enable these in your own application's `Config.cfc`:

```luceescript
// This will auto-trim all submissions via the front-end of the website
settings.autoTrimFormSubmissions.frontend = true;
```

Your application can also override these settings on an individual basis, by specifying an `autoTrim` argument to `event.getCollectionForForm()`. For example:

```luceescript
var formData = event.getCollectionForForm( formName="my.form", autoTrim=true );
```

This will auto-trim the submitted data, even if the application default is not to do so. The reverse also applies: you may set `autoTrim=false` even if it is turned on for the application as a whole.

Finally, you can configure this on a per-property basis, either in your object definition or in your form definition. A property with an `autoTrim` setting will *always* obey that setting, regardless of what is defined in the application or in `event.getCollectionForForm()`. For example:

```luceescript
component {
	property name="a_field_with_preserved_spaces" type="string" dbtype="varchar" autoTrim=false;
}
```

or:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form>
	<tab>
		<fieldset>
			<field name="always_trim_this_field" autoTrim="true" />
		</fieldset>
	</tab>
</form>
```---
id: presideforms-features
title: Restricting Preside form elements by feature
---

## Restricting Preside form elements by feature

Preside has a concept of features that are configurable in your application's `Config.cfc`. Features can be enabled and disabled for your entire application, or individual site templates. This can be useful for turning off core features, or features in extensions.

In the Preside forms system, you can tag your forms, tabs, fieldsets and fields with feature names so that those elements are removed from the form definition when the feature is disabled.

### Examples

Tag an entire form with a feature ("cms"). If the feature is turned off, the entire form will be removed from the library of forms in the system:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form feature="cms">
	<!-- ... -->
</form>
```

Remove a _tab_ in a form when the "websiteusers" feature is disabled:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form>
	<!-- ... -->
	<tab id="access" feature="websiteusers">
		<!-- ... -->
	</tab>
</form>
```


Remove a _fieldset_ in a form when the "websiteusers" feature is disabled:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form>
	<!-- ... -->
	<tab id="access">
		<fieldset id="general">
			<!-- ... -->
		</fieldset>
		<fieldset id="users" feature="websiteusers">
			<!-- ... -->
		</fieldset>
	</tab>
</form>
```

Remove a _field_ in a form when the "websiteusers" feature is disabled:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form>
	<!-- ... -->
	<tab id="access">
		<fieldset id="access">
			<field name="country_restriction" ... />
			<field name="website_benefit" feature="websiteusers" />
		</fieldset>
	</tab>
</form>
```---
id: presideforms-presideobjects
title: Using Preside data objects with form definitions
---

## Using Preside data objects with form definitions

### Field bindings

The `binding` attribute on field definitions allows you to pull in attributes and i18n defaults from preside object properties:

```xml
<field binding="page.title" />
```

In the example above, the field's definition will be taken from the `title` property of the `page` object (CFC file). A default [[presideforms-controls|form control]] will be assigned to the field based on the property type and other attributes. The title, help and placeholder will be defaulted to `preside-objects.page:field.title.title`, `preside-objects.page:field.title.help` and `preside-objects.page:field.title.placeholder`.

### Default forms

If you attempt to make use of a form that does not have an XML definition and whose name starts with "preside-objects.name_of_object.", a default form will be returned based on the preside object CFC file (in this case, "name_of_object"). 

For example, if there is no `/forms/preside-objects/blog_category/admin.add.xml` file defined and we do something like the call below, an automatic form definition will be used based on the `blog_category` preside object:

```luceescript
renderForm( ... formName="preside-objects.blog_category.admin.add", ... );
```

A notable use of this convention is in the Data Manager where you can create simple object definitions and just use their default form for adding and editing records. 
---
id: presideforms-dynamic
title: Dynamically generating Preside form definitions
---

## Dynamically generating Preside form definitions

As of Preside v10.6.0, the [[api-formsservice]] provides a [[formsservice-createform]] method for dynamically creating forms without the need for an XML definition file. This can be useful in scenarios where the form can take on many different fields that will differ depending on the current user context.

Example usage:

```luceescript
var newFormName = formsService.createForm( function( formDefinition ){

	formDefinition.setAttributes(
		i18nBaseUri = "forms.myform:"
	);

	formDefinition.addField(
		  tab       = "default"
		, fieldset  = "default"
		, name      = "title"
		, control   = "textinput"
		, maxLength = 100
		, required  = true
	);

	formDefinition.addField(
		  tab      = "default"
		, fieldset = "default"
		, name     = "body"
		, control  = "richeditor"
		, required = true
	);

} );
```

As seen in the example above, the method works by supplying a closure that takes a [[api-formdefinition]] object as its argument. You can then use the [[api-formdefinition]] object to build your form definition (see [[api-formdefinition]] for full API documentation).

## Extending existing forms

As well as creating forms from scratch, you can also extend an existing form by supplying the `basedOn` argument:

```luceescript
var newFormName = formsService.createForm( basedOn="existing.form", generator=function( formDefinition ){

	formDefinition.addField(
		  tab       = "default"
		, fieldset  = "default"
		, name      = "title"
		, control   = "textinput"
		, maxLength = 100
		, required  = true
	);

	// ...
} );
```

## Specifying a form name

By default, a form name will be generated for you and returned. If you wish, however, you can supply your own form name for the dynamically generated form:

```luceescript
formsService.createForm( basedOn="existing.form", formName="my.new.form", generator=function( formDefinition ){

	formDefinition.addField(
		  tab       = "default"
		, fieldset  = "default"
		, name      = "title"
		, control   = "textinput"
		, maxLength = 100
		, required  = true
	);

	// ...
} );
```

>>>> Be careful when specifying a form name. Should two dynamically generated forms share the same name but have different form definitions, you will run into problems. Form names should be unique per distinct definition.---
id: presideforms-permissioning
title: Restricting Preside form elements by permission key
---

## Restricting Preside form elements by permission key

As of Preside 10.8.0, the forms system allows you to restrict individual `field`, `fieldset` and `tab` elements by an _admin_ **permission key** (see [[cmspermissioning]] for full details of the admin permissioning system). Simply tag your element with a `permissionKey` attribute to indicate the permission key that controls access to the `field`/`fieldset`/`tab`.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form>
	<!-- only users with 'standard.editing' perms will see this tab -->
	<tab id="default" permissionKey="standard.editing">
		<fieldset id="default" sortorder="10">
			<field binding="myobject.title"       />
			
			<!-- only users with 'slug.edit' perms will see this field -->
			<field binding="myobject.slug" permissionkey="slugs.edit" />
		</fieldset>
		
		<!-- only users with 'advanced.editing' perms will see this fieldset -->
		<fieldset id="advanced" sortorder="10" permissionkey="advanced.editing">
			<field binding="myobject.title"       />
			<field binding="myobject.description" />
		</fieldset>
	</tab>
</form>
```

### Context permissions

If you are building a custom admin area and you are rendering and validating forms with permissions that are _context aware_ (see [[cmspermissioning]]), you can supply the context and context keys to the various methods for interacting with forms to ensure that the correct permissions are applied. For example:

```lucee
#renderForm(
	  formName              = "my.form"
	, permissionContext     = "myContext"
	, permissionContextKeys = [ contextId ]
 // , ...
)#
```

```luceescript
var formData = event.getCollectionForForm(
	  formName              = "my.form"
	, permissionContext     = "myContext"
	, permissionContextKeys = [ contextId ]
);
var validationResult = validateForm( 
	  formName              = "my.form"
	, formData              = formData
	, permissionContext     = "myContext"
	, permissionContextKeys = [ contextId ] 
);
```

>>> If you are unsure what context permissions mean, then you probably don't need to worry about them for getting your form permissions to work. The default settings will work well for any situation where you have not created any custom logic for context aware permissioning.---
id: presideforms-validation
title: Preside form validation
---

## Preside form validation

The [[presideforms]] integrates with the [[validation-framework]] to provide automatic *validation rulesets* for your preside form definitions and API methods to quickly and easily validate a submitted form (see [[presideforms-processing]]).

The validation rulesets are generated in two ways:

1. Common attributes on fields that lead to validation rules, e.g. `required`, `maxLength`, etc.
2. Explicit validation rules defined on fields

## Common attributes

The following attributes on field definitions will lead to automatic validation rules being defined for the field. Remember also that any attributes defined on a preside object property will be pulled into a field definition when using `<field binding="objectname.propertyname" />`.

### required

Any field with a `required="true"` flag will automatically have a `required` validator added to the forms ruleset.

### minLength

Any field with a numeric `minLength` attribute will automatically have a `minLength` validator added to the forms ruleset. If the field has both `minLength` and `maxLength`, it will instead have a `rangeLength` validator added.

### maxLength

Any field with a numeric `maxLength` attribute will automatically have a `maxLength` validator added to the forms ruleset. If the field has both `minLength` and `maxLength`, it will instead have a `rangeLength` validator added.

### minValue

Any field with a numeric `minValue` attribute will automatically have a `min` validator added to the forms ruleset. If the field has both `maxValue` and `minValue`, it will instead have a `range` validator added.

### maxValue

Any field with a numeric `maxValue` attribute will automatically have a `max` validator added to the forms ruleset. If the field has both `minValue` and `maxValue`, it will instead have a `range` validator added.

### format

If a string field has a `format` attribute, a pattern matching validation rule will be added.

### type

For preside object properties that are mapped to form fields, the data type will potentially have an associated validation rule that will be added for the field. For example, date fields will get a valid `date` validator.

### uniqueindexes

For preside object properties that are mapped to form fields and that define unique indexes, a `presideObjectUniqueIndex` validator will be automatically added. This validator is server-side only and ensure that the value in the field is unique and will not break the unique index constraint.

### passwordPolicyContext

If a password field has a `passwordPolicyContext` attribute, the field will validate against the given password policy. Current supported contexts are `website` and `admin`.

## Explicit validation rules

Explicit validation rules can be set on a field with the following syntax:

```xml
<field name="name" control="textinput" required="true" sortorder="20">
	<rule validator="match" message="formbuilder.item-types.formfield:validation.error.invalid.name.format">
		<param name="regex" value="^[a-zA-Z][a-zA-Z0-9_]*$" />
	</rule>
</field>
```

Each rule must specify a `validator` attribute that matches a registered [[validation-framework]] validator. An optional `message` attribute can also be supplied and this can be either a plain string message, or [[i18n]] resource URI for translation.

Any configuration parameters for the ruleset are then defined in child `param` tags that always have `name` and `value` attributes.---
id: presideforms-anatomy
title: Anatomy of a Preside form definition file
---

## Anatomy of a Preside form definition file

### Form element

All forms must have a root `form` element that contains one or more `tab` elements. 

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form i18nBaseUri="system-config.sentry:" tabsPlacement="left" extends="my.other.form">
    <tab>
        <!-- ... -->
    </tab>
</form>
```

#### Attributes

<div class="table-responsive">
    <table class="table">
        <tbody>
            <tr>
                <th>i18nBaseUri (optional)</th>
                <td>Base i18n resource URI to be used when calculating field labels, tab titles, etc. using convention. For example, "my.form:" would lead to URIs such as "my.form:tab.basic.title", etc.</td>
            </tr>
            <tr>
                <th>tabsPlacement (optional)</th>
                <td>Placement of the tabs UI in the admin. Valid values are: left, right, below and top (default)</td>
            </tr>
            <tr>
                <th>extends (optional)</th>
                <td>ID of another form whose definition this form should inherit and extend. See [[presideforms-merging]] for more details.</td>
            </tr>
        </tbody>
    </table>
</div> 


### Tab element

The tab element defines a tab pane. In the admin interface, tabs will appear using a twitter bootstrap tabs UI; how tabs appear in your application's front end is up to you. All forms must have at least one tab element; a form with only a single tab will be displayed without any tabs UI.

A tab element must contain one or more `fieldset` elements.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form i18nBaseUri="system-config.sentry:" tabsPlacement="left">
    <tab id="auth" sortorder="10">
        ...
    </tab>
    <tab id="advanced" sortorder="20">
        ...
    </tab>
</form>
```

#### Attributes

All attributes below are optional, although `id` is strongly advised. `title` and `description` attributes can be left out and defined using convention in i18n `.properties` file (see the `i18nBaseUri` form attribute above).

<div class="table-responsive">
    <table class="table">
        <tbody>
            <tr>
                <th>id</td>
                <td>A unique identifier value for the tab, e.g. "standard"</td>
            </tr>
            <tr>
                <th>sortorder</td>
                <td>A value to determine the order in which the tab will be displayed. The lower the number, the earlier the tab will be displayed.</td>
            </tr>
            <tr>
                <th>title</td>
                <td>A value that will be used for the tab title text. If not supplied, this will default to {i18nBaseUrl}tab.{tabID}.title (see [[presideforms-i18n]] for more details).</td>
            </tr>
            <tr>
                <th>iconClass</td>
                <td>Class to use to render an icon for the tab, e.g. "fa-calendar" (we use Font Awesome for icons). If not supplied, this will default to {i18nBaseUrl}tab.{tabID}.iconClass (see [[presideforms-i18n]] for more details).</td>
            </tr>
            <tr>
                <th>decription</td>
                <td>A value that will be used for the tab and generally output within the tab content section. If not supplied, this will default to {i18nBaseUrl}tab.{tabID}.description (see [[presideforms-i18n]] for more details).</td>
            </tr>
        </tbody>
    </table>
</div>

### Fieldset elements

A fieldset element can be used to group associated form elements together and for providing some visual indication of that grouping.

A fieldset must contain one or more `field` elements.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form i18nBaseUri="system-config.sentry:" tabsPlacement="left">
    <tab id="auth" sortorder="10">
        <fieldset id="authbasic" sortorder="10">
            ...
        </fieldset>
        <fieldset id="authadvanced" sortorder="10">
            ...
        </fieldset>
    </tab>
    ...
</form>
```

#### Attributes

<div class="table-responsive">
    <table class="table">
        <tbody>
            <tr>
                <th>id</th>
                <td>A unique identifier value for the fieldset, e.g. "main"</td>
            </tr>
            <tr>
                <th>title</th>
                <td>A value or i18n resource URI that will be used for the fieldset title text. If not supplied, this will default to {i18nBaseUrl}fieldset.{fieldsetID}.title (see [[presideforms-i18n]] for more details).</td>
            </tr>
            <tr>
                <th>decription</th>
                <td>A value or i18n resource URI that will be used for the fieldsets description that will be displayed before any form fields in the fieldset. If not supplied, this will default to {i18nBaseUrl}fieldset.{fieldsetID}.description (see [[presideforms-i18n]] for more details).</td>
            </tr>
            <tr>
                <th>sortorder</th>
                <td>A value to determine the order in which the fieldset will be displayed within the parent tab. The lower the number, the earlier the fieldset will be displayed.</td>
            </tr>
        </tbody>
    </table>
</div>

### Field elements

`Field` elements define an input field for your form. The attributes required for the field will vary depending on the form control defined (see [[presideforms-controls]]).

A `field` element can have zero or more `rule` child elements for defining customized validation rules.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form i18nBaseUri="system-config.sentry:" tabsPlacement="left">
    <tab id="auth" sortorder="10">
        <fieldset id="authbasic" sortorder="10">
            <field name="api_token" control="password" maxLength="50" />
            <field binding="sentry.configuration_option" />
        </fieldset>
        ...
    </tab>
    ...
</form>
```

#### Attributes

<div class="table-responsive">
    <table class="table">
        <tbody>
            <tr>
                <th>name</th>
                <td>Unique name of the form field. Required if binding is not used. </td>
            </tr>
            <tr>
                <th>binding</th>
                <td>Defines a preside object property from which to derive the field definition. Required if name is not used. See [[presideforms-presideobjects]] for further details.</td>
            </tr>
            <tr>
                <th>control</th>
                <td>Form control to use for the field (see [[presideforms-controls]]). If not supplied and a preside object property binding is defined, then the system will automatically select the appropriate control for the field. If not supplied and no binding is defined, then a default of "textinput" will be used.</td>
            </tr>
            <tr>
                <th>label</th>
                <td>A label for the field. If not supplied, this will default to {i18nBaseUrl}field.{fieldName}.title (see [[presideforms-i18n]] for more details).</td>
            </tr>
            <tr>
                <th>placeholder</th>
                <td>Placeholder text for the field. Relevant for form controls that use a placeholder (text inputs and textareas). If not supplied, this will default to {i18nBaseUrl}field.{fieldName}.placeholder (see [[presideforms-i18n]] for more details).</td>
            </tr>
            <tr>
                <th>help</th>
                <td>Help text to be displayed in help tooltip for the field. If not supplied, this will default to {i18nBaseUrl}field.{fieldName}.help (see [[presideforms-i18n]] for more details).</td>
            </tr>
            <tr>
                <th>sortorder</th>
                <td>A value to determine the order in which the field will be displayed within the parent fieldset. The lower the number, the earlier the field will be displayed.</td>
            </tr>
        </tbody>
    </table>
</div>

### Rule elements

A `rule` element must live beneath a `field` element and can contain zero or more `param` attributes. A rule represents a validation rule and deeply integrates with the [[validation-framework]]. See [[presideforms-validation]] for full details of validation with preside forms.

```xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<form i18nBaseUri="system-config.sentry:" tabsPlacement="left">
    <tab id="auth" sortorder="10">
        <fieldset id="authbasic" sortorder="10">
            <field name="api_token" control="password" maxLength="50" />
            <field name="repeat_api_token" control="password">
                <rule validator="sameAs" message="system-config.sentry:api_token.match.validation.message">
                    <param name="field" value="api_token" />
                </rule>
            </field>
            <field binding="sentry.configuration_option" />
        </fieldset>
        ...
    </tab>
    ...
</form>
```

Param elements consist of a name and value pair and will differ for each validator.

#### Attributes

<div class="table-responsive">
    <table class="table">
        <tbody>
            <tr>
                <th>validator</th>
                <td>ID of the validator to use (see [[validation-framework]] for full details on validators) </td>
            </tr>
            <tr>
                <th>message</th>
                <td>Message to display for validation errors. Can be an i18n resource URI for translatable validation messages.</td>
            </tr>
        </tbody>
    </table>
</div>---
id: cmspermissioning
title: CMS permissioning
---

## Overview

CMS Permissioning is split into three distinct concepts in Preside:

### Permissions and roles

These are defined in configuration and are not editable through the CMS GUI.

* **Permissions** allow you to grant or deny access to a particular action
* **Roles** provide convenient grant access to one or more permissions

### Users and groups

Users and groups are defined through the administrative GUI and are stored in the database.

* An *active* **user** must belong to one or more groups
* A **group** must have one or more *roles*

Permissions are granted to a user through the roles that are associated with the groups that she belongs to.

### Contextual permissions

Contextual permissions are fine grained permissions implemented specifically for any given area of the CMS that requires them.

For example, you could deny the "*Freelancers*" user group the "*Add pages*" permission for a particular page and its children in the sitetree; in this case, the context is the ID of the page.

Contextual permissions are granted or denied to user **groups** and always take precedence over permissions granted through groups and roles.

>>> If a feature of the CMS requires context permissions, it must supply its own views and handlers for managing them. Preside helps you out here with a viewlet and action handler for some common UI and saving logic, see 'Rolling out Context Permission GUIs', below.

## Configuring permissions and roles

Permissions and roles are configured in your site or extension's `Config.cfc` file. An example configuration might look like this:

```luceescript

public void function configure() {
    super.configure();

// PERMISSIONS
    // here we define a feature, "analytics dashboard" with a number of permissions
    settings.adminPermissions.analyticsdashboard = [ "navigate", "share", "configure" ];

    // features can be organised into sub-features to any depth, here
    // we have a depth of two, i.e. "eventmanagement.events"
    settings.adminPermissions.eventmanagement = {
          events = [ "navigate", "view", "add", "edit", "delete" ]
        , prices = [ "navigate", "view", "add", "edit", "delete" ]
    };

    // The settings above will translate to the following permission keys being
    // available for use in your Railo code, i.e. if ( hasCmsPermission( userId, permissionKey ) ) {...}:
    //
    // analyticsdashboard.navigate
    // analyticsdashboard.share
    // analyticsdashboard.configure
    //
    // eventmanagement.events.navigate
    // eventmanagement.events.view
    // eventmanagement.events.add
    // eventmanagement.events.edit
    // eventmanagement.events.delete
    //
    // eventmanagement.prices.navigate
    // eventmanagement.prices.view
    // eventmanagement.prices.add
    // eventmanagement.prices.edit
    // eventmanagement.prices.delete

// ROLES
    // roles are simply a named array of permission keys
    // permission keys for roles can be defined with wildcards (*)
    // and can be excluded with the ! character:

    // define a new role, with all event management perms except for delete
    settings.adminRoles.eventsOrganiser = [ "eventmanagement.*", "!*.delete" ];

    // another new role specifically for analytics viewing
    settings.roles.analyticsViewer = [ "analyticsdashboard.navigate", "analyticsdashboard.share" ];

    // add some new permissions to some existing core roles
    settings.adminRoles.administrator = settings.roles.administrator ?: [];
    settings.adminRoles.administrator.append( "eventmanagement.*" );
    settings.adminRoles.administrator.append( "analyticsdashboard.*" );

    settings.adminRoles.someRole = settings.roles.someRole ?: [];
```

### Defining names and descriptions (i18n)

Names and descriptions for your roles and permissions must be defined in i18n resource bundles.

For roles, you should add *name* and *description* keys for each role to the `/i18n/roles.properties` file, e.g.

```properties
eventsOrganiser.title=Events organiser
eventsOrganiser.description=The event organiser role grants aspects to all aspects of event management in the CMS except for deleting records (which must be done by the administrator)

analyticsViewer.title=Analytics viewer
analyticsViewer.description=The analytics viewer role grants permission to view statistics in the analytics dashboard
```

As of **10.24.0**, you can group your roles. Grouping are defined as `{your role}.group=value` and `roleGroup.{your role group}.title=Label`. For example:

```properties
roleGroup.event.title=Event

eventsOrganiser.group=event
```

For permissions, add your keys to the `/i18n/permissions.properties` file, e.g.


```properties
eventmanagement.events.navigate.title=Events management navigation
eventmanagement.events.navigate.description=View events management navigation links

eventmanagement.events.view=title=View events
eventmanagement.events.view=description=View details of events that have been entered into the system
```

>>> For permissions, you may only want to create resource bundle entries when the permissions will be used in contextual permission GUIs. Otherwise, the translations will never be used.

## Applying permissions in code with hasCmsPermission()

When you wish to permission control a given system feature, you should use the `hasCmsPermission()` method. For example:

```luceescript
// a general permission check
if ( !hasCmsPermission( permissionKey="eventmanagement.events.navigate" ) ) {
    event.adminAccessDenied(); // this is a preside request context helper
}

// a contextual permission check. In this case:
// "do we have permission to add folders to the asset folder with id [idOfCurrentFolder]"
if ( !hasCmsPermission( permissionKey="assetManager.folders.add", context="assetmanagerfolders", contextKeys=[ idOfCurrentFolder ] ) ) {
    event.adminAccessDenied(); // this is a preside request context helper
}
```

>>> The `hasCmsPermission()` method has been implemented as a ColdBox helper method and is available to all your handlers and views. If you wish to access the method from your services, you can access it via the `permissionService` service object, the core implementation of which can be found at `/preside/system/api/security/PermissionService.cfc`.

## Rolling out Context Permission GUIs

Should a feature you are developing for the admin require contextual permissions management, you can make use of a viewlet helper to give you a visual form and handler code to manage them.

For example, if we want to be able to manage permissions on event management *per* event, we might have a view at `/views/admin/events/managePermissions.cfm`, that contained the following code:

```lucee
#renderViewlet( event="admin.permissions.contextPermsForm", args={
      permissionKeys = [ "eventmanagement.events.*", "!*.managePerms" ] <!--- permissions that you want to manage within the form --->
    , context        = "eventmanager"
    , contextKey     = eventId
    , saveAction     = event.buildAdminLink( linkTo="events.saveEventPermissionsAction", querystring="id=#eventId#" )
    , cancelAction   = event.buildAdminLink( linkTo="events.viewEvent", querystring="id=#eventId#" )
} )#
```

Our `admin.events.saveEventPermissionsAction` handler action might then look like this:

```luceescript
function saveEventPermissionsAction( event, rc, prc ) {
    var eventId = rc.id ?: "";

    // check that we are allowed to manage the permissions of this event, or events in general ;)
    if ( !hasCmsPermission( permissionKey="eventmanager.events.manageContextPerms", context="eventmanager", contextKeys=[ eventId ] ) ) {
      event.adminAccessDenied();
    }

    // run the core 'admin.Permissions.saveContextPermsAction' event
    // this will save the permissioning configured in the
    // 'admin.permissions.contextPermsForm' form
    var success = runEvent( event="admin.Permissions.saveContextPermsAction", private=true );

    // redirect the user and present them with appropriate message
    if ( success ) {
      messageBox.info( translateResource( uri="cms:eventmanager.permsSaved.confirmation" ) );
      setNextEvent( url=event.buildAdminLink( linkTo="eventmanager.viewEvent", queryString="id=#eventId#" ) );
    }

    messageBox.error( translateResource( uri="cms:eventmanager.permsSaved.error" ) );
    setNextEvent( url=event.buildAdminLink( linkTo="events.managePermissions", queryString="id=#eventId#" ) );
}
```

## System users

Users that are defined as **system users** are exempt from all permission checking. In effect, they are granted access to **everything**. This concept exists to enable web agencies to manage every aspect of a site while setting up more secure access for their clients.

System users are only configurable through your site's `Config.cfc` file as a comma separated list of login ids. The default value of this setting is 'sysadmin'. For example, in your site's Config.cfc, you might have:

```luceescript
 public void function configure() {
    super.configure();

    // ...

    settings.system_users = "sysadmin,developer"; // both the 'developer' and 'sysadmin' users are now defined as system users
  }
```
---
id: sessionmanagement
title: Session management and stateless requests
---

# Session management

All session management in the core platform is handled by the [SessionStorage ColdBox plugin](http://wiki.coldbox.org/wiki/Plugins:SessionStorage.cfm). Your applications and extensions should also _always_ use this plugin when needing to store data against the session, rather than use the session scope directly.

By default, we use Lucee's session management for our session implementation, but as of Preside 10.12.0, we have created our own implementation which you can turn on.

## Turning on Preside's session management

The advantages of using Preside's Session Management are:

* Very simple database implementation
* Clean session tidying
* Simplified cookie management
* Lean implementation for better performance
* Simple to use in any environment, including Kubernetes and other containerised environments

To use Preside's session management, modify your app's `Application.cfc` to look something like:

```luceescript
component extends="preside.system.Bootstrap" {

	super.setupApplication(
		  id                       = "my-application"
		, presideSessionManagement = true
	);

}
```

## Accessing the session storage plugin

### In a handler

```luceescript
property name="sessionStorage" inject="coldbox:plugin:sessionStorage";

// or...

var sessionStorage = getPlugin( "sessionStorage" );
```

### In a service

```luceescript
/**
 * @singleton
 * @presideservice
 *
 */
component {

	/**
	 * @sessionStorage.inject coldbox:plugin:sessionStorage
	 *
	 */
	public any function init( required any sessionStorage ) {
		// set the session storage plugin to some local variable for later use
	}

}
```

Or

```luceescript
/**
 * @singleton
 * @presideservice
 *
 */
component {

	property name="sessionStorage" inject="coldbox:plugin:sessionStorage";

	// ...

}
```

## Using the session storage plugin

See the [ColdBox wiki for full documentation](http://wiki.coldbox.org/wiki/Plugins:SessionStorage.cfm).

# Stateless requests

As of v10.5.0, Preside comes with some configuration options for automatically serving "stateless" requests which turn off session management and ensure that no cookies are set. This is useful for things like [[restframework|REST API requests]], scheduled tasks, and known bots and spiders.

## Default implementation

The default implementation will flag the following requests as being stateless and not create sessions or cookies for them:

* Any request path starting with `/api/` (the default pattern for the [[restframework|REST Framework]])
* Lucee Scheduled Task requests (matching user agent 'CFSCHEDULE')
* Requests flagged as bot or spider requests, matched on user agent

## Overriding the default implementation

### Method 1: SetupApplication()

In your site's `Application.cfc`, you can pass arrays of user agent and URL regex patterns to the `setupApplication()` method that will be treated as stateless. These will _override_ the core defaults. For example:

```luceescript
component extends="preside.system.Bootstrap" {

	super.setupApplication(
		  id                         = "my-site"
		, statelessUrlPatterns       = [ "https?://static\..*" ]
		, statelessUserAgentPatterns = [ "CFSCHEDULE", "bot\b", "spider\b" ]
	);

}
```

In the example above the `statelessUrlPatterns` argument gives a single URL pattern that states that any URL with a "static." sub-domain will be treated as stateless. The `statelessUserAgentPatterns` argument, specifies that the "CFSCHEDULE" user agent, along with some simple bot patterns will be treated as stateless requests.

### Method 2: isStatelessRequest()

In your site's `Application.cfc`, implement the `isStatelessRequest( fullUrl )` method that must return `true` for stateless requests and `false` otherwise. For example:

```luceescript
component extends="preside.system.Bootstrap" {

	super.setupApplication(
		id = "my-site"
	);

	private boolean function isStatelessRequest( required string fullUrl ) {
		var isStateless = false;

		// add some custom logic to define stateless requests
		// ...

		return isStateless;
	}

}
```

You could also use a combination of both methods:

```luceescript
component extends="preside.system.Bootstrap" {

	// set custom URL and user agent patterns
	super.setupApplication(
		  id                         = "my-site"
		, statelessUrlPatterns       = [ "https?://static\..*" ]
		, statelessUserAgentPatterns = [ "CFSCHEDULE", "bot\b", "spider\b" ]
	);

	private boolean function isStatelessRequest( required string fullUrl ) {
		// use the core `isStatelessRequest()` method to act
		// on the URL and User agent patterns
		var isStateless = super.isStatelessRequest( argumentCollection=arguments );

		// your own extended logic
		if ( !isStateless ) {
			// add some further custom logic to define stateless requests
			// ...

		}

		return isStateless;
	}

}
```---
id: dataobjectviews
title: Data object views
---

## Overview

Preside provides a feature that allows you to autowire your data model to your views, completely bypassing hand written handlers and service layer objects. Rendering one of these views looks like this:

```lucee
#renderView(
      view          = "events/preview"
    , presideObject = "event"
    , filter        = { event_category = rc.category }
)#
```

In the example above, the `/views/events/preview.cfm` view will get rendered for each *event* record that matches the supplied filter, `{ event_category = rc.category }`. Each rendered view will be passed the database fields that it needs as individual arguments.

In order for the `renderView()` function to know what fields to select for your view, the view itself must declare what fields it requires. It does this using the `<cf_presideparam>` custom tag. Using our "event preview" example from above, our view file might look something like this:

```lucee
<cf_presideparam name="args.label"                                  /><!-- I need the 'label' field -->
<cf_presideparam name="args.teaser"                                 /><!-- I need the 'teaser' field -->
<cf_presideparam name="args.image"                                  /><!-- I need the 'image' field -->
<cf_presideparam name="args.event_type_id" field="event_type"       /><!-- I need the 'event_type' field, but aliased to 'event_type_id' -->
<cf_presideparam name="args.event_type"    field="event_type.label" /><!-- I need the 'label' field from the relatated object, event_type, aliased to 'event_type' -->

<cfparam name="_counter" type="numeric" /><!-- current row in the recordset being rendered -->
<cfparam name="_records" type="numeric" /><!-- total records in the recordset being rendered -->

<cfoutput>
    <div class="preview-pane">
        <h3>#args.label#</h3>
        <p class="event-type">
            <a href="#event.buildLink( pageId=args.event_type_id )#">
                #args.event_type#
            </a>
        </p>

        #renderAsset( assetId=args.image, context="previewPane" )#

        <p>#args.teaser#</p>
    </div>
</cfoutput>
```

>>> We introduced the `<cf_presideparam` custom tag in **Preside 10.2.4**. Prior to this, we used the `<cfparam` tag for this feature. The
`<cfparam` tag approach will continue to work in version 10 but we may decide to drop this support in future versions. This change is due to an unforeseen incompatibility with Adobe ColdFusion.

Given the examples above, the SQL you would expect to be automatically generated and executed for you would look something like this:

```sql
select     event.label
         , event.teaser
         , event.image
         , event.event_type as event_type_id
         , event_type.label as event_type

from       pobj_event      event
inner join pobj_event_type event_type on event_type.id = event.event_type

where      event.event_category = :event_category
```

## Filtering the records to display

Any arguments that you pass to the `renderView()` method will be passed on to the Preside Object `selectData()` method when retrieving the records to be rendered.

This means that you can specify any number of valid `selectData()` arguments to filter and sort the records for display. e.g.

```luceescript
rendered = renderView(
      view          = "event/detail"
    , presideObject = "event"
    , id            = eventId
);

rendered = renderView(
      view          = "event/preview"
    , presideObject = "event"
    , filter        = "event_type != :event_type or comment_count < :comment_count"
    , filterParams  = { event_type=rc.type, comment_count=10 }
    , startRow      = 11
    , maxRows       = 10
    , orderBy       = "datepublished desc"
);
```

## Declaring fields for your view

As seen in the examples above, the `<cf_presideparam>` tag is used by your view to specify what fields it needs to render. Any variable that is declared that starts with "args." will be considered a field on your preside object by default.

If we are rendering a view for a **news**  object, the following param will lead to `news.headline` being retrieved from the database:

```lucee
<cf_presideparam name="args.headline" />
```


### Aliases

You may find that you need to have a different variable name to the field that you need to select from the data object. To achieve this, you can use the `field` attribute to specify the name of the field:

```lucee
<cf_presideparam name="args.headline" field="news.label" />
```

You can use the same technique to do aggregate fields and any other SQL select goodness that you want:

```lucee
<cf_presideparam name="args.headline"      field="news.label" />
<cf_presideparam name="args.comment_count" field="Count( comments.id )" />
```

### Getting fields from other objects

For one to many style relationships, where your object is the many side, you can easily select fields from the related object using the `field` attribute shown above. Simply prefix the column name with the name of the foreign key field on your object. For example, if our **news** object has a single **news_category** field that is a foreign key to a category lookup, we could get the title of the category with:

```lucee
<cf_presideparam name="args.headline" field="news.label" />
<cf_presideparam name="args.category" field="news_category.label" />
```

### Front end editing

If you would like a field to be editable in the front end website, you can set the `editable` attribute to **true**:

```lucee
<cf_presideparam name="args.label" editable="true" />
```

### Accepting arguments that do not come from the database

Your view may need some variables that do not come from the database. For example, in the code below, the view is being passed the `showComments` argument that does not exist in the database.

```lucee
#renderView( view="myview", presideObject="news", args={ showComments=false } )#
```

To allow this to work, you can specify `field="false"`, so:

```lucee
<cf_presideparam name="args.headline" field="news.label" />
<cf_presideparam name="args.category" field="news_category.label" />
<cfparam name="args.showComments"     field="false" type="boolean" />
```

This looks as though it should not be necessary because we are using the `<cfparam` tag to state that we expect the `args.showComments` variable to be available. However, the `cfparam` tag is still supported here for backward compatibility with versions of Preside prior to **10.2.4**. As an alternative approach, one can use something like:

```lucee
<cf_presideparam name="args.headline" field="news.label" />
<cf_presideparam name="args.category" field="news_category.label" />

<cfset showComments = IsTrue( args.showComments ?: "" ) />
```

### Defining renderers

Each of the fields fetch from the database for your view will be pre-rendered using the default renderer for that field. So fields that use a richeditor will have their Widgets and embedded assets all ready rendered for you. To specify a different renderer, or to specify renderers on calculated fields, do:

```lucee
<cf_presideparam name="args.comment_count" field="Count( comments.id )" renderer="myNumberFormatter" />
```

## Caching

You can opt to cache your preside data object views by passing in caching arguments to the [[presideobjectviewservice-renderView]] method. A minimal example:

```luceescript
rendered = renderView(
      view          = "event/detail"
    , presideObject = "event"
    , id            = eventId
    , cache         = true     // cache with sensible default settings
);
```

See the [[presideobjectviewservice-renderView]] method documentation for details on all the possible arguments.


---
id: multilingualcontent
title: Multilingual content
---

## Overview

Preside comes packaged with a powerful multilingual content feature that allows you to make your client's pages and other data objects translatable to multiple languages.

Enabling multilingual translations is a case of:

1. Enabling the feature in your `Config.cfc` file
2. Marking the preside objects that you wish to be multilingual with a `multilingual` flag
3. Marking the specific properties of preside objects that you wish to be multilingual with a `multilingual` flag
4. Optionally providing specific form layouts for translations
5. Providing a mechanism in the front-end application for users to choose from configured languages

Once the multilingual content feature is enabled, Preside will provide a basic UI for allowing CMS administrators to translate content and to configure what languages are available. When selecting data for display in your application, Preside will automatically select translations of your multilingual properties for you when available for the currently selected language. If no translation is available, the system will fall back to the default content.

![Screenshot showing selection of configured languages](images/screenshots/select_translations.png)

## Enabling multilingual content

### Global config

Enabling the feature in your applications's `Config.cfc` file is achieved as follows:

```luceescript
public void function configure() {
    super.configure();

    // ...

    settings.features.multilingual.enabled = true;
```


### Configuring specific data objects

Configuring individual [[presidedataobject|Preside Objects]] is done using a `multilingual=true` flag on both the component itself and any properties you wish to be translatable:

```luceescript
/**
 * @multilingual true
 *
 */
component {
    property name="title" multilingual=true // ... (multilingual)
    property name="active" // ... (not multilingual)
}
```

## Configuring languages

Configuring languages is done entirely through the admin user interface and can be performed by your clients if necessary. To navigate to the settings page, go to *System* -> *Settings* -> *Content translations*:

![Screenshot showing configuration of content translation languages in the admin user interface](images/screenshots/translation_settings.png)

## Customizing translation forms

By default, the forms for translating records will be automatically generated. They will contain no tabs or fieldsets and the order of fields may be unpredictable.

To provide a better experience when dealing with records with many fields, you can define an alternative translation form at:

```
/forms/preside-objects/_translation_objectname/admin.edit.xml // where 'objectname' is the name of your object
```

When dealing with page types and pages, this will be:

```
/forms/preside-objects/_translation_page/admin.edit.xml // for the core page object
/forms/preside-objects/_translation_pagetypename/admin.edit.xml // where 'pagetypename' is the name of your page type
```

## Setting the current language

It is up to your application to choose the way in which it will set the language for the current request. One common way in which to do this would be to allow the user to pick from the available languages and to persist their preference.

The list of available languages can be obtained with the `listLanguages()` method of the `multilingualPresideObjectService` object, e.g.:

```luceescript
component {
    property name="multilingualPresideObjectService" inject="multilingualPresideObjectService";

    function someHandlerAction( event, rc, prc ) {
        prc.availableLanguages = multilingualPresideObjectService.listLanguages()
    }
}
```

Setting the current language can be done with `event.setLanguage( idOfLanguage )`. An ideal place to do this would be at the beggining of the request. This can be achieved in the `/handlers/General.cfc` handler. For example:

```luceescript
component extends="preside.system.handlers.General" {

    // here, userPreferenceService would be some custom service
    // object that was written to get and set user preferences
    // it is for illustration purposes only and not a core service
    property name="userPreferencesService" inject="userPreferencesService";

    function requestStart( event, rc, prc ) {
        super.requestStart( argumentCollection=arguments );

        event.setLanguage( userPreferencesService.getLanguage() );
    }
}
```

>>>>> Notice how the `General.cfc` handler extends `preside.system.handlers.General` and calls `super.requestStart( argumentCollection=arguments )`. Without this logic, the core request start logic would not take place, and the system would likely break completely.
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

```luceescript
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

	// as of 10.20.0 you can now dynamically disable the 
	// migration with the following *optional* method
	private boolean function isEnabled() {
		return isFeatureEnabled( "myFeature" );
	}

}
```

### Synchronous vs Asynchronous running

When you implement a `run()` method, your logic will run during application startup and application startup will not be complete until the migration completes. This is important for **critical** migrations where the application's data **must** be updated in order for correct operation of the application.

If your migration is not essential to the running of the application, you may wish to implement a `runAsync()` method instead. These migrations will be run in a background thread approximately 1 minute after application startup. Great for slow, non-essential migrations.

Both methods operate and are called in exactly the same way. Neither method receives any arguments other than core coldbox `event`, `rc` and `prc`.---
id: websiteusersandpermissioning
title: Website users and permissioning
---

## Overview

Preside supplies a basic core system for setting up user logins and permissioning for your front end websites. This system includes:

* Membership management screens in the administrator
* Ability to create users and user "benefits" (synonymous with user groups)
* Ability to apply access restrictions to site pages and assets through user benefits and individual users
* Core system for dealing with access denied responses
* Core handlers for processing login, logout and forgotten password

The expectation is that, for more involved sites, these core systems will be extended and interacted with to create a fuller membership experience.

## Users and Benefits

We provide a simple model of **users** and **benefits** with two core preside objects, `website_user` and `website_benefit`. A user can have multiple benefits. User benefits are analogous to user groups.

>>> We have kept the fields for both objects to a bare minimum so as to not impose unwanted logic to your sites. You are encouraged to extend these objects to add your site specific data needs.

## Login

The `website_user` object provides core fields for handling login and displaying the currently logged in user's name:

* `login_id`
* `email_address`
* `password`
* `display_name`

Passwords are hashed using BCrypt and the default login procedure checks the supplied login id for a match against either the `login_id` or `email_address` field before checking the validity of the password with BCrypt.

### Core handler actions

In addition to the core service logic, Preside also provides a thin handler layer for processing login and logout and for rendering a login page. The handler can be found at `/system/handlers/Login.cfc`. It provides the following direct actions and viewlets:

#### Default (index)

The default action will render the loginPage viewlet. It will also redirect the user if they are already logged in. You can access this action with the URL: mysite.com/login/ (generate the URL with `event.buildLink( linkTo="login" )`).

#### AttemptLogin

The `attemptLogin()` action will process a login attempt, redirecting to the default action on failure or redirecting to the last page accessed (or the default post login page if no last page can be calculated) on success. You can use `event.buildLink( linkTo='login.attemptLogin' )` to build the URL required to access this action.

The action expects the required POST parameters `loginId` and `password` and will also process the optional fields `rememberMe` and `postLoginUrl`.

#### Logout

The `logout()` action logs the user out of their session and redirects them either to the previous page or, if that cannot be calculated, to the default post logout page.

You can build a logout link with `event.buildLink( linkTo='login.logout' )`.

#### Viewlet: loginPage

The `loginPage` viewlet is intended to render the login page.

The core view for this viewlet is just an example and should probably be overwritten within your application. However it should show how things could be implemented.

The core handler ensures that the following arguments are passed to the view:

<div class="table-responsive">
    <table class="table">
        <thead>
            <tr>
                <th>Name</th>
                <th>Descriptiojn</th>
            </tr>
        </thead>
        <tbody>
            <tr><td>`args.allowRememberMe`</td> <td>Whether or not remember me functionality is allowed</td>
            <tr><td>`args.postLoginUrl`</td>    <td>URL to redirect the user to after successful login</td>
            <tr><td>`args.loginId`</td>         <td>Login id that the user entered in their last login attempt (if any)</td>
            <tr><td>`args.rememberMe`</td>      <td>Remember me preference that the user chose in their last login attempt (if any)</td>
            <tr><td>`args.message`</td>         <td>Message ID that can be used to render a message to the user. Core message IDs are `LOGIN_REQUIRED` and `LOGIN_FAILED`            </td>
        </tbody>
    </table>
</div>

>>> The default implementation of the access denied error handler renders this viewlet when the cause of the access denial is "LOGIN_REQUIRED" so that your login form will automatically be shown when login is required to access some resource.

### Checking login and getting logged in user details

You can check the logged in status of the current user with the helper method, `isLoggedIn()`. Additionally, you can check whether the current user is only auto logged in from a cookie with, `isAutoLoggedIn()`. User details can be retrieved with the helper methods `getLoggedInUserId()` and `getLoggedInUserDetails()`.

For example:

```luceescript
// an example 'add comment' handler:
public void function addCommentAction( event, rc, prc ) {
    if ( !isLoggedIn() || isAutoLoggedIn() ) {
        event.accessDenied( "LOGIN_REQUIRED" );
    }

    var userId       = getLoggedInUserId();
    var emailAddress = getLoggedInUserDetails().email_address ?: "";

    // ... etc.
}
```

### Login impersonation

CMS administrative users, with sufficient privileges, are able to "impersonate" the login of website users through the admin GUI. Once they have done this, they are treated as a fully logged in user in the front end.

If you wish to restrict these impersonated logins in any way, you can use the `isImpersonated()` method of the `websiteLoginService` object to check to see whether or not the current login is merely an impersonated one.

## Permissions

A permission is something that a user can do within the website. Preside comes with two permissions out of the box, the ability to access a restricted page and the ability to access a restricted asset. These are configured in `Config.cfc` with the `settings.websitePermissions` struct:

```luceescript
// /preside/system/config/Config.cfc
component {

    public void function configure() {
        // ... other settings ... //

        settings.websitePermissions = {
              pages  = [ "access" ]
            , assets = [ "access" ]
        };

        // ... other settings ... //

    }

}
```

The core settings above produces two permission keys, "pages.access" and "assets.access", these permission keys are used in creating and checking applied permissions (see below). The permissions can also be directly applied to a given user or benefit in the admin UI:

![Screenshot of the default edit benefit form. Benefits can have permissions directly applied to them.](images/screenshots/website_benefit_form.png)


The title and description of a permission key are defined in `/i18n/permissions.properties`:

```properties
# ... other keys ...

pages.access.title=Access restricted pages
pages.access.description=Users can view all restricted pages in the site tree unless explicitly denied access to them

assets.access.title=Access restricted assets
assets.access.description=Users can view or download all restricted assets in the asset tree unless explicitly denied access to them
```

### Applied permissions and contexts

Applied permissions are instances of a permission that are granted or denied to a particular user or benefit. These instances are stored in the `website_applied_permission` preside object.

#### Contexts

In addition to being able to set a grant or deny permission against a user or benefit, applied permissions can also be given a **context** and **context key** to create more refined permission schemes.

For instance, when you grant or deny access to a user for a particular **page** in the site tree, you are creating a grant or deny instance with a context of "page" and a context key that is the id of the page.


### Defining your own custom permissions

It is likely that you will want to define your own permissions for your site. Examples might be the ability to add comments, or upload documents. Creating the permission keys requires modifying both your site's Config.cfc and permissions.properties files:

```luceescript
// /mysite/application/config/Config.cfc
component extends="preside.system.config.Config" {

    public void function configure() {
        super.configure();

        // ... other settings ... //

        settings.websitePermissions.comments = [ "add", "edit" ];
        settings.websitePermissions.documents = [ "upload" ];

        // ... other settings ... //

    }

}
```

The settings above would produce three keys, `comments.add`, `comments.edit` and `documents.upload`.

```properties
# /mysite/application/i18n/permissions.properties

comments.add.title=Add comments
comments.add.description=Ability to add comments in our comments system

comments.edit.title=Edit comments
comments.edit.description=Ability to edit their own comments after they have been submitted

documents.upload.title=Upload documents
documents.upload.description=Ability to upload documents to share with other privileged members

With the permissions configured as above, the benefit or user edit screen would appear with the new permissions added:
```

![Screenshot of the edit benefit form with custom permissions added.](images/screenshots/website_benefit_form_extended.png)

### Checking permissions

>>> The core system already implements permission checking for restricted site tree page access and restricted asset access. You should only require to check permissions for your own custom permission schemes.

You can check to see whether or not the currently logged in user has a particular permission with the `hasWebsitePermission()` helper method. The minimum usage is to pass only the permission key:

```lucee
<cfif hasWebsitePermission( "comments.add" )>
    <button>Add comment</button>
</cfif>
```

You can also check a specific context by passing in the `context` and `contextKeys` arguments:

```luceescript
public void function addCommentAction( event, rc, prc ) {
    var hasPermission = hasWebsitePermission(
          permissionKey = "comments.add"
        , context       = "commentthread"
        , contextKeys   = [ rc.thread ?: "" ]
    );

    if ( !hasPermission ) {
        event.accessDenied( reason="INSUFFIENCT_PRIVILEGES" );
    }
}
```

>>> When checking a context permission, you pass an array of context keys to the `hasWebsitePermission()` method. The returned grant or deny permission will be the one associated with the first found context key in the array.

>>>This allows us to implement cascading permission schemes. For site tree access permissions for example, we pass an array of page ids. The first page id is the current page, the next id is its parent, and so on.

## Partial restrictions in site tree pages

The site tree pages system allows you to define that a page is "Partially restricted". You can check that a user does not have full access to a partially restricted page with `event.isPagePartiallyRestricted()`. This then allows you to implement alternative content to show when the user does not have full access. It is down to you to implement this alternative content. A simple example:

```lucee
<!-- /views/page-types/standard_page/index.cfm -->

<cfif event.isPagePartiallyRestricted()>
    #renderView( "/general/_partiallyRestricted" )
<cfelse>
    #args.main_content#
</cfif>
```
---
id: data-tenancy
title: Configuring data tenancy
---

## Overview

Data tenancy allows you to divide your data up into logical segments, or tenants. A classic example of this might be an application that serves different customers. The application is shared between all the customers, but each customer gets their own users and their own data and cannot see the data of the other customers.

Preside has always come with a concept of "site tenancy", but as of 10.8.0, it also provides a simple framework for defining your own custom tenancies.

## Example

Let's take a real-life scenario where an application maintains articles for on-line and print media. The application serves multiple customers and each article should belong to a single customer (we'll add some complexity to this later).

Article editors should be able to switch customer in the admin interface and automatically have their data filtered for that customer. Article editors require permissions to be able to work on particular customers' articles.

### Configuration

In our example, we have a single object for tenancy, `customer.cfc`. We are going to assume that the permissions model and data for customers is already setup and that we have a preside object for customer that looks something like this:

```luceescript
/**
 * @labelfield name
 */
component {
	property name="name";
	// ... other properties
}
```

To configure this object for tenancy, you would need to add the following to your application's `/application/config/Config.cfc`:

```luceescript
settings.tenancy.customer = {
	  object       = "customer"
	, defaultFk    = "customer"
};
```

This tells the framework that 'customer' can be used to create tenancy in other data objects. To configure an object to use this tenancy, we add `@tenant customer` to its definition. In our example, we want articles to have customer tenancy, so our `article.cfc` would look like this:

```luceescript
/**
 * @tenant     customer
 * @labelfield title
 */
component {
	//... 	
}
```

*That's it*. Our data model is now set. The framework will automatically inject the relevant foreign keys into the `article.cfc` object and ensure any indexes and unique indexes also include the `customer` foreign key.

Whenever data is selected from the `article` object, the framework will automatically filter it by the currently set `customer`. Whenever data is inserted into the `article` object store, the `customer` field will be automatically set to the currently active `customer`.

### Setting the active tenant per-request

In order for the framework to be able to auto-filter and maintain tenancy, you need to tell it what the current active tenant is per request. To do so, you can implement a handler action, `tenancy.{configuredtenant}.getId`. This handler should return the ID of the currently active tenant record. This handler action is called very early in the request lifecycle to ensure the active tenants get set before they need to be used.

In our example, our tenancy object is `customer`, so our convention based hander would live at `/handlers/tenancy/customer.cfc` and could look like this:


```luceescript
component {

	property name="customerService" inject="customerService";

	private string function getId( event, rc, prc ) {
		return customerService.getCurrentlyActiveCustomerId();
	}
}
```

>>>>> The logic that calculates the current tenant is entirely up to you. You may base it on the first part of the current domain, e.g. `customer.mysite.com`, or it may be based on a custom control in the admin interface that allows the user to switch between different tenants. **The tenancy framework does not provide any of this logic.**

If you do not wish to follow the convention based handler, you can configure a different one in your `settings.tenancy` config in `Config.cfc` using the `getIdHandler` property:

```luceescript
settings.tenancy.customer = {
	  object       = "cust"
	, defaultFk    = "cust_id"
	, getIdHandler = "customers.getActiveCustomerId"
};
```

### Setting default value for tenant

If the tenancy filter value might potentially be empty, you may want to set a default value; this can be implemented via a handler action, `tenancy.{configuredtenant}.getDefaultValue`. This handler should return the desired default value to filter any tenanted query. This feature is available from v10.25.0 and also patched back to following version: v10.17.41, v10.18.51, v10.19.41, v10.20.35, v10.21.31, v10.22.24, v10.23.11 and v10.24.8.

In our example, our tenancy object is `customer`, so our convention based handler would live at `/handlers/tenancy/customer.cfc` and could look like this:

```luceescript
component {

	property name="customerService" inject="customerService";

	private string function getDefaultValue( event, rc, prc ) {
		return customerService.getDefaultCustomerId();
	}
}
```

## More complex filter scenarios

You may find that the tenancy is less straight forward than a record belonging to a single tenant. You may have a situation where you have one _main_ tenant, and then many optional tenants.

In our customer article's example, an article can belong to a single customer but also be available to other partner customers. Our `article.cfc` may look like this:

```luceescript
/**
 * @tenant     customer
 * @labelfield title
 */
component {
	// ...

	property name="partner_customers" relationship="many-to-many" relatedto="customer" relatedvia="article_partner_customer";

	// ...
}
```

If our active customer tenant is "Acme LTD", we only want to see articles whose main customer is "Acme LTD" **OR** whose partner customers contain "Acme LTD".

To implement this logic, you need to create a `getFilter()` handler action in your tenancy handler. This method will take four arguments (as well as the standard Coldbox handler arguments):

* `objectName` - the name of the object being filtered (in our example, `article`)
* `fk` - the name of the foreign key property that is the main tenancy indicator (in our example, `customer`)
* `tenantId` - the currently active tenant ID
* `defaultFilter` - the filter that is used by default, return this if you do not require any custom filtering for the given object (you may have multiple objects that use tenancy and some with different filtering requirements)

An example:

```luceescript
component {

	property name="presideObjectService" inject="presideObjectService";
	property name="customerService" inject="customerService";

	private string function getId( event, rc, prc ) {
		return customerService.getCurrentlyActiveCustomerId();
	}

	private struct function getFilter( objectName, fk, tenantId, defaultFilter ) {
		if ( arguments.objectName == "article" ) {
			var filter       = "#objectName#.#fk# = :customer_id or _extra.id is not null";
			var filterParams = { customer_id = { type="cf_sql_varchar", value=tenantId } };
			var subquery     = presideObjectService.selectData(
				  objectName          = "article_partner_customer"
				, getSqlAndParamsOnly = true
				, distinct            = true
				, selectFields        = [ "article as id" ]
				, filter              = "customer = :customer_id"
				, filterParams        = filterParams
			);

			return { filter=filter, filterParams=filterParams, extraJoins=[ {
				  type           = "left"
				, subQuery       = subQuery.sql
				, subQueryAlias  = "_extra"
				, subQueryColumn = "id"
				, joinToTable    = arguments.objectName
				, joinToColumn   = "id"
			} ] };
		}

		return defaultFilter;
	}
}
```

If you do not wish to follow the convention based handler, you can configure a different one in your `settings.tenancy` config in `Config.cfc` using the `getFilterHandler` property:

```luceescript
settings.tenancy.customer = {
	  object           = "cust"
	, defaultFk        = "cust_id"
	, getFilterHandler = "customers.getTenancyFilter"
};
```

## Bypassing tenancy

You may wish to bypass tenancy altogether in some scenarios. To do so, you can pass the `bypassTenants` arguments to [[presideobjectservice-selectdata]]:

```luceescript
presideObjectService.selectData(
	  // ...
	, bypassTenants = [ "customer" ]
);
```

This will ensure that any tenancy filters are **not** applied for the given tenants. You are also able to specify these bypasses on an object picker in forms:


```xml
<field binding="article.related_articles" bypassTenants="customer" /> 
```

## Overriding the per-request tenant

If you need to select data from a tenant that is not the currently active tenant for the request, you can use the `tenantIds` argument to specify the IDs for specific tenants. For example:


```luceescript
// ...
var alternativeCustomerAccounts = accounts.selectData(
	  selectFields = [ "id", "account_name" ]
	, tenantIds    = { customer=alternativeCustomerId }
);
// ...
```

The value of this argument must be a struct whose keys are the names of the tenant and whose values are the ID to use for the tenant. See [[presideobjectservice-selectdata]] for documentation.
---
id: adminmenuitems
title: Configuring admin menu items
---

## Introduction

As of Preside **10.17.0**, the main navigation sytem was updated to introduce a core concept of configured admin menu items.

These are implemented in the side bar navigation and in the System drop down menu in the top navigation. See [[adminlefthandmenu]] and [[adminsystemmenu]].

## Config.cfc implementation

Each named menu item, e.g. "sitetree", must be specified in the `settings.adminMenuItems` struct in your `Config.cfc` file. An entry takes the following form:

```luceescript
settings.adminMenuItems.sitetree = {
    feature       = "sitetree"                                // optional feature flag. Only show menu item when feature is enabled
  , permissionKey = "sitetree.navigate"                       // optional admin perm key. Only show menu item if current user has access
  , activeChecks  = { handlerPatterns="^admin\.sitetree\.*" } // see 'Active checks' below
  , buildLinkArgs = { linkTo="sitetree" }                     // Structure of args to send to event.buildAdminLink
  , gotoKey       = "s"                                       // Optional global shortcut key for the nav item
  , icon          = "fa-sitemap"                              // Optional fontawesome icon
  , title         = "cms:sitetree"                            // Optional i18n uri for the title
  , subMenuItems  = [ "item1", "item2" ]                      // Optional array of child menu items (each referring to another menu item)
};
```

### Reference

<div class="table-responsive">
    <table class="table table-condensed">
        <thead>
            <tr>
                <th>Key</th>
                <th>Default</th>
                <th>Description</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>feature</td>
                <td><em class="text-hint">empty</em></td>
                <td>Optional feature flag. Only show menu item when feature is enabled</td>
            </tr>
            <tr>
                <td>permissionKey</td>
                <td><em class="text-hint">empty</em></td>
                <td>Optional admin permission key. Only show menu item if current user has access</td>
            </tr>
            <tr>
                <td>activeChecks</td>
                <td><em class="text-hint">empty</em></td>
                <td>Optional struct describing common checks to make to decide whether or not the item is active in any given request</td>
            </tr>
            <tr>
                <td>buildLinkArgs</td>
                <td><em class="text-hint">empty</em></td>
                <td>Structure of args to send to `event.buildAdminLink()`</td>
            </tr>
            <tr>
                <td>gotoKey</td>
                <td><em class="text-hint">empty</em></td>
                <td>Optional global shortcut key for the nav item</td>
            </tr>
            <tr>
                <td>icon</td>
                <td><code>admin.menuitem:{menuItemName}.iconClass</code></td>
                <td>Font awesome icon class name, or i18n URI that translates to one</td>
            </tr>
            <tr>
                <td>title</td>
                <td><code>admin.menuitem:{menuItemName}.title</code></td>
                <td>Title of the menu item, or i18n URI that translates to the title</td>
            </tr>
            <tr>
                <td>subMenuItems</td>
                <td><em class="text-hint">empty</em></td>
                <td>Optional array of child menu items (each referring to another menu item)</td>
            </tr>
        </tbody>
    </table>
</div>

### Active checks structure

Two keys can be used in the `activeChecks` structure to instruct the system to make common checks for the active state of the menu item: `handlerPatterns` and `datamanagerObject`.

#### handlerPatterns

Specify either a plain string regex pattern to match the current handler event, or supply an array of patterns. e.g.

```luceescript
settings.adminMenuItems.myItem = {
    // ...
    activeChecks  = { handlerPatterns="^admin\.myhandler\.myaction" }
}

// or
settings.adminMenuItems.myItem = {
    // ...
    activeChecks  = { handlerPatterns=[ "^admin\.myhandler\.myaction", "^admin\.anotherhandler\." ] }
}
```

#### datamanagerObject

Specify either a single object name (string), or array of object names. When any datamanager page using the specified object(s) is viewed, the item will be considered active. e.g.

```luceescript
settings.adminMenuItems.myItem = {
    // ...
    activeChecks  = { datamanagerObject="my_object" }
}

// or
settings.adminMenuItems.myItem = {
    // ...
    activeChecks  = { datamanagerObject=[ "my_object", "my_object_two" ] }
}
```

## Extending with dynamic functionality

At times, you may wish to have more dynamic control over the behaviour of your items. In addition to any configuration set above, you may also create a convention based handler to extend the item's behaviour. Create the handler at `/handlers/admin/layout/menuitem/{nameOfYourItem}.cfc`. It can then implement any of the methods below:

```luceescript
component {

    /**
     * System will run this once in application life-time
     * to ascertain whether or not to include the menu item.
     * Useful for more complex feature combination checks.
     */
    private boolean function neverInclude( args={} ) {
        return false;
    }

    /**
     * Implement this method to run more complex logic
     * to decide whether or not the current user has
     * access to the menu item. 
     *
     */
    private boolean function includeForUser( args={} ) {
        return true;
    }

    /**
     * Implement this method to run more complex logic
     * to decide whether or not the item is active for
     * the current request
     *
     */
    private boolean function isActive( args={} ) {
        return false;
    }

    /**
     * Implement this method to run more complex
     * / dynamic logic for building the link to the item
     *
     */
    private string function buildLink( args={} ) {
        return "";
    }

    /**
     * Run this method to dynamically decorate
     * the item configuration structure (passed in as args)
     *
     */
    private void function prepare( args={} ) {
        var dynamicChildren = [ /* ... */ ];
        ArrayAppend( args.subMenuItems, dynamicChildren, true );
    }


}
```---
id: workingwithmultiplesites
title: Working with multiple sites
---

## Overview

Preside allows users to create and manage multiple sites. This is perfect for things like microsites, different language sites and any other organisation of workflows and users.

![Screenshot showing the site picker that appears in the administrator for users with access to multiple sites and / or users with access to the site manager.](images/screenshots/site_picker.png)


From a development standpoint, the CMS allows developers to create and maintain multiple site templates. A site template is very similar to a Preside Extension, the difference being that the site template is only active when the currently active site is using the template.

Finally, the CMS allows you to easily segment the data in your Preside data objects by site. By doing so, each site will only have access to the data that is unique to it. The developers are in control of which data objects have their data shared across all sites and which objects have their data segmented per site.

## Site templates

Site templates are like a Preside application within another Preside application. They can contain all the same folders and concepts as your main application but are only active when the currently active site is using the template. This means that any widgets, page types, views, etc. that are defined within your site template, will only kick in when the site that uses the template is active. CMS administrators can apply a single template to a site.

![Screenshot of an edit site form where the user can choose which template to apply to the site.](images/screenshots/edit_site.png)


### Creating a barebones site template

To create a new site template, you will need to create a folder under your application's `application/site-templates/` folder (create one if it doesn't exist already). The name of your folder will become the name of the template, e.g. the following folder structure will define a site template with an id of `microsite`:

```
/application
    /site-templates
        /microsite
```

In order for the site template to appear in a friendly manner in the UI, you should also add an i18n properties file that corresponds to the site id. In the example above, you would create `/application/i18n/site-templates/microsite.properties`:

```properties
title=Microsite template
description=The microsite template provides layouts, widgets and page types that are unique to the site's microsites
```

### Overriding layouts, views, forms, etc.

To override any Preside features that are defined in your main application, you simply need to create the same files in the same directory structure within your site template.

For example, if you wanted to create a different page layout for a site template, you might want to override the main application's `/application/layouts/Main.cfm` file. To do so, simply create `/application/site-templates/mytemplate/layouts/Main.cfm`:

```
/application
    /layouts
        Main.cfm <-- this will be used when the active site is *not* using the 'microsite' site template
    /site-templates
        /microsite
            /layouts
                Main.cfm <-- this will be used when the active site is using the 'microsite' site template
```

This technique can be used for Form layouts, Widgets, Page types and i18n. It can also be used for Coldbox views, layouts and handlers.

>>>> You cannot make modifications to :doc:`presideobjects` with the intention that they will only take affect for sites using the current site template. Any changes to :doc:`presideobjects` affect the database schema and will always take affect for every single site and site template.
>>>> If you wish to have different fields on the same objects but for different site templates, we recommend defining all the fields in your core application's object and providing different form layouts that show / hide the relevent fields for each site template.

### Creating features unique to the site template

To create features that are unique to the site template, simply ensure that they are namespaced suitably so as not to conflict with other extensions and site templates. For example, to create an "RSS Feed" widget that was unique to your site template, you might create the following file structure:

```
/application
    /site-templates
        /microsite
            /forms
                /widgets
                    microsite-rss-widget.xml
            /i18n
                /widgets
                    microsite-rss-widget.properties
            /views
                /widgets
                    microsite-rss-widget.cfm
```

---
id: formbuilder
title: Working with the form builder
---

As of v10.5.0, Preside provides a system that enables content administrators to build input forms to gather submissions from their site's user base. The form builder system is fully extendable and this guide sets out to provide detailed instructions on how to do so.

See the following pages for detailed documentation:

1. [[formbuilder-overview]]
2. [[formbuilder-itemtypes]]
3. [[formbuilder-actions]]
4. [[formbuilder-styling-and-layout]]

![Screenshot showing a form builder form's workbench](images/screenshots/formbuilder_workbench.jpg)

>>>> The form builder system is not to be confused with the [[presideforms|Preside Forms system]]. The form builder is a system in which content editors can produce dynamically configured forms and insert them into content pages. The [[presideforms|Preside Forms system]] is a system of programatically defining forms that can be used either in the admin interface or hard wired into the application's front end interfaces.---
id: formbuilder-overview
title: Form Builder overview
---

As of v10.5.0, Preside provides a system that enables content administrators to build input forms to gather submissions from their site's user base.

>>> As of **v10.13.0**, Preside offers a v2 data model for form builder and this can be enabled separately. Enabling this feature will effect any forms that are created from that point on, previously created forms will continue to function as they were.

>>> This v2 data model makes querying the answers to questions more robust and provides an additional UI to manage a global set of questions that can be asked in forms.

![Screenshot showing a form builder form's workbench](images/screenshots/formbuilder_workbench.jpg)

## Enabling form builder

### Pre 10.13.0

In versions 10.5 to 10.12, the form builder system is disabled by default. To enable it, set the `enabled` flag on the `formbuilder` feature in your application's `Config.cfc$configure()` method:

```luceescript
component extends="preside.system.config.Config" {

	public void function configure() {
		super.configure();

		// ...

		// enable form builder
		settings.features.formbuilder.enabled = true;

		// ...
	}
}

```

### 10.13.0 and above

As of *10.13*, the form builder system is **enabled** by default. However, the v2 of the data model is turned **off** by default. To enable it:

```luceescript
component extends="preside.system.config.Config" {

	public void function configure() {
		super.configure();

		// ...

		// enable form builder
		settings.features.formbuilder2.enabled = true;

		// ...
	}
}

```

## Forms

Forms are the base unit of the system. They can be created, configured, activated and locked by your system's content editors. Once created, they can be inserted into content using the Form Builder form widget. A form definition consists of some basic configuration and any number of ordered and individually configured items (e.g. a text input, select box and email address).

![Screenshot showing a list of form builder forms](images/screenshots/formbuilder_forms.jpg)

Useful references for extending the core form object and associated widget:

* [[presideobject-formbuilder_form|Form builder: form (Preside Object)]]
* [[form-formbuilderformaddform]]
* [[form-formbuilderformeditform]]
* [[form-widgetconfigurationformformbuilderform]]

## Form items and item types

Form items are what provide the input and display definition of the form. _i.e. a form without any items will be essentially invisible_. Content editors can drag and drop item types into their form definition; they can then configure and reorder items within the form definition. The configuration options and display of the item will differ for different item _types_.

![Screenshot showing a configuration of a date picker item](images/screenshots/formbuilder_configureitem.jpg)

The core system provides a basic set of item types whose configuration can be modified and extended by your application or extensions. You are also able to introduce new item types in your application or extensions.

See [[formbuilder-itemtypes]] for more detail.

## Form actions

Form actions are configurable triggers that are fired once a form has been submitted. The core system comes with a single 'Email' action that allows the CMS administrator to configure email notification containing the form submission.

![Screenshot showing a form builder actions workbench](images/screenshots/formbuilder_actions.jpg)

Developers can create their own custom actions that are then available to content editors to add to their forms. See [[formbuilder-actions]] for more detail.

## Form builder permissioning

Access to the Form Builder admin system can be controlled through the [[cmspermissioning]] system. The following access keys are defined:

* `formbuilder.navigate`
* `formbuilder.addform`
* `formbuilder.editform`
* `formbuilder.lockForm`
* `formbuilder.activateForm`
* `formbuilder.deleteSubmissions`
* `formbuilder.editformactions`

In addition, a `formbuildermanager` _role_ is defined that has access to all form builder operations:

```luceescript
settings.adminRoles.formbuildermanager = [ "formbuilder.*" ];
```

Finally, by default, the `contentadministrator` _role_ has access to all permissions with the exception of `lock` and `activate` form.

### Defining more restricted roles

In your own application, you could provide more fine tuned form builder access rules with configuration along the lines of the examples below:

```luceescript
// Adding perms to an existing role
settings.adminRoles.contenteditor.append( "formbuilder.*"                  );
settings.adminRoles.contenteditor.append( "!formbuilder.lockForm"          );
settings.adminRoles.contenteditor.append( "!formbuilder.activateForm"      );
settings.adminRoles.contenteditor.append( "!formbuilder.deleteSubmissions" );

// defining a new role
settings.adminRoles.formbuilderviewer = [ "formbuilder.navigate" ];

```---
id: formbuilder-itemtypes
title: Form Builder item types
---

Form items are what provide the input and display definition of the form. _i.e. a form without any items will be essentially invisible_. Content editors can drag and drop item types into their form definition; they can then configure and reorder items within the form definition. The configuration options and display of the item will differ for different item _types_.

![Screenshot showing a configuration of a date picker item](images/screenshots/formbuilder_configureitem.jpg)

The core system provides a basic set of item types whose configuration can be modified and extended by your application or extensions. You are also able to introduce new item types in your application or extensions.

# Anatomy of an item type

## 1. Definition in Config.cfc

An item type must first be registered in the application or extension's `Config.cfc` file. Item types are grouped into item type categories which are used simply for display grouping in the form builder UI. The core definition looks something like this (subject to change):

```luceescript
settings.formbuilder = { itemtypes={} };

// The "standard" category
settings.formbuilder.itemTypes.standard = { sortorder=10, types={
      textinput    = { isFormField=true  }
    , textarea     = { isFormField=true  }
    // ...
} };

// The "content" category
settings.formbuilder.itemTypes.content = { sortorder=20, types={
      spacer    = { isFormField=false }
    , content   = { isFormField=false }
} };

```

Introducing a new form field item type in the "standard" category might then look like this:

```luceescript
settings.formbuilder.itemTypes.standard.types.colourPicker = { isFormField = true };
```

## 2. i18n labelling

The labels for each item type *category* are all defined in `/i18n/formbuilder/item-categories.properties`. Each category requires a "title" key:

```properties
standard.title=Basic
multipleChoice.title=Multiple choice
content.title=Content and layout
```

Each item _type_ subsequently has its own `.properties` file that lives at `/i18n/formbuilder/item-types/(itemtype).properties`. A bare minimum `.properties` file for an item type should define a `title` and `iconclass` key, but it could also be used to define labels for the item type's configuration form. For example:

```properties
# /i18n/formbuilder/item-types/date.properties
title=Date
iconclass=fa-calendar

field.minDate.title=Minimum date
field.minDate.help=If entered, the input date must be greater than this date

field.maxDate.title=Maximum date
field.maxDate.help=If entered, the input date must be less than this date

field.relativeOperator.title=Relativity
field.relativeOperator.help=In what way should the value of this field be constrained in relation to the options below

field.relativeToCurrentDate.title=Current date
field.relativeToCurrentDate.help=Whether or not the date value entered into this field should be constrained relative to today's date

field.relativeToField.title=Another field in the form
field.relativeToField.placeholder=e.g. start_date
field.relativeToField.help=The name of the field whose value should be used as a relative constraint when validating the value of this field

tab.validation.title=Date limits
fieldset.fixed.title=Fixed dates
fieldset.relative.title=Relative dates

relativeOperator.lt=Less than...
relativeOperator.lte=Less than or equal to...
relativeOperator.gt=Greater than...
relativeOperator.gte=Greater than or equal to...
```

## 3. Configuration form

An item type can _optionally_ have custom configuration options defined in a Preside form definition. The form must live at `/forms/formbuilder/item-types/(itemtype).xml`. If the item type is a form field, this definition will be merged with the [[form-formbuilderitemtypeallformfields|core formfield configuration form]]. For example:

```xml
<!-- /forms/formbuilder/item-types/date.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<form i18nBaseUri="formbuilder.item-types.date:">
	<tab id="validation">
		<fieldset id="fixed">
			<field name="minDate" control="datePicker"  required="false"  sortorder="10" />
			<field name="maxDate" control="datePicker"  required="false"  sortorder="20" />
		</fieldset>
		<fieldset id="relative">
			<field name="relativeOperator"      control="select"      required="false"  sortorder="10" values=" ,lt,lte,gt,gte" labels=" ,formbuilder.item-types.date:relativeOperator.lt,formbuilder.item-types.date:relativeOperator.lte,formbuilder.item-types.date:relativeOperator.gt,formbuilder.item-types.date:relativeOperator.gte" defaultValue="" />
			<field name="relativeToCurrentDate" control="yesNoSwitch" required="false"  sortorder="20" />
			<field name="relativeToField"       control="textinput"   required="false"  sortorder="30" />
		</fieldset>
	</tab>
</form>
```

## 4. Handler actions and viewlets

The final component of a Form builder item is its handler. The handler must live at `/handlers/formbuilder/item-types/(itemtype).cfc` and can be used for providing one or more of the following:

1. `renderInput()`: a renderer for the form input (required),
2. `renderResponse()`: a renderer for a response (optional),
3. `renderResponseForExport()`: a renderer for a response in spreadsheet (optional),
4. `getExportColumns()`: logic to determine what columns are required in an spreadsheet export (optional),
5. `getItemDataFromRequest()`: logic to extract a submitted response from the request (optional),
6. `renderResponseToPersist()`: logic to render the response for saving in the database (optional),
7. `getValidationRules()`: logic to calculate what _validators_ are required for the item (optional)

### renderInput()

The `renderInput()` action is the only _required_ action for an item type and is used to render the item for the front end view of the form. A simple example:

```luceescript
// /handlers/formbuilder/item-types/TextArea.cfc
component {

	private string function renderInput( event, rc, prc, args={} ) {
		return renderFormControl(
			  argumentCollection = args
			, type               = "textarea"
			, context            = "formbuilder"
			, id                 = args.id ?: ( args.name ?: "" )
			, layout             = ""
			, required           = IsTrue( args.mandatory ?: "" )
		);
	}
}
```

The `args` struct passed to the viewlet will contain any saved configuration for the item (see "Configuration form" above), along with the following additional keys:

* **id:** A unique ID for the form item (calculated dynamically per request to ensure uniqueness)
* **error:** An error message. This may be supplied if the form has validation errors that need to be displayed for the item

#### renderInput.cfm (no handler version)

An alternative example of an input renderer might be for an item type that is _not_ a form control, e.g. the 'content' item type. Its viewlet could be implemented simply as a view, `/views/formbuilder/item-types/content/renderInput.cfm`:

```lucee
<cfoutput>
	#renderContent( 
		  renderer = "richeditor"
		, data     = ( args.body ?: "" )
	)#
</cfoutput>
```

`args.body` is available to the item type because it is defined in its configuration form.

### renderResponse()

An item type can optionally supply a response renderer as a _viewlet_ matching the convention `formbuilder.item-types.(itemtype).renderResponse`. This renderer will be used to display the item as part of a form submission. If no renderer is defined, the system will fall back on the core viewlet, `formbuilder.defaultRenderers.response`.

An example of this is the `Radio buttons` control that renders the selected answer for an item:

```luceescript
// /handlers/formbuilder/item-types/Radio.cfc
component {
	// ...

	// args struct contains response (that is saved in 
	// the database) and itemConfiguration keys
	private string function renderResponse( event, rc, prc, args={} ) {
		var itemConfig = args.itemConfiguration ?: {};
		var response   = args.response;
		var values     = ListToArray( itemConfig.values ?: "", Chr( 10 ) & Chr( 13 ) );
		var labels     = ListToArray( itemConfig.labels ?: "", Chr( 10 ) & Chr( 13 ) );

		// loop through configured radio options
		for( var i=1; i<=values.len(); i++ ) {

			// find a match for the response
			if ( values[ i ] == response ) {

				// if label + value are different
				// include both the label and the value 
				// in the rendered response
				if ( labels.len() >= i && labels[ i ] != values[ i ] ) {
					return labels[ i ] & " (#values[i]#)";
				}

				// or just the value if same as label
				return response;
			}
		}

		// response did not match, just show
		// the saved response as is
		return response;
	}

	// ...
}
```

### renderResponseForExport()

This method allows you to render a response specifically for spreadsheet export. When used in conjunction with `getExportColumns()`, the result can be multiple columns of rendered responses.

For example, the `Matrix` item type looks like this:


```luceescript
// /handlers/formbuilder/item-types/Matrix.cfc
component {
	// ...

	// the args struct will contain response and itemConfiguration keys.
	// the response is whatever has been saved in the database for the item
	private array function renderResponseForExport( event, rc, prc, args={} ) {
		var qAndA = _getQuestionsAndAnswers( argumentCollection=arguments );
		var justAnswers = [];

		for( qa in qAndA ) {
			justAnswers.append( qa.answer );
		}

		// here we return an array of answers corresponding
		// to the question columns that we have defined
		// in the getExportColumns() method (see below)
		return justAnswers;
	}

	// ...

	// the args struct will contain the item's configuration
	private array function getExportColumns( event, rc, prc, args={} ) {
		var rows       = ListToArray( args.rows ?: "", Chr(10) & Chr(13) );
		var columns    = [];
		var itemName   = args.label ?: "";

		for( var row in rows ) {
			if ( !IsEmpty( Trim( row ) ) ) {
				columns.append( itemName & ": " & row );
			}
		}

		return columns;
	}

	// ...

	// this is just a specific utility method used by the matrix item type
	// to extract out questions and their answers from a saved response
	private array function _getQuestionsAndAnswers( event, rc, prc, args={} ) {
		var response   = IsJson( args.response ?: "" ) ? DeserializeJson( args.response ) : {};
		var itemConfig = args.itemConfiguration ?: {};
		var rows       = ListToArray( Trim( itemConfig.rows ?: "" ), Chr(10) & Chr(13) );
		var answers    = [];

		for( var question in rows ) {
			if ( Len( Trim( question ) ) ) {
				var inputId = _getQuestionInputId( itemConfig.name ?: "", question );

				answers.append( {
					  question = question
					, answer   = ListChangeDelims( ( response[ inputId ] ?: "" ), ", " )
				} );
			}
		}

		return answers;
	}
}
```

### getExportColumns()

This method allows us to define a custom set of spreadsheet export columns for a configured item type. This may be necessary if the item type actually results in multiple sub-questions being asked. You do _not_ need to implement this method for simple item types.

A good example of this is the `Matrix` item type that allows editors to configure a set of questions (rows) and a set of optional answers (columns). The `getExportColumns()` method for the `Matrix` item type looks like this:

```luceescript
// /handlers/formbuilder/item-types/Matrix.cfc
component {
	// ...

	// the args struct will contain the item's configuration
	private array function getExportColumns( event, rc, prc, args={} ) {
		var rows       = ListToArray( args.rows ?: "", Chr(10) & Chr(13) );
		var columns    = [];
		var itemName   = args.label ?: "";

		for( var row in rows ) {
			if ( !IsEmpty( Trim( row ) ) ) {
				columns.append( itemName & ": " & row );
			}
		}

		return columns;
	}
}
```

### getItemDataFromRequest()

This method allows us to extract out data from a form submission in a format that is ready for validation and/or saving to the database for our configured item. For simple item types, such as a text input, this is not necessary as we would simply need to take whatever value is submitted for the item.

An example usage is the `FileUpload` item type. In this case, we want to upload the file in the form field to a temporary location and return a structure of information about the file that can then be validated later in the request:

```luceescript
// /handlers/formbuilder/item-types/FileUpload.cfc
component {
	// ...

	// The args struct passed to the viewlet will contain inputName, requestData and itemConfiguration keys
	private any function getItemDataFromRequest( event, rc, prc, args={} ) {
		// luckily for us here, there is already a process that 
		// preprocesses a file upload and returns a struct of file info :)
		var tmpFileDetails = runEvent(
			  event          = "preprocessors.fileupload.index"
			, prePostExempt  = true
			, private        = true
			, eventArguments = { fieldName=args.inputName ?: "", preProcessorArgs={} }
		);

		return tmpFileDetails;
	}

	// ...
}
```


### renderResponseToPersist()

This method allows you to perform any manipulation on a submitted response for an item, _after_ form validation and _before_ saving to the database. For simple item types, such as a text input, this is generally not necessary as we can simply take whatever value is submitted for the item.

An example usage of this is the `FileUpload` item type. In this case, we want to take a temporary file and save it to storage, returning the storage path to save in the database:

```luceescript
// /handlers/formbuilder/item-types/FileUpload.cfc
component {
	// ...

	// The args struct passed to the viewlet will contain the submitted response + any item configuration
	private string function renderResponseToPersist( event, rc, prc, args={} ) {
		// response in this case will be a structure
		// containing information about the file
		var response = args.response ?: "";

		if ( IsBinary( response.binary ?: "" ) ) {
			var savedPath = "/#( args.formId ?: '' )#/#CreateUUId()#/#( response.tempFileInfo.clientFile ?: 'uploaded.file' )#";

			formBuilderStorageProvider.putObject(
				  object = response.binary
				, path   = savedPath
			);

			return savedPath;
		}

		return SerializeJson( response );
	}

	// ...
}
```

### getValidationRules()

This method should return an array of validation rules for the configured item (see [[validation-framework]] for full documentation on validation rules). These rules will be used both server-side, using the Validation framework, and client-side, using the jQuery Validate library, where appropriate.

>>> The core form builder system provides some standard validation rules for mandatory fields, min/max values and min/max lengths. You only need to supply validation rule logic for specific rules that your item type may require.

An example:

```luceescript
// /handlers/formbuilder/item-types/FileUpload.cfc
component {
	// ...

	// The args struct passed to the viewlet will contain any saved configuration for the item.
	private array function getValidationRules( event, rc, prc, args={} ) {
		var rules = [];

		// add a filesize validation rule if the item has
		// been configured with a max file size constraint

		if ( Val( args.maximumFileSize ?: "" ) ) {
			rules.append( {
				  fieldname = args.name ?: ""
				, validator = "fileSize"
				, params    = { maxSize = args.maximumFileSize }
			} );
		}

		return rules;
	}

	// ...
}
```

### getQuestionDataType()

>>> v10.13.0 and up only

As of **10.13.0**, your item type can implement the `getQuestionDataType()` private handler action. This is provided with `args.configuration` which you can use to inform the v2 formbuilder data model which field type to save the response against. If not implemented, the system will default to `text` which means querying the responses can not benefit from table indexes.

Possible return responses are:

* `text` - The default, just a clob of data
* `shorttext` - Maximum 200 chars - can be indexed in the database for faster lookups
* `date` - A valid date or date time
* `bool` - A valid boolean value
* `int` - An integer value
* `float` - A floating point number

Example from the number item type:

```luceescript
private string function getQuestionDataType( event, rc, prc, args={} ) {
	var format = args.configuration.format ?: "";

	if ( format == "integer" ) {
		return "int";
	}

	return "float";
}
```

### renderV2ResponsesForDb()

>>> v10.13.0 and up only

As of **10.13.0**, your item type can implement a `renderV2ResponsesForDb` handler action to prepare responses for saving in the database.

This action should return either:

1. **A simple value**, for simple item types
2. **An array of simple values**, for multiple select item types - the order of the values should match the user selected order
3. **A struct of simple keys with simple values**, for form items that are broken into multiple fields (see matrix for example)

The action receives:

* `args.response` - contains the processed form submission for the question 
* `args.configuration` - struct, the user configuration of the item

Example from the `Matrix` item type:

```luceescript
private struct function renderV2ResponsesForDb( event, rc, prc, args={} ) {
	var response = {};
	var qAndAs = _getQuestionsAndAnswers( argumentCollection=arguments );

	for( var qAndA in qAndAs ) {
		response[ qAndA.question ] = qAndA.answer;
	}

	return response;
}
```---
id: formbuilder-actions
title: Form Builder actions
---

Form actions are configurable triggers that are fired once a form has been submitted. The core system comes with a single 'Email' action that allows the CMS administrator to configure email notification containing the form submission.

![Screenshot showing a form builder actions workbench](images/screenshots/formbuilder_actions.jpg)

Developers can create their own custom actions that are then available to content editors to add to their forms.

# Creating a custom form action

## 1. Register the action in Config.cfc

Actions are registered in your application and extension's `Config.cfc` file as a simple array. To register a new 'webhook' action, simply append 'webhook' to the `settings.formbuilder.actions` array:

```luceescript
component extends="preside.system.config.Config" {

	public void function configure() {
		super.configure();


		// ...
		settings.formbuilder.actions.append( "webhook" );

		// ...
	}
}
```

## 2. i18n for titles, icons, etc.

Each registered action should have its own `.properties` file at `/i18n/formbuilder/actions/(action).properties`. It should contain `title`, `iconclass` and `description` keys + any other keys it needs for configuration forms, etc. For example, the `.properties` file for a "webhook" action might look like:

```
# /i18n/formbuilder/actions/webhook.properties

title=Webhook
iconclass=fa-send
description=Sends a POST request to the configured URL containing data about the submitted form

field.endpoint.title=Endpoint
field.endpoint.placeholder=e.g. https://mysite.com/formbuilder/webhook/
```

## 3. Create a configuration form

To allow editors to configure your action, supply a configuration form at `/forms/formbuilder/actions/(action).xml`. For example, the "email" configuration form looks like this:

```xml
<!-- /forms/formbuilder/actions/email.xml -->

<?xml version="1.0" encoding="UTF-8"?>
<form i18nBaseUri="formbuilder.actions.email:">
	<tab id="default" sortorder="10">
		<fieldset id="default" sortorder="10">
			<field name="subject"    control="textinput" required="true"  />
			<field name="recipients" control="textinput" required="true"  />
			<field name="send_from"  control="textinput" required="false" />
		</fieldset>
	</tab>
</form>
```

![Screenshot showing a configuration of an email action](images/screenshots/formbuilder_configureaction.jpg)

## 4. Implement an onSubmit handler

The `onSubmit` handler is where your action processes the form submission and does whatever it needs to do. This handler will be a private method in `/handlers/formbuilder/actions/(youraction).cfc`. For example, the email action's submit handler looks like this:

```luceescript
component {

	property name="emailService" inject="emailService";

	// the args struct contains:
	// 
	// configuration  : struct of configuration options for the action
	// submissionData : the processed and saved data of the submission (struct)
	// 
	private void function onSubmit( event, rc, prc, args={} ) {
		emailService.send(
			  template = "formbuilderSubmissionNotification"
			, args     = args
			, to       = ListToArray( args.configuration.recipients ?: "", ";," )
			, from     = args.configuration.send_from ?: ""
			, subject  = args.configuration.subject ?: "Form submission notification"
		);
	}

}
```

## 5. Implement a placeholder viewlet (optional)

The placeholder viewlet allows you to customize how your configured action appears in the Form builder actions workbench:

![Screenshot showing the placeholder of a configured action](images/screenshots/formbuilder_actionplaceholder.jpg)

The viewlet called will be `formbuilder.actions.(youraction).renderAdminPlaceholder`. For the email action, this has been implemented as a handler method:

```luceescript
// /handlers/formbuilder/actions/Email.cfc

component {

	// ...

	private string function renderAdminPlaceholder( event, rc, prc, args={} ) {
		var placeholder = '<i class="fa fa-fw fa-envelope"></i> ';
		var toAddress   = HtmlEditFormat( args.configuration.recipients ?: "" );
		var fromAddress = HtmlEditFormat( args.configuration.send_from  ?: "" );

		if ( Len( Trim( fromAddress ) ) ) {
			placeholder &= translateResource(
				  uri  = "formbuilder.actions.email:admin.placeholder.with.from.address"
				, data = [ "<strong>#toAddress#</strong>", "<strong>#fromAddress#</strong>" ]
			);
		} else {
			placeholder &= translateResource(
				  uri  = "formbuilder.actions.email:admin.placeholder.no.from.address"
				, data = [ "<strong>#toAddress#</strong>" ]
			);
		}

		return placeholder;
	}
}
```---
id: formbuilder-styling-and-layout
title: Form Builder styling and layout
---

The form builder system allows you to provide custom layouts for:

1. Entire forms
2. Individual form items

These layouts can be used to give your content editors choice about the appearance of their forms.

## Form layouts

Custom form layouts are implemented as viewlets with the pattern `formbuilder.layouts.form.(yourlayout)`. Layouts are registered simply by implementing a viewlet with this pattern (as either a handler or view).

### The viewlet

The `args` struct passed to the viewlet will contain a `renderedForm` key that contains the form itself with all the rendered items and submit button. It will also be passed any custom arguments sent to the [[formbuilderservice-renderform]] method (e.g. custom configuration in the form builder form widget).

The default layout is implemented simply with a view:

```lucee
<!-- /views/formbuilder/layouts/form/default.cfm -->

<cfparam name="args.renderedForm" type="string">
<cfoutput>
	<div class="formbuilder-form form form-horizontal">
		#args.renderedForm#
	</div>
</cfoutput>
```

### i18n for layout name

For each custom layout that you provide, an entry should be added to the `/i18n/formbuilder/layouts/form.properties` file to provide a title for layout choice menus. For instance, if you created a layout called 'stacked', you would add the following:

```properties
# /i18n/formbuilder/layouts/form.properties

stacked.title=Stacked layout
```

## Item layouts

Form item layouts are implemented in a similar way to form layouts. Viewlets matching the pattern `formbuilder.layouts.formfield.(yourlayout)` will be automatically registered as _global_ layouts for _all_ form field items.

In addition, specific layouts for item types can also be implemented by creating viewlets that match the pattern, `formbuilder.layouts.formfield.(youritemtype).(yourlayout)`. If an item type specific layout shares the same name as a global form field layout, the item type specific layout will be used when rendering an item for that type.

### The viewlet

The item layout viewlet will receive an `args` struct with:

* `renderedItem`, the rendered form control
* `error`, any error message associated with the item
* all configuration options set on the item

The default item layout looks like:

```lucee
<cfparam name="args.renderedItem" type="string"  />
<cfparam name="args.label"        type="string"  />
<cfparam name="args.id"           type="string"  />
<cfparam name="args.error"        type="string"  default=""  />
<cfparam name="args.mandatory"    type="boolean" default="false" />

<cfoutput>
	<div class="form-group">
		<label class="col-sm-3 control-label no-padding-right" for="#args.id#">
			#args.label#
			<cfif IsTrue( args.mandatory )>
				<em class="required" role="presentation">
					<sup>*</sup>
					<span>#translateResource( "cms:form.control.required.label" )#</span>
				</em>
			</cfif>
		</label>

		<div class="col-sm-9">
			<div class="clearfix">
				#args.renderedItem#
				<cfif Len( Trim( args.error ) )>
					<label for="#args.id#" class="error">#args.error#</label>
				</cfif>
			</div>
		</div>
	</div>
</cfoutput>
```

### i18n for layout names

Human friendly names for layouts should be added to `/i18n/formbuilder/layouts/formfield.properties`. For example, if creating a "twocolumn" layout, you should add the following:

```properties
# /i18n/formbuilder/layouts/formfield.properties

twocolumn.title=Two column
```
---
id: extensions
title: "Writing Extensions for Preside"
---

## Introduction

Extensions are a fundamental feature of Preside development that enable you to package and share Preside features with other developers and users.

You can find publicly available extensions on [Forgebox](https://forgebox.io/type/preside-extensions).

## Anatomy of an extension

Extensions live under the `/application/extensions` folder within your Preside application, each extension with its own folder, e.g.

```
/application
    ...
    /extensions
        /my-extension-1
        /my-extension-2
        /my-extension-3
        ...
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

Define ColdBox view files here. Any views that match the relative path and filename of a view in core Preside, or a view file in a preceding extension, will override their counterpart. This means you can, for example, create an extension that completely overrides the Preside admin view for 'add record'.---
id: spreadsheets
title: Working with spreadsheets
---

As of v10.5.0, Preside comes with a built in spreadsheet library. Lucee itself does not have any out-of-box `<cfspreadsheet` functionality so traditionally an extension will be installed to provide compatibility. However, to avoid dependencies on server extension installs, we decided to include a library that would be available as part of the software.

The library we have used is [Spreadsheet CFML](https://github.com/cfsimplicity/spreadsheet-cfml) by [Julian Halliwell](https://github.com/cfsimplicity) (cfsimplicity).

Full documentation can be found at the links above, however, a quick start example follows:

```luceescript
// sometesthandler.cfc
component {

    // Preside makes the library available as 'spreadsheetLib'
    // that can be injected with wirebox
    property name="spreadsheetLib" inject="spreadsheetLib";

    function index() {
        var workbook    = spreadSheetLib.new();
        var data        = QueryNew( "First,Last", "VarChar,VarChar", [
              [ "Susi"  , "Sorglos"  ]
            , [ "Frumpo", "McNugget" ]
        ] );

        spreadSheetLib.addRows( workbook, data );
        spreadSheetLib.download( workbook, "testfile.xls" );
    }

}
```
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

Environment variables can be made available to Preside in three ways. **In each instance**, the environment variables will be available to you in the struct: `settings.env`. For example, if a variable 'fu=bar' was injected, you would be able to access and use it with:

```
settings.fu = settings.env.fu;
```

>>> Prior to 10.11.0, these variables were available to you as `settings.injectedConfig`. This variable will still exist to maintain backward compatibility, but we suggest using `settings.env` from now on.

### Method one: Environment file

As of **10.11.0**, you can create a file named `.env` at the root of your project. Variables are defined as `key=value` pairs on newlines. For example:

```
syncdb=false
forcessl=true
alloweddomains=www.mysite.com,api.mysite.com
```

_We suggest that this config file is not commited to your repository. Instead, generated it as part of your build or deploy process to dynamically set environment variables per environment._

### Method two: "Injected Configuration" file

Supply a json file at `/application/config/.injectedConfiguration` that contains any settings that you wish to inject. For example:

```json
{
	  "syncDb"         : false
	, "forceSsl"       : true
	, "allowedDomains" : "www.mysite.com,api.mysite.com"
}
```

_We suggest that this config file is not commited to your repository. Instead, generated it as part of your build or deploy process to dynamically set environment variables per environment._

### Method three: OS environment vars

Any operating system environment variables that are prefixed with `PRESIDE_` will automatically be available in your `settings.injectedConfig` struct. For example, you may have the following environment vars available to your server/container:

```
PRESIDE_syncDb=false
PRESIDE_forceSsl=true
PRESIDE_allowedDomains=www.mysite.com,api.mysite.com
```

These would be available in your application + Config.cfc as (i.e. the `PRESIDE_` prefix is stripped):

```luceescript
settings.env = {
	  syncDb         = false
	, forceSsl       = true
	, allowedDomains = "www.mysite.com,api.mysite.com"
};
```
---
id: admingritternotifications
title: "Configuring admin 'gritter' notifications"
---

## Introduction

Gritter notifications appear in the admin after successful inserting, saving and deleting of records, or when an error happens. Up until Preside 10.11.0, these notifications appeared at the top right hand side of the admin UI and this was not configurable.

As of Preside 10.11.0, the default position of these notifications is at the bottom right hand side of the screen and two new configuration options were added that you can set in your application or extension's `Config.cfc$configure()` method:


```luceescript
component {
    
    function configure() {
        // ...
        settings.adminNotificationsSticky    = true;           // default
        settings.adminNotificationsPosition  = "bottom-right"; // default
        // ...
    }
}
```

**Sticky** notifications require the user to dismiss the notification before it disappears (default). If set to false, the notification will disappear after some time.

Valid positions for the `adminNotificationsPosition` setting are:

* `top-left`
* `top-right`
* `bottom-left`
* `bottom-right` (default)---
id: dataobjects
title: Data objects
---

## Overview

**Preside Data Objects** are the data layer implementation for Preside. Just about everything in the system that persists data to the database uses Preside Data Objects to do so.

The Preside Data Objects system is deeply integrated into the CMS:

* Input forms and other administrative GUIs can be automatically generated for your preside objects
* [[dataobjectviews]] provide a way to present your data to end users without the need for handler or service layers
*  The Data Manager provides a GUI for managing your client specific data and is based on entirely on Preside Data Objects
* Your preside objects can have their data tied to individual [[workingwithmultiplesites]], without the need for any extra programming of site filters.

The following guide is intended as a thorough overview of Preside Data Objects. For API reference documentation, see [[api-presideobjectservice]].

## Object CFC Files

Data objects are represented by ColdFusion Components (CFCs). A typical object will look something like this:

```luceescript
component {
    property name="name"          type="string" dbtype="varchar" maxlength="200" required=true;
    property name="email_address" type="string" dbtype="varchar" maxlength="255" required=true uniqueindexes="email";

    property name="tags" relationship="many-to-many" relatedto="tag";
}
```

A singe CFC file represents a table in your database. Properties defined using the `property` tag represent fields and/or relationships on the table.

### Database table names

By default, the name of the database table will be the name of the CFC file prefixed with **pobj_**. For example, if the file was `person.cfc`, the table name would be **pobj_person**.

You can override these defaults with the `tablename` and `tableprefix` attributes:

```luceescript
/**
 * @tablename   mytable
 * @tableprefix mysite_
 */
component {
    // .. etc.
}
```

>>> All of the preside objects that are provided by the core Preside system have their table names prefixed with **psys_**.

### Registering objects

The system will automatically register any CFC files that live under the `/application/preside-objects` folder of your site (and any of its sub-folders). Each .cfc file will be registered with an ID that is the name of the file without the ".cfc" extension.

For example, given the directory structure below, *four* objects will be registered with the IDs *blog*, *blogAuthor*, *event*, *eventCategory*:

```
/application
    /preside-objects
        /blogs
            blog.cfc
            blogAuthor.cfc
        /events
            event.cfc
            eventCategory.cfc
```

>>> Notice how folder names are ignored. While it is useful to use folders to organise your Preside Objects, they carry no logical meaning in the system.

#### Extensions and core objects

For extensions, the system will search for CFC files in a `/preside-objects` folder at the root of your extension.

Core system Preside Objects can be found at `/preside/system/preside-objects`.

## Properties

Properties represent fields on your database table or mark relationships between objects (or both).

Attributes of the properties describe details such as data type, data length and validation requirements. At a minimum, your properties should define a *name*, *type* and *dbtype* attribute. For *varchar* fields, a *maxLength* attribute is also required. You will also typically need to add a *required* attribute for any properties that are a required field for the object:

```luceescript
component {
    property name="name"          type="string"  dbtype="varchar" maxLength="200" required=true;
    property name="max_delegates" type="numeric" dbtype="int"; // not required
}
```

### Standard attributes

While you can add any arbitrary attributes to properties (and use them for your own business logic needs), the system will interpret and use the following standard attributes:

<div class="table-resp">
    <table class="table">
        <thead>
            <tr>
                <th>Name</th>
                <th>Required</th>
                <th>Default</th>
                <th>Description</th>
            </tr>
        </thead>
        <tbody>
            <tr><td>name</td>                 <td>Yes</td> <td>*N/A*</td>     <td>Name of the field</td>                                                                                                                                                                                                                                               </tr>
            <tr><td>type</td>                 <td>No</td>  <td>"string"</td>  <td>CFML type of the field. Valid values: *string*, *numeric*, *boolean*, *date*</td>                                                                                                                                                                                    </tr>
            <tr><td>dbtype</td>               <td>No</td>  <td>"varchar"</td> <td>Database type of the field to be define on the database table field        </td>                                                                                                                                                                                     </tr>
            <tr><td>maxLength</td>            <td>No</td>  <td>0</td>         <td>For dbtypes that require a length specification. If zero, the max size will be used.</td>                                                                                                                                                                            </tr>
            <tr><td>required</td>             <td>No</td>  <td>**false**</td> <td>Whether or not the field is required.    </td>                                                                                                                                                                                                                       </tr>
            <tr><td>default</td>              <td>No</td>  <td>""</td>        <td>A default value for the property. Can be dynamically created, see :ref:`presideobjectsdefaults`</td>                                                                                                                                                                 </tr>
            <tr><td>indexes</td>              <td>No</td>  <td>""</td>        <td>List of indexes for the field, see :ref:`preside-objects-indexes`</td>                                                                                                                                                                                               </tr>
            <tr><td>uniqueindexes</td>        <td>No</td>  <td>""</td>        <td>List of unique indexes for the field, see :ref:`preside-objects-indexes`</td>                                                                                                                                                                                        </tr>
            <tr><td>control</td>              <td>No</td>  <td>"default"</td> <td>The default form control to use when rendering this field in a Preside Form. If set to 'default', the value for this attribute will be calculated based on the value of other attributes. See :doc:`/devguides/formcontrols` and :doc:`/devguides/formlayouts`.</td> </tr>
            <tr><td>renderer</td>             <td>No</td>  <td>"default"</td> <td>The default content renderer to use when rendering this field in a view. If set to 'default', the value for this attribute will be calculated based on the value of other attributes. (reference needed here).</td>                                                  </tr>
            <tr><td>minLength</td>            <td>No</td>  <td>*none*</td>    <td>Minimum length of the data that can be saved to this field. Used in form validation, etc. </td>                                                                                                                                                                      </tr>
            <tr><td>minValue</td>             <td>No</td>  <td>*none*</td>    <td>The minumum numeric value of data that can be saved to this field. *For numeric types only*.</td>                                                                                                                                                                    </tr>
            <tr><td>maxValue</td>             <td>No</td>  <td>*N/A*</td>     <td>The maximum numeric value of data that can be saved to this field. *For numeric types only*.</td>                                                                                                                                                                    </tr>
            <tr><td>format</td>               <td>No</td>  <td>*N/A*</td>     <td>Either a regular expression or named validation filter (reference needed) to validate the incoming data for this field</td>                                                                                                                                          </tr>
            <tr><td>pk</td>                   <td>No</td>  <td>**false**</td> <td>Whether or not this field is the primary key for the object, *one field per object*. By default, your object will have an *id* field that is defined as the primary key. See :ref:`preside-objects-default-properties` below.</td>                                   </tr>
            <tr><td>generator</td>            <td>No</td>  <td>"none"</td>    <td>Named generator for generating a value for this field when inserting/updating a record with the value of this field ommitted. See "Generated fields", below.</td>
            <tr><td>generate</td>             <td>No</td>  <td>"never"</td>   <td>If using a generator, indicates when to generate the value. Valid values are "never", "insert" and "always".</td>
            <tr><td>formula</td>              <td>No</td>  <td>""</td>        <td>Allows you to define a field that does not exist in the database, but can be selected and used in the application. This attribute should consist of arbitrary SQL to produce a value. See "Formula fields", below.</td>
            <tr><td>relationship</td>         <td>No</td>  <td>"none"</td>    <td>Either *none*, *many-to-one* or *many-to-many*. See :ref:`preside-objects-relationships`, below.</td>                                                                                                                                                                </tr>
            <tr><td>relatedTo</td>            <td>No</td>  <td>"none"</td>    <td>Name of the Preside Object that the property is defining a relationship with. See :ref:`preside-objects-relationships`, below.</td>                                                                                                                                  </tr>
            <tr><td>relatedVia</td>           <td>No</td>  <td>""</td>        <td>Name of the object through which a many-to-many relationship will pass. If it does not exist, the system will created it for you.  See :ref:`preside-objects-relationships`, below.</td>                                                                             </tr>
            <tr><td>relationshipIsSource</td> <td>No</td>  <td>**true**</td>  <td>In a many-to-many relationship, whether or not this object is regarded as the "source" of the relationship. If not, then it is regarded as the "target". See :ref:`preside-objects-relationships`, below.</td>                                                       </tr>
            <tr><td>relatedViaSourceFk</td>   <td>No</td>  <td>""</td>        <td>The name of the source object's foreign key field in a many-to-many relationship's pivot table. See :ref:`preside-objects-relationships`, below.</td>                                                                                                                </tr>
            <tr><td>relatedViaTargetFk</td>   <td>No</td>  <td>""</td>        <td>The name of the target object's foreign key field in a many-to-many relationship's pivot table. See :ref:`preside-objects-relationships`, below.</td>                                                                                                                </tr>
            <tr><td>enum</td>                 <td>No</td>  <td>""</td>        <td>The name of the configured enum to use with this field. See "ENUM properties", below.</tr>
            <tr><td>aliasses</td>                 <td>No</td>  <td>""</td>        <td>List of alternative names (aliasses) for the property.</tr>        </tbody>
    </table>
</div>

### Default properties

The bare minimum code requirement for a working Preside Data Object is:

```luceescript
component {}
```

Yes, you read that right, an "empty" CFC is an effective Preside Data Object. This is because, by default, Preside Data Objects will be automatically given  `id`, `label`, `datecreated` and `datemodified` properties. The above example is equivalent to:

```luceescript
component {
    property name="id"           type="string" dbtype="varchar"   required=true maxLength="35" generator="UUID" pk=true;
    property name="label"        type="string" dbtype="varchar"   required=true maxLength="250";
    property name="datecreated"  type="date"   dbtype="datetime" required=true;
    property name="datemodified" type="date"   dbtype="datetime" required=true;
}
```

#### The ID Field

The ID field will be the primary key for your object. We have chosen to use a UUID for this field so that data migrations between databases are achievable. If, however, you wish to use an auto incrementing numeric type for this field, you could do so by overriding the `type`, `dbtype` and `generator` attributes:

```luceescript
component {
    property name="id" type="numeric" dbtype="int" generator="increment";
}
```

The same technique can be used to have a primary key that does not use any sort of generator (you would need to pass your own IDs when inserting data):

```luceescript
component {
    property name="id" generator="none";
}
```

>>>>>> Notice here that we are just changing the attributes that we want to modify (we do not specify `required` or `pk` attributes). All the default attributes will be applied unless you specify a different value for them.

#### The Label field

The **label** field is used by the system for building automatic GUI selectors that allow users to choose your object records.

![Screenshot showing a record picker for a "Blog author" object](images/screenshots/object_picker_example.png)


If you wish to use a different property to represent a record, you can use the `labelfield` attribute on your CFC, e.g.:

```luceescript
/**
 * @labelfield title
 *
 */
component {
    property name="title" type="string" dbtype="varchar" maxlength="100" required=true;
    // etc.
}
```

If you do not want your object to have a label field at all (i.e. you know it is not something that will ever be selectable, and there is no logical field that might be used as a string representation of a record), you can add a `nolabel=true` attribute to your CFC:

```luceescript
/**
 * @nolabel true
 *
 */
component {
    // ... etc.
}
```

#### The DateCreated and DateModified fields

These do exactly what they say on the tin. If you use the APIs to insert and update your records, the values of these fields will be set automatically for you.


### Default values for properties

You can use the `default` attribute on a property tag to define a default value for a property. This value will be used during an `insertData()` operation when no value is supplied for the property. E.g.

```luceescript
component {
    // ...
    property name="max_attendees" type="numeric" dbtype="int" required=false default=100;
}
```

#### Dynamic defaults

Default values can also be generated dynamically at runtime. Currently, this comes in two flavours:

1. Supplying raw CFML to be evaluated at runtime
2. Supplying the name of a method defined in your object that will be called at runtime, this method will be passed a 'data' argument that is a structure containing the data to be inserted

For raw CFML, prefix your value with `cfml:`, e.g. `cfml:CreateUUId()`. For methods that are defined on your object, use `method:methodName`. e.g.

```luceescript
component  {
    // ...
    property name="event_start_date" type="date"   dbtype="date"                      required=false default="cfml:Now()";
    property name="slug"             type="string" dbtype="varchar"   maxlength="200" required=false default="method:calculateSlug";

    public string function calculateSlug( required struct data ) {
        return LCase( ReReplace( data.label ?: "", "\W", "_", "all" ) );
    }
}
```

>>> As of Preside 10.8.0, this approach is deprecated and you should use generated fields instead (see below)

### Generated fields

As of **10.8.0**, generators allow you to dynamically generate the value of a property when a record is first being inserted and, optionally, when a record is updated. The `generate` attribute of a property dictates _when_ to use a generator. Valid values are:

* `never` (default), never generate the value
* `insert`, only generate a value when a record is first inserted
* `always`, generate a value on both insert and update of records

The `generator` attribute itself then allows you to use a system pre-defined generator or use your own by prefixing the generator with `method:` (the method name that follows should be defined on your object). For example:

```luceescript
component {
    // ...

    property name="alternative_pk"   type="string" dbtype="varchar" maxlength=35 generate="insert" generator="UUID";
    property name="description"      type="string" dbtype="text";
    property name="description_hash" type="string" dbtype="varchar" maxlength=32 generate="always" generator="method:hashDescription";

    // ...

    // The method will receive a single argument that is the struct
    // of data passed to the insertData() or updateData() methods
    public any function hashDescription( required struct changedData ) {
        if ( changedData.keyExists( "description" ) ) {
            if ( changedData.description.len() ) {
                return Hash( changedData.description );
            }

            return "";
        }
        return; // return NULL to not alter the value when no description is being updated
    }
}
```

The core system provides you with these named generators:

* `UUID` - uses `CreateUUId()` to generate a UUID for your field. This is used by default for the primary key in preside objects.
* `timestamp` - uses `Now()` to auto generate a timestamp for your field
* `hash` - used in conjunction with a `generateFrom` attribute that should be a list of other properties which to concatenate and generate an MD5 hash from
* `nextint` - **introduced in 10.12.0**, gives the next incremental integer value for the field
* `slug` - takes an optional `generateFrom` attribute that defines which field (if present in the submitted data) should be used to generate the slug; by default it will use the object's label field. A unique slug will be generated, so may be suffixed with `-1`, `-2`, etc.

#### Developer provided generators

As of **10.13.0**, you are able to create convention based handler actions for generators. The convention based handler name for any generator is `generators.{generatorname}`.

For example, the property below would attempt to use a handler action of `generators.my.generator`, i.e. a file `/handlers/generators/My.cfc` with a `generator()` method.

```luceescript
property name="is_cool" ... generator="my.generator";
```

Your handler action will receive an `args` struct in the arguments with the following keys:

* `objectName`: the name of the object whose record is being added/updated
* `id`: the ID of the record (for updates only)
* `generator`: the full generator string used
* `data`: a struct with the data being passed to the insert/update operation
* `prop`: a struct with all the property attributes of the property whos value is being generated

##### Example

```luceescript
component {

    private boolean function generator( event, rc, prc, args={} ) {
        return IsTrue( args.data.under_thirty ?: "" ) && ( ( args.status ?: "" ) == "active" );
    }

}
```

### Formula fields

Properties that define a formula are not generated as fields in your database tables. Instead, they are made available to your application to be selected in `selectData` queries. The value of the `formula` attribute should be a valid SQL statement that can be used in a SQL `select` statement and include `${prefix}` tokens before any field definitions (see below for an explanation). For example:

```luceescript
/**
 * @datamanagerGridFields title,comment_count,datemodified
 *
 */
component {
    // ...

    property name="comments" relationship="one-to-many" relatedto="article_comment";
    property name="comment_count" formula="Count( distinct ${prefix}comments.id )" type="numeric";

    // ...
}
```

```luceescript
articles = articleDao.selectData(
    selectFields = [ "id", "title", "comment_count" ]
);
```

Formula fields can also be used in your DataManager data grids and be assigned labels in your object's i18n `.properties` file.

>>> Note that formula fields are only selected when _explicitly defined_ in your `selectFields`. If you leave `selectData` to return "all" fields, only the properties that are stored in the database will be returned.

#### Formula ${prefix} token

The `${prefix}` token in formula fields allows your formula field to be used in more complex select queries that traverse your data model's relationships. Another example, this time a `person` cfc:

```luceescript
component {
    // ...
    property name="first_name" ...;
    property name="last_name"  ...;

    property name="full_name" formula="Concat( ${prefix}first_name, ' ', ${prefix}last_name )";
    // ...
}
```
Now, let us imagine we have a company object, with an "employees" `one-to-many` property that relates to our `person` object above. We may want to select employees from a company:

```luceescript
var employees = companyDao.selectData(
      id           = arguments.companyId
    , selectFields = [ "employees.id", "employees.full_name" ]
);
```

The `${prefix}` token allows us to take the `employees.` prefix of the `full_name` field and replace it so that the final select SQL becomes: `Concat( employees.first_name, ' ', employees.last_name )`. Without a `${prefix}` token, your formula field will only work when selecting directly from the object in which the property is defined, it will not work when traversing relationships as with the example above.

#### Aggregate functions in formula fields

As of **10.23.0**, a new syntax for aggregate functions within formula fields is available, which gives significant performance gains in the generated SQL queries.

Whereas previously you may have written:

```luceescript
property name="comment_count"        type="numeric" formula="count( distinct ${prefix}comments.id )";
property name="latest_comment_reply" type="date"    formula="max( ${prefix}comments$replies.date )";
```

...these would now be written like this:

```luceescript
property name="comment_count"        type="numeric" formula="agg:count{ comments.id }";
property name="latest_comment_reply" type="date"    formula="agg:max{ comments$replies.date }";
```

The syntax takes the form `agg:` followed by the aggregate function name (count, min, max, sum, avg) and then the property to be aggregated contained within curly braces `{}`. Note that `${prefix}` is not required.

The existing syntax will still work, but the new syntax should provide improved performance - especially when multiple formulas are included in the same query, and when the volumes of data involved grow larger. Existing `count()` formulae will automatically be detected and will make use of the optimisation.


### ENUM properties

Properties defined with an `enum` attribute implement an application enforced ENUM system. Named ENUM types are defined in your application's `Config.cfc` and can then be attributed to a property which then automatically limits and validates the options that are available to the field. ENUM options are saved to the database as a plain string; we avoid any mapping with integer values to keep the implementation portable and simple. Example ENUM definitions in `Config.cfc`:

```luceescript
settings.enum = {};
settings.enum.redirectType                = [ "301", "302" ];
settings.enum.pageAccessRestriction       = [ "inherit", "none", "full", "partial" ];
settings.enum.pageIframeAccessRestriction = [ "inherit", "block", "sameorigin", "allow" ];
```

In addition to the `Config.cfc` definition, each ENUM type should have a corresponding `.properties` file to define the labels and optional description of each item. The file must live at `/i18n/enum/{enumTypeId}.properties`. For example:


```properties
# /i18n/enum/redirectType.properties
301.label=301 Moved Permanently
301.description=A 301 redirect indicates that the resource has been *permanently* moved to the new locations. This is particularly important to use for moved content as it instructs search engines to index the new location, potentially without losing any SEO rankings. Browsers will aggressively cache these redirects to avoid wasted calls to a URL that it has been told is moved.

302.label=302 Found (Temporary redirect)
302.description=A 302 redirect indicates that the resource has been *temporarily* moved to the new location. Use this only when you know that you will/might reinstate the original source URL at some point in time.
```

### Defining relationships with properties

Relationships are defined on **property** tags using the `relationship` and `relatedTo` attributes. For example:

```luceescript
// eventCategory.cfc
component {}

// event.cfc
component {
    property name="category" relationship="many-to-one" relatedto="eventCategory" required=true;
}
```

If you do not specify a `relatedTo` attribute, the system will assume that the foreign object has the same name as the property field. For example, the two objects below would be related through the `eventCategory` property of the `event` object:

```luceescript
// eventCategory.cfc
component {}

// event.cfc
component {
    property name="eventCategory" relationship="many-to-one" required=true;
}
```

#### One to Many relationships

In the examples, above, we define a **one to many** style relationship between `event` and `eventCategory` by adding a foreign key property to the `event` object.

The `category` property will be created as a field in the `event` object's database table. Its datatype will be automatically derived from the primary key field in the `eventCategory` object and a Foreign Key constraint will be created for you.

>>> The `event` object lives on the **many** side of this relationship (there are *many events* to *one category*), hence why we use the relationship type, *many-to-one*.

You can also declare the relationship on the other side (i.e. the 'one' side). This will allow you to traverse the relationship from either angle. e.g. we could add a 'one-to-many' property on the `eventCategory.cfc` object; this will not create a field in the database table, but will allow you to query the relationship from the category viewpoint:

```luceescript
// eventCategory.cfc
component {
    // note that the 'relationshipKey' property is the FK in the event object
    // this will default to the name of this object
    property name="events" relationship="one-to-many" relatedTo="event" relationshipKey="eventCategory";
}

// event.cfc
component {
    property name="eventCategory" relationship="many-to-one" required=true;
}
```

#### Many to Many relationships

If we wanted an event to be associated with multiple event categories, we would want to use a **Many to Many** relationship:

```luceescript
// eventCategory.cfc
component {}

// event.cfc
component {
    property name="eventCategory" relationship="many-to-many";
}
```

In this scenario, there will be no `eventCategory` field created in the database table for the `event` object. Instead, a "pivot" database table will be automatically created that looks a bit like this (in MySQL):

```sql
-- table name derived from the two related objects, delimited by __join__
create table `pobj_event__join__eventcategory` (
    -- table simply has a field for each related object
      `event`         varchar(35) not null
    , `eventcategory` varchar(35) not null

    -- plus we always add a sort_order column, should you care about
    -- the order in which records are related
    , `sort_order`    int(11)     default null

    -- unique index on the event and eventCategory fields
    , unique key `ux_event__join__eventcategory` (`event`,`eventcategory`)

    -- foreign key constraints on the event and eventCategory fields
    , constraint `fk_1` foreign key (`event`        ) references `pobj_event`         (`id`) on delete cascade on update cascade
    , constraint `fk_2` foreign key (`eventcategory`) references `pobj_eventcategory` (`id`) on delete cascade on update cascade
) ENGINE=InnoDB;
```

>>> Unlike **many to one** relationships, the **many to many** relationship can be defined on either or both objects in the relationship. That said, you will want to define it on the object(s) that make use of the relationship. In the event / eventCategory example, this will most likely be the event object. i.e. `event.insertData( label=eventName, eventCategory=listOfCategoryIds )`.

#### "Advanced" Many to Many relationships

You can excert a little more control over your many-to-many relationships by making use of some extra, non-required, attributes:

```luceescript
// event.cfc
component {
    property name                 = "eventCategory"
             relationship         = "many-to-many"
             relatedTo            = "eventCategory"
             relationshipIsSource = false              // the event object is regarded as the 'target' side of the relationship rather than the 'source' (default is 'source' when relationship defined in the object)
             relatedVia           = "event_categories" // create a new auto pivot object called "event_categories" rather than the default "event__join__eventCategory"
             relatedViaSourceFk   = "cat"              // name the foreign key field to the source object (eventCategory) to be just 'cat'
             relatedViaTargetFk   = "ev";              // name the foreign key field to the target object (event) to be just 'ev'
}
```

TODO: explain these in more detail. In short though, these attributes control the names of the pivot table and foreign keys that get automatically created for you. If you leave them out, Preside will figure out sensible defaults for you.

As well as controlling the automatically created pivot table name with "relatedVia", you can also use this attribute to define a relationship that exists through a pre-existing pivot object.

>>>>>> If you have multiple many-to-many relationships between the same two objects, you will **need** to use the `relatedVia` attribute to ensure that a different pivot table is created for each context.

#### Subquery relationships with "SelectData Views"

In **10.11.0** the concept of [[selectdataviews]] was introduced. These 'views' are loosely synonymous with SQL views in that they allow you to store a complex query and reference it by a simple name.

They can be used in relationship helper properties and result in subqueries being created when querying them. The syntax is the same as that of a `one-to-many` relationship:

```
component {
    property name="active_posts" relationship="select-data-view" relatedTo="activePosts" relationshipKey="blog_category";
}
```

See [[selectdataviews]] for more.

### Defining indexes and unique constraints

The Preside Object system allows you to define database indexes on your fields using the `indexes` and `uniqueindexes` attributes. The attributes expect a comma separated list of index definitions. An index definition can be either an index name or combination of index name and field position, separated by a pipe character. For example:

```luceescript
// event.cfc
component {
    property name="category" indexes="category,categoryName|1" required=true relationship="many-to-one" ;
    property name="name"     indexes="categoryName|2"          required=true type="string" dbtype="varchar" maxlength="100";
    // ...
}
```

The example above would result in the following index definitions:

```sql
create index ix_category     on pobj_event( category );
create index ix_categoryName on pobj_event( category, name );
```

The exact same syntax applies to unique indexes, the only difference being the generated index names are prefixed with `ux_` rather than `ix_`.

## Keeping in sync with the database

When you reload your application, the system will attempt to synchronize your object definitions with the database. While it does a reasonably good job at doing this, there are some considerations:

* If you add a new, required, field to an object that has existing data in the database, an exception will be raised. This is because you cannot add a `NOT NULL` field to a table that already has data. *You will need to provide upgrade scripts to make this type of change to an existing system.*

* When you delete properties from your objects, the system will rename the field in the database to `_deprecated_yourfield`. This prevents accidental loss of data but can lead to a whole load of extra fields in your DB during development.

* The system never deletes whole tables from your database, even when you delete the object file

## Working with the API

The `PresideObjectService` service object provides methods for performing CRUD operations on the data along with other useful methods for querying the metadata of each of your data objects. There are two ways in which to interact with the API:

1. Obtain an instance the `PresideObjectService` and call its methods directly
2. Obtain an "auto service object" for the specific object you wish to work with and call its decorated CRUD methods as well as any of its own custom methods

You may find that all you wish to do is to render a view with some data that is stored through the Preside Object service. In this case, you can bypass the service layer APIs and use the [[presidedataobjectviews]] system instead.


### Getting an instance of the Service API

We use [Wirebox](http://wiki.coldbox.org/wiki/WireBox.cfm) to auto wire our service layer. To inject an instance of the service API into your service objects and/or handlers, you can use wirebox's "inject" syntax as shown below:

```luceescript

// a handler example
component {
    property name="presideObjectService" inject="presideObjectService";

    function index( event, rc, prc ) {
        prc.eventRecord = presideObjectService.selectData( objectName="event", id=rc.id ?: "" );

        // ...
    }
}

// a service layer example
// (here at Pixl8, we prefer to inject constructor args over setting properties)
component {

    /**
     * @presideObjectService.inject presideObjectService
     */
     public any function init( required any presideObjectService ) {
        _setPresideObjectService( arguments.presideObjectService );

        return this;
     }

     public query function getEvent( required string id ) {
        return _getPresideObjectService().selectData(
              objectName = "event"
            , id         = arguments.id
        );
     }

     // we prefer private getters and setters for accessing private properties, this is our house style
     private any function _getPresideObjectService() {
         return variables._presideObjectService;
     }
     private void function _setPresideObjectService( required any presideObjectService ) {
         variables._presideObjectService = arguments.presideObjectService;
     }

}
```

### Using Auto Service Objects

An auto service object represents an individual data object. They are an instance of the given object that has been decorated with the service API CRUD methods.

Calling the CRUD methods works in the same way as with the main API with the exception that the objectName argument is no longer required. So:

```luceescript
record = presideObjectService.selectData( objectName="event", id=id );

// is equivalent to:
eventObject = presideObjectService.getObject( "event" );
record      = eventObject.selectData( id=id );
```

#### Getting an auto service object

This can be done using either the `getObject()` method of the Preside Object Service or by using a special Wirebox DSL injection syntax, i.e.

```luceescript
// a handler example
component {
    property name="eventObject" inject="presidecms:object:event";

    function index( event, rc, prc ) {
        prc.eventRecord = eventObject.selectData( id=rc.id ?: "" );

        // ...
    }
}

// a service layer example
component {

    /**
     * @eventObject.inject presidecms:object:event
     */
     public any function init( required any eventObject ) {
        _setPresideObjectService( arguments.eventObject );

        return this;
     }

     public query function getEvent( required string id ) {
        return _getEventObject().selectData( id = arguments.id );
     }

     // we prefer private getters and setters for accessing private properties, this is our house style
     private any function _getEventObject() {
         return variables._eventObject;
     }
     private void function _setEventObject( required any eventObject ) {
         variables._eventObject = arguments.eventObject;
     }

}
```

### CRUD Operations

The service layer provides core methods for creating, reading, updating and deleting records (see individual method documentation for reference and examples):

* [[presideobjectservice-selectdata]]
* [[presideobjectservice-insertdata]]
* [[presideobjectservice-updatedata]]
* [[presideobjectservice-deletedata]]

In addition to the four core methods above, there are also further utility methods for specific scanarios:

* [[presideobjectservice-dataexists]]
* [[presideobjectservice-selectmanytomanydata]]
* [[presideobjectservice-syncmanytomanydata]]
* [[presideobjectservice-getdenormalizedmanytomanydata]]
* [[presideobjectservice-getrecordversions]]
* [[presideobjectservice-insertdatafromselect]]


#### Specifying fields for selection

The [[presideobjectservice-selectdata]] method accepts a `selectFields` argument that can be used to specify which fields you wish to select. This can be done by the field's name or one of it's aliasses. This can be used to select properties on your object as well as properties on related objects and any plain SQL aggregates or other SQL operations. For example:

```luceescript
records = newsObject.selectData(
    selectFields = [ "news.id", "news.title", "Concat( category.label, category$tag.label ) as catandtag"  ]
);
```

The example above would result in SQL that looked something like:

```sql
select      news.id
          , news.title
          , Concat( category.label, tag.label ) as catandtag

from        pobj_news     as news
inner join  pobj_category as category on category.id = news.category
inner join  pobj_tag      as tag      on tag.id      = category.tag
```

>>> The funky looking `category$tag.label` is expressing a field selection across related objects - in this case **news** -> **category** -> **tag**. See relationships, below, for full details.

### Filtering data

All but the **insertData()** methods accept a data filter to either refine the returned recordset or the records to be updated / deleted. The API provides two arguments for filtering, `filter` and `filterParams`. Depending on the type of filtering you need, the `filterParams` argument will be optional.

#### Simple filtering

A simple filter consists of one or more strict equality checks, all of which must be true. This can be expressed as a simple CFML structure; the structure keys represent the object fields; their values represent the expected record values:

```luceescript
records = newsObject.selectData( filter={
      category             = chosenCategory
    , "category$tag.label" = "red"
} );
```

>>> The funky looking `category$tag.label` is expressing a filter across related objects - in this case **news** -> **category** -> **tag**. We are filtering news items whos category is tagged with a tag whose label field = "red".

#### Complex filters

More complex filters can be achieved with a plain SQL filter combined with filter params to make use of parametized SQL statements:

```luceescript
records = newsObject.selectData(
      filter       = "category != :category and DateDiff( publishdate, :publishdate ) > :daysold and category$tag.label = :category$tag.label"
    , filterParams = {
           category             = chosenCategory
         , publishdate          = publishDateFilter
         , "category$tag.label" = "red"
         , daysOld              = { type="integer", value=3 }
      }
);
```

>>> Notice that all but the *daysOld* filter param do not specify a datatype. This is because the parameters can be mapped to fields on the object/s and their data types derived from there. The *daysOld* filter has no field mapping and so its data type must also be defined here.

#### Multiple filters

In addition to the `filter` and `filterParams` arguments, you can also make use of an `extraFilters` argument that allows you to pass an array of structs, each with a `filter` and optional `filterParams` key. All filters will be combined using a logical AND:

```luceescript
records = newsObject.selectData(
    extraFilters = [{
          filter = { active=true }
    },{
          filter       = "category != :category and DateDiff( publishdate, :publishdate ) > :daysold and category$tag.label = :category$tag.label"
        , filterParams = {
               category             = chosenCategory
             , publishdate          = publishDateFilter
             , "category$tag.label" = "red"
             , daysOld              = { type="integer", value=3 }
          }

    } ]
);
```

#### Pre-saved filters

Developers are able to define named filters that can be passed to methods in an array using the `savedFilters` argument, for example:

```luceescript
records = newsObject.selectData( savedFilters = [ "activeCategories" ] );
```

These filters can be defined either in your application's `Config.cfc` file or, **as of 10.11.0**, by implementing a convention based handler. In either case, the named filter should resolve to a _struct_ with `filter` and `filterParams` keys that follow the same rules documented above.

##### Defining saved filters in Config.cfc

A saved filter is defined using the `settings.filters` struct. A filter can either be a struct, with `filter` and optional `filterParams` keys, _or_ an inline function that returns a struct:

```luceescript
settings.filters.activeCategories = {
      filter       = "category.active = :category.active and category.pub_date > Now()"
    , filterParams = { "category.active"=true }
};

// or:

settings.filters.activeCategories = function( struct args={}, cbController ) {
    return cbController.getWirebox.getInstance( "categoriesService" ).getActiveCategoriesFilter();
}
```

##### Defining saved filters using handlers

**As of 10.11.0**, these filters can be defined by _convention_ by implementing a private coldbox handler at `DataFilters.filterName`. For example, to implement a `activeCategories` filter:

```luceescript
// /handlers/DataFilters.cfc
component {

    property name="categoriesService" inject="categoriesService";

    private struct function activeCategories( event, rc, prc, args={} ) {
        return categoriesService.getActiveCategoriesFilter();

        // or

        return {
              filter       = "category.active = :category.active and category.pub_date > :category.pub_date"
            , filterParams = { "category.active"=true, "category.pub_date"=Now() }
        }
    }

}
```

#### Default filters

**As of 10.11.0**, developers can use **saved filters** as default filters. Default filters are filters that will be **automatically** applied to **selectData()**.

##### Using default filters

Default filters can be applied by passing a list of saved filters to the `@defaultFilters` annotations in the object file. For example:

```luceescript
/**
 * @defaultFilters publishedStuff,approvedStuff
 */
component {
    // ...
}
```

##### Ignoring default filters

In case of needing to ignore the default filters, developers need to pass an array of default filters that wished to be ignored to `ignoreDefaultFilters` argument in their `selectData()`. For example:

```luceescript
allRecords = recordObject.selectData( ignoreDefaultFilters = [ "publishedStuff", "approvedStuff" ] );
```

### Making use of relationships

As seen in the examples above, you can use a special field syntax to reference properties in objects that are related to the object that you are selecting data from / updating data on. When you do this, the service layer will automatically create the necessary SQL joins for you.

The syntax takes the form: `(relatedObjectReference).(propertyName)`. The related object reference can either be the name of the related object, or a `$` delimited path of property names that navigate through the relationships (see examples below).

This syntax can be used in:

* Select fields
* Filters
* Order by statements
* Group by statements

To help with the examples, we'll illustrate a simple relationship between three objects:

```luceescript

// tag.cfc
component {}

// category.cfc
component {
    property name="category_tag" relationship="many-to-one" relatedto="tag"  required=true;
    property name="news_items"   relationship="one-to-many" relatedTo="news" relationshipKey="news_category";
    // ..
}

// news.cfc
component {
    property name="news_category" relationship="many-to-one" relatedto="category" required=true;
    // ..
}
```

#### Auto join example

```luceescript
// update news items whose category tag = "red"
presideObjectService.updateData(
      objectName = "news"
    , data       = { archived = true }
    , filter     = { "tag.label" = "red" } // the system will automatically figure out the relationship path between the news object and the tag object
);
```

#### Property name examples

```luceescript
// delete news items whose category label = "red"
presideObjectService.deleteData(
      objectName = "news"
    , data       = { archived = true }
    , filter     = { "news_category.label" = "red" }
);

// select title and category tag from all news objects, order by the category tag
presideObjectService.selectData(
      objectName   = "news"
    , selectFields = [ "news.title", "news_category$category_tag.label as tag" ]
    , orderby      = "news_category$category_tag.label"
);

// selecting categories with a count of news articles for each category
presideObjectService.selectData(
      objectName   = "category"
    , selectFields = [ "category.label", "Count( news_items.id ) as news_item_count" ]
    , orderBy      = "news_item_count desc"
);
```

>>>> While the auto join syntax can be really useful, it is limited to cases where there is only a single relationship path between the two objects. If there are multiple ways in which you could join the two objects, the system can have no way of knowing which path it should take and will throw an error.

### Caching

By default, all [[presideobjectservice-selectData]] calls have their recordset results cached. These caches are automatically cleared when the data changes.

You can specify *not* to cache results with the `useCache` argument.

### Cache per object

**As of Preside 10.10.55**, an additional feature flag enables the setting of caches _per object_. This greatly simplifies and speeds up the cache clearing and invalidation logic which may benefit certain application profiles. The feature can be enabled in your `Config.cfc` with:

```luceescript
settings.features.queryCachePerObject.enabled = true;
```

Configuration of the `defaultQueryCache` then becomes the _default_ configuration for each individual object's own cachebox cache instance.

In addition, you can annotate your Preside object with `@cacheProvider` to use a different cache provider for a specific object. Finally, any other annotation attributes on your object that begin with `@cache` will be treated as properties of the cache box cache.

A common example may be to set a larger cache for a specific object with different reaping frequency and eviction count:

```luceescript
/**
 * @cacheMaxObjects    10000
 * @cacheReapFrequency 5
 * @cacheEvictCount    2000
 */
component {

}
```

## Extending Objects

>>>>>> You can easily extend core data objects and objects that have been provided by extensions simply by creating `.cfc` file with the same name.

Objects with the same name, but from different sources, are merged at runtime so that you can have multiple extensions all contributing to the final object definition.

Take the `page` object, for example. You might write an extension that adds an **allow_comments** property to the object. That CFC would look like this:

```luceescript
// /extensions/myextension/preside-objects/page.cfc
component {
    property name="allow_comments" type="boolean" dbtype="boolean" required=false default=true;
}
```

After adding that code and reloading your application, you would find that the **psys_page** table now had an **allow_comments** field added.

Then, in your site, you may have some client specific requirements that you need to implement for all pages. Simply by creating a `page.cfc` file under your site, you can mix in properties along with the **allow_comments** mixin above:

```luceescript
// /application/preside-objects/page.cfc
component {
    // remove a property that has been defined elsewhere
    property name="embargo_date" deleted=true;

    // alter attributes of an existing property
    property name="title" maxLength="50"; // strict client requirement?!

    // add a new property
    property name="search_engine_boost" type="numeric" dbtype="integer" minValue=0 maxValue=100 default=0;
}
```

>>> To have your object changes reflected in GUI forms (i.e. the add and edit page forms in the example above), you will likely need to modify the form definitions for the object you have changed.

## Versioning

By default, Preside Data Objects will maintain a version history of each database record. It does this by creating a separate database table that is prefixed with `_version_`. For example, for an object named 'news', a version table named **_version_pobj_news** would be created.

The version history table contains the same fields as its twin as well as a few specific fields for dealing with version numbers, etc. All foreign key constraints and unique indexes are removed.

### Opting out

To opt out of versioning for an object, you can set the `versioned` attribute to **false** on your CFC file:

```luceescript
/**
 * @versioned false
 *
 */
component {
    // ...
}
```

### Interacting with versions

Various admin GUIs such as the :doc:`datamanager` implement user interfaces to deal with versioning records. However, if you find the need to create your own, or need to deal with version history records in any other way, you can use methods provided by the service api:

* [[presideobjectservice-getrecordversions]]
* [[presideobjectservice-getversionobjectname]]
* [[presideobjectservice-objectisversioned]]
* [[presideobjectservice-getnextversionnumber]]

In addition, you can specify whether or not you wish to use the versioning system, and also what version number to use if you are, when calling the [[presideobjectservice-insertData]], [[presideobjectservice-updateData]] and [[presideobjectservice-deleteData]] methods by using the `useVersioning` and `versionNumber` arguments.

Finally, you can select data from the version history tables with the [[presideobjectservice-selectdata]] method by using the `fromVersionTable`, `maxVersion` and `specificVersion` arguments.

### Many-to-many related data

By default, auto generated `many-to-many` data tables will be versioned along with your record changes. You can opt out of this by adding a `versioned=false` attribute to the `many-to-many` property:

```luceescript
property name="categories" relationship="many-to-many" relatedTo="category" versioned=false;
```

Inversely, you may have a `many-to-many` relationship for which you have an explicit join table that you'd like versioned along with the parent record. In this scenario, you can explicitly set `versioned=true`:

```luceescript
property name="categories" relationship="many-to-many" relatedTo="category" relatedVia="explicit_categories_obj" versioned=true;
```

### Ignoring changes

By default, when the data actually changes in your object, a new version will be created. If you wish certain fields to be ignored when it comes to determining whether or not a new version should be created, you can add a `ignoreChangesForVersioning` attribute to the property in the preside object.

An example scenario for this might be an object whose data is synced with an external source on a schedule. You may add a helper property to record the last sync check date, if no other fields have changed, you probably don't want a new version record being created just for that sync check date. In this case, you could do:

```luceescript
property name="_last_sync_check" type="date" dbtype="datetime" ignoreChangesForVersioning=true;
```

### Only create versions on update

As of **10.9.0**, you are able to specify that a version record is **not** created on **insert**. Instead, the first version record will be created on the first update to the record. This allows you to save on unnecessary version records in your database. To do this, add the `versionOnInsert=false` attribute to you object, e.g.

```luceescript
/**
 * @versioned       true
 * @versionOnInsert false
 */
component {
    // ...
}
```

## Organising data by sites

You can instruct the Preside Data Objects system to organise your objects' data into your system's individual sites (see [[workingwithmultiplesites]]). Doing so will mean that any data reads and writes will be specific to the currently active site.

To enable this feature for an object, simply add the `siteFiltered` attribute to the `component` tag:

```luceescript
/**
 * @siteFiltered true
 *
 */
component {
    // ...
}
```

>>>> As of Preside 10.8.0, this method is deprecated and you should instead use `@tenant site`. See [[data-tenancy]].


## Flagging an object record

You are able to flag a record for your objects' data. Doing so will mean you able to filter which records are flagged in the object.

To enable this feature for an object, simple add the `flagEnabled` attribute (disabled by default) to the `component` tag:

```luceescript
/**
 * @flagEnabled true
 *
 */
component {
    // ...
}
```

If you wish to use a different property to flag a record, you can use the `flagField` attribute on your CFC, e.g.:

```luceescript
/**
 * @flagField record_flag
 *
 */
component {
    property name="record_flag" type="boolean" dbtype="boolean" default="0" renderer="none" required=true;
}
```
---
id: presidesuperclass
title: Using the super class
---

## Overview

Preside comes with its own suite of service objects that you can use in your application just like any of your application's own service objects. In order to make it easy to access the most common core services, we created the [[api-presidesuperclass]] that can be injected into your service objects simply by adding the `@presideService` annotation to your service CFC file:

```luceescript
/**
 * @presideService
 */
component {

    function init() {
        return this;
    }

    // ...
}
// or
component presideService {

    function init() {
        return this;
    }

    // ...
}
```

>>> Service CFCs that declare themselves as Preside Services **must** implement an `init()` method, even if it does nothing but `return this;`.

## Usage

Once your service has been flagged as being a "Preside Service", it will instantly have a number of core methods available to it such as `$getPresideObject()` and `$isFeatureEnabled()`. e.g.

```luceescript
public boolean function updateProfilePicture( required string pictureFilePath ) {
    if ( $isWebsiteUserLoggedIn() && !$isWebsiteUserImpersonated() ) {
        return $getPresideObject( "website_user" ).updateData(
              id   = $getWebsiteLoggedInUserId()
            , data = { profile_picture = arguments.pictureFilePath }
        );
    }

    return false;
}
```

### Helpers

As of **10.11.0**, service components using the Preside Super Class have a `$helpers` object available to them. This object contains all the Coldbox helper UDFs defined in Preside, your application and any extensions you have installed. For example, you can now make use of the `isTrue()` helper with:

```luceescript
/**
 * @presideService true
 * @singleton      true
 */
component {
    function init() {
        return this;
    }

    function someMethod( required any someArg ) {
        if ( $helpers.isTrue( someArg ) ) {
            // do something
        }
    }
}
```

### Full reference

For a full reference of all the methods available, see [[api-presidesuperclass]].

>>> You will notice that we have prefixed all the function names in the Super Class with `$`. This is to make name conflicts less likely and to indicate that the methods have been injected into your object.
---
id: emailtemplatingv2
title: Email centre
---

## Overview

As of 10.8.0, Preside comes with a sophisticated but simple system for email templating that allows developers and content editors to work together to create a highly tailored system for delivering both marketing and transactional email.

>>> See [[emailtemplating]] for documentation on the basic email templating system prior to 10.8.0

## Concepts

### Email layouts

Email "layouts" are provided by developers and designers to provide content administrators with a basic set of styles and layout for their emails. Each template can be given configuration options that allow content administrators to tweak the behaviour of the template globally and per email.

An example layout might include a basic header and footer with configurable social media links and company contact details.

See [[creatingAnEmailLayout]].

### Email templates

An email _template_ is the main body of any email and is editorially driven, though developers may provide default content. When creating or configuring an email template, users may choose a layout from the application's provided set of layouts. If only one layout is available, no choice will be given.

Email templates are split into two categories:

1. System email templates (see [[systemEmailTemplates]])
2. Editorial email templates (e.g. for newsletters, etc.)

Editorial email templates will work out-of-the-box and require no custom development.

### Recipient types

Recipient types are configured to allow the email centre to send intelligently to different types of recipient. Each email template is configured to send to a specific recipient type. The core system provides three types:

1. Website user
2. Admin user
3. Anonymous

You may also have further custom recipient types and you may wish to modify the configuration of these three core types. See [[emailRecipientTypes]] for a full guide.

### Service providers

Email service providers are mechanims for performing an email send. You may have a 'Mailgun API' service provider, for example (see our [Mailgun Extension](https://github.com/pixl8/preside-ext-mailgun)).

The core provides a default SMTP provider and you are free to create multiple different providers for different purposes. See [[emailServiceProviders]] for a full guide.

### General settings

Navigating to **Email centre -> Settings** reveals a settings form for general email sending configuration. You may wish to add to this default configuration form, or retrieve settings programmatically. See [[emailSettings]] for a full guide.

## Feature switches and permissions

### Features

The email centre admin UI can be switched off using the `emailCentre` feature switch. In your application's `Config.cfc` file:

```luceescript
settings.features.emailCenter.enabled = false;
```

Furthermore, there is a separate feature switch to enable/disable _custom_ email template admin UIs, `customEmailTemplates`:


```luceescript
settings.features.customEmailTemplates.enabled = false;
```

Both features are enabled by default. The `customEmailTemplates` feature is only available when the the `emailCenter` feature is also enabled; disabling just the `emailCenter` feature has the effect of disabling both features.

As of 10.9.0, the ability to re-send emails sent via the email centre has been added. This is disabled by default, and can be enabled with the `emailCenterResend` feature:

```luceescript
settings.features.emailCenterResend.enabled = true;
```

See [[resendingEmail]] for a detailed guide.


### Permissions

The email centre comes with a set of permission keys that can be used to fine tune your administrator roles. The permissions are defined as:

```luceescript
settings.adminPermissions.emailCenter = {
	  layouts          = [ "navigate", "configure" ]
	, customTemplates  = [ "navigate", "view", "add", "edit", "delete", "publish", "savedraft", "configureLayout", "editSendOptions", "send" ]
	, systemTemplates  = [ "navigate", "savedraft", "publish", "configurelayout" ]
	, serviceProviders = [ "manage" ]
	, settings         = [ "navigate", "manage", "resend" ]
	, blueprints       = [ "navigate", "add", "edit", "delete", "read", "configureLayout" ]
	, logs             = [ "view" ]
	, queue            = [ "view", "clear" ]
  }
```

The default `sysadmin` and `contentadmin` user roles have access to all of these permissions _except_ for the `emailCenter.queue.view` and `emailCenter.queue.clear` permissions. For a full guide to customizing admin permissions and roles, see [[cmspermissioning]].

## Interception points

As of 10.11.0, there are a number of interception points that can be used to more deeply customize the email sending experience. You may, for example, use the `onSendEmail` interception point to inject campaign tags into all links in an email. Interception points are listed below:

### onPrepareEmailSendArguments

This interception point is announced after the "sendArgs" are prepared ready for sending the email. This include keys such as `htmlBody`, `textBody`, `to`, `from`, etc. You will receive `sendArgs` as a key in the `interceptData` argument and can then modify this struct as you see fit. e.g.

```luceescript
component extends="coldbox.system.Interceptor" {

	property name="smartSubjectService" inject="delayedInjector:smartSubjectService";

	public void function onPrepareEmailSendArguments( event, interceptData ) {
		interceptData.sendArgs.subject = smartSubjectService.optimizeSubject( argumentCollection=interceptData.sendArgs );
	}
}
```

### preSendEmail

This interception point is announced just before the email is sent. It is near identical to `onPrepareEmailSendArguments` but also contains a `settings` key pertaining to the email service provider sending the email.  e.g.

```luceescript
component extends="coldbox.system.Interceptor" {

	// force local testing perhaps??
	public void function preSendEmail( event, interceptData ) {
		interceptData.settings.smtp_host = "127.0.0.1"; 
	}

}
```

### postSendEmail

This interception point is announced just after the email is sent and after any logs have been inserted in the database. Receives the same arguments as `preSendEmail`.

```luceescript
component extends="coldbox.system.Interceptor" {

	property name="someService" inject="delayedInjector:someService";

	public void function postSendEmail( event, interceptData ) {
		someService.doSomethingAfterEmailSend( argumentCollection=interceptData.sendArgs );
	}

}
```
---
id: emailRecipientTypes
title: Creating and configuring email recipient types
---

## Email recipient types

Defining and configuring recipient types allows your email editors to inject useful variables into their email templates. It also allows the system to keep track of emails that have been sent to specific recipients and to use the correct email address for the recipient.

## Configuring recipient types

There are up to four parts to configuring a recipient type:

1. Declaration in Config.cfc
2. i18n `.properties` file for labelling
3. Hander to provide methods for getting the address and variables for a recipient
4. (optional) Adding foreign key to the core [[presideobject-email_template_send_log]] object for your particular recipient type's core object

### 1. Config.cfc declaration

All email recipient types must be registered in `Config.cfc`. An example configuration might look like this:

```luceescript
// register an 'eventDelegate' recipient type:
settings.email.recipientTypes.eventDelegate   = {
	  parameters             = [ "first_name", "last_name", "email_address", "mobile_number" ]
	, filterObject           = "event_delegate"
	, gridFields             = [ "first_name", "last_name", "email_address", "mobile_number" ]
	, recipientIdLogProperty = "event_delegate_recipient"
};
```

#### Configuration options

* `parameters` - an array of parameters that are available for injection by editors into email content and subject lines
* `filterObject` - preside object that is the source object for the recipient, this can be filtered against for sending a single email to a large audience.
* `gridFields` - array of properties defined on the `filterObject` that should be displayed in the grid that shows when listing the potential recipients of an email
* `recipientIdLogProperty` - foreign key property on the [[presideobject-email_template_send_log]] object that should be used for storing the recipient ID in send logs (see below)
* `feature` - an optional string value indicating the feature that the recipient type belongs to. If the feature is disabled, the recipient type will not be available.

### 2. i18n property file

Each recipient type should have a corresponding `.properties` file to provide labels for the type and any parameters that are declared. The file must live at `/i18n/email/recipientType/{recipientTypeId}.properties`. An example:

```properties
title=Event delegate
description=Email sent to delegates of events

param.first_name.title=First name
param.first_name.description=First name of the delegate

# ...
```

The recipient type itself has a `title` and `description` key. Any defined parameters can also then have `title` and `description` keys, prefixed with `param.{paramid}.`.

### 3. Handler for generating parameters

Recipient types require a handler for returning parameters for a recipient and for returning the recipient's email address. This should live at `/handlers/email/recipientType/{recipientTypeId}.cfc` and have the following signature:

```luceescript
component {
	private struct function prepareParameters( required string recipientId ) {}

	private struct function getPreviewParameters() {}

	private string function getToAddress( required string recipientId ) {}
	
	// as of 10.12.0
	private string function getUnsubscribeLink( required string recipientId, required string templateId ) {}
}
```

#### prepareParameters()

The `prepareParameters()` method should return a struct whose keys are the IDs of the parameters that are defined in `Config.cfc` (see above) and whose values are either:

* a string value to be used in both plain text and html emails
* a struct with `html` and `text` keys whose values are strings to be used in their respective email renders

The purpose here is to allow variables in an email's body and/or subject to be replaced with details of the recipient. The method accepts a `recipientId` argument so that you can make a DB query to get the required details. For example:

```luceescript
// handlers/email/recipientType/EventDelegate.cfc
component {

	property name="bookingService" inject="bookingService";

	private struct function prepareParameters( required string recipientId ) {
		var delegate = bookingService.getDelegate( arguments.recipientId );

		return {
			  first_name = delegate.first_name
			, last_name  = delegate.last_name
			// ... etc
		};
	}

	// ...
}
```

#### getPreviewParameters()

The `getPreviewParameters()` method has the exact same purpose as the `getParameters()` method _except_ that it should return a static set of parameters that can be used to preview any emails that are set to send to this recipient type. It does not accept any arguments.

For example:

```luceescript
private struct function getPreviewParameters() {
	return {
		  first_name = "Example"
		, last_name  = "Delegate"
		// ... etc
	};
}
```

#### getToAddress()

The `getToAddress()` method accepts a `recipientId` argument and must return the email address to which to send email. For example:

```luceescript
private struct function getToAddress( required string recipientId ) {
	var delegate = bookingService.getDelegate( arguments.recipientId );

	return delegate.email_address ?: "";
}
```

#### getUnsubscribeLink()

As of **10.12.0**. The `getUnsubscribeLink()` method accepts `recipientId` and `templateId` arguments and can return a link to use for unsubscribes (or an empty string for no link).

For example, you may wish to link to an 'edit profile' page, or some page specific to custom fields set on the email template:

```luceescript
private struct function getUnsubscribeLink( required string recipientId, required string templateId ) {
	var listId = myCustomService.getEmailTemplateUnsubscribeList( arguments.templateId );

	return event.buildLink( 
		  linkto      = "mycustomemail.ubsubscribeHandler"
		, queryString = "rid=#arguments.recipientId#&lid=#listId#"
	);
}
```


```luceescript
private struct function getToAddress( required string recipientId ) {
	var delegate = bookingService.getDelegate( arguments.recipientId );

	return delegate.email_address ?: "";
}
```

### 4. Email log foreign key

When email is sent through the [[emailservice-send|emailService.send()]] method, Preside keeps a DB log record for the send in the [[presideobject-email_template_send_log]] object. This record is used to track delivery, opens, clicks, etc. for the email.

In order to be able to later report on which recipients have engaged with email, you should add a foreign key property to the object that relates to the core object of your recipient type. For example, add a `/preside-objects/email_template_send_log.cfc` file to your application/extension:

```luceescript
/**
 * extend the core email_template_send_log object
 * to add our foreign key for event delegate recipient
 * type
 *
 */
component {
	// important: this must NOT be a required field
	property name="delegate_recipient" relationship="many-to-one" relatedto="event_delegate" required=false;
}
```

This extra property is then referenced in the configuration of your recipient type in your application's/extension's `Config.cfc` file (see above):

```luceescript
settings.email.templates.recipientTypes.eventDelegate   = {
	// ...
	, recipientIdLogProperty = "delegate_recipient"
};
```
---
id: emailServiceProviders
title: Creating email service providers
---

## Email service providers

Email service providers perform the task of sending email. Preside comes with a standard SMTP service provider that sends mail through `cfmail`. Service providers can be configured through the email centre admin UI.

## Creating an email service provider

There are four parts to creating a service provider:

1. Declaration in Config.cfc
2. i18n `.properties` file for labelling
3. xml form definition for configuring the provider
4. Handler to provide methods for sending and for validating settings

### Declaration in Config.cfc

A service provider must be defined in Config.cfc. Here are a couple of 'mailchimp' examples:

```luceescript
// use defaults for everything (recommended):
settings.email.serviceProviders.mailchimp = {};

// or, all options (with defaults):
settings.email.serviceProviders.mailchimp = {
      configForm             = "email.serviceprovider.mailchimp"
    , sendAction             = "email.serviceprovider.mailchimp.send"
    , validateSettingsAction = "email.serviceprovider.mailchimp.validateSettings"
};
```

#### Configuration options

* `configForm` - path to [[presideforms|xml form definition]] for configuring the provider
* `sendAction` - coldbox handler action path of the handler action that performs the sending of email
* `validateSettingsAction` - optional coldbox handler action path of the handler action that will perform validation against user inputted provider settings (using the config form)

### i18n .properties file

Each service provider should have a corresponding `.properties` file to provide labels for the provider and any configuration options in the config form. The default location is `/i18n/email/serviceProvider/{serviceProviderId}.properties`. An example:

```properties
title=MailGun
description=A sending provider for that sends email through the MailGun sending API
iconclass=fa-envelope

# config form labels:

fieldset.default.description=Note that we do not currently send through the mailgun API due to performance issues (it is far slower than sending through native SMTP). Retrieve your SMTP details from the mailgun web interface and enter below.

field.server.title=SMTP Server
field.server.placeholder=e.g. smtp.mailgun.org
field.port.title=Port
field.username.title=Username
field.password.title=Password

field.mailgun_test_mode.title=Test mode
field.mailgun_test_mode.help=Whether or not emails are actually sent to recipients or sending is only faked.

```

The only required keys are `title`, `description` and `iconclass`. Keys for your form definition are up to you.

### Configuration form

Service providers are configured in the email centre:


![Screenshot showing email service provider configuration](images/screenshots/emailServiceProviderSettings.png)


In order for this to work, you must supply a configuration form definition. The default location for your service provider's configuration form is `/forms/email/serviceProvider/{serviceProviderId}.xml`. An example:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form i18nBaseUri="email.serviceProvider.mailgun:">
    <tab id="default">
        <fieldset id="default">
            <field name="server"            control="textinput"   required="false" default="smtp.mailgun.org" />
            <field name="port"              control="spinner"     required="false" default="587" minvalue="1" maxValue="99999" />
            <field name="username"          control="textinput"   required="false" />
            <field name="password"          control="password"    required="false" outputSavedValue="true" />
            <field name="mailgun_api_key"   control="textinput"   required="false" />
            <field name="mailgun_test_mode" control="yesNoSwitch" required="false" />
        </fieldset>
    </tab>
</form>
```

### Handler

Your service provider must provide a handler with at least a `send` action + an optional `validateSettings()` action. The default location of the file is `/handlers/email/serviceProvider/{serviceProviderId}.cfc`. The method signatures look like this:

```luceescript
component {

    private boolean function send( struct sendArgs={}, struct settings={} ) {}

    private any function validateSettings( required struct settings, required any validationResult ) {}

}
```

#### send()

The send method accepts a structure of `sendArgs` that contain `recipient`, `subject`, `body`, etc. and a structure of `settings` that are the saved configuration settings of your service provider. The method should return `true` if sending was successful.

The code listing below shows the core SMTP send logic at the time of writing this doc:

```luceescript
private boolean function send( struct sendArgs={}, struct settings={} ) {
    var m           = new Mail();
    var mailServer  = settings.server      ?: "";
    var port        = settings.port        ?: "";
    var username    = settings.username    ?: "";
    var password    = settings.password    ?: "";
    var params      = sendArgs.params      ?: {};
    var attachments = sendArgs.attachments ?: [];

    m.setTo( sendArgs.to.toList( ";" ) );
    m.setFrom( sendArgs.from );
    m.setSubject( sendArgs.subject );

    if ( sendArgs.cc.len()  ) {
        m.setCc( sendArgs.cc.toList( ";" ) );
    }
    if ( sendArgs.bcc.len() ) {
        m.setBCc( sendArgs.bcc.toList( ";" ) );
    }
    if ( Len( Trim( sendArgs.textBody ) ) ) {
        m.addPart( type='text', body=Trim( sendArgs.textBody ) );
    }
    if ( Len( Trim( sendArgs.htmlBody ) ) ) {
        m.addPart( type='html', body=Trim( sendArgs.htmlBody ) );
    }
    if ( Len( Trim( mailServer ) ) ) {
        m.setServer( mailServer );
    }
    if ( Len( Trim( port ) ) ) {
        m.setPort( port );
    }
    if ( Len( Trim( username ) ) ) {
        m.setUsername( username );
    }
    if ( Len( Trim( password ) ) ) {
        m.setPassword( password );
    }

    for( var param in params ){
        m.addParam( argumentCollection=sendArgs.params[ param ] );
    }
    for( var attachment in attachments ) {
        var md5sum   = Hash( attachment.binary );
        var tmpDir   = getTempDirectory() & "/" & md5sum & "/";
        var filePath = tmpDir & attachment.name
        var remove   = IsBoolean( attachment.removeAfterSend ?: "" ) ? attachment.removeAfterSend : true;

        if ( !FileExists( filePath ) ) {
            DirectoryCreate( tmpDir, true, true );
            FileWrite( filePath, attachment.binary );
        }

        m.addParam( disposition="attachment", file=filePath, remove=remove );
    }

    sendArgs.messageId = sendArgs.messageId ?: CreateUUId();

    m.addParam( name="X-Mailer", value="Preside" );
    m.addParam( name="X-Message-ID", value=sendArgs.messageId );
    m.send();

    return true;
}
```

#### validateSettings()

The `validateSettings()` method accepts a `settings` struct that contains the user-defined settings submitted with the form, and a [[api-validationresult|validationResult]] object for reporting errors. It must return the passed in `validationResult`.

The core SMTP provider, for example, validates the SMTP server:

```luceescript
private any function validateSettings( required struct settings, required any validationResult ) {
    if ( IsTrue( settings.check_connection ?: "" ) ) {
        var errorMessage = emailService.validateConnectionSettings(
              host     = arguments.settings.server    ?: ""
            , port     = Val( arguments.settings.port ?: "" )
            , username = arguments.settings.username  ?: ""
            , password = arguments.settings.password  ?: ""
        );

        if ( Len( Trim( errorMessage ) ) ) {
            if ( errorMessage == "authentication failure" ) {
                validationResult.addError( "username", "email.serviceProvider.smtp:validation.server.authentication.failure" );
            } else {
                validationResult.addError( "server", "email.serviceProvider.smtp:validation.server.details.invalid", [ errorMessage ] );
            }
        }
    }

    return validationResult;
}
```

>>>>>> You are only required to supply custom validation logic here; you do **not** have to provide regular form validation logic that is automatically handled by the regular [[presideforms]] validation system.


---
id: systemEmailTemplates
title: Creating and sending system email templates
---

## System email templates

The development team may provide system transactional email templates such as "Reset password" or "Event booking confirmation". These templates are known as *system* templates and are available through the UI for content editors to _edit_; they cannot be created or deleted by content editors.

## Sending system email templates

System transactional emails are programatically sent using the [[emailservice-send]] method of the [[api-emailservice]] or the [[presidesuperclass-$sendemail]] method of the [[presidesuperclass|Preside super class]] (which proxies to the [[api-emailservice|emailService]].[[emailservice-send]] method).

While the [[emailservice-send]] method takes many arguments, these are chiefly for backwards compatibility. For sending the "new" (as of 10.8.0) style email templates, we only require three arguments:

```luceescript
$sendEmail(
	  template    = "bookingConfirmation"
	, recipientId = userId
	, args        = { bookingId=bookingId }
);
```

* `template` - ID of the configured template (see below)
* `recipientId` - ID of the recipient. The source object for this ID will differ depending on the [[emailRecipientTypes|recipient type]] of the email.
* `args` - Any additional data that the email template needs to render the correct information (see below)

## Creating system email templates

There are three parts to creating a system email template:

1. Declaration in Config.cfc
2. i18n `.properties` file for labelling
3. Hander to provide methods for generating email variables and default content

### 1. Config.cfc declaration

All system email templates must be registered in `Config.cfc`. An example configuration might look like this:

```luceescript
// register a 'bookingConfirmation' template:
settings.email.templates.bookingConfirmation = {
	recipientType = "websiteUser",
	parameters    = [
		  { id="booking_summary"  , required=true }
		, { id="edit_booking_link", required=false }
	]
};
```

#### Configuration options

* `recipientType` - each template _must_ declare a recipient type (see [[emailRecipientTypes]]). This is a string value and indicates the target recipients for the email template.
* `parameters` - an optional array of parameters that the template makes available for editors to be able insert into dynamic content. Each parameter is a struct with `id` and `required` fields.
* `feature` - an optional string value indicating the feature that the email template belongs to. If the feature is disabled, the template will not be available.

### 2. i18n .properties file

Each template should have a corresponding `.properties` file to provide labels for the template and any parameters that are declared. The file must live at `/i18n/email/template/{templateid}.properties`. An example:

```properties
title=Event booking confirmation
description=Email sent to customers who have just booked on an event

param.booking_summary.title=Booking summary
param.booking_summary.description=Booking summary text including tickets purchased, etc.

param.edit_booking_link.title=Edit booking link
param.edit_booking_link.description=A link to the page where delegate's can edit their booking
```

The template itself has a `title` and `description` key. Any defined parameters can also then have `title` and `description` keys, prefixed with `param.{paramid}.`.

### 3. Handler for generating parameters and defaults

The final part of creating a system transactional email template is the handler. This should live at `/handlers/email/template/{templateId}.cfc` and have the following signature:

```luceescript
component {

	private struct function prepareParameters() {}

	private struct function getPreviewParameters() {}

	private string function defaultSubject() {}

	private string function defaultHtmlBody() {}

	private string function defaultTextBody() {}

}
```

#### prepareParameters()

The `prepareParameters()` is where any real display and processing logic for your email template occurs; _email templates are only responsible for rendering parameters that are available for editors to use in their email content - **not** for rendering an entire email layout_.  The method should return a struct whose keys are the IDs of the parameters that are defined in `Config.cfc` (see above) and whose values are either:

* a string value to be used in both plain text and html emails
* a struct with `html` and `text` keys whose values are strings to be used in their respective email renders

The arguments passed to the `prepareParameters()` method will consist of any extra `args` that were passed to the [[emailservice-send]] method when the email was requested to be sent.

For example:

```luceescript
// send email call from some other service
emailService.send(
	  template    = "bookingConfirmation"
	, recipientId = userId
	, args        = { bookingId=bookingId } // used as the arguments set for the prepareParameters() call
);
```

```luceescript
// handlers/email/template/BookingConfirmation.cfc
component {

	property name="bookingService" inject="bookingService";

	// bookingId argument expected in `args` struct
	// in all `send()` calls for 'bookingConfirmation'
	// template
	private struct function prepareParameters( required string bookingId ) {
		var params = {};
		var args   = {};

		args.bookingDetails = bookingService.getBookingDetails( arguments.bookingId );

		params.eventName      = args.bookingDetails.event_name;
		params.bookingSummary = {
			  html = renderView( view="/email/template/bookingConfirmation/_summaryHtml", args=args )
			, text = renderView( view="/email/template/bookingConfirmation/_summaryText", args=args )
		};

		return params;
	}

	// ...
}
```

#### getPreviewParameters()

The `getPreviewParameters()` method has the exact same purpose as the `getParameters()` method _except_ that it should return a static set of parameters that can be used to preview the email template in the editing interface. It does not accept any arguments.

For example:

```luceescript
private struct function getPreviewParameters() {
	var params = {};
	var args   = {};

	args.bookingDetails = {
		  event_name = "Example event"
		, start_time = "09:00"
		// ... etc
	};

	params.eventName      = "Example event";
	params.bookingSummary = {
		  html = renderView( view="/email/template/bookingConfirmation/_summaryHtml", args=args )
		, text = renderView( view="/email/template/bookingConfirmation/_summaryText", args=args )
	};

	return params;
}
```

#### defaultSubject()

The `defaultSubject()` method should return a **default** subject line to use for the email should an editor never have supplied one. e.g.

```luceescript
private struct function defaultSubject() {
	return "Your booking confirmation ${booking_no}";
}
```

This is _only_ used to populate the database the very first time that the template is detected by the application.

#### defaultHtmlBody()

The `defaultHtmlBody()` method should return a **default** HTML body to use for the email should an editor never have supplied one. e.g.

```luceescript
private struct function defaultHtmlBody() {
	return renderView( view="/email/template/bookingConfirmation/_defaultHtmlBody" );
}
```

You should create a sensible default that uses the configurable parameters just as an editor would do. This is _only_ used to populate the database the very first time that the template is detected by the application.


#### defaultTextBody()

The `defaultTextBody()` method should return a **default** plain text body to use for the email should an editor never have supplied one. e.g.

```luceescript
private struct function defaultTextBody() {
	return renderView( view="/email/template/bookingConfirmation/_defaultTextBody" );
}
```

You should create a sensible default that uses the configurable parameters just as an editor would do. This is _only_ used to populate the database the very first time that the template is detected by the application.
---
id: resendingEmail
title: Re-sending emails and content logging
---

## Overview

Preside 10.9.0 introduces the ability to re-send emails via the email centre. It also allows for the logging of the actual generated email content, enabling admin users to view the exact content of emails as they were sent, and also to re-send the original content to a user.

The feature is disabled by default, and can be enabled with the `emailCenterResend` feature:

```luceescript
settings.features.emailCenterResend.enabled = true;
```

By default, any logged email content is stored for a period of 30 days, after which it will be automatically removed (although the send and activity logs will still be available). This default can easily be configured:

```luceescript
settings.email.defaultContentExpiry = 30;
```

>>>> Logging the content of individual emails can potentially use a large amount of database storage, especially if you are logging the content of newsletters sent to large email lists.

Note that if you set `defaultContentExpiry` to 0, email content will not be logged (unless you specifically override this setting for an individual template — see below).

### Email activity log

When viewing the email activity of a message from the send log, you will see one or two re-send action buttons:

**Rebuild and re-send email** will regenerate the email based on the original arguments passed to the `sendMail()` function. This is available for _all_ emails when re-send functionality is enabled. Note that if the template or dynamic data has changed since the email was first sent, the resulting email may be different from the original.

**Re-send original email** is available if content saving is enabled for a template _and_ there is saved email content for the email (i.e. saving was enabled when the email was sent, and the content has not expired). This will re-send an exact copy of the email as it was originally sent.

If there is valid saved content for an email, you will also see the email activity divided into tabs. The main tab is the usual activity log; there are also **HTML** and **Plain text** tabs which allow an admin user to view the content of the email as it was sent:

![Screenshot showing the email activity pane with tabs for viewing sent content.](images/screenshots/email-activity-saved-content.png)

### System email templates

By default, the content of sent system emails is saved for the default period. This can be overridden per template using the `saveContent` setting, as there will be some emails (e.g. those with expiring links or with security considerations) where it is not desirable to store this content. For example, this is the definition of the Admin User Password Reset template, with content saving turned off:

```luceescript
settings.email.templates.resetCmsPassword = {
	  feature       = "cms"
	, recipientType = "adminUser"
	, saveContent   = false
	, parameters    = [ { id="reset_password_link", required=true }, "site_url" ]
};
```

You may also define the content expiry (in days) of an individual system template using the `contentExpiry` setting:

```luceescript
settings.email.templates.templateName.contentExpiry = 15;
```

The `resetCmsPassword` template above also highlights another potential issue: the reset token used to generate the email expires after a period of time. A simple regeneration of the email will use the original (probably now invalid) reset token, which is stored in the `send_args` property of the email log.

To solve this, add the method `rebuildArgsForResend()` to your template handler. This takes a single argument — the ID of the email log entry in `email_template_send_log`; from this you can do whatever logic is needed to create a `sendArgs` struct to pass to the `sendEmail()` method. As an example, this is the method in the handler `ResetCmsPassword.cfc`:

```luceescript
private struct function rebuildArgsForResend( required string logId ) {
	var userId    = sendLogDao.selectData( id=logId, selectFields=[ "security_user_recipient" ] ).security_user_recipient;
	var tokenInfo = loginService.createLoginResetToken( userId );

	return { resetToken="#tokenInfo.resetToken#-#tokenInfo.resetKey#" };
}
```

This retrieves the admin user's ID from the email send log, generates a new reset token for that user, and returns the reset token for use in creation of a new email.


### Custom email templates

By default, the content of custom email templates _is not saved_. Content saving can be turned on for individual templates via the template's settings page:

![Screenshot showing the content saving options for custom email templates.](images/screenshots/email-resend-custom-templates.png)

If no content expiry is specified — "Save for [x] days" — then the system default value will be used.---
id: emailtemplating
title: Email templating (pre-10.8.0)
---

## Overview

Preside comes with a very simple email templating system that allows you to define email templates by creating ColdBox handlers.

Emails are sent through the core email service which in turn invokes template handlers to render the emails and return any other necessary mail parameters.

## Creating an email template handler

To create an email template handler, you must create a regular Coldbox handler under the `/handlers/emailTemplates` directory. The handler needs to implement a single *private* action, `prepareMessage()` that returns a structure containing any message parameters that it needs to set. For example:

```luceescript
// /mysite/application/handlers/emailTemplates/adminNotification.cfc
component {

    private struct function prepareMessage( event, rc, prc, args={} ) {
        return {
              to      = [ getSystemSetting( "email", "admin_notification_address", "" ) ]
            , from    = getSystemSetting( "email", "default_from_address", "" )
            , subject = "Admin notification: #( args.notificationTitle ?: '' )#"
            , htmlBody = renderView( view="/emailTemplates/adminNotification/html", layout="email", args=args )
            , textBody = renderView( view="/emailTemplates/adminNotification/text", args=args )
        };
    }

}
```

An example send() call for this template might look like this:

```luceescript
 emailService.send( template="adminNotification", args={
      notificationTitle   = "Something just happened"
    , notificationMessage = "Some message"
} );
```

## Supplying message arguments to the send() method

Your email template handlers are not required to supply all the details of the message; these can be left to the calling code to supply. For example, we could refactor the above example so that the `to` and `subject` parameters need to be supplied by the calling code:

```luceescript
// /mysite/application/handlers/emailTemplates/adminNotification.cfc
component {

    private struct function prepareMessage( event, rc, prc, args={} ) {
        return {
              htmlBody = renderView( view="/emailTemplates/adminNotification/html", layout="email", args=args )
            , textBody = renderView( view="/emailTemplates/adminNotification/text", args=args )
        };
    }

}
```

```luceescript
emailService.send(
      template = "adminNotification"
    , args     = { notificationMessage = "Some message" }
    , to       = user.email_address
    , subject  = "Alert: something just happend"
);
```

>>> Note the missing "from" parameter. The core send() implementation will attempt to use the system configuration setting `email.default_from_address` when encountering messages with a missing **from** address. This default address can be configured by users through the Preside administrator (see [[editablesystemsettings]]).

## Mail server and other configuration settings

The core system comes with a system configuration form for mail server settings. See [[editablesystemsettings]] for more details on how this is implemented.

The system uses these configuration values to set the server and port when sending emails. The "default from address" setting is used when sending mail without a specified from address.

This form may be useful to extend in your site should you want to configure other mail related settings. i.e. you might have default "to" addresses for particular admin notification emails, etc.




---
id: creatingAnEmailLayout
title: Creating an email layout
---

>>> Email layouts were introduced in Preside 10.8.0. See [[emailtemplatingv2]] for more details.

## Creating an email layout

### 1. Create viewlets for HTML and plain text renders

Email layouts are created by convention. Each layout is defined as a pair of [[Viewlets|Preside viewlets]], one for the HTML version of the layout, another for the text only version of the layout. The convention based viewlet ids are `email.layout.{layoutid}.html` and `email.layout.{layoutid}.text`.

The viewlets receive three common variables in their `args` argument:

* `subject` - the email subject
* `body` - the main body of the email
* `viewOnlineLink` - a link to view the full email online (may be empty for transactional emails, for example)

In addition, the viewlets will also receive args from the layout's config form, if it has one (see 3, below).

A very simple example:

```lucee
<!-- /views/email/layout/default/html.cfm -->
<cfoutput><!DOCTYPE html>
<html>
    <head>
        <title>#args.subject#</title>
    </head>
    <body>
        <a href="#args.viewOnlineLink#">View in a browser</a>
        #args.body#
    </body>
</html>
</cfoutput>
```

```lucee
<!-- /views/email/layout/default/text.cfm -->
<cfoutput>
#args.subject#
#repeatString( '=', args.subject.len() )#

View online: #args.viewOnlineLink#

#args.body#
</cfoutput>
```

### 2. Provide translatable title and description

In addition to the viewlet, each layout should also have translation entries in a `/i18n/email/layout/{layoutid}.properties` file. Each layout should have a `title` and `description` entry. For example:

```properties
title=Transactional email layout
description=Use the transactional layout for emails that happen as a result of some user action, e.g. send password reminder, booking confirmation, etc.
```

### 3. Provide optional configuration form

If you want your application's content editors to be able to tweak layout options, you can also provide a configuration form at `/forms/email/layout/{layoutid}.xml`. This will allow end-users to configure global defaults for the layout and to tweak settings per email. For example:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form i18nBaseUri="email.layout.transactional:">
    <tab id="default">
        <fieldset id="default" sortorder="10">
            <field name="twitterLink" />
            <field name="facebookLink" />
            <field name="address" control="textarea" />
        </fieldset>
    </tab>
</form>
```

With the form above, editors might be able to configure social media links and the company address that appear in the layout.---
id: emailSettings
title: Working with Email centre settings
---

## Email centre settings

The email centre has a general settings form with global email configuration (screenshot below). The form, [[form-emailcentergeneralsettingsform]], is located at `/forms/email/settings/general.xml`. You can provide your own extensions to the form by creating the same file in your application or extension (see [[presideforms]]).

![Screenshot showing email centre general settings](images/screenshots/emailSettingsForm.png)

## Retrieving settings

All settings are saved and retrieved using the `email` category in the [[editablesystemsettings]] system. For example:

```luceescript
// all settings example:
var allEmailSettings = $getPresideCategorySettings( "email" );

// specific setting example:
var defaultFrom = $getPresideSetting( category="email", setting="default_from_address" );
```

---
id: datamanager
title: Data Manager
---

## Introduction

Preside's Data Manager is a sophisticated auto CRUD admin for your data objects. With very little configuration, you are able to set up listing screens, add, edit and delete screens, version history screens, auditing, translation, bulk edit functionality, etc. In addition, as of Preside 10.9.0, this system can be highly customized both globally and _per data object_ so that you can rapidly build awesome custom admin interfaces in front of your application's database.

![Screenshot showing example of a Data Manager listing view](images/screenshots/datamanager-example.png)

As there is a lot to cover, we have broken the documentation down, see distinct topics below:

* [[datamanagerbasics]]
* [[customizingdatamanager]]
* [[adminrecordviews]]
* [[enhancedrecordviews]]---
id: datamanager-customization-gettoprightbuttonsforviewrecord
title: "Data Manager customization: getTopRightButtonsForViewRecord"
---

## Data Manager customization: getTopRightButtonsForViewRecord

The `getTopRightButtonsForViewRecord` customization allows you to _completely override_ the set of buttons that appears at the top right hand side of the view record listing screen. It must _return an array_ of structs that describe the buttons to display and is provided the `objectName` in the `args` struct.

Note, if you simply want to add, or tweak, the top right buttons, you may wish to use [[datamanager-customization-extratoprightbuttonsforviewrecord]].

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private array function getTopRightButtonsForViewRecord( event, rc, prc, args={} ) {
		var actions    = [];
		var objectName = args.objectName ?: "";
		var recordId   = prc.recordId ?: ""

		actions.append({
			  link      = event.buildAdminLink( objectName=objectName, operation="reports", recordId=recordId )
			, btnClass  = "btn-default"
			, iconClass = "fa-bar-chart"
			, globalKey = "r"
			, title     = translateResource( "preside-objects.blog:reports.btn" )
		} );

		return actions;
	}

}
```

>>> See [[datamanager-customization-toprightbuttonsformat]] for detailed documentation on the format of the action items.
---
id: customizingdatamanager
title: Customizing Data Manager
---

## Introduction

As of Preside 10.9.0, [[datamanager]] comes with a customization system that allows you to customize many aspects of the Data Manager both globally and per object. In addition, you are able to use all the features of Data Manager for your object **without needing to list your object in the Data Manager homepage**. This means that you can create your own custom navigation to your object and not need to write any further code to create your CRUD admin interface - perfect for building custom admin interfaces with dedicated navigation.

## Customization system overview

Customizations are implemented as convention based ColdBox _handlers_. Customizations that should be applied globally belong in `/handlers/admin/datamanager/GlobalCustomizations.cfc`. Customizations that should be applied to a specific object go in `/handlers/admin/datamanager/objectname.cfc`. For example, if you wish to supply customizations for a `blog_author` object, you would create a handler file: `/handlers/admin/datamanager/blog_author.cfc`.

The Data Manager implements a large number of customizations. Each customization will be implemented in your handlers as a **private** handler action. The return type (if any) and arguments supplied to the action will depend on the specific customization.

For example, you may wish to do some extra processing after saving an `employee` record using the `postEditRecordAction` customization:

```luceescript
// /application/handlers/datamanager/employee.cfc

component {

	// as this is a regular coldbox handler
	// we can use wirebox to inject and access our service layer
	property name="notificationService" inject="notificationService";

	private void function postEditRecordAction( event, rc, prc, args={} ) {
		// the args struct values will vary depending on the customization point.
		// in this case, we get new and old data (as well as many other fields)
		var newData    = args.formData       ?: {};
		var oldData    = args.existingRecord ?: {};
		var employeeId = args.recordId       ?: {}

		// here, as an example, we use the notification service to
		// raise a "Date of birth change" notification when the DOB changes
		if ( newData.keyExists( "dob" ) && newData.dob != oldData.dob ) {
			notificationService.createNotification( topic="DOBChange", type="info", data={ employeeId=employeeId } )
		}

		// of course, we could do anything we like here. For instance,
		// we could redirect the user to a different screen than the
		// normal "post-edit" behaviour for Data Manager.
	}

}
```

## Building and customizing links

With the new 10.9.0 customization system comes a new method of building data manager links for objects. Use `event.buildAdminLink( objectName=objectName )` along with optional arguments, `operation` and `recordId` to build various links. For example, to link to the data manager listing page for an object, use the following:

```luceescript
event.buildAdminLink( objectName=objectName );
```

To link to the default view for a record, use:

```luceescript
event.buildAdminLink( objectName=objectName, recordId=recordId );
```

To link to a specific page or action URL for an object or record, add the `operation` argument, e.g.

```luceescript
event.buildAdminLink( objectName=objectName, operation="addRecord" );
event.buildAdminLink( objectName=objectName, operation="editRecord", recordId=recordId );
// etc.
```

The core, "out-of-box" operations are:

* `listing`
* `viewRecord`
* `addRecord`
* `addRecordAction`
* `editRecord`
* `editRecordAction`
* `deleteRecordAction`
* `translateRecord`
* `sortRecords`
* `managePerms`
* `ajaxListing`
* `multiRecordAction`
* `exportDataAction`
* `dataExportConfigModal`
* `recordHistory`
* `getNodesForTreeView`


>>>>>> You can pass extra query string parameters to any of these links with the `queryString` argument. For example:
>>>>>>
```
event.buildAdminLink(
	  objectName  = objectName
	, operation   = "addRecord"
	, queryString = "categoryId=#categoryId#"
);
```

### Custom link builders

There is a naming convention for providing a custom link builder for an operation: `build{operation}Link`. There are therefore Data Manager customizations named `buildListingLink`, `buildViewRecordLink`, and so on. For example, to provide a completely different link for a view record screen for your object, you could do:

```luceescript
// /application/handlers/admin/datamanager/blog_author.cfc

component {

	private string function buildViewRecordLink( event, rc, prc, args={} ) {
		var recordId = args.recordId    ?: "";
		var extraQs  = args.queryString ?: "";
		var qs       = "id=#recordId#";

		if ( extraQs.len() ) {
			qs &= "&#extraQs#";
		}

		// e.g. here we would have a coldbox handler /admin/BlogAuthors.cfc
		// with a public 'view' method for completely controlling the entire
		// view record request outside of Data Manager
		return event.buildAdminLink( linkto="blogauthors.view", querystring=qs );
	}
}
```

### Adding your own operations

If you are extending Data Manager to add extra pages for a particular object (for example), you can create new operations by following the same link building convention above. For example, say we wanted to build a "preview" link for an article, we can use the following:

```luceescript
// /handlers/admin/datamanager/article.cfc
component extends="preside.system.base.AdminHandler" {

// Public events for extra admin pages and actions
	public void function preview() {
		event.initializeDatamanagerPage(
			  objectName = "article"
			, recordId   = rc.id ?: ""
		);

		event.addAdminBreadCrumb(
			  title = translateResource( "preside-objects.article:preview.breadcrumb.title" )
			, linke = ""
		);

		prc.pageTitle = translateResource( "preside-objects.article:preview.page.title" );
		prc.pageSubTitle = translateResource( "preside-objects.article:preview.page.subtitle" );
	}

// customizations
	private string function buildPreviewLink( event, rc, prc, args={} ) {
		var qs = "id=#( args.recordId ?: "" )#";

		if ( Len( Trim( args.queryString ?: "" ) ) ) {
			qs &= "&#args.queryString#";
		}

		return event.buildAdminLink( linkto="datamanager.article.preview", querystring=qs );
	}



}
```

Linking to the "preview" operation can then be done with:

```luceescript
event.buildAdminLink( objectName="article", operation="preview", id=recordId );
```

>>> Notice that the handler extends `preside.system.base.AdminHandler`. This base handler supplies a preAction that sets the admin layout and checks for logged in users. You should do this when supplying additional public handler actions in your customization.

#### event.initializeDatamanagerPage()

Notice the handy `event.initializeDatamanagerPage()` in the example, above. This method will setup standard breadcrumbs for your page as well as setting up common variables that are available to other data manager pages such as:

* `prc.recordId`: id of the current record being viewed
* `prc.record`: current record being viewed
* `prc.recordLabel`: rendered label field for the current record
* `prc.objectName`: current object name
* `prc.objectTitle`: translated title of the current object
* `prc.objectTitlePlural`: translated _plural_ title of the current object

The method expects either one, or two arguments: `objectName`, the name of the object, and `recordId`, the ID of the current record (if applicable).


## Customization reference

There are currently more than 60 customization points in the Data Manager and this number is set to grow. We have grouped them into categories below for your reference:

### Record listing table / grid

>>> In addition to the specific customizations, below, you can also use the following helper functions in your handlers and views to render a data table / tree view for an object:
>>>
```luceescript
renderedListingTable = objectDataTable( objectName="blog_post", args={} );
renderedTreeView = objectTreeView( objectName="article", args={} );
```


* [[datamanager-customization-listingviewlet|listingViewlet]]
* [[datamanager-customization-prerenderlisting|preRenderListing]]
* [[datamanager-customization-postrenderlisting|postRenderListing]]
* [[datamanager-customization-gettoprightbuttonsforobject|getTopRightButtonsForObject]]
* [[datamanager-customization-extratoprightbuttonsforobject|extraTopRightButtonsForObject]]
* [[datamanager-customization-prefetchrecordsforgridlisting|preFetchRecordsForGridListing]]
* [[datamanager-customization-getadditionalquerystringforbuildajaxlistinglink|getAdditionalQueryStringForBuildAjaxListingLink]]
* [[datamanager-customization-postfetchrecordsforgridlisting|postFetchRecordsForGridListing]]
* [[datamanager-customization-decoraterecordsforgridlisting|decorateRecordsForGridListing]]
* [[datamanager-customization-getactionsforgridlisting|getActionsForGridListing]]
* [[datamanager-customization-getrecordactionsforgridlisting|getRecordActionsForGridListing]]
* [[datamanager-customization-extrarecordactionsforgridlisting|extraRecordActionsForGridListing]]
* [[datamanager-customization-getrecordlinkforgridlisting|getRecordLinkForGridListing]]
* [[datamanager-customization-listingmultiactions|listingMultiActions]]
* [[datamanager-customization-getlistingmultiactions|getListingMultiActions]]
* [[datamanager-customization-getextralistingmultiactions|getExtraListingMultiActions]]
* [[datamanager-customization-getlistingbatchactions|getListingBatchActions]]
* [[datamanager-customization-multirecordaction|multiRecordAction]]
* [[datamanager-customization-renderfooterforgridlisting|renderFooterForGridListing]]


### Adding records

* [[datamanager-customization-addrecordform|addRecordForm]]
* [[datamanager-customization-getaddrecordformname|getAddRecordFormName]]
* [[datamanager-customization-getquickaddrecordformname|getQuickAddRecordFormName]]
* [[datamanager-customization-prerenderaddrecordform|preRenderAddRecordForm]]
* [[datamanager-customization-prequickaddrecordform|preQuickAddRecordForm]]
* [[datamanager-customization-postrenderaddrecordform|postRenderAddRecordForm]]
* [[datamanager-customization-addrecordactionbuttons|addRecordActionButtons]]
* [[datamanager-customization-getaddrecordactionbuttons|getAddRecordActionButtons]]
* [[datamanager-customization-getextraaddrecordactionbuttons|getExtraAddRecordActionButtons]]
* [[datamanager-customization-gettoprightbuttonsforaddrecord|getTopRightButtonsForAddRecord]]
* [[datamanager-customization-extratoprightbuttonsforaddrecord|extraTopRightButtonsForAddRecord]]
* [[datamanager-customization-addrecordaction|addRecordAction]]
* [[datamanager-customization-quickAddRecordAction|quickAddRecordAction]]
* [[datamanager-customization-preaddrecordaction|preAddRecordAction]]
* [[datamanager-customization-prequickaddrecordaction|preQuickAddRecordAction]]
* [[datamanager-customization-postaddrecordaction|postAddRecordAction]]
* [[datamanager-customization-postquickaddrecordaction|postQuickAddRecordAction]]


### Viewing records

>>> The customizations below allow you to override or decorate the core record rendering system in Data Manager. In addition to these, you should also familiarize yourself with [[adminrecordviews]] as the core view record screen can also be customized using annotations within your Preside Objects.

* [[datamanager-customization-renderrecord|renderRecord]]
* [[datamanager-customization-prerenderrecord|preRenderRecord]]
* [[datamanager-customization-postrenderrecord|postRenderRecord]]
* [[datamanager-customization-prerenderrecordleftcol|preRenderRecordLeftCol]]
* [[datamanager-customization-postrenderrecordleftcol|postRenderRecordLeftCol]]
* [[datamanager-customization-prerenderrecordrightcol|preRenderRecordRightCol]]
* [[datamanager-customization-postrenderrecordrightcol|postRenderRecordRightCol]]
* [[datamanager-customization-gettoprightbuttonsforviewrecord|getTopRightButtonsForViewRecord]]
* [[datamanager-customization-extratoprightbuttonsforviewrecord|extraTopRightButtonsForViewRecord]]

### Editing records

* [[datamanager-customization-editrecordform|editRecordForm]]
* [[datamanager-customization-geteditrecordformname|getEditRecordFormName]]
* [[datamanager-customization-getquickeditrecordformname|getQuickEditRecordFormName]]
* [[datamanager-customization-prerendereditrecordform|preRenderEditRecordForm]]
* [[datamanager-customization-prequickeditrecordform|preQuickEditRecordForm]]
* [[datamanager-customization-postrendereditrecordform|postRenderEditRecordForm]]
* [[datamanager-customization-editrecordactionbuttons|editRecordActionButtons]]
* [[datamanager-customization-geteditrecordactionbuttons|getEditRecordActionButtons]]
* [[datamanager-customization-getextraeditrecordactionbuttons|getExtraEditRecordActionButtons]]
* [[datamanager-customization-gettoprightbuttonsforeditrecord|getTopRightButtonsForEditRecord]]
* [[datamanager-customization-extratoprightbuttonsforeditrecord|extraTopRightButtonsForEditRecord]]
* [[datamanager-customization-editrecordaction|editRecordAction]]
* [[datamanager-customization-quickeditrecordaction|quickeditRecordAction]]
* [[datamanager-customization-preeditrecordaction|preEditRecordAction]]
* [[datamanager-customization-prequickeditrecordaction|preQuickEditRecordAction]]
* [[datamanager-customization-posteditrecordaction|postEditRecordAction]]
* [[datamanager-customization-postquickeditrecordaction|postQuickEditRecordAction]]

### Cloning records

* [[datamanager-customization-clonerecordform|cloneRecordForm]]
* [[datamanager-customization-getclonerecordformname|getCloneRecordFormName]]
* [[datamanager-customization-prerenderclonerecordform|preRenderCloneRecordForm]]
* [[datamanager-customization-postrendereditrecordform|postRenderCloneRecordForm]]
* [[datamanager-customization-clonerecordactionbuttons|cloneRecordActionButtons]]
* [[datamanager-customization-getclonerecordactionbuttons|getCloneRecordActionButtons]]
* [[datamanager-customization-getextraclonerecordactionbuttons|getExtraCloneRecordActionButtons]]
* [[datamanager-customization-clonerecordaction|cloneRecordAction]]
* [[datamanager-customization-preclonerecordaction|preCloneRecordAction]]
* [[datamanager-customization-postclonerecordaction|postCloneRecordAction]]

### Deleting records

* [[datamanager-customization-deleterecordaction|deleteRecordAction]]
* [[datamanager-customization-predeleterecordaction|preDeleteRecordAction]]
* [[datamanager-customization-postdeleterecordaction|postDeleteRecordAction]]
* [[datamanager-customization-prebatchdeleterecordsaction|preBatchDeleteRecordsAction]]
* [[datamanager-customization-postbatchdeleterecordsaction|postBatchDeleteRecordsAction]]
* [[datamanager-customization-getdeletionconfirmationmatch|getDeletionConfirmationMatch]]


### Building links

* [[datamanager-customization-buildlistinglink|buildListingLink]]
* [[datamanager-customization-buildviewrecordlink|buildViewRecordLink]]
* [[datamanager-customization-buildaddrecordlink|buildAddRecordLink]]
* [[datamanager-customization-buildaddrecordactionlink|buildAddRecordActionLink]]
* [[datamanager-customization-buildeditrecordlink|buildEditRecordLink]]
* [[datamanager-customization-buildeditrecordactionlink|buildEditRecordActionLink]]
* [[datamanager-customization-builddeleterecordactionlink|buildDeleteRecordActionLink]]
* [[datamanager-customization-buildtranslaterecordlink|buildTranslateRecordLink]]
* [[datamanager-customization-buildsortrecordslink|buildSortRecordsLink]]
* [[datamanager-customization-buildmanagepermslink|buildManagePermsLink]]
* [[datamanager-customization-buildajaxlistinglink|buildAjaxListingLink]]
* [[datamanager-customization-buildmultirecordactionlink|buildMultiRecordActionLink]]
* [[datamanager-customization-buildexportdataactionlink|buildExportDataActionLink]]
* [[datamanager-customization-builddataexportconfigmodallink|buildDataExportConfigModalLink]]
* [[datamanager-customization-buildrecordhistorylink|buildRecordHistoryLink]]
* [[datamanager-customization-buildgetnodesfortreeviewlink|buildGetNodesForTreeViewLink]]

### Permissioning

* [[datamanager-customization-checkpermission|checkPermission]]
* [[datamanager-customization-isoperationallowed|isOperationAllowed]]

### General

* [[datamanager-customization-prelayoutrender|preLayoutRender]]
* [[datamanager-customization-toprightbuttons|topRightButtons]]
* [[datamanager-customization-extratoprightbuttons|extraTopRightButtons]]
* [[datamanager-customization-rootbreadcrumb|rootBreadcrumb]]
* [[datamanager-customization-objectbreadcrumb|objectBreadcrumb]]
* [[datamanager-customization-recordbreadcrumb|recordBreadcrumb]]
* [[datamanager-customization-versionnavigator|versionNavigator]]


## Interception points

Your application can listen into several core interception points to enhance the features of the Data manager customization, e.g. to implement custom authentication. See the [ColdBox Interceptor's documentation](http://wiki.coldbox.org/wiki/Interceptors.cfm) for detailed documentation on interceptors.

The Interception points are:

### postExtraTopRightButtonsForObject

Fired after the _extraTopRightButtonsForObject_ customization action had run. Takes `objectName` and `actions` as arguments.

### postGetExtraQsForBuildAjaxListingLink

Fired after the _getAdditionalQueryStringForBuildAjaxListingLink_ customization action (if any) had run. Takes `objectName` and `extraQs` as arguments.

### postExtraRecordActionsForGridListing

Fired after the _extraRecordActionsForGridListing_ customization action had run. Takes `record`, `objectName` and `actions` as arguments.

### onGetListingBatchActions

Fired during the _getListingMultiActions_ customisation action. Takes `args` as arguments.

### postGetExtraListingMultiActions

Fired after the _getExtraListingMultiActions_ customization action had run. Takes `args` as arguments.

### postGetExtraAddRecordActionButtons

Fired after the _getExtraAddRecordActionButtons_ customization action had run. Takes `args` as arguments.

### postExtraTopRightButtonsForAddRecord

Fired after the _extraTopRightButtonsForAddRecord_ customization action had run. Takes `objectName` and `actions` as arguments.

### postExtraTopRightButtonsForViewRecord

Fired after the _extraTopRightButtonsForViewRecord_ customization action had run. Takes `objectName` and `actions` as arguments.

### postGetExtraEditRecordActionButtons

Fired after the _getExtraEditRecordActionButtons_ customization action had run. Takes `args` as arguments.

### postExtraTopRightButtonsForEditRecord

Fired after the _extraTopRightButtonsForEditRecord_ customization action had run. Takes `objectName` and `actions` as arguments.

### postGetExtraCloneRecordActionButtons

Fired after the _getExtraCloneRecordActionButtons_ customization action had run. Takes `args` as arguments.

### postExtraTopRightButtons

Fired after the _extraTopRightButtons_ customization action had run. Takes `objectName`, `action` and `actions` as arguments.


## Creating your own customizations

You may wish to utilize the customization system in your extensions to allow implementations to easily override additional data manager features that you may provide. To do so, you can inject the [[api-datamanagercustomizationservice]] into your handler or service and make use of the methods:

* [[datamanagercustomizationservice-runCustomization]]
* [[datamanagercustomizationservice-objectHasCustomization]]

For example:


```luceescript
if ( datamanagerCustomizationService.objectHasCustomization( objectName, "printPreview" ) ) {
	printPreview = datamanagerCustomizationService.runCustomization(
		  objectName = objectName
		, action     = "printPreview"
		, args       = args
	);
} else {
	printPreview = renderView( view=defaultView, args=args );
}
```

Or:

```luceescript
printPreview = datamanagerCustomizationService.runCustomization(
	  objectName     = objectName
	, action         = "printPreview"
	, defaultHandler = "myhandler.printPreview"
	, args           = args
);
```

## Custom navigation to your objects

One of the most powerful changes in 10.9.0 is the ability to have objects use the Data Manager system _without needing to be listed in the Data Manager homepage_. This means that you could have a main navigation link directly to your object(s), for example. In short, you can build highly custom admin interfaces much quicker and with much less code.

### Remove from Data Manager homepage

To allow an object to use Data Manager without appearing in the Data Manager homepage listing, use the `@datamanagerEnabled true` annotation and **not** the `@datamanagerGroup` annotation. For example:

```luceescript
// /application/preside-objects/blog.cfc
/**
 * @datamanagerEnabled true
 *
 */
component {
    // ...
}
```

### Example: Add to the admin left-hand menu

>>>>>> See [[adminlefthandmenu]] for a full guide to customizing the left-hand menu/navigation.

In your application or extension's `Config.cfc` file, modify the `settings.adminSideBarItems` to add a new entry for your object. For example:

```luceescript
settings.adminSideBarItems.append( "blog" );
```

Then, create a corresponding view at `/views/admin/layout/sidebar/blog.cfm`. For _example_:

```luceescript
// /views/admin/layout/sidebar/blog.cfm
hasPermission = hasCmsPermission(
	  permissionKey = "read"
	, context       = "datamanager"
	, contextKeys   = [ "blog" ]
);
if ( hasPermission ) {
    Echo( renderView(
          view = "/admin/layout/sidebar/_menuItem"
        , args = {
              active  = ReFindNoCase( "^admin\.datamanager", event.getCurrentEvent() ) && ( prc.objectName ?: "" ) == "blog"
            , link    = event.buildAdminLink( objectName="blog" )
            , gotoKey = "b"
            , icon    = "fa-comments"
            , title   = translateResource( 'preside-objects.blog:menu.title' )
          }
    ) );
}

```

### Modify the breadcrumb

By default, your object will get breadcrumbs that start with a link to the Data Manager homepage. Use the breadcrumb customizations to modify this:

* [[datamanager-customization-rootbreadcrumb|rootBreadcrumb]]
* [[datamanager-customization-objectbreadcrumb|objectBreadcrumb]]
* [[datamanager-customization-recordbreadcrumb|recordBreadcrumb]]

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private void function rootBreadcrumb() {
		// Deliberately do nothing so as to remove the root
		// 'Data manager' breadcrumb just for the 'blog' object.

		// We could, instead, call event.addAdminBreadCrumb( title=title, link=link )
		// to provide an alternative root breadcrumb
	}

}
```

## Modify core default page titles and other layout changes

A really useful customization is the [[datamanager-customization-prelayoutrender|preLayoutRender]] customization. This fires before the full admin page layout is rendered and allows you to make adjustments after all the handler logic has run. For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

    private void function preLayoutRender( event, rc, prc, args={} ) {
        prc.pageTitle = translateResource(
              uri          = "preside-objects.blog:#args.action#.page.title"
            , defaultValue = prc.pageTitle ?: ""
        );
        prc.pageSubTitle = translateResource(
              uri          = "preside-objects.blog:#args.action#.page.subtitle"
            , defaultValue = prc.pageSubTitle ?: ""
        );
        prc.pageIcon = "fa-comments";
    }

    private void function preLayoutRenderForEditRecord( event, rc, prc, args={} ) {
        prc.pageTitle = translateResource(
              uri  = "preside-objects.blog:editRecord.page.title"
            , data = [ prc.recordLabel ?: "" ]
        );

        // modify the title of the last breadcrumb
        var breadCrumbs = event.getAdminBreadCrumbs();
        breadCrumbs[ breadCrumbs.len() ].title = prc.pageTitle;
    }
}
```---
id: datamanager-customization-isoperationallowed
title: "Data Manager customization: isOperationAllowed"
---

## Data Manager customization: isOperationAllowed

Similar to the [[datamanager-customization-checkpermission|checkPermission]] customization, the `isOperationAllowed` customization allows you to completely override the core Data Manager logic for determining whether the given operation is allowed for the object.

It is expected to return a `boolean` value and is given the following in the `args` struct:

* `objectName`: The name of the object
* `operation`: The operation to check. Core operations are: `add`, `arguments`, `delete`, `edit` and `read`

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private boolean function isOperationAllowed( event, rc, prc, args={} ) {
		var operation = args.operation ?: "";

		return operation != "delete";
	}

}
```

>>> For core operations, you are also able to achieve similar results by setting `@dataManagerAllowedOperations` on your preside object. See [[datamanagerbasics]] for documentation.



---
id: datamanager-customization-postclonerecordaction
title: "Data Manager customization: postCloneRecordAction"
---

## Data Manager customization: postCloneRecordAction

The `postCloneRecordAction` customization allows you to run logic _after_ the core Data Manager clone record logic is run. It is not expected to return a value and is supplied the following in the `args` struct:

* `objectName`: name of the object
* `newId`: ID of the newly cloned record
* `formData`: struct containing the form submission
* `existingRecord`: struct containing the data from the current record
* `validationResult`: validation result from general form validation


For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private void function postCloneRecordAction( event, rc, prc, args={} ) {
		// redirect to a different than default page
		setNextEvent( event.buildAdminLink(
			  objectName = "blog"
			, recordId   = ( args.formData.id ?: "" )
			, operation  = "preview"
		) );
	}
}
```

See also: [[datamanager-customization-preclonerecordaction|predCloneRecordAction]] and [[datamanager-customization-clonerecordaction|cloneRecordAction]].

---
id: datamanager-customization-renderfooterforgridlisting
title: "Data Manager customization: renderFooterForGridListing"
---

## Data Manager customization: renderFooterForGridListing

>>> This feature was introduced in 10.11.0

The `renderFooterForGridListing` customization allows you render footer text at the bottom of a dynamic data grid in the Data Manager. This may be to show a sum of certain fields based on the search and filters used, or just show a static message. It must return the string of the rendered message.

* `objectName`: The name of the object
* `records`: The paginated records that have been selected to show
* `getRecordsArgs`: Arguments that were passed to [[datamanagerservice-getrecordsforgridlisting]], including filters

For example:


```luceescript
// /application/handlers/admin/datamanager/pipeline.cfc
component {

    property name="pipelineService" inject="pipelineService";

    private string function renderFooterForGridListing( event, rc, prc, args={} ) {
        var pr = pipelineService.getPipelineTotalReport(
              filter       = args.getRecordsArgs.filter       ?: {}
            , extraFilters = args.getRecordsArgs.extraFilters ?: []
            , searchQuery  = args.getRecordsArgs.searchQuery  ?: ""
            , gridFields   = args.getRecordsArgs.gridFields   ?: []
            , searchFields = args.getRecordsArgs.searchFields ?: []
        );

        return translateResource(
              uri  = "pipeline_table:listing.table.footer"
            , data = [ NumberFormat( pr.total ), NumberFormat( pr.adjusted ), pr.currencySymbol ]
        );
    }

}
```---
id: datamanager-customization-buildviewrecordlink
title: "Data Manager customization: buildViewRecordLink"
---

## Data Manager customization: buildViewRecordLink

The `buildViewRecordLink` customization allows you to customize the URL for viewing an object's record. It is expected to return the URL as a string and is provided the `objectName` and `recordId` in the `args` struct along with any other arguments passed to `event.buildAdminLink()`. In addition, it may also be given `version` and `language` keys in the `args` struct should versioning and/or multilingual be enabled. e.g.

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function buildViewRecordLink( event, rc, prc, args={} ) {
		var recordId    = args.recordId ?: "";
		var version     = Val( args.version ?: "" );
		var qs          = "id=" & recordId;

		if ( version ) {
			qs &= "&version=" & version;
		}

		if ( Len( Trim( args.queryString ?: "" ) ) {
			qs &= "&" & args.queryString;
		}

		return event.buildAdminLink( linkto="admin.blogmanager.viewrecord", queryString=qs );
	}

}
```

---
id: datamanager-customization-buildrecordhistorylink
title: "Data Manager customization: buildRecordHistoryLink"
---

## Data Manager customization: buildRecordHistoryLink

The `buildRecordHistoryLink` customization allows you to customize the URL for viewing an object record's version history. It is expected to return the URL as a string and is provided the `objectName` and `recordId` in the `args` struct along with any other arguments passed to `event.buildAdminLink()`. e.g.

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function buildRecordHistoryLink( event, rc, prc, args={} ) {
		var recordId    = args.recordId ?: "";
		var qs          = "id=" & recordId;

		if ( Len( Trim( args.queryString ?: "" ) ) {
			qs &= "&" & args.queryString;
		}

		return event.buildAdminLink( linkto="admin.blogmanager.viewrecordhistory", queryString=qs );
	}

}
```


---
id: datamanager-customization-renderrecord
title: "Data Manager customization: renderRecord"
---

## Data Manager customization: renderRecord

The `renderRecord` customization allows you to completely override the rendering of a single record for your object. Permissions checking, crumbtrails and page titles will all be taken care of; but the rest is up to you.

The action is expected to return the rendered HTML of the record as a string and is provided the following in the args struct:

* `objectName`: The object name
* `recordId`: ID of the record
* `version`: Version number of the record (if the object is versioned)

>>>>>> You can also make use of variables in the `prc` scope, such as `prc.record`, that will allow you to potentially not duplicate calls to the database.

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function renderRecord() {
		args.blog = prc.record ?: QueryNew(''); // Data Manager will have already fetched the record for you. Check out the prc scope for other commonly fetched goodies that you can make use of

		return renderView( view="/admin/blogs/customRecordView", args=args );
	}

}
```

---
id: datamanager-customization-getactionsforgridlisting
title: "Data Manager customization: getActionsForGridListing"
---

## Data Manager customization: getActionsForGridListing

The `getActionsForGridListing` customization allows you to completely rewrite the logic for adding grid actions to an object's listing table (by grid actions, we mean the list of links to the right of each row in the table).

The method must return _an array_. Each item in the array should be a rendered set of actions for the corresponding row in the recordset passed in `args.records`. For example:

```luceescript
// /application/handlers/admin/datamanager/blog_post.cfc
component {

	private array function getActionsForGridListing( event, rc, prc, args={} ) {
		var records = args.records ?: QueryNew('');
		var actions = [];

		if ( records.recordCount ) {
			// This is a condensed example of a useful general approach.
			// Render *outside* of the loop and use placeholders.
			// Then just replace placeholders when looping the records
			// for much better efficiency
			var template = renderView( view="/admin/my/custom/gridActions", args={ id="{id}" } );

			for( var record in records ) {
				actions.append( template.replace( "{id}", record.id, "all" ) );
			}
		}


		return actions;
	}

}
```

---
id: datamanager-customization-buildtranslaterecordlink
title: "Data Manager customization: buildTranslateRecordLink"
---

## Data Manager customization: buildTranslateRecordLink

The `buildTranslateRecordLink` customization allows you to customize the URL for displaying an object's translate record form. It is expected to return the URL as a string and is provided the following in the `args` struct:

* `objectName`: Name of the object
* `recordId`: ID of the record to be translated
* `language`: ID of the language
* `version`: If versioning enabled, specific version number to load
* `fromDataGrid`: Whether or not this link was built for data grid (can be used to direct back to grid, rather than edit/view record)

e.g.

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function buildTranslateRecordLink( event, rc, prc, args={} ) {
		var recordId    = args.recordId ?: "";
		var language    = args.language ?: "";
		var version     = Val( args.version ?: "" );
		var qs          = "id=#recordId#&language=#language#";

		if ( version ) {
			qs &= "&version=" & version;
		}

		if ( Len( Trim( args.queryString ?: "" ) ) {
			qs &= "&" & args.queryString;
		}

		return event.buildAdminLink( linkto="admin.blogmanager.translate", queryString=qs );
	}

}
```



---
id: datamanager-customization-prerenderlisting
title: "Data Manager customization: preRenderListing"
---

## Data Manager customization: preRenderListing

The `preRenderListing` customization allows you to add your own output _above_ the default object listing screen.

The customization handler should return a string of the rendered viewlet and is supplied an args structure with an `objectName` key.

For example:

```luceescript
// /application/handlers/admin/datamanager/sensitive_data.cfc
component {

	private string function preRenderListing( event, rc, prc, args={} ) {
		return '<p class="alert alert-danger">Warning: use this listing with extreme caution.</p>';
	}

}
```

---
id: datamanager-customization-getclonerecordactionbuttons
title: "Data Manager customization: getCloneRecordActionButtons"
---

## Data Manager customization: getCloneRecordActionButtons

The `getCloneRecordActionButtons` customization allows you to _completely override_ the set of buttons and links that appears below the clone record form. It must _return an array_ of structs that describe the buttons to display and is provided `objectName` and `recordId` in the `args` struct.

Note, if you simply want to add, or tweak, the buttons, you may wish to use [[datamanager-customization-getextraclonerecordactionbuttons]].

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private array function getCloneRecordActionButtons( event, rc, prc, args={} ) {
		var actions = [{
			  type      = "link"
			, href      = event.buildAdminLink( objectName="blog" )
			, class     = "btn-default"
			, globalKey = "c"
			, iconClass = "fa-reply"
			, label     = translateResource( uri="cms:cancel.btn" )
		}];

		actions.append({
			  type      = "button"
			, class     = "btn-info"
			, iconClass = "fa-save"
			, name      = "_saveAction"
			, value     = "publish"
			, label     = translateResource( uri="cms:datamanager.addrecord.btn", data=[ prc.objectTitle ?: "" ] )
		} );

		actions.append({
			  type      = "button"
			, class     = "btn-plus"
			, iconClass = "fa-save"
			, name      = "_saveAction"
			, value     = "publishAndClone"
			, label     = translateResource( uri="cms:presideobjects.blog:addrecord.and.clone.btn", data=[ prc.objectTitle ?: "" ] )
		} );

		return actions;
	}

}
```

>>> See [[datamanager-customization-actionbuttons]] for detailed documentation on the format of the action items.

---
id: datamanager-customization-getextraeditrecordactionbuttons
title: "Data Manager customization: getExtraEditRecordActionButtons"
---

## Data Manager customization: getExtraEditRecordActionButtons

The `getExtraEditRecordActionButtons` customization allows you to modify the set of buttons and links that appears below the edit record form. It is expected _not_ to return a value and receives the following in the `args` struct:

* `objectName`: The name of the object
* `recordId`: The id of the current record
* `actions`: the array of button "actions"

Note, if you want to completely override the buttons, you may wish to use [[datamanager-customization-geteditrecordactionbuttons]].

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private array function getExtraEditRecordActionButtons( event, rc, prc, args={} ) {
		var actions = args.actions ?: [];

		actions.append({
			  type      = "button"
			, class     = "btn-plus"
			, iconClass = "fa-save"
			, name      = "_saveAction"
			, value     = "publishAndEdit"
			, label     = translateResource( uri="cms:presideobjects.blog:editrecord.and.edit.btn", data=[ prc.objectTitle ?: "" ] )
		} );
	}

}
```

>>> See [[datamanager-customization-actionbuttons]] for detailed documentation on the format of the action items.

---
id: datamanager-customization-buildexportdataactionlink
title: "Data Manager customization: buildExportDataActionLink"
---

## Data Manager customization: buildExportDataActionLink

The `buildExportDataActionLink` customization allows you to customize the URL used to submit data export forms. It is expected to return the URL as a string and is provided the `objectName` in the `args` struct along with any other arguments passed to `event.buildAdminLink()`. e.g.

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function buildExportDataActionLink( event, rc, prc, args={} ) {
		var queryString = args.queryString ?: "";

		return event.buildAdminLink( linkto="admin.blogmanager.dataExportAction", queryString=queryString );
	}

}
```

---
id: datamanager-customization-getquickaddrecordformname
title: "Data Manager customization: getQuickAddRecordFormName"
---

## Data Manager customization: getQuickAddRecordFormName

>>> This customization was added in Preside 10.13.0

The `getQuickAddRecordFormName` customization allows you to use a different form name than the Data Manager default for "quick adding" records. The method should return the form name (see [[presideforms]]) and is provided `args.objectName` should you need to use it. For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function getQuickAddRecordFormName( event, rc, prc, args={} ) {
		return "admin.blogs.addblog";
	}

}
```

---
id: datamanager-customization-postQuickEditrecordaction
title: "Data Manager customization: postQuickEditRecordAction"
---

## Data Manager customization: postQuickEditRecordAction

The `postQuickEditRecordAction` customization allows you to run logic _after_ the core Data Manager add record logic is run. It is not expected to return a value and is supplied the following in the `args` struct:

* `objectName`: name of the object
* `formData`: struct containing the form submission
* `validationResult`: validation result from general form validation

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private void function postQuickEditRecordAction( event, rc, prc, args={} ) {
		var newId = args.newId ?: "";

		// redirect to a different than default page
		setNextEvent( url=event.buildAdminLink(
			  objectName = "blog"
			, recordId   = newId
			, operation  = "preview"
		) );
	}
}
```

See also: [[datamanager-customization-prequickeditrecordaction|preQuickEditRecordAction]] and [[datamanager-customization-quickeditrecordaction|quickEditRecordAction]].


---
id: datamanager-customization-getlistingmultiactions
title: "Data Manager customization: getListingMultiActions"
---

## Data Manager customization: getListingMultiActions

The `getListingMultiActions` customization allows you to completely override the array of buttons that gets rendered as part of the listing screen (displayed when a user selects rows from the grid). It should return an array of button definitions as defined in [[datamanager-customization-multi-action-buttons]].

Note, if you only want to modify the buttons, or add / remove to them, look at: [[datamanager-customization-getextralistingmultiactions|getExtraListingMultiActions]]. Overriding the generated buttons string entirely can be achieved with: [[datamanager-customization-listingmultiactions|listingMultiActions]].


For example:


```luceescript
// /application/handlers/admin/datamanager/GlobalDefaults.cfc
component {

    private array function getListingMultiActions( event, rc, prc, args={} ) {
        return [{
              label     = "Archive selected entities"
            , name      = "archive"
            , prompt    = "Archive the selected entities"
            , globalKey = "d"
            , class     = "btn-danger"
            , iconClass = "fa-trash-o"
        }];
    }

}
```---
id: datamanager-customization-deleterecordaction
title: "Data Manager customization: deleteRecordAction"
---

## Data Manager customization: deleteRecordAction

The `deleteRecordAction` allows you to override the core action logic for deleting a record through the Data Manager. The core will have already checked permissions for deleting records, but all other logic will be up to you to implement (including audit trails, etc.).

The method is not expected to return a value and is provided with `args.objectName` and `args.recordId`. _The expectation is that the method will redirect the user after processing the request._

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	property name="blogService" inject="blogService";
	property name="messageBox" inject="messagebox@cbmessagebox";

	private void function deleteRecordAction( event, rc, prc, args={} ) {
		blogService.archiveBlog( args.recordId ?: "" );

		messageBox.info( translateResource( uri="preside-objects.blog:archived.message", data=[ prc.recordLabel ?: "" ] ) );
		
		setNextEvent( url=event.buildAdminLink( objectName = "blog" ) );
	}

}
```---
id: datamanager-customization-editrecordaction
title: "Data Manager customization: editRecordAction"
---

## Data Manager customization: editRecordAction

The `editRecordAction` allows you to override the core action logic for adding a record when a form is submitted. The core will have already checked permissions for editing records, but all other logic will be up to you to implement (including audit trails, validation, etc.).

The method is not expected to return a value and is provided with `args.objectName` and `args.recordId`. _The expectation is that the method will redirect the user after processing the request._

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	property name="blogService" inject="blogService";

	private void function editRecordAction( event, rc, prc, args={} ) {
		var formName         = "my.custom.editrecord.form";
		var recordId         = args.recordId ?: "";
		var formData         = event.getDataForForm( formName );
		var validationResult = validateForm( formName, formData );

		if ( validationResult.validated ) {
			blogService.saveBlog( argumentCollection=formData, id=recordId );

			setNextEvent( url=event.buildAdminLink(
				  objectName = "blog"
				, recordId   = recordId
			) );
		}

		var persist = formData;
		persist.validationResult = validationResult;

		setNextEvent( url=event.buildAdminLink(
			  objectName = "blog"
			, operation  = "editRecord"
			, recordId   = recordId
		), persistStruct=persist );

	}

}


```

>>> If you wish to still use core logic for editing records but need to add additional logic to the process, use [[datamanager-customization-preeditrecordaction|preEditRecordAction]] or [[datamanager-customization-posteditrecordaction|postEditRecordAction]] instead.

---
id: datamanager-customization-postrenderrecordleftcol
title: "Data Manager customization: postRenderRecordLeftCol"
---

## Data Manager customization: postRenderRecordLeftCol

The `postRenderRecordLeftCol` customization allows you to add custom HTML _below_ the left-hand column of the core view record screen for your object (see [[adminrecordviews]]). The action is expected to return a string containing the HTML and is provided the following in the `args` struct:

* `objectName`: The object name
* `recordId`: ID of the record
* `version`: Version number of the record (if the object is versioned)

>>>>>> You can also make use of variables in the `prc` scope, such as `prc.record`, that will allow you to potentially not duplicate calls to the database.

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function postRenderRecordLeftCol() {
		args.blog = prc.record ?: QueryNew('');

		return renderView( view="/admin/blogs/auditTrail", args=args );
	}

}
```

---
id: datamanager-customization-gettoprightbuttonsforeditrecord
title: "Data Manager customization: getTopRightButtonsForEditRecord"
---

## Data Manager customization: getTopRightButtonsForEditRecord

The `getTopRightButtonsForEditRecord` customization allows you to _completely override_ the set of buttons that appears at the top right hand side of the edit record screen. It must _return an array_ of structs that describe the buttons to display and is provided the `objectName` in the `args` struct.

Note, if you simply want to add, or tweak, the top right buttons, you may wish to use [[datamanager-customization-extratoprightbuttonsforeditrecord]].

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private array function getTopRightButtonsForEditRecord( event, rc, prc, args={} ) {
		var actions    = [];
		var objectName = args.objectName ?: "";
		var recordId   = prc.recordId ?: "";

		actions.append({
			  link      = event.buildAdminLink( objectName=objectName, operation="reports", recordId=recordId )
			, btnClass  = "btn-default"
			, iconClass = "fa-bar-chart"
			, globalKey = "r"
			, title     = translateResource( "preside-objects.blog:reports.btn" )
		} );

		return actions;
	}

}
```

>>> See [[datamanager-customization-toprightbuttonsformat]] for detailed documentation on the format of the action items.---
id: datamanager-customization-editrecordform
title: "Data Manager customization: editRecordForm"
---

## Data Manager customization: editRecordForm

The `editRecordForm` customization allows you to completely overwrite the view for rendering the edit record form page. The crumb trail, permissions checks and page title will be taken care of, but the rest is up to you.

The handler should return a string (the rendered edit record form page) is provided the following in the `args` struct.

* `objectName`: The name of the object
* `recordId`: The ID of the record being edited
* `record`: Struct of the record being edited
* `editRecordAction`: URL for submitting the form
* `useVersioning`: Whether or not to use versioning
* `version`: Version number (for versioning only) of the record in `args.record`
* `draftsEnabled`: Whether or not drafts are enabled
* `canSaveDraft`: Whether or not the current user can save drafts (for drafts only)
* `canPublish`: Whether or not the current user can publish (for drafts only)
* `cancelAction`: URL that any rendered 'cancel' link should use

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc
component {

	private string function editRecordForm( event, rc, prc, args={} ) {
		return renderView( view="/admin/my/custom/editrecordForm", args=args );
	}

}
```


---
id: datamanager-customization-prerenderrecordrightcol
title: "Data Manager customization: preRenderRecordRightCol"
---

## Data Manager customization: preRenderRecordRightCol

The `preRenderRecordRightCol` customization allows you to add custom HTML _above_ the right-hand column of the core view record screen for your object (see [[adminrecordviews]]). The action is expected to return a string containing the HTML and is provided the following in the `args` struct:

* `objectName`: The object name
* `recordId`: ID of the record
* `version`: Version number of the record (if the object is versioned)

>>>>>> You can also make use of variables in the `prc` scope, such as `prc.record`, that will allow you to potentially not duplicate calls to the database.

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function preRenderRecordRightCol() {
		args.blog = prc.record ?: QueryNew('');

		return renderView( view="/admin/blogs/auditTrail", args=args );
	}

}
```

---
id: datamanager-customization-extratoprightbuttonsforaddrecord
title: "Data Manager customization: extraTopRightButtonsForAddRecord"
---

## Data Manager customization: extraTopRightButtonsForAddRecord

The `extraTopRightButtonsForAddRecord` customization allows you to add to, or modify, the set of buttons that appears at the top right hand side of the add record screen. It is provided an `actions` array along with the `objectName` in the `args` struct and is not expected to return a value.

Modifying `args.actions` is required to make changes to the top right buttons.


>>> See [[datamanager-customization-toprightbuttonsformat]] for detailed documentation on the format of the action items.


For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private void function extraTopRightButtonsForAddRecord( event, rc, prc, args={} ) {
		var objectName = args.objectName ?: "";

		args.actions = args.actions ?: [];

		args.actions.append({
			  link      = event.buildAdminLink( objectName=objectName, operation="reports" )
			, btnClass  = "btn-default"
			, iconClass = "fa-bar-chart"
			, globalKey = "r"
			, title     = translateResource( "preside-objects.blog:reports.btn" )
		} );
	}

}
```





---
id: datamanager-customization-postbatchdeleterecordsaction
title: "Data Manager customization: postBatchDeleteRecordsAction"
---

## Data Manager customization: postBatchDeleteRecordsAction

As of **Preside 10.16.0**, the `postBatchDeleteRecordsAction` customization allows you to run logic _after_ the core Data Manager logic batch deletes a number of records. It is not expected to return a value and is supplied the following in the `args` struct:

* `object`: name of the object
* `records`: query containing the records that will be deleted
* `logger`: logger object - used to output logs to an end user following the batch delete process
* `progress`: progress object - used to update progress bar for the end user following the batch delete process

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	property name="blogService" inject="blogService";

	private void function postBatchDeleteRecordsAction( event, rc, prc, args={} ) {
		var canLog = StructKeyExists( args, "logger" );
		var canInfo = canLog && args.logger.canInfo();

		for( var record in records ) {
			blogService.notifyServicesOfDeletedBlog( record.id );
			if ( canInfo ) {
				args.logger.info( "Did something with [#record.label#]" );
			}
		}
	}
}

```

See also: [[datamanager-customization-prebatchdeleterecordsaction|preBatchDeleteRecordsAction]]



---
id: datamanager-customization-postQuickaddrecordaction
title: "Data Manager customization: postQuickAddRecordAction"
---

## Data Manager customization: postQuickAddRecordAction

The `postQuickAddRecordAction` customization allows you to run logic _after_ the core Data Manager add record logic is run. It is not expected to return a value and is supplied the following in the `args` struct:

* `objectName`: name of the object
* `formData`: struct containing the form submission
* `newId`: ID of the newly created record


For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private void function postQuickAddRecordAction( event, rc, prc, args={} ) {
		var newId = args.newId ?: "";

		// redirect to a different than default page
		setNextEvent( url=event.buildAdminLink(
			  objectName = "blog"
			, recordId   = newId
			, operation  = "preview"
		) );
	}
}
```

See also: [[datamanager-customization-prequickaddrecordaction|preQuickAddRecordAction]] and [[datamanager-customization-quickaddrecordaction|quickAddRecordAction]].


---
id: datamanager-customization-prelayoutrender
title: "Data Manager customization: preLayoutRender"
---

## Data Manager customization: preLayoutRender

The `preLayoutRender` customization allows you fire off code just before the full admin page layout is rendered for a Data manager based page. The customization is **not** expected to return a value and can be used to set variables that effect the layout such as `prc.pageTitle`, `prc.pageIcon` and the breadcrumbs for the request.

In addition to this global customization, you can also implement customizations with the convention `preLayoutRenderFor{actionName}`, where `{actionName}` is the name of the current data manager action. For example `preLayoutRenderForViewRecord`.

The following attributes are available in the `args` struct but examining the `prc` scope is also useful for getting at already generated content such as `prc.record`, `prc.recordLabel`, etc.

* `objectName`: the name of the object
* `action`: the current coldbox action, e.g. `editRecord`, `viewRecord`, `object`, etc.


For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

    private void function preLayoutRender( event, rc, prc, args={} ) {
        prc.pageTitle = translateResource(
              uri          = "preside-objects.blog:#args.action#.page.title"
            , defaultValue = prc.pageTitle ?: ""
        );
    }

    private void function preLayoutRenderForEditRecord( event, rc, prc, args={} ) {
        prc.pageTitle = translateResource(
              uri  = "preside-objects.blog:editRecord.page.title"
            , data = [ prc.recordLabel ?: "" ]
        );

        // modify the title of the last breadcrumb
        var breadCrumbs = event.getAdminBreadCrumbs();
        breadCrumbs[ breadCrumbs.len() ].title = prc.pageTitle;
    }
}
```---
id: datamanager-customization-buildgetnodesfortreeviewlink
title: "Data Manager customization: buildGetNodesForTreeViewLink"
---

## Data Manager customization: buildGetNodesForTreeViewLink

The `buildGetNodesForTreeViewLink` customization allows you to customize the ajax URL for fetching child nodes for tree view. It is expected to return the listing URL as a string and is provided the `objectName` in the `args` struct along with any other arguments passed to `event.buildAdminLink()`. e.g.


```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function buildGetNodesForTreeViewLink( event, rc, prc, args={} ) {
		var queryString = args.queryString ?: "";

		return event.buildAdminLink( linkto="admin.blogmanager.ajaxTreeViewNodes", queryString=queryString );
	}

}
```

>>> See [[datamanagerbasics]] for information regarding setting up a tree view for your object.
---
id: datamanager-customization-preQuickeditrecordaction
title: "Data Manager customization: preQuickEditRecordAction"
---

## Data Manager customization: preQuickEditRecordAction

The `preQuickEditRecordAction` customization allows you to run logic _before_ the core Data Manager edit record logic is run. It is not expected to return a value and is supplied the following in the `args` struct:

* `objectName`: name of the object
* `formData`: struct containing the form submission

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	property name="blogService" inject="blogService";

	private void function preQuickEditRecordAction( event, rc, prc, args={} ) {
		rc.clearance_level = blogService.calculateClearanceLevel( argumentCollection=args.formData ?: {} );
	}
}

```

See also: [[datamanager-customization-postquickeditrecordaction|postQuickEditRecordAction]] and [[datamanager-customization-quickeditrecordaction|quickEditRecordAction]].


---
id: datamanager-customization-clonerecordactionbuttons
title: "Data Manager customization: cloneRecordActionButtons"
---

## Data Manager customization: cloneRecordActionButtons

The `cloneRecordActionButtons` customization allows you to completely override the form action buttons (e.g. "Cancel", "Add record") for the clone record form. The handler is expected to return a string that is the rendered HTML and is provided the following in the `args` struct:

* `objectName`: The name of the object
* `recordId`: The ID of the record being cloneed
* `record`: Struct of the record being cloneed
* `cloneRecordAction`: URL for submitting the form
* `draftsEnabled`: Whether or not drafts are enabled
* `canSaveDraft`: Whether or not the current user can save drafts (for drafts only)
* `canPublish`: Whether or not the current user can publish (for drafts only)
* `cancelAction`: URL that any rendered 'cancel' link should use

For example:


```luceescript
// /application/handlers/admin/datamanager/GlobalDefaults.cfc
component {

	private string function cloneRecordActionButtons( event, rc, prc, args={} ) {
		var objectName = args.objectName ?: "";
		
		args.cancelAction = event.buildAdminLink( objectName=objectName );

		return renderView( view="/admin/datamanager/globaldefaults/cloneRecordActionButtons", args=args );
	}

}
```

```lucee
<!--- /application/views/admin/datamanager/globaldefaults/cloneRecordActionButtons.cfm --->

<cfoutput>
	<div class="col-md-offset-2">
		<a href="#args.cancelAction#" class="btn btn-default" data-global-key="c">
			<i class="fa fa-reply bigger-110"></i>
			Cancel
		</a>
		
		<button type="submit" class="btn btn-info" tabindex="#getNextTabIndex()#">
				<i class="fa fa-save bigger-110"></i> Save record
		</button>
	</div>
</cfoutput>
```

>>>> The core implementation has logic for showing different buttons for drafts and dynamically building labels for buttons, etc. Be sure to know what you're missing out on when overriding this (or any) customization!

---
id: customizing-deletion-prompt-matches
title: "Customizing the delete record prompt and match text"
---

## Summary

As of **10.16.0**, you are able to configure objects to use a "match" text in the delete prompt. You can configure both application-wide default behaviour, and object-level overrides for the default.

![Screenshot of a delete record prompt](images/screenshots/deleteprompt.png)

## Configuring application defaults

### Enabling/disabling the match text

There are two **Config.cfc** settings that control whether or not match text must be input:

```luceescript
// default values supplied by Preside
settings.dataManager.defaults.typeToConfirmDelete      = false;
settings.dataManager.defaults.typeToConfirmBatchDelete = true;
```

So by _default_, we _will_ prompt to enter a matching text when _batch_ deleting records, but _not_ while deleting _single_ records. Update the settings above to change this behaviour.

### Customizing the global match text

Two i18n entries are used for the match text. To change them, supply your own application/extension overrides of the properties:

```properties
# /i18n/cms.properties
datamanager.delete.record.match=delete
datamanager.batch.delete.records.match=delete
```

## Per object customisation

### Enabling/disabling the match text

To have an object use a non-default behaviour, annotate the object cfc file with the `datamanagerTypeToConfirmDelete` and/or `datamanagerTypeToConfirmBatchDelete` flags:

```luceescript
/**
 * @datamanagerTypeToConfirmDelete      true
 * @datamanagerTypeToConfirmBatchDelete true
 *
 */
component {
	// ...
}

```

### Customizing per-object match text

You have two approaches available here, static i18n match text and dynamically generated text for single record deletes.

#### Static i18n

In your object's `.properties` file (i.e. `/i18n/preside-objects/my_object.propertes`), implement the property keys `delete.record.match` and/or `batch.delete.records.match`. i.e.

```properties
# ...

delete.record.match=CONFIRM
batch.delete.records.match=DO IT
```

#### Dynamic match text for single record deletes

To create dynamic match text per record, use the datamanager customisation: [[datamanager-customization-getrecorddeletionpromptmatch|getRecordDeletionPromptMatch]] (see guide for more details).




---
id: datamanager-customization-prerendereditrecordform
title: "Data Manager customization: preRenderEditRecordForm"
---

## Data Manager customization: preRenderEditRecordForm

The `preRenderEditRecordForm` customization allows you to add rendered HTML _before_ the rendering of the core edit record form. The HTML will live _inside_ the html `<form>` tags, so that you are able to add form fields into the form.

The handler is expected to return a string that is the rendered HTML and is provided the following in the `args` struct:

* `objectName`: The name of the object
* `recordId`: The ID of the record being edited
* `record`: Struct of the record being edited
* `editRecordAction`: URL for submitting the form
* `useVersioning`: Whether or not to use versioning
* `version`: Version number (for versioning only) of the record in `args.record`
* `draftsEnabled`: Whether or not drafts are enabled
* `canSaveDraft`: Whether or not the current user can save drafts (for drafts only)
* `canPublish`: Whether or not the current user can publish (for drafts only)
* `cancelAction`: URL that any rendered 'cancel' link should use

For example:


```luceescript
// /application/handlers/admin/datamanager/faq.cfc

component {

	private string function preRenderEditRecordForm( event, rc, prc, args={} ) {
		return '<p class="alert alert-warning">Remember: double check existing records before adding a new FAQ.</p>';
	}

}
```

See also: [[datamanager-customization-postrendereditrecordform|postRenderEditRecordForm]]

---
id: datamanager-customization-extrarecordactionsforgridlisting
title: "Data Manager customization: extraRecordActionsForGridListing"
---

## Data Manager customization: extraRecordActionsForGridListing

The `extraRecordActionsForGridListing` allows you to add actions to the object's record listing rows, or modify the existing actions. It is not expected to return a value and is passed the following in the `args` struct:


* `objectName`: Name of the object.
* `record`: Struct representing the record for the current row.
* `actions`: Array containing the already calculated actions for the row. Modify this array to add/remove/edit the actions as per your requirements.

Each "action" in the `args.actions` array is a struct with the following possible keys:

* `link`: Link for the action
* `icon`: Font awesome icon class for the action, e.g. `fa-pencil`
* `class`: Additional css classes for the action
* `contextKey`: Optional keyboard shortcut that will activate the action when the row is in focus
* `title`: Optional title that will be used in the title attribute of the link
* `target`: Link target, e.g. "\_blank" to open in a new tab

For example:

```luceescript
// /application/handlers/admin/datamanager/blog_post.cfc

component {

	private void function extraRecordActionsForGridListing( event, rc, prc, args={} ) {
		var objectName = args.objectName ?: "";
		var record     = args.record     ?: {};
		var recordId   = record.id       ?: "";

		args.actions = args.actions ?: [];
		args.actions.append( {
			  link       = event.buildAdminLink( objectName=objectName, operation="download", recordid=recordId )
			, icon       = "fa-download"
			, contextKey = "d"
			, target     = "_blank"
		} );
	}

}
```

>>> If you need to complete make a new set of actions and disregard the core defaults, you should use [[datamanager-customization-getrecordactionsforgridlisting]] or [[datamanager-customization-getactionsforgridlisting]].---
id: datamanager-customization-buildmultirecordactionlink
title: "Data Manager customization: buildMultiRecordActionLink"
---

## Data Manager customization: buildMultiRecordActionLink

The `buildMultiRecordActionLink` customization allows you to customize the URL used to submit the multi-record modification action (i.e. multi edit or delete). It is expected to return the URL as a string and is provided the `objectName` in the `args` struct along with any other arguments passed to `event.buildAdminLink()`. e.g.

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function buildMultiRecordActionLink( event, rc, prc, args={} ) {
		var queryString = args.queryString ?: "";

		return event.buildAdminLink( linkto="admin.blogmanager.multiAction", queryString=queryString );
	}

}
```

---
id: datamanager-customization-getextraaddrecordactionbuttons
title: "Data Manager customization: getExtraAddRecordActionButtons"
---

## Data Manager customization: getExtraAddRecordActionButtons

The `getExtraAddRecordActionButtons` customization allows you to modify the set of buttons and links that appears below the add record form. It is expected _not_ to return a value and receives the following in the `args` struct:

* `objectName`: The name of the object
* `actions`: the array of button "actions"

Note, if you want to completely override the buttons, you may wish to use [[datamanager-customization-getaddrecordactionbuttons]].

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private array function getExtraAddRecordActionButtons( event, rc, prc, args={} ) {
		var actions = args.actions ?: [];

		actions.append({
			  type      = "button"
			, class     = "btn-plus"
			, iconClass = "fa-save"
			, name      = "_saveAction"
			, value     = "publishAndEdit"
			, label     = translateResource( uri="cms:presideobjects.blog:addrecord.and.edit.btn", data=[ prc.objectTitle ?: "" ] )
		} );
	}

}
```

>>> See [[datamanager-customization-actionbuttons]] for detailed documentation on the format of the action items.

---
id: datamanager-customization-checkpermission
title: "Data Manager customization: checkPermission"
---

## Data Manager customization: checkPermission

The `checkPermission` customization allows you to completely override the Data Manager permissions checking for any object.

Depending on the arguments, it is either expected to return a `boolean` value to indicate whether or not the user has the asked for permission, or throw an `event.adminAccessDenied()` when the user does not have permission. It is provided with the following in the `args` struct:

* `object`: Name of the object
* `key`: Permission key, will be one of `add`, `datamanager`, `delete`, `edit`, `manageContextPerms`, `navigate`, `presideobject`, `publish`, `read`, `savedraft`, `translate`, `viewversions`
* `throwOnError`: Whether to throw `event.adminAccessDenied()` when not permitted, or just return `false`


For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private boolean function checkPermission( event, rc, prc, args={} ) {
		var key           = "blogmanager.#( args.key ?: "" )#";
		var hasPermission = hasCmsPermission( key );

		if ( !hasPermission && IsTrue( args.throwOnError ?: "" ) ) {
			event.adminAccessDenied();
		}

		return hasPermission;
	}

}

```

>>>>>> See [[cmspermissioning]] for a full guide on setting up your own permissions.



---
id: datamanager-customization-quickAddRecordAction
title: "Data Manager customization: quickAddRecordAction"
---

## Data Manager customization: quickAddRecordAction

The `quickAddRecordAction` allows you to override the core action logic for adding a record when a form is submitted. The core will have already checked permissions for adding records, but all other logic will be up to you to implement (including audit trails, validation, etc.).

The method is not expected to return a value and is provided with `args.objectName`. _The expectation is that the method will redirect the user after processing the request._

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	property name="blogService" inject="blogService";

	private void function quickAddRecordAction( event, rc, prc, args={} ) {
		var formName         = "my.custom.addrecord.form";
		var formData         = event.getDataForForm( formName );
		var validationResult = validateForm( formName, formData );

		if ( validationResult.validated ) {
			var newRecordId = blogService.addBlog( argumentCollection=formData );

			setNextEvent( url=event.buildAdminLink(
				  objectName = "blog"
				, recordId   = newRecordId
			) );
		}

		var persist = formData;
		persist.validationResult = validationResult;

		setNextEvent( url=event.buildAdminLink(
			  objectName = "blog"
			, operation  = "addRecord"
		), persistStruct=persist );

	}

}


```

>>> If you wish to still use core logic for adding records but need to add additional logic to the process, use [[datamanager-customization-prequickaddrecordaction|preQuickAddRecordAction]] or [[datamanager-customization-postquickaddrecordaction|postQuickAddRecordAction]] instead.---
id: datamanager-customization-prefetchrecordsforgridlisting
title: "Data Manager customization: preFetchRecordsForGridListing"
---

## Data Manager customization: preFetchRecordsForGridListing

The `preFetchRecordsForGridListing` customization can be used to modify the arguments sent to [[datamanagerservice-getrecordsforgridlisting]] method. The `args` struct sent to the customization action represents the arguments to be sent to [[datamanagerservice-getrecordsforgridlisting]]. No return value is expected.

A common example might be to add an extra filter to the the query. For example:

```luceescript
// /application/handlers/admin/datamanager/blog_post.cfc
component {

	private void function preFetchRecordsForGridListing( event, rc, prc, args={} ) {
		var category = rc.category ?: "";

		if ( !IsEmpty( category ) ) {
			args.extraFilters = args.extraFilters ?: [];
			
			args.extraFilters.append( { filter={ category=category } } );		
		}

	}

}
```

Note, that this example would rely on `rc.category` somehow being present in the _ajax_ request that fetches the record set. One method of achieving this would be to make use of [[datamanager-customization-getadditionalquerystringforbuildajaxlistinglink]]. For example:


```luceescript
// /application/handlers/admin/datamanager/blog_post.cfc
component {

	// this is run when building the ajax link, i.e. in the main
	// request for the listing page
	private string function getAdditionalQueryStringForBuildAjaxListingLink( event, rc, prc, args={} ) {
		// category here could have been placed in the URL
		// by a category drop down button, for example
		
		var category = rc.category ?: "";

		return "category=#category#";
	}


	// this is run during the ajax fetch of records
	private void function preFetchRecordsForGridListing( event, rc, prc, args={} ) {
		var category = rc.category ?: "";

		if ( !IsEmpty( category ) ) {
			args.extraFilters = args.extraFilters ?: [];
			
			args.extraFilters.append( { filter={ category=category } } );		
		}

	}

}
```---
id: datamanager-customization-postrenderrecord
title: "Data Manager customization: postRenderRecord"
---

## Data Manager customization: postRenderRecord

The `postRenderRecord` customization allows you to add additional HTML _below_ the core rendering of a view record screen for an object. The action is expected to return a string containing the HTML and is provided the following in the `args` struct:

* `objectName`: The object name
* `recordId`: ID of the record
* `version`: Version number of the record (if the object is versioned)

>>>>>> You can also make use of variables in the `prc` scope, such as `prc.record`, that will allow you to potentially not duplicate calls to the database.

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function postRenderRecord() {
		args.blog = prc.record ?: QueryNew('');

		return renderView( view="/admin/blogs/viewRecordFooter", args=args );
	}

}
```

See also: [[datamanager-customization-prerenderrecord|preRenderRecord]].

---
id: datamanager-customization-getclonerecordformname
title: "Data Manager customization: getCloneRecordFormName"
---

## Data Manager customization: getCloneRecordFormName

The `getCloneRecordFormName` customization allows you to use a different form name than the Data Manager default for cloneing records. The method should return the form name (see [[presideforms]]) and is provided `args.objectName` should you need to use it. For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function getCloneRecordFormName( event, rc, prc, args={} ) {
		return "admin.blogs.cloneblog";
	}

}
```

---
id: datamanager-customization-getaddrecordactionbuttons
title: "Data Manager customization: getAddRecordActionButtons"
---

## Data Manager customization: getAddRecordActionButtons

The `getAddRecordActionButtons` customization allows you to _completely override_ the set of buttons and links that appears below the add record form. It must _return an array_ of structs that describe the buttons to display and is provided the `objectName` in the `args` struct.

Note, if you simply want to add, or tweak, the buttons, you may wish to use [[datamanager-customization-getextraaddrecordactionbuttons]].

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private array function getAddRecordActionButtons( event, rc, prc, args={} ) {
		var actions = [{
			  type      = "link"
			, href      = event.buildAdminLink( objectName="blog" )
			, class     = "btn-default"
			, globalKey = "c"
			, iconClass = "fa-reply"
			, label     = args.cancelLabel
		}];

		actions.append({
			  type      = "button"
			, class     = "btn-info"
			, iconClass = "fa-save"
			, name      = "_saveAction"
			, value     = "publish"
			, label     = translateResource( uri="cms:datamanager.addrecord.btn", data=[ prc.objectTitle ?: "" ] )
		} );

		actions.append({
			  type      = "button"
			, class     = "btn-plus"
			, iconClass = "fa-save"
			, name      = "_saveAction"
			, value     = "publishAndEdit"
			, label     = translateResource( uri="cms:presideobjects.blog:addrecord.and.edit.btn", data=[ prc.objectTitle ?: "" ] )
		} );

		return actions;
	}

}
```

>>> See [[datamanager-customization-actionbuttons]] for detailed documentation on the format of the action items.

---
id: datamanager-customization-buildaddrecordlink
title: "Data Manager customization: buildAddRecordLink"
---

## Data Manager customization: buildAddRecordLink

The `buildAddRecordLink` customization allows you to customize the URL used to show the add record form. It is expected to return the URL as a string and is provided the `objectName` in the `args` struct along with any other arguments passed to `event.buildAdminLink()`. e.g.

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function buildAddRecordLink( event, rc, prc, args={} ) {
		var queryString = args.queryString ?: "";

		return event.buildAdminLink( linkto="admin.blogmanager.addRecordScreen", queryString=queryString );
	}

}
```

---
id: datamanager-customization-listingviewlet
title: "Data Manager customization: listingViewlet"
---

## Data manager customization: listingViewlet

The `listingViewlet` customization allows you to completely override the _entire_ viewlet for rendering a listing view for an object (i.e. the view that normally shows the data table listing records).

The customization handler should return a string of the rendered viewlet and is supplied an args structure with an `objectName` key.

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc
component {

	private string function listingViewlet( event, rc, prc, args={} ) {
		return renderView( view="/admin/datamanager/blog/listing", args=args );
	}

}
```



---
id: datamanager-customization-getrecordactionsforgridlisting
title: "Data Manager customization: getRecordActionsForGridListing"
---

## Data Manager customization: getRecordActionsForGridListing

The `getRecordActionsForGridListing` allows you to override the grid actions that display for each record in your object's record listing view. It is expected to return an array of structs representing the actions and receives two arguments in the `args` struct:

* `objectName`: the name of the object
* `record`: a struct representing the current record whose grid actions you are to return

Each item can/should have the following keys:

* `link`: Link for the action
* `icon`: Font awesome icon class for the action, e.g. `fa-pencil`
* `class`: Additional css classes for the action
* `contextKey`: Optional keyboard shortcut that will activate the action when the row is in focus
* `title`: Optional title that will be used in the title attribute of the link
* `target`: Link target, e.g. "\_blank" to open in a new tab

For example:

```luceescript
// /application/handlers/admin/datamanager/blog_post.cfc

component {

	private array function getRecordActionsForGridListing( event, rc, prc, args={} ) {
		var objectName = args.objectName ?: "";
		var record     = args.record     ?: {};
		var recordId   = record.id       ?: "";

		return [ {
			  link = event.buildAdminLink( objectName=objectName, operation="download", recordid=recordId )
			, icon = "fa-download"
		} ];
	}

}
```

>>> This customization is very similar to the [[datamanager-customization-getactionsforgridlisting|getActionsForGridListing]] customization. The key difference is that this customization operates on individual rows and may be a better option for situations where you need to run business logic per row.
>>>
>>> You may also consider the [[datamanager-customization-extrarecordactionsforgridlisting|extraRecordActionsForGridListing]] customization that allows you to add/modify the actions so that you can re-use existing core funcionality and logic for the actions rather than completely rewriting the logic.---
id: datamanager-customization-getaddrecordformname
title: "Data Manager customization: getAddRecordFormName"
---

## Data Manager customization: getAddRecordFormName

The `getAddRecordFormName` customization allows you to use a different form name than the Data Manager default for adding records. The method should return the form name (see [[presideforms]]) and is provided `args.objectName` should you need to use it. For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function getAddRecordFormName( event, rc, prc, args={} ) {
		return "admin.blogs.addblog";
	}

}
```

---
id: datamanager-customization-prerenderaddrecordform
title: "Data Manager customization: preRenderAddRecordForm"
---

## Data Manager customization: preRenderAddRecordForm

The `preRenderAddRecordForm` customization allows you to add rendered HTML _before_ the rendering of the core add record form. The HTML will live _inside_ the html `<form>` tags, so that you are able to add form fields into the form.

The handler is provided with `args.objectName` and is expected to return a string that is the rendered HTML. For example:


```luceescript
// /application/handlers/admin/datamanager/faq.cfc

component {

	private string function preRenderAddRecordForm( event, rc, prc, args={} ) {
		return '<p class="alert alert-warning">Remember: double check existing records before adding a new FAQ.</p>';
	}

}
```

See also: [[datamanager-customization-postrenderaddrecordform|postRenderAddRecordForm]]---
id: datamanager-customization-postrenderclonerecordform
title: "Data Manager customization: postRenderdCloneRecordForm"
---

## Data Manager customization: postRenderdCloneRecordForm

The `postRenderdCloneRecordForm` customization allows you to add rendered HTML _after_ the rendering of the core clone record form. The HTML will live _inside_ the html `<form>` tags, so that you are able to add form fields into the form.

The handler is expected to return a string that is the rendered HTML and is provided the following in the `args` struct:

* `objectName`: The name of the object
* `recordId`: The ID of the record being cloned
* `record`: Struct of the record being cloned
* `cloneRecordAction`: URL for submitting the form
* `useVersioning`: Whether or not to use versioning
* `version`: Version number (for versioning only) of the record in `args.record`
* `draftsEnabled`: Whether or not drafts are enabled
* `canSaveDraft`: Whether or not the current user can save drafts (for drafts only)
* `canPublish`: Whether or not the current user can publish (for drafts only)
* `cancelAction`: URL that any rendered 'cancel' link should use

For example:

```luceescript
// /application/handlers/admin/datamanager/faq.cfc

component {

	private string function postRenderdCloneRecordForm( event, rc, prc, args={} ) {
		return '<p class="alert alert-warning">Before hitting submit, below - triple-chek your speling and grama!</p>';
	}

}
```

See also: [[datamanager-customization-prerenderaddrecordform|preRenderAddRecordForm]]

---
id: datamanager-customization-postrenderrecordrightcol
title: "Data Manager customization: postRenderRecordRightCol"
---

## Data Manager customization: postRenderRecordRightCol

The `postRenderRecordRightCol` customization allows you to add custom HTML _below_ the right-hand column of the core view record screen for your object (see [[adminrecordviews]]). The action is expected to return a string containing the HTML and is provided the following in the `args` struct:

* `objectName`: The object name
* `recordId`: ID of the record
* `version`: Version number of the record (if the object is versioned)

>>>>>> You can also make use of variables in the `prc` scope, such as `prc.record`, that will allow you to potentially not duplicate calls to the database.

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function postRenderRecordRightCol() {
		args.blog = prc.record ?: QueryNew('');

		return renderView( view="/admin/blogs/auditTrail", args=args );
	}

}
```

---
id: datamanager-customization-editrecordactionbuttons
title: "Data Manager customization: editRecordActionButtons"
---

## Data Manager customization: editRecordActionButtons

The `editRecordActionButtons` customization allows you to completely override the form action buttons (e.g. "Cancel", "Add record") for the edit record form. The handler is expected to return a string that is the rendered HTML and is provided the following in the `args` struct:

* `objectName`: The name of the object
* `recordId`: The ID of the record being edited
* `record`: Struct of the record being edited
* `editRecordAction`: URL for submitting the form
* `useVersioning`: Whether or not to use versioning
* `version`: Version number (for versioning only) of the record in `args.record`
* `draftsEnabled`: Whether or not drafts are enabled
* `canSaveDraft`: Whether or not the current user can save drafts (for drafts only)
* `canPublish`: Whether or not the current user can publish (for drafts only)
* `cancelAction`: URL that any rendered 'cancel' link should use

For example:


```luceescript
// /application/handlers/admin/datamanager/GlobalDefaults.cfc
component {

	private string function editRecordActionButtons( event, rc, prc, args={} ) {
		var objectName = args.objectName ?: "";
		
		args.cancelAction = event.buildAdminLink( objectName=objectName );

		return renderView( view="/admin/datamanager/globaldefaults/editRecordActionButtons", args=args );
	}

}
```

```lucee
<!--- /application/views/admin/datamanager/globaldefaults/editRecordActionButtons.cfm --->

<cfoutput>
	<div class="col-md-offset-2">
		<a href="#args.cancelAction#" class="btn btn-default" data-global-key="c">
			<i class="fa fa-reply bigger-110"></i>
			Cancel
		</a>
		
		<button type="submit" class="btn btn-info" tabindex="#getNextTabIndex()#">
				<i class="fa fa-save bigger-110"></i> Save record
		</button>
	</div>
</cfoutput>
```

>>>> The core implementation has logic for showing different buttons for drafts and dynamically building labels for buttons, etc. Be sure to know what you're missing out on when overriding this (or any) customization!

---
id: datamanager-customization-buildlistinglink
title: "Data Manager customization: buildListingLink"
---

## Data Manager customization: buildListingLink

The `buildListingLink` customization allows you to customize the link for the listing screen for an object. It is expected to return the listing URL as a string and is provided the `objectName` in the `args` struct along with any other arguments passed to `event.buildAdminLink()`. e.g.

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function buildListingLink( event, rc, prc, args={} ) {
		var queryString = args.queryString ?: "";

		return event.buildAdminLink( linkto="admin.blogmanager", queryString=queryString );
	}

}
```---
id: datamanager-customization-multirecordaction
title: "Data Manager customization: multiRecordAction"
---

## Data Manager customization: multiRecordAction

The `multiRecordAction` customization allows you customize the processing of a multi row action submission from the listing screen. It is not expected to return a value. However, if it processes the request and does not want any further core processing to take place, it **must redirect the user to a success page** (i.e. send the user back to the listing page and add a success message). It recieves the following in the `args` struct:

* `objectName`: The name of the object
* `action`: the name of the action that was performed (the button/link selected in the listing screen)
* `ids`: an array of record IDs that the action should be performed on (empty if `batchAll` is `true`)
* `batchAll`: as of **10.16.0**, a boolean flag to indicate that the user picked the "Select all records matching the current filter"
* `batchSrcArgs`: as of **10.16.0**, a struct of args that were used in a `selectData` call to fetch the records using the current datatable filters. Only needed when `batchAll` is `true`

See also:

* [[datamanager-customization-listingmultiactions|listingMultiActions]]
* [[datamanager-customization-getlistingmultiactions|getListingMultiActions]]
* [[datamanager-customization-getextralistingmultiactions|getExtraListingMultiActions]]

For example:


```luceescript
// /application/handlers/admin/datamanager/GlobalDefaults.cfc
component {

    property name="myCustomArchiveService" inject="myCustomArchiveService";
    property name="batchOperationService"  inject="datamanagerBatchOperationService";
    property name="threadUtil"             inject="threadUtil";
    property name="messageBox"             inject="messagebox@cbmessagebox";

    private array function multiRecordAction( event, rc, prc, args={} ) {
        var objectName   = args.objectName ?: "";
        var action       = args.action     ?: "";
        var ids          = args.ids        ?: [];
        var batchAll     = IsTrue( args.batchAll ?: "" );
        var batchSrcArgs = args.batchSrcArgs ?: {};

        if ( args.action == "archive" ) {
            if ( !batchAll ) {
                myCustomArchiveService.archiveRecords( objectName=objectName, ids=ids );
                messageBox.info( "Archive success message here.." );
                setNextEvent( url=event.buildAdminLink( objectName=objectName ) );               
            }

            // batch all, let's do in a bg thread
            // first, queue the batch operation using the "batchSrcArgs"
            var queueId = batchOperationService.queueBatchOperation( objectName, batchSrcArgs );

            // next, create adhoc task
            var taskId = createTask(
                  event                = "admin.datamanager.globaldefaults.batchArchiveInBgThread"
                , runNow               = true
                , adminOwner           = event.getAdminUserId()
                , title                = "cms:datamanager.batcharchive.task.title"
                , returnUrl            = event.buildAdminLink( objectName=objectName, operation="listing" )
                , discardAfterInterval = CreateTimeSpan( 0, 0, 5, 0 )
                , args       = {
                      objectName   = objectName
                    , batchQueueId = queueId
                }
            );

            // finally, redirect to the task progress screen to allow user to watch progress
            setNextEvent( url=event.buildAdminLink(
                  linkTo      = "adhoctaskmanager.progress"
                , queryString = "taskId=" & taskId
            ) );
        }

        // otherwise, do nothing, core will process the multi action
        // submission
    }


    /**
     * Implementation of background thread batch archive using batch operation queue
     *
     */
    private boolean function batchArchiveInBgThread( event, rc, prc, args={}, logger, progress ) {
        var objectName        = args.objectName ?: "";
        var queueId           = args.batchQueueId ?: "";
        var canLog            = StructkeyExists( arguments, "logger" );
        var canInfo           = canLog && arguments.logger.canInfo();
        var canWarn           = canLog && arguments.logger.canWarn();
        var canReportProgress = StructKeyExists( arguments, "progress" );
        var queueSize         = canReportProgress ? batchOperationService.getBatchOperationQueueSize( queueId ) : 0;
        var processed         = 0;
        var ids               = [];
        
        do {
            ids = batchOperationService.getNextBatchRecordsFromQueue(
                  queueId          = queueId
                , maxRows          = 100  // default
                , clearImmediately = true // default
            );

            if ( !ArrayLen( ids ) ) {
                break;
            }

            if ( threadUtil.isInterrupted() ) {
                batchOperationService.clearBatchOperationQueue( queueId );
                if ( canWarn ) {
                    arguments.logger.warn( "Batch operation was cancelled or interrupted. Safely quitting..." );
                }
                return false;
            }

            myCustomArchiveService.archiveRecords( objectName=objectName, ids=ids );

            if ( canReportProgress ) {
                processed += ArrayLen( ids );
                arguments.progress.setProgress( Int( ( 100 / queueSize ) * processed ) );
            }

            if ( canInfo ) {
                arguments.logger.info( "Archived [#ArrayLen( ids )#] records. Next..." );
            }

        } while( ArrayLen( ids ) == 100 )
        
        return true;
    }

}
```---
id: datamanager-customization-geteditrecordformname
title: "Data Manager customization: getEditRecordFormName"
---

## Data Manager customization: getEditRecordFormName

The `getEditRecordFormName` customization allows you to use a different form name than the Data Manager default for editing records. The method should return the form name (see [[presideforms]]) and is provided `args.objectName` should you need to use it. For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function getEditRecordFormName( event, rc, prc, args={} ) {
		return "admin.blogs.editblog";
	}

}
```

---
id: datamanager-customization-prerenderclonerecordform
title: "Data Manager customization: preRenderCloneRecordForm"
---

## Data Manager customization: preRenderCloneRecordForm

The `preRenderCloneRecordForm` customization allows you to add rendered HTML _before_ the rendering of the core clone record form. The HTML will live _inside_ the html `<form>` tags, so that you are able to add form fields into the form.

The handler is expected to return a string that is the rendered HTML and is provided the following in the `args` struct:

* `objectName`: The name of the object
* `recordId`: The ID of the record being cloneed
* `record`: Struct of the record being cloneed
* `cloneRecordAction`: URL for submitting the form
* `draftsEnabled`: Whether or not drafts are enabled
* `canSaveDraft`: Whether or not the current user can save drafts (for drafts only)
* `canPublish`: Whether or not the current user can publish (for drafts only)
* `cancelAction`: URL that any rendered 'cancel' link should use

For example:


```luceescript
// /application/handlers/admin/datamanager/faq.cfc

component {

	private string function preRenderCloneRecordForm( event, rc, prc, args={} ) {
		return '<p class="alert alert-warning">Remember: double check existing records before adding a new FAQ.</p>';
	}

}
```

See also: [[datamanager-customization-postrenderclonerecordform|postRenderCloneRecordForm]]

---
id: datamanager-customization-gettoprightbuttonsforaddrecord
title: "Data Manager customization: getTopRightButtonsForAddRecord"
---

## Data Manager customization: getTopRightButtonsForAddRecord

The `getTopRightButtonsForAddRecord` customization allows you to _completely override_ the set of buttons that appears at the top right hand side of the add record screen. It must _return an array_ of structs that describe the buttons to display and is provided the `objectName` in the `args` struct.

Note, if you simply want to add, or tweak, the top right buttons, you may wish to use [[datamanager-customization-extratoprightbuttonsforaddrecord]].

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private array function getTopRightButtonsForAddRecord( event, rc, prc, args={} ) {
		var actions    = [];
		var objectName = args.objectName ?: "";

		actions.append({
			  link      = event.buildAdminLink( objectName=objectName, operation="reports" )
			, btnClass  = "btn-default"
			, iconClass = "fa-bar-chart"
			, globalKey = "r"
			, title     = translateResource( "preside-objects.blog:reports.btn" )
		} );

		return actions;
	}

}
```

>>> See [[datamanager-customization-toprightbuttonsformat]] for detailed documentation on the format of the action items.

---
id: datamanager-customization-preclonerecordaction
title: "Data Manager customization: preCloneRecordAction"
---

## Data Manager customization: preCloneRecordAction

The `preCloneRecordAction` customization allows you to run logic _before_ the core Data Manager clone record logic is run. It is not expected to return a value and is supplied the following in the `args` struct:

* `objectName`: name of the object
* `formData`: struct containing the form submission
* `existingRecord`: struct containing the data from the current record
* `validationResult`: validation result from general form validation

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	property name="blogService" inject="blogService";

	private void function preCloneRecordAction( event, rc, prc, args={} ) {
		rc.clearance_level = blogService.calculateClearanceLevel( argumentCollection=args.formData ?: {} );
	}
}

```

See also: [[datamanager-customization-postclonerecordaction|postCloneRecordAction]] and [[datamanager-customization-clonerecordaction|cloneRecordAction]].


---
id: datamanager-customization-builddataexportconfigmodallink
title: "Data Manager customization: buildDataExportConfigModalLink"
---

## Data Manager customization: buildDataExportConfigModalLink

The `buildDataExportConfigModalLink` customization allows you to customize the ajax URL used to fetch the data export config form for an object. It is expected to return the URL as a string and is provided the `objectName` in the `args` struct along with any other arguments passed to `event.buildAdminLink()`. e.g.

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function buildDataExportConfigModalLink( event, rc, prc, args={} ) {
		var queryString = args.queryString ?: "";

		return event.buildAdminLink( linkto="admin.blogmanager.exportConfigModal", queryString=queryString );
	}

}
```

---
id: datamanager-customization-predeleterecordaction
title: "Data Manager customization: preDeleteRecordAction"
---

## Data Manager customization: preDeleteRecordAction

The `preDeleteRecordAction` customization allows you to run logic _before_ the core Data Manager delete record(s) logic is run. It is not expected to return a value and is supplied the following in the `args` struct:

* `object`: name of the object
* `records`: query containing the records that will be deleted

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	property name="blogService" inject="blogService";

	private void function preDeleteRecordAction( event, rc, prc, args={} ) {
		var records = args.records ?: QueryNew('');

		for( var record in records ) {
			blogService.moveRecordToRecycleBinTable( record.id );
		}
	}
}

```

See also: [[datamanager-customization-postdeleterecordaction|postDeleteRecordAction]] and [[datamanager-customization-deleterecordaction|deleteRecordAction]].




---
id: datamanager-customization-postrenderaddrecordform
title: "Data Manager customization: postRenderAddRecordForm"
---

## Data Manager customization: postRenderAddRecordForm

The `postRenderAddRecordForm` customization allows you to add rendered HTML _after_ the rendering of the core add record form. The HTML will live _inside_ the html `<form>` tags, so that you are able to add form fields into the form.

The handler is provided with `args.objectName` and is expected to return a string that is the rendered HTML. For example:


```luceescript
// /application/handlers/admin/datamanager/faq.cfc

component {

	private string function postRenderAddRecordForm( event, rc, prc, args={} ) {
		return '<p class="alert alert-warning">Before hitting submit, below - triple-chek your speling and grama!</p>';
	}

}
```

See also: [[datamanager-customization-prerenderaddrecordform|preRenderAddRecordForm]]
---
id: datamanager-customization-posteditrecordaction
title: "Data Manager customization: postEditRecordAction"
---

## Data Manager customization: postEditRecordAction

The `postEditRecordAction` customization allows you to run logic _after_ the core Data Manager edit record logic is run. It is not expected to return a value and is supplied the following in the `args` struct:

* `objectName`: name of the object
* `formData`: struct containing the form submission
* `existingRecord`: struct containing the data from the current record
* `validationResult`: validation result from general form validation


For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private void function postEditRecordAction( event, rc, prc, args={} ) {
		// redirect to a different than default page
		setNextEvent( event.buildAdminLink(
			  objectName = "blog"
			, recordId   = ( args.formData.id ?: "" )
			, operation  = "preview"
		) );
	}
}
```

See also: [[datamanager-customization-preeditrecordaction|preEditRecordAction]] and [[datamanager-customization-editrecordaction|editRecordAction]].

---
id: datamanager-customization-postrendereditrecordform
title: "Data Manager customization: postRenderEditRecordForm"
---

## Data Manager customization: postRenderEditRecordForm

The `postRenderEditRecordForm` customization allows you to add rendered HTML _after_ the rendering of the core edit record form. The HTML will live _inside_ the html `<form>` tags, so that you are able to add form fields into the form.

The handler is expected to return a string that is the rendered HTML and is provided the following in the `args` struct:

* `objectName`: The name of the object
* `recordId`: The ID of the record being edited
* `record`: Struct of the record being edited
* `editRecordAction`: URL for submitting the form
* `useVersioning`: Whether or not to use versioning
* `version`: Version number (for versioning only) of the record in `args.record`
* `draftsEnabled`: Whether or not drafts are enabled
* `canSaveDraft`: Whether or not the current user can save drafts (for drafts only)
* `canPublish`: Whether or not the current user can publish (for drafts only)
* `cancelAction`: URL that any rendered 'cancel' link should use

For example:

```luceescript
// /application/handlers/admin/datamanager/faq.cfc

component {

	private string function postRenderEditRecordForm( event, rc, prc, args={} ) {
		return '<p class="alert alert-warning">Before hitting submit, below - triple-chek your speling and grama!</p>';
	}

}
```

See also: [[datamanager-customization-prerenderaddrecordform|preRenderAddRecordForm]]

---
id: datamanager-customization-buildmanagepermslink
title: "Data Manager customization: buildManagePermsLink"
---

## Data Manager customization: buildManagePermsLink

The `buildManagePermsLink` customization allows you to customize the link for the manage permissions screen for an object. It is expected to return the URL as a string and is provided the `objectName` in the `args` struct along with any other arguments passed to `event.buildAdminLink()`. e.g.

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function buildManagePermsLink( event, rc, prc, args={} ) {
		var queryString = args.queryString ?: "";

		return event.buildAdminLink( linkto="admin.blogmanager.manageperms", queryString=queryString );
	}

}
```

---
id: datamanager-customization-buildeditrecordactionlink
title: "Data Manager customization: buildEditRecordActionLink"
---

## Data Manager customization: buildEditRecordActionLink

The `buildEditRecordActionLink` customization allows you to customize the URL used to submit the edit record form. It is expected to return the action URL as a string and is provided the `objectName` in the `args` struct along with any other arguments passed to `event.buildAdminLink()` (the record ID is expected to be posted with the form). e.g.

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function buildEditRecordActionLink( event, rc, prc, args={} ) {
		var queryString = args.queryString ?: "";

		return event.buildAdminLink( linkto="admin.blogmanager.editRecordAction", queryString=queryString );
	}

}
```
---
id: datamanager-customization-postdeleterecordaction
title: "Data Manager customization: postDeleteRecordAction"
---

## Data Manager customization: postDeleteRecordAction

The `postDeleteRecordAction` customization allows you to run logic _after_ the core Data Manager delete record(s) logic is run. It is not expected to return a value and is supplied the following in the `args` struct:

* `object`: name of the object
* `records`: query containing the records that were deleted

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private void function postDeleteRecordAction( event, rc, prc, args={} ) {
		// redirect to a different than default page
		setNextEvent( url=event.buildAdminLink(
			  objectName = "blog"
			, operation  = "postDeleteWarning"
		), persistStruct=args );
	}
	
}
```

See also: [[datamanager-customization-predeleterecordaction|preDeleteRecordAction]] and [[datamanager-customization-deleterecordaction|deleteRecordAction]].


---
id: datamanager-customization-addrecordaction
title: "Data Manager customization: addRecordAction"
---

## Data Manager customization: addRecordAction

The `addRecordAction` allows you to override the core action logic for adding a record when a form is submitted. The core will have already checked permissions for adding records, but all other logic will be up to you to implement (including audit trails, validation, etc.).

The method is not expected to return a value and is provided with `args.objectName`. _The expectation is that the method will redirect the user after processing the request._

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	property name="blogService" inject="blogService";

	private void function addRecordAction( event, rc, prc, args={} ) {
		var formName         = "my.custom.addrecord.form";
		var formData         = event.getDataForForm( formName );
		var validationResult = validateForm( formName, formData );

		if ( validationResult.validated ) {
			var newRecordId = blogService.addBlog( argumentCollection=formData );

			setNextEvent( url=event.buildAdminLink(
				  objectName = "blog"
				, recordId   = newRecordId
			) );
		}

		var persist = formData;
		persist.validationResult = validationResult;

		setNextEvent( url=event.buildAdminLink(
			  objectName = "blog"
			, operation  = "addRecord"
		), persistStruct=persist );

	}

}


```

>>> If you wish to still use core logic for adding records but need to add additional logic to the process, use [[datamanager-customization-preAddRecordAction|preAddRecordAction]] or [[datamanager-customization-postaddrecordaction|postAddRecordAction]] instead.---
id: datamanager-customization-prerenderrecord
title: "Data Manager customization: preRenderRecord"
---

## Data Manager customization: preRenderRecord

The `preRenderRecord` customization allows you to add additional HTML above the core rendering of a view record screen for an object. The action is expected to return a string containing the HTML and is provided the following in the `args` struct:

* `objectName`: The object name
* `recordId`: ID of the record
* `version`: Version number of the record (if the object is versioned)

>>>>>> You can also make use of variables in the `prc` scope, such as `prc.record`, that will allow you to potentially not duplicate calls to the database.

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function preRenderRecord() {
		args.blog = prc.record ?: QueryNew('');

		return renderView( view="/admin/blogs/viewRecordHeader", args=args );
	}

}
```

See also: [[datamanager-customization-postrenderrecord|postRenderRecord]].


---
id: datamanager-customization-extratoprightbuttonsforviewrecord
title: "Data Manager customization: extraTopRightButtonsForViewRecord"
---

## Data Manager customization: extraTopRightButtonsForViewRecord

The `extraTopRightButtonsForViewRecord` customization allows you to add to, or modify, the set of buttons that appears at the top right hand side of the view record screen. It is provided an `actions` array along with the `objectName` in the `args` struct and is not expected to return a value.

Modifying `args.actions` is required to make changes to the top right buttons.


>>> See [[datamanager-customization-toprightbuttonsformat]] for detailed documentation on the format of the action items.


For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private void function extraTopRightButtonsForViewRecord( event, rc, prc, args={} ) {
		var objectName = args.objectName ?: "";
		var recordId   = prc.recordId    ?: "";

		args.actions = args.actions ?: [];

		args.actions.append({
			  link      = event.buildAdminLink( objectName=objectName, operation="reports", recordId=recordId )
			, btnClass  = "btn-default"
			, iconClass = "fa-bar-chart"
			, globalKey = "r"
			, title     = translateResource( "preside-objects.blog:reports.btn" )
		} );
	}

}
```

---
id: datamanager-customization-toprightbuttons
title: "Data Manager customization: topRightButtons"
---

## Data Manager customization: topRightButtons

The `topRightButtons` customization allows you to completely customize the logic that outputs top right buttons for _all_ data manager admin pages for your object. It should return the rendered HTML of the buttons and receives the following in the `args` struct:

* `objectName`: the name of the object
* `action`: the current coldbox action, e.g. `editRecord`, `viewRecord`, `object`, etc.


For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function topRightButtons( event, rc, prc, args={} ) {
		switch( args.action ?: "" ) {
			case "object":
			case "viewrecord":
			case "editrecord":
				return renderViewlet( "blogmanager.topRightButtonsFor#args.action#" );
		}
		
		return "";
	}
}
```---
id: datamanager-customization-actionbuttons
title: "Reference: Data Manager action buttons array for add and edit forms"
---

## Reference: Data Manager action buttons array for add and edit forms

The add and edit record forms allow you modify the action button set that appear beneath the form. These modififications expect to either return an array of structs and/or strings, or are passed this array of structs/strings for modification / appending to.

### Keys

Each "action" struct can/must have the following keys:

* `type` _(required)_: Must be either 'link' or 'button'
* `label` _(required)_: Label to show on the button
* `href` _(optional)_: Required  when `type=link` - href of the link
* `name` _(optional)_: For `type=button` only. Name of the field that is sent with the form submission.
* `value` _(optional)_: For `type=button` only. Value of the field that is sent with the form submission.
* `class` _(optional)_: Twitter bootstrap button class for the button. e.g. `btn-info`, `btn-warning`, `btn-success`, `btn-danger`, etc.
* `iconClass` _(optional)_: Font awesome icon class to use. Icon will be displayed before the label on the button.
* `globalKey` _(optional)_: Global keyboard key shortcut for the button.

>>> Note: alternatively, a button in the array can be a fully rendered string representing the button (should you require something a bit different)

### Examples

A link button

```luceescript
{
      type      = "link"
    , href      = event.buildAdminLink( objectName=objectName, operation="preview" )
    , class     = "btn-info"
    , label     = translateResource( "preside-objects.blog:preview.btn" )
    , iconClass = "fa-eye"
}
```

A regular button:

```luceescript
{
      type      = "button"
    , name      = "_postAction"
    , value     = "saveDraftAndPreview"
    , class     = "btn-info"
    , label     = translateResource( "preside-objects.blog:preview.btn" )
    , iconClass = "fa-eye"
}
```---
id: datamanager-customization-postaddrecordaction
title: "Data Manager customization: postAddRecordAction"
---

## Data Manager customization: postAddRecordAction

The `postAddRecordAction` customization allows you to run logic _after_ the core Data Manager add record logic is run. It is not expected to return a value and is supplied the following in the `args` struct:

* `objectName`: name of the object
* `formData`: struct containing the form submission
* `newId`: ID of the newly created record


For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private void function postAddRecordAction( event, rc, prc, args={} ) {
		var newId = args.newId ?: "";

		// redirect to a different than default page
		setNextEvent( url=event.buildAdminLink(
			  objectName = "blog"
			, recordId   = newId
			, operation  = "preview"
		) );
	}
}
```

See also: [[datamanager-customization-preaddrecordaction|pre	AddRecordAction]] and [[datamanager-customization-addrecordaction|addRecordAction]].


---
id: datamanager-customization-buildajaxlistinglink
title: "Data Manager customization: buildAjaxListingLink"
---

## Data Manager customization: buildAjaxListingLink

The `buildAjaxListingLink` customization allows you to customize the URL used to fetch records via ajax to be displayed in the listing screen. It is expected to return the URL as a string and is provided the `objectName` in the `args` struct along with any other arguments passed to `event.buildAdminLink()`. e.g.

>>> You may also wish to look at [[datamanager-customization-getadditionalquerystringforbuildajaxlistinglink]] should you simply wish to add some query parameters to the core URL.

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function buildAjaxListingLink( event, rc, prc, args={} ) {
		var queryString = args.queryString ?: "";

		return event.buildAdminLink( linkto="admin.blogmanager.ajaxRecordsForDataTable", queryString=queryString );
	}

}
```

---
id: datamanager-customization-postrenderlisting
title: "Data Manager customization: postRenderListing"
---

## Data Manager customization: postRenderListing

The `postRenderListing` customization allows you to add your own output _below_ the default object listing screen.

The customization handler should return a string of the rendered viewlet and is supplied an args structure with an `objectName` key.

For example:

```luceescript
// /application/handlers/admin/datamanager/sensitive_data.cfc
component {

	private string function postRenderListing( event, rc, prc, args={} ) {
		return '<p class="alert alert-success">Tip: use this listing with extreme caution.</p>';
	}

}
```

---
id: datamanager-customization-getextralistingmultiactions
title: "Data Manager customization: getExtraListingMultiActions"
---

## Data Manager customization: getExtraListingMultiActions

The `getExtraListingMultiActions` customization allows you to modify the array of buttons that gets rendered as part of the listing screen (displayed when a user selects rows from the grid). It is expected _not_ to return a value and receives the following in the `args` struct:

* `objectName`: The name of the object
* `actions`: the array of button "actions"


Items in the array should match button definitions as defined in [[datamanager-customization-multi-action-buttons]].

Also note, that you can use the [[datamanager-customization-multirecordaction|multiRecordAction]] to process any custom actions that you add.

For example:


```luceescript
// /application/handlers/admin/datamanager/GlobalDefaults.cfc
component {

    private void function getExtraListingMultiActions( event, rc, prc, args={} ) {
        args.actions = args.actions ?: [];
        args.actions.append( {
              label     = "Archive selected entities"
            , name      = "archive"
            , prompt    = "Archive the selected entities"
            , class     = "btn-danger"
            , iconClass = "fa-clock-o"
        } );
    }

}
```
---
id: datamanager-customization-gettoprightbuttonsforobject
title: "Data Manager customization: getTopRightButtonsForObject"
---

## Data Manager customization: getTopRightButtonsForObject

The `getTopRightButtonsForObject` customization allows you to _completely override_ the set of buttons that appears at the top right hand side of the record listing screen. It must _return an array_ of structs that describe the buttons to display and is provided the `objectName` in the `args` struct.

Note, if you simply want to add, or tweak, the top right buttons, you may wish to use [[datamanager-customization-extratoprightbuttonsforobject]].

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private array function getTopRightButtonsForObject( event, rc, prc, args={} ) {
		var actions    = [];
		var objectName = args.objectName ?: "";

		actions.append({
			  link      = event.buildAdminLink( objectName=objectName, operation="reports" )
			, btnClass  = "btn-default"
			, iconClass = "fa-bar-chart"
			, globalKey = "r"
			, title     = translateResource( "preside-objects.blog:reports.btn" )
		} );

		return actions;
	}

}
```

>>> See [[datamanager-customization-toprightbuttonsformat]] for detailed documentation on the format of the action items.---
id: datamanager-customization-getextraclonerecordactionbuttons
title: "Data Manager customization: getExtraCloneRecordActionButtons"
---

## Data Manager customization: getExtraCloneRecordActionButtons

The `getExtraCloneRecordActionButtons` customization allows you to modify the set of buttons and links that appears below the clone record form. It is expected _not_ to return a value and receives the following in the `args` struct:

* `objectName`: The name of the object
* `recordId`: The id of the current record
* `actions`: the array of button "actions"

Note, if you want to completely override the buttons, you may wish to use [[datamanager-customization-getclonerecordactionbuttons]].

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private array function getExtraCloneRecordActionButtons( event, rc, prc, args={} ) {
		var actions = args.actions ?: [];

		actions.append({
			  type      = "button"
			, class     = "btn-plus"
			, iconClass = "fa-save"
			, name      = "_saveAction"
			, value     = "publishAndClone"
			, label     = translateResource( uri="cms:presideobjects.blog:clonerecord.and.clone.btn", data=[ prc.objectTitle ?: "" ] )
		} );
	}

}
```

>>> See [[datamanager-customization-actionbuttons]] for detailed documentation on the format of the action items.

---
id: datamanager-customization-prerenderrecordleftcol
title: "Data Manager customization: preRenderRecordLeftCol"
---

## Data Manager customization: preRenderRecordLeftCol

The `preRenderRecordLeftCol` customization allows you to add custom HTML _above_ the left-hand column of the core view record screen for your object (see [[adminrecordviews]]). The action is expected to return a string containing the HTML and is provided the following in the `args` struct:

* `objectName`: The object name
* `recordId`: ID of the record
* `version`: Version number of the record (if the object is versioned)

>>>>>> You can also make use of variables in the `prc` scope, such as `prc.record`, that will allow you to potentially not duplicate calls to the database.

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function preRenderRecordLeftCol() {
		args.blog = prc.record ?: QueryNew('');

		return renderView( view="/admin/blogs/auditTrail", args=args );
	}

}
```
---
id: datamanager-customization-extratoprightbuttons
title: "Data Manager customization: extraTopRightButtons"
---

## Data Manager customization: extraTopRightButtons

The `extraTopRightButtons` customization allows you to run additional button logic for _all_ data manager pages. For example, you may wish to always add a 'reports' button. It is expected _not_ to return a value and receives the following in the `args` struct:

* `objectName`: The name of the object
* `action`: the current coldbox action, e.g. `editRecord`, `viewRecord`, `
* `actions`: the array of button "actions"

Modifying `args.actions` is required to make changes to the top right buttons.

>>> See [[datamanager-customization-toprightbuttonsformat]] for detailed documentation on the format of the action items.

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private void function extraTopRightButtons( event, rc, prc, args={} ) {
		var action = args.action ?: "";
		var actionsWithButtons = [ "editRecord", "viewRecord" ];

		if ( actionsWithButtons.findNoCase( action ) ) {
			args.actions = args.actions ?: [];
			args.actions.append({
				  link      = event.buildAdminLink( objectName="blog", operation="reports" )
				, btnClass  = "btn-default"
				, iconClass = "fa-bar-chart"
				, globalKey = "r"
				, title     = translateResource( "preside-objects.blog:reports.btn" )
			} );
		}
	}

}
```

---
id: datamanager-customization-extratoprightbuttonsforeditrecord
title: "Data Manager customization: extraTopRightButtonsForEditRecord"
---

## Data Manager customization: extraTopRightButtonsForEditRecord

The `extraTopRightButtonsForEditRecord` customization allows you to add to, or modify, the set of buttons that appears at the top right hand side of the edit record screen. It is provided an `actions` array along with the `objectName` in the `args` struct and is not expected to return a value.

Modifying `args.actions` is required to make changes to the top right buttons.


>>> See [[datamanager-customization-toprightbuttonsformat]] for detailed documentation on the format of the action items.


For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private void function extraTopRightButtonsForEditRecord( event, rc, prc, args={} ) {
		var objectName = args.objectName ?: "";
		var recordId   = prc.recordId    ?: "";

		args.actions = args.actions ?: [];

		args.actions.append({
			  link      = event.buildAdminLink( objectName=objectName, operation="reports", recordId=recordId )
			, btnClass  = "btn-default"
			, iconClass = "fa-bar-chart"
			, globalKey = "r"
			, title     = translateResource( "preside-objects.blog:reports.btn" )
		} );
	}

}
```


---
id: datamanager-customization-addrecordactionbuttons
title: "Data Manager customization: addRecordActionButtons"
---

## Data Manager customization: addRecordActionButtons

The `addRecordActionButtons` customization allows you to completely override the form action buttons (e.g. "Cancel", "Add record") for the add record form. The handler should return the rendered HTML for the buttons and will be supplied `args.objectName` in the `args` struct.


For example:


```luceescript
// /application/handlers/admin/datamanager/GlobalDefaults.cfc
component {

	private string function addRecordActionButtons( event, rc, prc, args={} ) {
		var objectName = args.objectName ?: "";
		
		args.cancelAction = event.buildAdminLink( objectName=objectName );

		return renderView( view="/admin/datamanager/globaldefaults/addRecordActionButtons", args=args );
	}

}
```

```lucee
<!--- /application/views/admin/datamanager/globaldefaults/addRecordActionButtons.cfm --->

<cfoutput>
	<div class="col-md-offset-2">
		<a href="#args.cancelAction#" class="btn btn-default" data-global-key="c">
			<i class="fa fa-reply bigger-110"></i>
			Cancel
		</a>
		
		<button type="submit" class="btn btn-info" tabindex="#getNextTabIndex()#">
				<i class="fa fa-save bigger-110"></i> Add record
		</button>
	</div>
</cfoutput>
```

>>>> The core implementation has logic for showing different buttons for drafts and dynamically building labels for buttons, etc. Be sure to know what you're missing out on when overriding this (or any) customization!
---
id: datamanager-customization-recordbreadcrumb
title: "Data Manager customization: recordBreadcrumb"
---

## Data Manager customization: recordBreadcrumb

The `recordBreadcrumb` customization allows you to override what happens for the breadcrumb that represents a record. This defaults to a title that is the record label, and a link that goes to the view or edit page for the object (depending on permissions and what operations are available). For example:

```luceescript
// /application/handlers/admin/datamanager/blog_post.cfc

component {

	private string function recordBreadcrumb() {
		var recordLabel = prc.recordLabel ?: "";
		var recordId    = prc.recordId    ?: "";
		var record      = prc.record      ?: {};

		if ( IsTrue( record.special ?: "" ) ) {
			event.addAdminBreadCrumb( 
				  title = recordLabel
				, link  = event.buildAdminLink( objectName="blog_post", recordId=recordId, operation="specialview" )
			);
		} else {
			event.addAdminBreadCrumb( 
				  title = recordLabel
				, link  = event.buildAdminLink( objectName="blog_post", recordId=recordId )
			);
		}
	}
	
}
```---
id: datamanager-customization-editrecordaction
title: "Data Manager customization: editRecordAction"
---

## Data Manager customization: editRecordAction

The `editRecordAction` allows you to override the core action logic for adding a record when a form is submitted. The core will have already checked permissions for editing records, but all other logic will be up to you to implement (including audit trails, validation, etc.).

The method is not expected to return a value and is provided with `args.objectName` and `args.recordId`. _The expectation is that the method will redirect the user after processing the request._

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	property name="blogService" inject="blogService";

	private void function editRecordAction( event, rc, prc, args={} ) {
		var formName         = "my.custom.editrecord.form";
		var recordId         = args.recordId ?: "";
		var formData         = event.getDataForForm( formName );
		var validationResult = validateForm( formName, formData );

		if ( validationResult.validated ) {
			blogService.saveBlog( argumentCollection=formData, id=recordId );

			setNextEvent( url=event.buildAdminLink(
				  objectName = "blog"
				, recordId   = recordId
			) );
		}

		var persist = formData;
		persist.validationResult = validationResult;

		setNextEvent( url=event.buildAdminLink(
			  objectName = "blog"
			, operation  = "editRecord"
			, recordId   = recordId
		), persistStruct=persist );

	}

}


```

>>> If you wish to still use core logic for editing records but need to add additional logic to the process, use [[datamanager-customization-preeditrecordaction|preEditRecordAction]] or [[datamanager-customization-posteditrecordaction|postEditRecordAction]] instead.

---
id: datamanager-customization-versionnavigator
title: "Data Manager customization: versionNavigator"
---

## Data Manager customization: versionNavigator

The `versionNavigator` customization allows you to override the 'version navigator' that shows at the top of view, edit and translate record screens. The customization is expected to return the rendered HTML of the navigator and is provided the following in the `args` struct:

* `object`: The object name
* `id`: The current record ID
* `version`: The current version number
* `isDraft`: Whether or not the current version is a draft
* `baseUrl`: The "base" URL for version navigation. This URL will have the token `{version}` in the string and this should be replaced with the previous/next version numbers when building version navigation links

For example:

```luceescript
// /application/handlers/admin/datamanager/GlobalCustomizations.cfc

component {

	property name="versioningService"    inject="versioningService";
	property name="presideObjectService" inject="presideObjectService";

	private void function versionNavigator( event, rc, prc, args={} ) {
		var selectedVersion = Val( args.version ?: "" );
		var objectName      = args.object ?: "";
		var id              = args.id     ?: "";

		args.latestVersion          = versioningService.getLatestVersionNumber( objectName=objectName, recordId=id );
		args.latestPublishedVersion = versioningService.getLatestVersionNumber( objectName=objectName, recordId=id, publishedOnly=true );
		args.versions               = presideObjectService.getRecordVersions(
			  objectName = objectName
			, id         = id
		);

		if ( !selectedVersion ) {
			selectedVersion = args.latestVersion;
		}

		args.isLatest    = args.latestVersion == selectedVersion;
		args.nextVersion = 0;
		args.prevVersion = args.versions.recordCount < 2 ? 0 : args.versions._version_number[ args.versions.recordCount-1 ];

		for( var i=1; i <= args.versions.recordCount; i++ ){
			if ( args.versions._version_number[i] == selectedVersion ) {
				args.nextVersion = i > 1 ? args.versions._version_number[i-1] : 0;
				args.prevVersion = i < args.versions.recordCount ? args.versions._version_number[i+1] : 0;
			}
		}

		return renderView( view="/admin/datamanager/globalcustomizations/versionNavigator", args=args );
	}

}
```

---
id: datamanager-customization-addrecordform
title: "Data Manager customization: addRecordForm"
---

## Data Manager customization: addRecordForm

The `addRecordForm` customization allows you to completely overwrite the view for rendering the add record form page. The crumb trail, permissions checks and page title will be taken care of, but the rest is up to you.

The handler should return a string (the rendered add record form page) and expects `objectName` in the passed `args` struct. For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc
component {

	private string function addRecordForm( event, rc, prc, args={} ) {
		return renderView( view="/admin/my/custom/addrecordForm", args=args );
	}

}
```

---
id: datamanager-customization-preQuickAddrecordaction
title: "Data Manager customization: preQuickAddRecordAction"
---

## Data Manager customization: preQuickAddRecordAction

The `preQuickAddRecordAction` customization allows you to run logic _before_ the core Data Manager Add record logic is run. It is not expected to return a value and is supplied the following in the `args` struct:

* `objectName`: name of the object
* `formData`: struct containing the form submission

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	property name="blogService" inject="blogService";

	private void function preQuickAddRecordAction( event, rc, prc, args={} ) {
		rc.clearance_level = blogService.calculateClearanceLevel( argumentCollection=args.formData ?: {} );
	}
}

```

See also: [[datamanager-customization-postquickaddrecordaction|postQuickAddRecordAction]] and [[datamanager-customization-quickaddrecordaction|quickAddRecordAction]].


---
id: datamanager-customization-geteditrecordactionbuttons
title: "Data Manager customization: getEditRecordActionButtons"
---

## Data Manager customization: getEditRecordActionButtons

The `getEditRecordActionButtons` customization allows you to _completely override_ the set of buttons and links that appears below the edit record form. It must _return an array_ of structs that describe the buttons to display and is provided `objectName` and `recordId` in the `args` struct.

Note, if you simply want to add, or tweak, the buttons, you may wish to use [[datamanager-customization-getextraeditrecordactionbuttons]].

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private array function getEditRecordActionButtons( event, rc, prc, args={} ) {
		var actions = [{
			  type      = "link"
			, href      = event.buildAdminLink( objectName="blog" )
			, class     = "btn-default"
			, globalKey = "c"
			, iconClass = "fa-reply"
			, label     = translateResource( uri="cms:cancel.btn" )
		}];

		actions.append({
			  type      = "button"
			, class     = "btn-info"
			, iconClass = "fa-save"
			, name      = "_saveAction"
			, value     = "publish"
			, label     = translateResource( uri="cms:datamanager.addrecord.btn", data=[ prc.objectTitle ?: "" ] )
		} );

		actions.append({
			  type      = "button"
			, class     = "btn-plus"
			, iconClass = "fa-save"
			, name      = "_saveAction"
			, value     = "publishAndEdit"
			, label     = translateResource( uri="cms:presideobjects.blog:addrecord.and.edit.btn", data=[ prc.objectTitle ?: "" ] )
		} );

		return actions;
	}

}
```

>>> See [[datamanager-customization-actionbuttons]] for detailed documentation on the format of the action items.

---
id: datamanager-customization-getadditionalquerystringforbuildajaxlistinglink
title: "Data Manager customization: getAdditionalQueryStringForBuildAjaxListingLink"
---

## Data Manager customization: getAdditionalQueryStringForBuildAjaxListingLink

The `getAdditionalQueryStringForBuildAjaxListingLink` customization allows you to supply extra query string parameters to the AJAX URL endpoint that fetches records for an object's record listing screen. It must return a string representing the additional query string parameters and takes the `objectName` in the `args` struct.

You may wish to do this so that you can provide extra filters on the results using the [[datamanager-customization-prefetchrecordsforgridlisting|preFetchRecordsForGridListing]] customization, for example.

e.g.

```luceescript
// /application/handlers/admin/datamanager/blog_post.cfc
component {

	// this is run when building the ajax link, i.e. in the main
	// request for the listing page
	private string function getAdditionalQueryStringForBuildAjaxListingLink( event, rc, prc, args={} ) {
		// category here could have been placed in the URL
		// by a category drop down button, for example
		
		var category = rc.category ?: "";

		return "category=#category#";
	}


	// this is run during the ajax fetch of records
	private void function preFetchRecordsForGridListing( event, rc, prc, args={} ) {
		var category = rc.category ?: "";

		if ( !IsEmpty( category ) ) {
			args.extraFilters = args.extraFilters ?: [];
			
			args.extraFilters.append( { filter={ category=category } } );		
		}

	}

}
```
---
id: datamanager-customization-rootbreadcrumb
title: "Data Manager customization: rootBreadcrumb"
---

## Data Manager customization: rootBreadcrumb

The `rootBreadcrumb` customization allows you to override what happens for the "root" breadcrumb of an object. The default core behaviour for this is to add a "Data manager" link for any objects that are managed in the Data manager homepage. An alternative may be to build the crumbtrail of a parent object (think blog post / blog) so that the root breadcrumb for your object becomes something like: `Blogs > My Awesome blog` for a `blog_post` object. For example:

```luceescript
// /application/handlers/admin/datamanager/blog_post.cfc

component {

	private string function rootBreadcrumb() {
		var blogId          = prc.record.blog ?: ( rc.blogId ?: "" )
		var blogLabel       = renderLabel( "blog", blogId );
		var blogListingLink = event.buildAdminLink( objectName="blog" );

		if ( !Len( Trim( blogId ) ) || !Len( Trim( blogLabel ) ) ) {
			setNextEvent( url=blogListingLink );
		}

		blogLink  = event.buildAdminLink( objectName="blog", recordId=blogId );

		event.addAdminBreadCrumb( title="Blogs"  , link=blogListingLink );
		event.addAdminBreadCrumb( title=blogLabel, link=blogLink        );
	}
}
```

---
id: datamanager-customization-buildsortrecordslink
title: "Data Manager customization: buildSortRecordsLink"
---

## Data Manager customization: buildSortRecordsLink

The `buildSortRecordsLink` customization allows you to customize the link for the diplaying the sort records screen for an object. It is expected to return the URL as a string and is provided the `objectName` in the `args` struct along with any other arguments passed to `event.buildAdminLink()`. e.g.

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function buildSortRecordsLink( event, rc, prc, args={} ) {
		var queryString = args.queryString ?: "";

		return event.buildAdminLink( linkto="admin.blogmanager.sortblogs", queryString=queryString );
	}

}
```

---
id: datamanager-customization-preQuickAddRecordForm
title: "Data Manager customization: preQuickAddRecordForm"
---

## Data Manager customization: preQuickAddRecordForm

The `preQuickAddRecordForm` customization allows you to add javascript _before_ the rendering of the core edit record form.

For example:


```luceescript
// /application/handlers/admin/datamanager/faq.cfc

component {

	private void function preQuickAddRecordForm( event, rc, prc, args={} ) {
		event.include( assetId="/js/admin/specific/appointment/" );
	}

}
```

See also: [[datamanager-customization-quickaddrecordaction|quickAddRecordAction]]

---
id: datamanager-customization-builddeleterecordactionlink
title: "Data Manager customization: buildDeleteRecordActionLink"
---

## Data Manager customization: buildDeleteRecordActionLink

The `buildDeleteRecordActionLink` customization allows you to customize the URL for deleting an object's record. It is expected to return the URL as a string and is provided the `objectName` and `recordId` in the `args` struct along with any other arguments passed to `event.buildAdminLink()`. e.g.

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function buildDeleteRecordActionLink( event, rc, prc, args={} ) {
		var recordId    = args.recordId ?: "";
		var version     = Val( args.version ?: "" );
		var qs          = "id=" & recordId;

		if ( Len( Trim( args.queryString ?: "" ) ) {
			qs &= "&" & args.queryString;
		}

		return event.buildAdminLink( linkto="admin.blogmanager.deleteRecordAction", queryString=qs );
	}

}
```



---
id: datamanager-customization-multi-action-buttons
title: "Data Manager customization: Multi-action button definitions"
---

## Data Manager customization: Multi-action button definitions

The record listing screen allows you modify the action button set that appear beneath the listing table when a user selects one or more records in the table. See:

* [[datamanager-customization-listingmultiactions|listingMultiActions]]
* [[datamanager-customization-getlistingmultiactions|getListingMultiActions]]
* [[datamanager-customization-getextralistingmultiactions|getExtraListingMultiActions]]


These modififications expect to either return an array of structs and/or strings, or are passed this array of structs/strings for modification / appending to.

### Keys

Each "action" struct can/must have the following keys:

* `name` _(required)_: The name of the action
* `label` _(required)_: Label to show on the button
* `class` _(optional)_: Twitter bootstrap button class for the button. e.g. `btn-info`, `btn-warning`, `btn-success`, `btn-danger`, etc.
* `iconClass` _(optional)_: Font awesome icon class to use. Icon will be displayed before the label on the button.
* `globalKey` _(optional)_: Global keyboard key shortcut for the button.

>>> Note: alternatively, a button in the array can be a fully rendered string representing the button (should you require something a bit different)

### Example


```luceescript
{
      name      = "share"
    , class     = "btn-info"
    , label     = translateResource( "preside-objects.blog:preview.btn" )
    , iconClass = "fa-share"
    , globalKey = "s"
}
```---
id: datamanager-customization-preeditrecordaction
title: "Data Manager customization: preEditRecordAction"
---

## Data Manager customization: preEditRecordAction

The `preEditRecordAction` customization allows you to run logic _before_ the core Data Manager edit record logic is run. It is not expected to return a value and is supplied the following in the `args` struct:

* `objectName`: name of the object
* `formData`: struct containing the form submission
* `existingRecord`: struct containing the data from the current record
* `validationResult`: validation result from general form validation

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	property name="blogService" inject="blogService";

	private void function preEditRecordAction( event, rc, prc, args={} ) {
		rc.clearance_level = blogService.calculateClearanceLevel( argumentCollection=args.formData ?: {} );
	}
}

```

See also: [[datamanager-customization-posteditrecordaction|postEditRecordAction]] and [[datamanager-customization-editrecordaction|editRecordAction]].


---
id: datamanager-customization-clonerecordform
title: "Data Manager customization: cloneRecordForm"
---

## Data Manager customization: cloneRecordForm

The `cloneRecordForm` customization allows you to completely overwrite the view for rendering the clone record form page. The crumb trail, permissions checks and page title will be taken care of, but the rest is up to you.

The handler should return a string (the rendered clone record form page) and is provided the following in the `args` struct.

* `objectName`: The name of the object
* `recordId`: The ID of the record being cloneed
* `record`: Struct of the record being cloneed
* `cloneRecordAction`: URL for submitting the form
* `draftsEnabled`: Whether or not drafts are enabled
* `canSaveDraft`: Whether or not the current user can save drafts (for drafts only)
* `canPublish`: Whether or not the current user can publish (for drafts only)
* `cancelAction`: URL that any rendered 'cancel' link should use

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc
component {

	private string function cloneRecordForm( event, rc, prc, args={} ) {
		return renderView( view="/admin/my/custom/clonerecordForm", args=args );
	}

}
```


---
id: datamanager-customization-buildaddrecordactionlink
title: "Data Manager customization: buildAddRecordActionLink"
---

## Data Manager customization: buildAddRecordActionLink

The `buildAddRecordActionLink` customization allows you to customize the URL used to submit the add record form. It is expected to return the action URL as a string and is provided the `objectName` in the `args` struct along with any other arguments passed to `event.buildAdminLink()`. e.g.

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function buildAddRecordActionLink( event, rc, prc, args={} ) {
		var queryString = args.queryString ?: "";

		return event.buildAdminLink( linkto="admin.blogmanager.addRecordAction", queryString=queryString );
	}

}
```

---
id: datamanager-customization-prebatchdeleterecordsaction
title: "Data Manager customization: preBatchDeleteRecordsAction"
---

## Data Manager customization: preBatchDeleteRecordsAction

As of **Preside 10.16.0**, the `preBatchDeleteRecordsAction` customization allows you to run logic _before_ the core Data Manager logic batch deletes a number of records. It is not expected to return a value and is supplied the following in the `args` struct:

* `object`: name of the object
* `records`: query containing the records that will be deleted
* `logger`: logger object - used to output logs to an end user following the batch delete process
* `progress`: progress object - used to update progress bar for the end user following the batch delete process

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	property name="blogService" inject="blogService";

	private void function preBatchDeleteRecordsAction( event, rc, prc, args={} ) {
		var records = args.records ?: QueryNew('');
		var canLog = StructKeyExists( args, "logger" );
		var canWarn = canLog && args.logger.canWarn();

		for( var i=records.recordCount; i>0; i-- ) {
			if ( blogService.cannotHardDelete( records.id[ i ] ) ) {
				blogService.moveRecordToRecycleBinTable( records.id[ i ] );
				QueryRowDelete( records, i );
				if ( canWarn ) {
					args.logger.warn( "Soft deleting blog [#records.label[i]#] because it contains posts that are of the greatest historical and cultural significance..." );
				}
			}
		}
	}
}

```

See also: [[datamanager-customization-postbatchdeleterecordsaction|postBatchDeleteRecordsAction]]



---
id: datamanager-customization-getrecorddeletionpromptmatch
title: "Data Manager customization: getRecordDeletionPromptMatch"
---

## Data Manager customization: getRecordDeletionPromptMatch

As of **Preside 10.16.0**, the `getRecordDeletionPromptMatch` customization allows you to supply dynamic runtime confirmation match text for the delete prompt. For example, you may want to ask users to type in the name record they are deleting to confirm deletion.

![Screenshot of a delete record prompt](images/screenshots/deleteprompt.png)

## Arguments

The method receives `args.record` - a struct containing details of the record that the user may delete.

## Example

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	property name="blogService" inject="blogService";

	private void function getRecordDeletionPromptMatch( event, rc, prc, args={} ) {
		return args.record.label ?: "delete";
	}
}

```

See also: [[customizing-deletion-prompt-matches]]



---
id: datamanager-customization-listingmultiactions
title: "Data Manager customization: listingMultiActions"
---

## Data Manager customization: listingMultiActions

The `listingMultiActions` customization allows you to completely override the buttons that appear when a user selects multiple rows in a regular listing table. It should return a string containing the rendered buttons.

Note: the buttons that appear here rely on some javascript to turn into something useful for the subsequent request. Each button should be of type `submit` and have a unique `name` that will be sent to the next request as the value of `rc.multiAction`. Customize in conjunction with the [[datamanager-customization-multirecordaction|multiRecordAction]] customization that can process the result.

See also: [[datamanager-customization-getlistingmultiactions|getListingMultiActions]] and 
[[datamanager-customization-getextralistingmultiactions|getExtraListingMultiActions]].


For example:


```luceescript
// /application/handlers/admin/datamanager/GlobalDefaults.cfc
component {

	private string function listingMultiActions( event, rc, prc, args={} ) {
		return renderView( view="/admin/datamanager/_myCustomMultiActions", args=args );
	}

}
```

```lucee
<!--- /application/views/admin/datamanager/_myCustomMultiActions.cfm --->

<cfoutput>
	<button class="btn btn-danger confirmation-prompt" type="submit" name="delete" disabled="disabled" data-global-key="d" title="Archive the selected entities">
			<i class="fa fa-trash-o bigger-110"></i>
			Archive selected entities
		</button>
</cfoutput>
```---
id: datamanager-customization-quickEditRecordAction
title: "Data Manager customization: quickEditRecordAction"
---

## Data Manager customization: quickEditRecordAction

The `quickEditRecordAction` allows you to override the core action logic for adding a record when a form is submitted. The core will have already checked permissions for adding records, but all other logic will be up to you to implement (including audit trails, validation, etc.).

The method is not expected to return a value and is provided with `args.objectName`. _The expectation is that the method will redirect the user after processing the request._

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	property name="blogService" inject="blogService";

	private void function quickEditRecordAction( event, rc, prc, args={} ) {
		var formName         = "my.custom.addrecord.form";
		var formData         = event.getDataForForm( formName );
		var validationResult = validateForm( formName, formData );

		if ( validationResult.validated ) {
			var newRecordId = blogService.addBlog( argumentCollection=formData );

			setNextEvent( url=event.buildAdminLink(
				  objectName = "blog"
				, recordId   = newRecordId
			) );
		}

		var persist = formData;
		persist.validationResult = validationResult;

		setNextEvent( url=event.buildAdminLink(
			  objectName = "blog"
			, operation  = "addRecord"
		), persistStruct=persist );

	}

}


```

>>> If you wish to still use core logic for adding records but need to add additional logic to the process, use [[datamanager-customization-prequickeditrecordaction|preQuickEditRecordAction]] or [[datamanager-customization-postquickeditrecordaction|postQuickEditRecordAction]] instead.---
id: datamanager-customization-getlistingbatchactions
title: "Data Manager customization: getListingBatchActions"
---

## Data Manager customization: getListingBatchActions

The `getListingBatchActions` customization allows you to prepare the array of buttons that gets rendered as part of the listing screen (displayed when a user selects rows from the grid). The element should at least contain a `label`, `iconClass` and `name` (most important and must be unique), along with a public function named `{name}BatchAction`.


For example:


```luceescript
// /application/handlers/admin/datamanager/GlobalDefaults.cfc
component {

    private array function getListingBatchActions( event, rc, prc, args={} ) {
        return [{
              label     = "Archive selected entities"
            , iconClass = "fa-trash-o"
            , name      = "archiveEntity"
        }];
    }

    private array function multiRecordAction( event, rc, prc, args={} ) {
        // ...
        if ( args.action == "archiveEntity" ) {
            // ... your logic here
        }
    }

}
```

See [[datamanager-customization-multirecordaction]] for a full guide to implementing batch record actions.---
id: datamanager-customization-postfetchrecordsforgridlisting
title: "Data Manager customization: postFetchRecordsForGridListing"
---

## Data Manager customization: postFetchRecordsForGridListing

The `postFetchRecordsForGridListing` customization allows you to modify the result set that will be used to fill an object's record listing table. It receives `objectName` and `records` (query result set) in the `args` struct and is not expected to return a result.

This customization is run before the [[datamanager-customization-decoraterecordsforgridlisting|decorateRecordsForGridListing]] customization and appears to do the same thing. However, you can use _this_ customization to make changes before using the _core_ Data Manager implementation of [[datamanager-customization-decoraterecordsforgridlisting|decorateRecordsForGridListing]] that will add grid fields, checkboxes, etc. to the result set.

For example, here we use a fictional injected service to add values to each record that we may wish to use later (there would probably be a more efficient way to do this, but perhaps this could be the only way for you to achieve it):

```luceescript
// /application/handlers/admin/datamanager/blog_post.cfc

component {

	property name="myCustomSecurityService" inject="myCustomSecurityService";

	private void function postFetchRecordsForGridListing( event, rc, prc, args={} ) {
		var records = args.records ?: QueryNew( '' );
		var secureCol = [];

		for( var r in records ){
			secureCol.append( myCustomSecurityService.isSecure( r.id ?: "" ) );
		}

		QueryAddColumn( records, "isSecure", secureCol );
	}

}
```

---
id: datamanager-customization-decoraterecordsforgridlisting
title: "Data Manager customization: decorateRecordsForGridListing"
---

## Data Manager customization: decorateRecordsForGridListing

The `decorateRecordsForGridListing` customization allows you to modify the result set that will be used to fill an object's record listing table. The core implementation of this customization adds columns for action links, checkboxes for multi row actions, etc.

>>>> Unless you know that you want to completely override all this logic, you are likely better off using the [[datamanager-customization-postfetchrecordsforgridlisting|postFetchRecordsForGridListing]] customization.

The customization is not expected to return a value and receives the following in the `args` struct:

* `records`: Query result set
* `objectName`: Object name
* `gridFields`: Array of grid fields used by the current table
* `useMultiActions`: Whether or not to use multi actions (i.e. whether or not to include checkbox per row)
* `isMultilingual`: Whether or not the object is multilingual (i.e. whether or not to add translation status column to the table)
* `draftsEnabled`: Whether or not drafts are enabled for the object (i.e. whether or not to include drafts status column)

For example, here we use a fictional injected service to add values to each record that we may wish to use later (there would probably be a more efficient way to do this, but perhaps this could be the only way for you to achieve it):

```luceescript
// /application/handlers/admin/datamanager/blog_post.cfc

component {

	property name="myCustomSecurityService" inject="myCustomSecurityService";

	private void function decorateRecordsForGridListing( event, rc, prc, args={} ) {
		var records = args.records ?: QueryNew( '' );
		var secureCol = [];

		for( var r in records ){
			secureCol.append( myCustomSecurityService.isSecure( r.id ?: "" ) );
		}

		QueryAddColumn( records, "isSecure", secureCol );
	}

}
```

---
id: datamanager-customization-buildeditrecordlink
title: "Data Manager customization: buildEditRecordLink"
---

## Data Manager customization: buildEditRecordLink

The `buildEditRecordLink` customization allows you to customize the URL for viewing an object's edit form. It is expected to return the URL as a string and is provided the `objectName` and `recordId` in the `args` struct along with any other arguments passed to `event.buildAdminLink()`. In addition, it may also be given `resultAction` and `version` keys in the `args` struct.

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function buildEditRecordLink( event, rc, prc, args={} ) {
		var recordId    = args.recordId ?: "";
		var version     = Val( args.version ?: "" );
		var qs          = "id=" & recordId;

		if ( version ) {
			qs &= "&version=" & version;
		}

		if ( Len( Trim( args.queryString ?: "" ) ) {
			qs &= "&" & args.queryString;
		}

		return event.buildAdminLink( linkto="admin.blogmanager.editrecord", queryString=qs );
	}

}
```

---
id: datamanager-customization-getrecordlinkforgridlisting
title: "Data Manager customization: getRecordLinkForGridListing"
---

## Data Manager customization: getRecordLinkForGridListing

The `getRecordLinkForGridListing` allows you to override the default record link that is given to each record node in a **tree view**. The customization is expected to return a string (the link), and receives the following arguments in the `args` struct:

* `objectName`: the name of the object
* `record`: a struct representing the current record whose link you are to return

For example:

```luceescript
// /application/handlers/admin/datamanager/blog_post.cfc

component {

	private string function getRecordLinkForGridListing( event, rc, prc, args={} ) {
		var objectName = args.objectName  ?: "";
		var record     = args.record      ?: {};
		var postType   = args.record.type ?: "";
		var recordId   = record.id        ?: "";

		if ( postType == "fancy" ) {
			return event.buildAdminLink( objectName=objectName, recordId=recordId, operation="viewFancyPost" );
		}

		return event.buildAdminLink( objectName=objectName, recordId=recordId );
	}

}
```---
id: datamanager-customization-preaddrecordaction
title: "Data Manager customization: preAddRecordAction"
---

## Data Manager customization: preAddRecordAction

The `preAddRecordAction` customization allows you to run logic _before_ the core Data Manager add record logic is run. It is not expected to return a value and is supplied the following in the `args` struct:

* `objectName`: name of the object
* `formData`: struct containing the form submission

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	property name="blogService" inject="blogService";

	private void function preAddRecordAction( event, rc, prc, args={} ) {
		var formName = "preside-objects.blog.admin.add";
		var formData = event.getDataForForm( formName );

		rc.clearance_level = blogService.calculateClearanceLevel( argumentCollection=formData );
	}
}

```

See also: [[datamanager-customization-postaddrecordaction|postAddRecordAction]] and [[datamanager-customization-addrecordaction|addRecordAction]].
---
id: datamanager-customization-getquickeditrecordformname
title: "Data Manager customization: getQuickEditRecordFormName"
---

## Data Manager customization: getQuickEditRecordFormName

>>> This customization was added in Preside 10.13.0

The `getQuickEditRecordFormName` customization allows you to use a different form name than the Data Manager default for "quick editing" records. The method should return the form name (see [[presideforms]]) and is provided `args.objectName` should you need to use it. For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private string function getQuickEditRecordFormName( event, rc, prc, args={} ) {
		return "admin.blogs.editblog";
	}

}
```

---
id: datamanager-customization-objectbreadcrumb
title: "Data Manager customization: objectBreadcrumb"
---

## Data Manager customization: objectBreadcrumb

The `objectBreadcrumb` customization allows you to override what happens for the "object" breadcrumb of an object. This defaults to a title that is the object, and a link that goes to the listing page for the object. For example:

```luceescript
// /application/handlers/admin/datamanager/blog_post.cfc

component {

	private string function objectBreadcrumb() {
		var blogId = prc.record.blog ?: ( rc.blogId ?: "" );

		if ( !Len( Trim( blogId ) ) ) {
			setNextEvent( url=blogListingLink );
		}

		event.addAdminBreadCrumb(
			  title = "Posts"
			, link  = event.buildAdminLink( objectName="blog", recordId=blogId, operation="posts" )
		);
	}
}
```

---
id: datamanager-customization-toprightbuttonsformat
title: "Reference: Data Manager top right buttons array"
---

## Reference: Data Manager top right buttons array

Several [[customizingdatamanager|Data Manager customizations]] allow you modify the top right buttons that appear for a particular screen in the Data Manager. These modififications expect to either return an array of structs and/or strings, or are passed this array of structs/strings for modification / appending to.

### Keys

Each "action" struct can/must have the following keys:

* `title` _(required)_: Title/label to display on the button.
* `link` _(optional)_: Required when there are no child actions.
* `btnClass` _(optional)_: Twitter bootstrap button class for the button. e.g. `btn-success`, `btn-danger`, etc.
* `iconClass` _(optional)_: Font awesome icon class to use. Icon will be displayed before the title.
* `globalKey` _(optional)_: Global keyboard key shortcut for the button.
* `prompt` _(optional)_: Prompt for the action should you want a modal dialog to appear to confirm the action.
* `match` _(optional)_: The prompt modal dialog will display this word and requires that the user enters it in order to continue.
* `target` _(optional)_: e.g. "\_blank" to have the button link open in a new tab.
* `children` _(optional)_: Array of child actions that will appear in a drop-down menu on button click.

>>> Note: alternatively, a button in the array can be a fully rendered string representing the button (should you require something a bit different)

### Children

If you wish your button to be a drop down menu, use the `children` array. Each item in the array is a struct with the following possible keys:

* `title` _(required)_: Title/label for the item
* `link` _(required)_: Link of the item
* `prompt` _(optional)_: Prompt for the action should you want a modal dialog to appear to confirm the action.
* `match` _(optional)_: The prompt modal dialog will display this word and requires that the user enters it in order to continue.
* `target` _(optional)_: Optional link target, e.g. "\_blank" to open in a new tab
* `icon` _(optional)_: Font awesome icon class for the item. Icon will appear before the title

As of 10.20, child actions can be supplied as a pre-rendered string **or** you can supply the explicit string "---" to create a spacer entry.

### Examples

A minimal button item:

```luceescript
{
      link      = event.buildAdminLink( objectName=objectName, operation="preview" )
    , title     = translateResource( "preside-objects.blog:preview.btn" )
    , iconClass = "fa-eye"
}
```

A button with children:

```luceescript
{
      title     = translateResource( "preside-objects.blog:options.btn" )
    , iconClass = "fa-wrench"
    , children  = [
          { title="Stats"   , link=statsLink   , icon="fa-bar-chart" }
        , { title="Download", link=downloadLink, icon="fa-download"  }
      ]
}
```

A button with primary action and children (from 10.20 onwards):

```luceescript
{
      title     = translateResource( "preside-objects.blog:options.btn" )
    , link      = event.buildAdminLink( objectName=objectName, operation="options" )
    , iconClass = "fa-wrench"
    , children  = [
          { title="Stats"   , link=statsLink   , icon="fa-bar-chart" }
        , { title="Download", link=downloadLink, icon="fa-download"  }
        , "---" // spacer
        , { title="Something else", link=someOtherLink, icon="fa-heels"  }
      ]
}
```
---
id: datamanager-customization-extratoprightbuttonsforobject
title: "Data Manager customization: extraTopRightButtonsForObject"
---

## Data Manager customization: extraTopRightButtonsForObject

The `extraTopRightButtonsForObject` customization allows you to add to, or modify, the set of buttons that appears at the top right hand side of the record listing screen. It is provided an `actions` array along with the `objectName` in the `args` struct and is not expected to return a value.

Modifying `args.actions` is required to make changes to the top right buttons.


>>> See [[datamanager-customization-toprightbuttonsformat]] for detailed documentation on the format of the action items.


For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private void function extraTopRightButtonsForObject( event, rc, prc, args={} ) {
		var objectName = args.objectName ?: "";

		args.actions = args.actions ?: [];

		args.actions.append({
			  link      = event.buildAdminLink( objectName=objectName, operation="reports" )
			, btnClass  = "btn-default"
			, iconClass = "fa-bar-chart"
			, globalKey = "r"
			, title     = translateResource( "preside-objects.blog:reports.btn" )
		} );
	}

}
```



---
id: datamanager-customization-preQuickEditRecordForm
title: "Data Manager customization: preQuickEditRecordForm"
---

## Data Manager customization: preQuickEditRecordForm

The `preQuickEditRecordForm` customization allows you to add javascript _before_ the rendering of the core edit record form.

For example:


```luceescript
// /application/handlers/admin/datamanager/faq.cfc

component {

	private void function preQuickEditRecordForm( event, rc, prc, args={} ) {
		event.include( assetId="/js/admin/specific/appointment/" );
	}

}
```

See also: [[datamanager-customization-quickeditrecordaction|quickEditRecordAction]]

---
id: datamanagerbasics
title: Data Manager Basics
---

## Introduction

This page will take you through the basic default set up and configuration of [[datamanager]] for a [[dataobjects|Preside data object]]. By the end of this guide, you should be comfortable creating a basic admin CRUD interface for an object within the main Data Manager user interface.

## Data Manager homepage

The Data Manager homepage in the Preside administrator displays all of the objects in the system **that have been configured to display within Data Manager**. Objects are organised into groups and are searchable (by object name). Clicking on an object will take you into that object's listing screen.


![Screenshot showing example of a Data Manager object listing screen](images/screenshots/datamanager-listing-screen.png)

### Get your object listed in the Data Manager homepage

In order for your object to appear in the Data Manager homepage, your `.cfc` file must be annotated with the `@datamanagerGroup` annotation. For example:

```luceescript
// /application/preside-objects/author.cfc

/**
 * @datamanagerGroup blog
 * @labelfield       name
 */
component {
	property name="name" type="string" dbtype="varchar" maxlength="200" required=true uniqueindexes="name";
}
```

That is all there is to it. You now how a full CRUD interface for your object. However, you probably want to make things a little more user friendly with regards to human readable and translatable labels; see below.

### Translatable and human readable labels

Each Preside Object should have a corresponding `.properties` file that will provide title, description, optional icon class and entries for each field in your object. The file must live at: `/i18n/preside-objects/myobject.properties`. For example:

```properties
# /application/i18n/preside-objects/author.properties
title=Authors
title.singular=Author
description=Authors of blog posts
iconclass=fa-user

field.name.title=Author Name
```

#### Translate title base on context

As 10.12, context had introduced to Preside Object title properties. Object listing view is using `listing` context, you able to have different field label in the listing table by adding `field.{field_name}.listing.title`. For example:

```properties
field.product_id.title=Product ID
field.product_id.listing.title=#
```

You also able to add help text for the listing table. For example:

```properties
field.product_id.listing.help=Product ID
```

![Screenshot showing example of a Data Manager object listing screen with overwrite label](images/screenshots/datamanager-listing-overwrite-label-example.png)

>>>>>> _See [[presideforms-i18n]] for more conventions for field names, placeholders, help, etc._

Each Data Manager **group** should also have a corresponding `.properties` file at `/i18n/preside-objects/groups/groupname.properties`. For our blog example:

```properties
# /application/i18n/preside-objects/groups/blog.properties
title=Blogs
description=Data related to blogs
iconclass=fa-comments
```

## Basic customizations for the listing grid

There are four basic customizations that can be achieved with simple annotations on your preside object `.cfc` file:

1. Change the fields that are displayed in the table
2. Change the _default_ sort order of records
3. Change the sortable fields in the table
4. Change the fields that are searchable

In addition, limiting the _operations_ that are allowed on an object will affect the actions that appear on each row (see **Limiting operations**, below).

To specify a non-default list of fields to display in the table, use the `@datamanagerGridFields` annotation.

To specify a default sort order for the table, use the `@datamanagerDefaultSortOrder` annotation.

To specify a non-default list of fields to sortable in the table, use the `@datamanagerSortableFields` annotation.

To specify a non-default list of fields that are _searchable_ in the table, use the `@datamanagerSearchFields` annotation.

For example:


```luceescript
// /application/preside-objects/author.cfc

/**
 * @labelfield                  name
 * @datamanagerGroup            blog
 * @datamanagerGridFields       name,post_count,datemodified
 * @datamanagerSortableFields   name,post_count
 * @datamanagerSearchFields     name,posts.title
 * @datamanagerDefaultSortOrder post_count desc
 */
component {
	property name="name" type="string" dbtype="varchar" maxlength="200" required=true uniqueindexes="name";
	property name="posts" relationship="one-to-many" relatedto="blog_post" relationshipkey="blog_author";
	property name="post_count" type="numeric" formula="Count( ${prefix}posts.id )";
}
```

## Customizing the listing grid header label

There is a `listing` context available when translate property name for listing grid header.

To specify a label for listing grid, add `field.{your_field}.listing.title=Listing label` in corresponding object i18n file.

Optional tooltip can be added to listing grid header field, add `field.{your_field}.listing.help=Listing label help` in corresponding object i18n file.

## Customizing the add / edit record forms

The Data Manager uses convention-based form names to build add and edit forms for your object. Prior to 10.9.0, these were:

* Add form: `/forms/preside-objects/objectname/admin.add.xml`
* Edit form: `/forms/preside-objects/objectname/admin.edit.xml`

As of Preside 10.9.0, you are also able to create a _single form_ that will be used as both **add** _and_ **edit**:

* Default form: `/forms/preside-objects/objectname.xml`

If you do not supply any form `.xml` definitions at all, the system will build a default form based on the `.cfc` definition. In many cases, particularly for simple objects, this will suffice.

Any **Preside object forms** that are defined beneath `/forms/preside-objects` will have a default i18n base URI of `preside-objects.objectname:`. This means that you can define all your convention based form field, tab and fieldset labels for your forms in your preside object's `.properties` file. See See [[presideforms-i18n]] for more information on form labeling conventions.

>>> See [[presideforms]] for full documentation on Preside's forms system.

## Versioning & Drafts

By default, preside objects are versioned (this can be turned off per object by adding the `@versioned false` annotation on the `.cfc` file. All versioned objects will automatically get a versioning user interface within Data Manager. In addition, you can turn on _drafts_ capability for your versioned objects by adding the `@datamanagerAllowDrafts` annotation to your object, for example:

```luceescript
// /application/preside-objects/author.cfc

/**
 * @labelfield                  name
 * @datamanagerGroup            blog
 * @datamanagerGridFields       name,post_count,datemodified
 * @datamanagerSearchFields     name,posts.title
 * @datamanagerDefaultSortOrder post_count desc
 * @datamanagerAllowDrafts      true
 */
component {
	property name="name" type="string" dbtype="varchar" maxlength="200" required=true uniqueindexes="name";
	property name="posts" relationship="one-to-many" relatedto="blog_post" relationshipkey="blog_author";
	property name="post_count" type="numeric" formula="Count( ${prefix}posts.id )";
}
```

## Limiting operations

The system defines eight core "operations" that can be "performed" on any given object record:

1. `read`: view an individual record in the view record screen
2. `add`: add new records
3. `edit`: edit records
4. `batchedit`: batch edit records (as of 10.12.0)
5. `delete`: delete a record
6. `batchdelete`: batch delete records (as of 10.12.0)
7. `clone`: clones a record (as of 10.10.0)
8. `viewversions`: view version history for a record

All operations are enabled by default. To limit the operations that are allowed for an object, use either the `@datamanagerAllowedOperations` or `@datamanagerDisallowedOperations`annotations, supplying a comma separated list without spaces of the operations that are allowed/disallowed. For example, we could disable deleting and the view screen for our blog authors with:

```luceescript
// /application/preside-objects/author.cfc

/**
 * @labelfield                      name
 * @datamanagerGroup                blog
 * @datamanagerDisallowedOperations delete,read
 */
component {
	property name="name" type="string" dbtype="varchar" maxlength="200" required=true uniqueindexes="name";
}
```

## Allowing records to be translated

The Data Manager comes with a basic user interface to allow translation of records. See [[multilingualcontent]] for how configure this feature and enable this per object.

## Displaying records in a tree view

>>> This feature is available since version 10.9.0

For hierarchical data, you can choose to show the listing screen as a tree by using the following attributes on your object:

* `@datamanagerTreeView`: True / false - whether or not to use tree view
* `@datamanagerTreeParentProperty`: The self referencing foreign key property that creates the hierarchical relationship
* `@datamanagerTreeSortOrder`: What field(s) to sort on when displaying the children of a node

For example:

```luceescript
// /application/preside-objects/article.cfc

/**
 * @labelfield                    title
 * @datamanagerTreeView           true
 * @datamanagerTreeParentProperty parent_article
 * @datamanagerTreeSortOrder      title
 *
 */
component {
	property name="parent_article" relationship="many-to-one" relatedto="article";

	property name="title" type="string" dbtype="varchar" maxlength=100 required=true;
	property name="body"  type="string" dbtype="text";
}
```
---
id: adminrecordviews
title: Admin record views
---

## Overview

As of **Preside 10.9.0**, the admin system comes with a framework for displaying single records through the data manager. An example might look like this:

![Screenshot showing example data view](images/screenshots/presidedataview.jpg)

This view is automatically available to any object that is managed in the data manager and will display fields and relationships of a record, grouped into configurable display boxes. The display groups, sort order and renderers for fields are all fully customizable. You are even able to use your own handler entirely for displaying a record.

## Customizing the view screen

### View groups and columns

One of the first features you might want to customize is the grouping of fields in the default view of a record for your object.

The standard groups are `default` and `system` and these will appear in your view with core Preside fields in the `system` "box" and everything else in the `default` "box". By default, the `default` group's title will be the name of the object, will have a sort order of `1`, and be positioned in the `left` column; the system group will have a sort order of `1` and be positioned in the `right` column:

![Screenshot showing example data view with standard groups](images/screenshots/adminviewStandardGroups.jpg)

#### Assign a property to a group

To assign a property to a particular view group, use the `adminViewGroup` attribute on the `property` definition, e.g.

```luceescript
// category.cfc
component {
	property name="label" adminViewGroup="system";
}
```

The above change to our object would lead to a grouping as below:

![Screenshot showing example data view with only a system group](images/screenshots/adminviewOnlySystemGroup.jpg)

#### Creating and customizing groups

A group is automatically registered as soon as it is referenced by the `adminViewGroup` attribute on a property. For instance, if we wanted to add a new `many-to-many` `posts` property on category and assign it to a group named 'posts', we could do so:


```luceescript
// category.cfc
component {
	property name="label" adminViewGroup="system";
	property name="posts" adminViewGroup="posts" relationship="many-to-many" relatedto="blog_post" relatedvia="blog_post_category";
}
```

![Screenshot showing example data view with a custom group](images/screenshots/adminviewCustomGroup.jpg)

We can then use convention to give the group a translatable name, icon, column and sort order. Add the following keys to the corresponding `.properties` file for you object:

```properties
viewgroup.{groupname}.title=A group title
viewgroup.{groupname}.iconClass=fa-icon
viewgroup.{groupname}.sortorder=2
viewgroup.{groupname}.column=right
```

For example, in our `category.properties` file:

```properties
# /application/i18n/preside-objects/category.properties

# ...

viewgroup.posts.title=Posts
viewgroup.posts.iconClass=fa-file-text-o
viewgroup.posts.column=left
viewgroup.posts.sortorder=1


viewgroup.system.title=Category
viewgroup.system.iconClass=fa-tag
viewgroup.system.column=right
viewgroup.system.sortorder=2
```

Leads to:

![Screenshot showing example data view with a custom group decorated with custom labelling](images/screenshots/adminviewCustomGroupWithLabels.jpg)

#### Omit field label for many-to-many fields

To omit a property's field label, use the `displayPropertyTitle` attribute on the `property` definition, e.g.

```luceescript
// category.cfc
component {
	...
	property name="posts" ... displayPropertyTitle=false;
}
```

![Screenshot showing example data view with property field title is hidden](images/screenshots/adminviewPropertyTitleHidden.png)

### Field renderers

Each field is rendered using a regular Preside content renderer with a context of `[ "adminview", "admin" ]` (if the renderer has a `adminview` context, use that, if not, use `admin`, if not, use `default`). In addition, the renderer viewlet is passed `objectName`, `propertyName`, and `recordId` in the `args` struct so that it can do things like render a datatable showing related records filtered by the current record.

For the most part, you should not need to customize the renderers here and a sensible default will be chosen.

#### Assigning a renderer

To assign a renderer to a property specifically for admin record views, use the `adminRenderer` attibute:

```luceescript
property name="label" adminrenderer="richeditor";
```

If you do not specify an `adminRenderer` but you _do_ specify a general renderer with the `renderer` attribute, the `renderer` value will be used:

```luceescript
property name="label" renderer="richeditor";
property name="something" renderer="richeditor" adminRenderer="none";
```

>>> A renderer value of `none` will mean that the property will not be displayed at all.

#### Creating a custom renderer

Content renderers are viewlets that live at `renderers.content.{renderername}.{context}`. To create a specific admin record view renderer named `myrenderer`, you could create a handler CFC with the following:

```luceescript
// /handlers/renderers/content/MyRenderer.cfc
component {

	private string function adminView( event, rc, prc, args={} ) {
		var value         = args.data         ?: "";
		var objectName    = args.objectName   ?: "";
		var propertyName  = args.propertyName ?: "";
		var recordId      = args.recordId     ?: "";

		return _doSomethingToValue( value, ... );
	}
}
```

Alternatively, the renderer could be just a view at `/views/renderers/content/myRenderer/adminView.cfm`:

```lucee
<cfparam name="args.data"         default="" />
<cfparam name="args.objectName"   default="" />
<cfparam name="args.propertyName" default="" />
<cfparam name="args.recordId"     default="" />

<!--- obviously do more than this... --->
<cfoutput>#args.data#</cfoutput>
```

### Property sort orders

The order of properties within an admin view defaults to the order of definition of the properties within the `.cfc` file. However, you can influence the sort order by adding a `sortOrder` attribute (which will also be the default sort order for the field in form layouts):

```luceescript
property name="title" sortorder=20;
property name="blog" sortorder=10;
// etc.
```

### Richeditor preview layout

The `richeditor` content renderer uses a special iFrame to display the rendered content in a full HTML layout. The purpose of this is to allow you to load front-end CSS and show the content as it would appear in the front end site.

The default preview layout provided by Preside will load the CSS defined to be used within your ckeditor instances with the `settings.ckeditor.defaults.stylesheets` setting. To change this, define your own layout in your application folder at `/application/layouts/richeditorPreview.cfm`. Use the following core layout as a starting point to customize:

```lucee
<cfscript>
	stylesheets = getSetting( name="ckeditor.defaults.stylesheets", defaultValue=[] );
	if ( IsArray( stylesheets ) ) {
		for( var stylesheet in stylesheets ) {
			event.include( stylesheet );
		}
	}

	css         = event.renderIncludes( "css" );
	js          = event.renderIncludes( "js" );
	content     = args.content ?: "";
</cfscript>

<cfoutput><!DOCTYPE html>
<html lang="en" class="richeditor-preview presidecms">
	<head>
		<meta charset="utf-8" />
		<meta name="robots" content="NOINDEX,NOFOLLOW" />
		<meta name="description" content="" />
		<meta name="viewport" content="width=device-width, initial-scale=1.0" />

		#css#
	</head>

	<body>
		#content#
		#js#
	</body>
</html></cfoutput>
```

### Other ways to customize the view

As of **Preside 10.24.0**, the admin system provides an alternative system to the default view record screen, detailed in [[enhancedrecordviews]].

In [[customizingdatamanager]], there are full details of how you can customize the Data Manager either globally, or per object. The following customizations relate to the view screen and allow you to either completely override the rendering of the view screen, or add HTML to various areas:

* [[datamanager-customization-renderrecord|renderRecord]]
* [[datamanager-customization-prerenderrecord|preRenderRecord]]
* [[datamanager-customization-prerenderrecordleftcol|preRenderRecordLeftCol]]
* [[datamanager-customization-prerenderrecordrightcol|preRenderRecordRightCol]]
* [[datamanager-customization-postrenderrecordleftcol|postRenderRecordLeftCol]]
* [[datamanager-customization-postrenderrecordrightcol|postRenderRecordRightCol]]
* [[datamanager-customization-postrenderrecord|postRenderRecord]]

---
id: enhancedrecordviews
title: Enhanced record views
---

## Introduction

As of **Preside 10.24.0**, the admin system provides an alternative system to the default view record screen. To get started with it, create a data manager handler for your entity that extends `preside.system.base.EnhancedDataManagerBase`.

### "Info-card" and tabs

The view record layout uses standard Preside datamanager "top right buttons" and crumbtrail customizations but adds a concept of an "info card" and "view tabs" for your record.

![image](images/screenshots/enhanced-datamanager-infocard.png)

_If you have the [Alternate Admin Theme extension](https://www.forgebox.io/view/preside-ext-alt-admin-theme) installed, you can also make use of an alternative UX which gives a sidebar menu in place of the tabs, and allows for a header card to be placed at the top of the sidebar._

_The Alternate Admin Theme is likely to become the default core admin theme in a future release of Preside._

### Customizing the "info card"

The info card layout is configured using three columns that are arrays of info card items. The default configuration is to have **created** and **modified** info in column three but you can customize these as you wish. The columns must be set in the psuedo-constructor of your CFC and look like this:

```luceescript
component extends="preside.system.base.EnhancedDataManagerBase" {

	variables.infoCol1 = variables.infoCol1 ?: [];
	variables.infoCol2 = variables.infoCol2 ?: [];
	variables.infoCol3 = variables.infoCol3 ?: [];

	// for example, add new items to whatever is already
	// existing in the columns
	ArrayAppend( variables.infoCol1, "entityStatus" );
	ArrayAppend( variables.infoCol2, "entityWebsite" );

// ....
```

For each item in an info column, you can implement a private viewlet handler in your CFC, `_infoCard{colname}()`. For example:

```luceescript
component extends="preside.system.base.EnhancedDataManagerBase" {

	variables.infoCol1 = variables.infoCol1 ?: [];
	variables.infoCol2 = variables.infoCol2 ?: [];
	variables.infoCol3 = variables.infoCol3 ?: [];

	ArrayAppend( variables.infoCol1, "entityStatus" );

	private string function _infoCardEntityStatus( event, rc, prc, args={} ) {
		var record = args.record ?: {}; // struct of the current record

		return '<i class="fa fa-fw fa-check green"></i>&nbsp; #( record.status ?: "" )#';
	}
```

However, you can also just use a field name for the item and the system will use the standard admin renderer for that item _if you do not supply a custom viewlet for the info card_.

#### Specifiying info card column sizes

You may also hard code an array of column sizes for your info card. These sizes should add up to a total of 12 to match the bootstrap grid system. Examples:

```luceescript
variables.infoCol1 = [ "status", "owner" ];
variables.infoCol2 = [ "description" ];
variables.infoCol3 = [];

// set column sizes
variables.infoColSizes = [ 3, 9, 0 ];
```

#### Rendered description

By setting `variables.infoDescription`, you can choose a property from the record, or a defined custom infoCard item, to be rendered above the infocard. Example:

```luceescript
variables.infoDescription = "teaser";
```

#### preRenderDataManagerObjectInfoCard interceptor

Before the info card is rendered, an interception event `preRenderDataManagerObjectInfoCard` is announced.

This receives the following in its `interceptData`:

* `objectName` - the name of the object
* `record` - the record data for the displayed record
* `tabs` - an array of tab names to display
* `currentTab` - the name of the currently selected tab

Manipulating this data would enable an extension to add its own tab to an object's default array of tabs, for example.

### Customizing tabs

Similar to the info card items, tabs must be configured in your object's psuedo-constructor. For example:

```luceescript
component extends="preside.system.base.EnhancedDataManagerBase" {
	variables.tabs = variables.tabs ?: [ "default" ]; // the default
	ArrayInsertAt( variables.tabs, 2, "directory" );
	ArrayAppend( variables.tabs, "orders" );
	ArrayAppend( variables.tabs, "bookings" );
	variables.maxTabCount = 5; // default is 6

```

For each tab, you must supply a corresponding viewlet (`_{tabid}Tab()`) in your handler to render the _content_ of the tab. For example:

```luceescript
component extends="preside.system.base.EnhancedDataManagerBase" {
	variables.tabs = variables.tabs ?: [ "default" ]; // the default
	ArrayAppend( variables.tabs, "bookings" );

	private string function _bookingsTab( event, rc, prc, args={} ) {
		return "your view rendering logic here";
	}

```

#### Tab title's and icons

Tab icons and titles can be specified by convention in your `/i18n/preside-objects/my_entity.properties` file with the convention:

```properties
viewtab.tabid.title=Title of tab
viewtab.tabid.iconClass=fa-list orange
```

If you wish to implement more complex logic for rendering your tab title, you can implement a `_{tabId}TabTitle()` handler action:


```luceescript
component extends="preside.system.base.EnhancedDataManagerBase" {
	variables.tabs = variables.tabs ?: [ "default" ]; // the default
	ArrayAppend( variables.tabs, "bookings" );

	private string function _bookingsTabTitle( event, rc, prc, args={} ) {
		var bookingsCount = bookingsService.getBookingsCount( args.recordId ?: "" );
		return translateResource( "preside-objects.my_entity:viewtab.bookings.title" ) & ' <span class="badge">#NumberFormat( bookingsCount )#</span>';
	}
	private string function _bookingsTab( event, rc, prc, args={} ) {
		return "your view rendering logic here";
	}

```

#### Tab content

To display DB record fields in name value pair within table, you can call the view `/admin/datamanager/_propertyNameValueData`, pass in the array list of field names as `fields` args from within the tab viewlet. E.g.

```luceescript
private string function _defaultTab( event, rc, prc, args={} ) {
	return renderView( view="/admin/datamanager/_propertyNameValueData", args={
		  objectName = args.objectName ?: ""
		, fields     = [ "description", "start_date", "..." ]
		, detail     = args.record
	} );
}
```

To manipulate the field data for similar display layout, use `extraRows` args. E.g.

```luceescript
private string function _defaultTab( event, rc, prc, args={} ) {
	var extraRows = [];

	if ( Len( args.record.amount_paid ) ) {
		ArrayAppend( extraRows, {
			  title = translateResource( "preside-objects.#args.objectName#:field.amount_paid.title" )
			, body  = renderLabel( "currency", args.record.paid_currency ) & args.record.amount_paid
		} );
	}

	return renderView( view="/admin/datamanager/_propertyNameValueData", args={
		  objectName = args.objectName ?: ""
		, extraRows  = extraRows
		, detail     = args.record
	} );
}
```

#### "Max" tabs

By specifying a `maxTabCount` setting, you limit the number of tabs that will show before tabs are treated as "additional". Additional tabs are grouped in a final tab using a dropdown menu.

For instance, if have 10 tabs and can easily fit 8 in before breaking on to two lines, then you may wish to set this value to 8:

```luceescript
variables.maxTabCount = 8; // default is 6
```

#### preRenderDataManagerObjectTabs interceptor

Before the tabs are rendered, an interception event `preRenderDataManagerObjectTabs` is announced.

This receives the following in its `interceptData`:

* `objectName` - the name of the object
* `record` - the record data for the displayed record
* `col1`, `col2`, `col3` - arrays of the items to be displayed in each column
* `infoDescription` - the rendered description to appear before the info card

Manipulating this data would enable an extension to add its own items to an object's info card, or add to or manipulate the recored description.

### Sidebar Navigation

If you have the [Alternate Admin Theme extension](https://www.forgebox.io/view/preside-ext-alt-admin-theme) installed, there is an alternative UX which gives a sidebar menu in place of the tabs.

This can be enabled for an object by setting:
```luceescript
variables.sidebarNavigation = true; // default is false (i.e. traditional tab layout)
```

#### Tab content

Tab content is defined the same as before. The only differences are that only the content of the active tab is rendered on any one page, and whether a tab/sidebar item is hidden is now based on the menu item generator, not on a tab having no content.

#### Tab titles

Custom tab title methods are not used in the sidebar. Instead, any logic contained previously in these should be refactored into the `_{tab}MenuItem()` method.

#### Menu items

Sidebar menu items are still governed by the `variables.tabs` array, and in the absence of any customisation the menu item will have a text label sourced from the `viewtab.tabid.title` i18n property, as before.

Note however that the title property **should not** now include a placeholder for adding badges, but should be the simple text title.

If you wish to implement more complex logic for rendering your tab title, you can implement a `_{tabId}MenuItem()` handler action.

The handler action will receive as its `args` the following:

* `objectName`
* `recordId`
* `tabId` - the tabId of the menu item
* `currentTab` - the tabId of the currently selected tab
* `subMenuItems` - an array of the items child items, which will have been built first

A menu item has the following base structure:

* `link` _string_ Target link of the menu item.
* `title` _string_ Label of the menu item, defaults to the `viewtab.tabid.title` i18n property
* `badge` _string_ Content of a badge to be shown after the menu title - could be text or numeric. Defaults to empty string (no badge)
* `badgeClass` _string_ One of "success", "warning", "danger" or "error", defining the colour of the badge. Defaults to empty string (blue info badge).
* `active` _boolean_ is this the currently selected tab?
* `display` _boolean_ whether this menu item should be displayed in the sidebar
* `open` _boolean_ whether a menu with children should be open on page load. Defaults to true if one of its children is the active page, otherwise false
* `submenuItems` _array_ an array of similarly structured menu items

The handler action should then return a struct of the items to be modified, which will be merged with the base item. For example:

```luceescript
private struct function _bookingsMenuItem( event, rc, prc, args={} ) {
	if ( !isFeatureEnabled( "bookings" ) ) {
		return { display=false }; // The menu item will not be displayed
	}

	// Return a record count as the badge content, which will be combined
	// with the default values that have been generated automatically
	var bookingsCount = bookingsService.getBookingsCount( args.recordId ?: "" );
	return {
		badge = bookingsCount
	};
}
```

#### Nested menu items

Nested menu structures can be defined in `variables.tabs` by including structs:

```luceescript
variables.tabs = [
	  "default"
	, "activity"
	, { id="paymentsmenu", children=[ "orders","invoices","payments" ] }
];
```

Child menu items and their parent items are customised just the same as any other menu. The only caveat is that the parent is simply a menu toggle to hide/reveal its children - it does not have a link action of its own.

Menus can be nested at multiple levels, so a child menu item could have its own children.


#### Sidebar header

If you are displaying sidebar navigation, you can also define a header panel to appear at the top of the sidebar, above the menu.

This might display, for example, a contact's name, photo and basic contact info, and will be shown on all tab pages for the object.

The header is defined by adding a `renderSidebarHeader()` method to your datamanager object, which should return a string value - the rendered sidebar header. An empty string will result in no header being displayed.

```luceescript
private string function renderSidebarHeader( event, rc, prc, args={} ) {
	// Do not display the record title at the top of the main content panel,
	// as we will be including it in this header
	prc.displayPageHeader  = false;

	// Add one or more classes to the containing <header> element
	// to make targeted styling easier
	prc.sidebarHeaderClass = "crm-sidebar-header";

	// render a list of tags to be passed through to the view
	args.renderedTags = renderContent(
		  renderer = "crmTagsList"
		, data     = ""
		, context  = [ "adminview", "admin" ]
		, args     = {
			  objectName = "crm_contact"
			, recordId   = args.record.id
			, maxRows    = 3
			, class      = "sidebar-header-tags"
		}
	);

	// return the rendered view
	return renderView( view="/admin/datamanager/crm_contact/_sidebarHeader", args=args );
}
```


### Permissioning

In addition to improving the view record screen, the base object gives you a standard implementation of the `checkPermission()` customization. Set `variables.permissionBase` in your pseudo constructor to automically map the data manager operations:

* `read`
* `add`
* `edit`
* `delete`
* `clone`

i.e. if you set a base of `payments.`, then permission check keys will look like `payments.read`, `payments.add` and so on.

If you do not set `variables.permissionBase`, the base will default to the object name. However, this default behaviour can be customised by setting up by adding a custom method `getPermissionBaseFromObjectName()` to `/handlers/admin/datamanager/GlobalCustomizations.cfc`, e.g.:

```luceescript
private string function getPermissionBaseFromObjectName( event, rc, prc, args={} ) {
	return ReReplaceNoCase( args.objectName, "^crm_", "" );
}
```

The above would remove `crm_` from the beginning of any object name to create the permission base; but you could have more complex logic in here if required.
---
id: widgets
title: Widgets
---

One of Preside's most powerful and easy to build features is its widget framework. Technially, a widget is a [[viewlets|Preside viewlet]] for which the editorial user supplies the configuration arguments through a [[presideforms|Preside config form]]. Editorial users are able to insert a Preside widget in any part of a [[workingwiththericheditor||Preside Richeditor field]] and the widget will be fully rendered at runtime. Visually, they look like this:

![Screenshot showing widget selector](images/screenshots/widgetSelection.jpg)

![Screenshot showing widget configurator](images/screenshots/widgetConfiguration.jpg)

![Screenshot showing widget placeholders](images/screenshots/widgetplaceholders.jpg)


## Creating a new widget

A widget consists of three parts, a viewlet (with optional handler), a configuration form and a `.properties` resource file. Each part is registered through convention of `/widgets.{widgetname}`. So, to create a widget with an ID of 'tableOfContents', you could create the following files

```
/forms/widgets/tableOfContents.xml
/i18n/widgets/tableOfContents.properties
/handlers/widgets/TableOfContents.cfc          // optional, if only view is used
/views/widgets/tableOfContents/index.cfm       // optional, if handler is used
/views/widgets/tableOfContents/placeholder.cfm // optional
```

>>> The `new widget` dev console command gives an easy to use wizard to scaffold these files for you.

### The form

The form is simply any valid Preside form definition (see: [[presideforms]]). With that said, we advise setting a `i18nBaseUri` value to map to the `.properties` file of the widget; this will make supplying labels, icons and placeholders easy to do all in the same widget resource bundle file, e.g.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form i18nBaseUri="widgets.tableOfContents:">
    <tab id="default">
        <fieldset id="default" sortorder="10">
            <field name="title" control="textinput" required="true" />
            <field name="pages" control="siteTreePagePicker" multiple="true" sortable="true" />
        </fieldset>
    </tab>
</form>
```

In addition, and as of Preside 10.7.0, you can also specify a `categories` attribute on your widget `form` element. This will allow you to later filter available widgets for a particular Richeditor instance (see below), e.g.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form i18nBaseUri="widgets.newsletterPromoBox" categories="newsletter,email">
    <tab id="default">
        <fieldset id="default" sortorder="10">
            ...
```

### The i18n resource file

At a minimum, you should supply three keys, `title`, `description` and `iconClass`:

```properties
title=Form Builder Form
description=Embed a Form Builder Form in your content
iconclass=fa-check-square-o
```

These keys will be used in the widget selector to help your content editors choose which widget to insert into their content.

Additional keys can then be used for any purpose you like, for example, configuration field labels, help and placeholders:

```properties
title=Form Builder Form
description=Embed a Form Builder Form in your content
iconclass=fa-check-square-o

# ...

placeholder=Form: {1}

# ...

field.instanceid.title=Instance name
field.instanceid.placeholder=e.g. 'Contact page'
field.instanceid.help=If you plan on embeddeding the same form in multiple locations, you can use the instance name field to report against which instance of the form your visitors used when submitting their responses.

# ...
```

### The render viewlet

The viewlet used to render a widget at runtime will be `widgets.{widgetid}`, or `widgets.{widgetid}.index`. If you're creating a handler, create it at `/handlers/widgets/MyWidget.cfc` and implement an `index` action to process the render.

The `args` struct passed to the action will contain the user configured values from the config form. For example:

```luceescript
// /handlers/widgets/FormBuilderForm.cfc
component {
    property name="formbuilderService" inject="formbuilderService";

    private function index( event, rc, prc, args={} ) {
        var formId   = args.form   ?: "";
        var layout   = args.layout ?: "";
        var rendered = "";

        if ( Len( Trim( formId ) ) ) {
            if ( !formbuilderService.isFormActive( formId ) ) {
                if ( !event.isAdminUser() ) {
                    return "";
                }

                rendered = '<div class="alert alert-warning"><p><strong>' & translateResource( "formbuilder:inactive.form.admin.preview.warning") & '</strong></p></div>';
            }
            rendered &= formbuilderService.renderForm(
                  formId           = formId
                , layout           = layout
                , configuration    = args
                , validationResult = rc.validationResult ?: ""
            );
        }

        return rendered;
    }

    ...
}
```

### Placeholder viewlet

In addition to a runtime render viewlet, you can also supply a placeholder viewlet so that you can customize the appearance of the placeholder that appears in the richeditor. The convention based viewlet path is `widgets.{widgetid}.placeholder`. For example:

```luceescript
// /handlers/widgets/FormBuilderForm.cfc
component {
    property name="formbuilderService" inject="formbuilderService";

    ...

    private string function placeholder( event, rc, prc, args={} ) {
        var fbForm          = formbuilderService.getForm( args.form ?: "" );
        var translationArgs = [ fbForm.name ?: "unknown form" ];

        if ( Len( Trim( args.instanceid ?: "" ) ) ) {
            translationArgs[1] &= " (" & args.instanceid & ")";
        }

        return translateResource( uri="widgets.FormBuilderForm:placeholder", data=translationArgs );
    }
}
```

## Filtering widgets in editors

As of Preside 10.7.0, you can limit the widgets that are selectable in a given richeditor. To do so, use the `widgetCategories` attribute of the [[formcontrol-richeditor]] form control. For example, in a form:

```xml
    <field name="newsletter_body" control="richeditor" widgetCategories="email,newsletter" />

    ...
```

Or, in a Preside Object:

```luceescript
property name="newsletter_body" type="string" dbtype="text" widgetCategories="email,newsletter";
```

If a widget does not specify any categories, a category of "default" will be used. Similarly, if no `widgetCategories` attribute is supplied for the richeditor control, it will be assumed to be "default". With this in mind, if you wish to have a widget categorised for specific scenarios, but also wish it to appear in default richeditor configurations, you should explicitly add the "default" category:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form i18nBaseUri="widgets.myWidget:" categories="default,mySpecialCategory">
    <tab id="default">
        <!-- ... -->
```---
id: sitetreenavigationmenus
title: Sitetree navigation menus
---

## Overview

A common task for CMS driven websites is to build navigation menus based on the site tree. Preside provides two extendable viewlets (see [[viewlets]]) to aid in rendering such menus with the minimum of fuss; `core.navigation.mainNavigation` and `core.navigation.subNavigation`.

## Main navigation

The purpose of the main navigation viewlet is to render the menu that normally appears at the top of a website and that is usually either one, two or three levels deep. For example:

```lucee
<nav role="navigation">
    <ul class="nav navbar-nav">
        <li class="hiddex-sm home-nav"><a href="/"><span class="fa fa-home"></span></a></li>

        #renderViewlet( event="core.navigation.mainNavigation", args={ depth=2 } )#
    </ul>
</nav>
```

This would result in output that looked something like this:

```html
<nav class="site-navigation" role="navigation">
    <ul class="nav navbar-nav">
        <li class="hiddex-sm home-nav"><a href="/"><span class="fa fa-home"></span></a></li>

        <!-- start of "core.navigation.mainNavigation" -->
        <li class="active">
            <a href="/news.html">News</a>
        </li>
        <li class="dropdown">
            <a href="/about.html">About us</a>
            <ul class="dropdown-menu" role="menu">
                <li><a href="/about/team.html">Our team</a></li>
                <li><a href="/about/offices.html">Our offices</a></li>
                <li><a href="/about/ethos.html">Our ethos</a></li>
            </ul>
        </li>
        <li>
            <a href="/contact.html">Contact</a>
        </li>
        <!-- end of "core.navigation.mainNavigation" -->
    </ul>
</nav>
```

>>> Notice how the core implementation does not render the outer `<ul>` element for you. This allows you to build navigation items either side of the automatically generated navigation such as login links and other application driven navigation.

### Viewlet options

You can pass the following arguments to the viewlet through the `args` structure:

<div class="table-responsive">
    <table class="table">
        <thead>
            <tr>
                <th>Name</th>
                <th>Description</th>
            </tr>
        </thead>
        <tbody>
            <tr><td>`rootPage`</td> <td>ID of the page whose children make up the top level of the menu. This defaults to the site's homepage.</td></tr>
            <tr><td>`depth`</td>    <td>Number of nested dropdown levels to drill into. Default is 1, i.e. just render the immediate children of the root page and have no drop downs</td></tr>

            <tr>
                <td>`ulNestedClass`</td>
                <td>You can change the sub menu UL class using this variable. Default:'dropdown-menu'</td>
            </tr>

            <tr>
                <td>`liCurrentClass`</td>
                <td>You can change the class of the current active li using this variable. Default:'active'</td>
            </tr>

            <tr>
                <td>`liHasChildrenClass`</td>
                <td>You can change the sub menu li class using this variable. Default:'dropdown'</td>
            </tr>

            <tr>
                <td>`liHasChildrenAttributes`</td>
                <td>You can configure the addtional attributes for the li using this variable. Default:none</td>
            </tr>

             <tr>
                <td>`aCurrentClass`</td>
                <td>You can change the class of the current active link using this variable. Default:'active'</td>
            </tr>

            <tr>
                <td>`aHasChildrenClass`</td>
                <td>You can change the sub menu achor link class using this variable. Default:none</td>
            </tr>

            <tr>
                <td>`aHasChildrenAttributes`</td>
                <td>You can configure the additional attributes for sub menu achor link using this variable. Default:none</td>
            </tr>
        </tbody>
    </table>
</div>

### Overriding the view

You might find yourself in a position where the HTML markup provided by the core implementation does not suit your needs. You can override this markup by providing a view at `/views/core/navigaton/mainNavigation.cfm`. The view will be passed a single argument, `args.menuItems`, which is an array of structs whose structure looks like this:

```luceescript
[
    {
        "id"       : "F9923DE1-9B2D-4544-A4E7F8E198888211",
        "title"    : "News",
        "active"   : true,
        "children" : []
    },
    {
        "id"       : "F9923DE1-9B2D-4544-A4E7F8E198888A6F",
        "title"    : "About us",
        "active"   : false,
        "children" : [
            {
                "id"       : "F9923DE1-9B2D-4544-A4E7F8E198888000",
                "title"    : "Our team",
                "active"   : false,
                "children" : []
            },
            {
                "id"       : "F9923DE1-9B2D-4544-A4E7F8E198888FF8",
                "title"    : "Our offices",
                "active"   : false,
                "children" : []
            },
            {
                "id"       : "F9923DE1-9B2D-4544-A4E7F8E1988887FE",
                "title"    : "Our ethos",
                "active"   : false,
                "children" : []
            }
        ]
    },
    {
        "id"       : "F9923DE1-9B2D-4544-A4E7F8E19888834A",
        "title"    : "COntact us",
        "active"   : false,
        "children" : []
    }
]
```

This is what the core view implementation looks like:

```lucee
<cfoutput>
    <cfloop array="#( args.menuItems ?: [] )#" index="i" item="item">
        <li class="<cfif item.active>active </cfif><cfif item.children.len()>dropdown</cfif>">
            <a href="#event.buildLink( page=item.id )#">#item.title#</a>
            <cfif item.children.len()>
                <ul class="dropdown-menu" role="menu">
                    <!-- NOTE the recursion here -->
                    #renderView( view='/core/navigation/mainNavigation', args={ menuItems=item.children } )#
                </ul>
            </cfif>
        </li>
    </cfloop>
</cfoutput>
```

## Sub navigation

The sub navigation viewlet renders a navigation menu that is often placed in a sidebar and that shows siblings, parents and siblings of parents of the current page. For example:

```
News
*Events and training*
    Annual Conference
    *Online*
        Free webinars
        *Bespoke online training* <-- current page
About us
Contact us
```

This viewlet works in exactly the same way to the main navigation viewlet, however, the HTML output and the input arguments are very slightly different:

### Viewlet options

<div class="table-responsive">
    <table class="table">
        <thead>
            <tr>
                <th>Name</th>
                <th>Description</th>
            </tr>
        </thead>
        <tbody>
            <tr><td>`startLevel`</td> <td>At what depth in the tree to start at. Default is 2. This will produce a different root page for the menu depending on where in the tree the current page lives</td></tr>
            <tr><td>`depth`</td>      <td>Number of nested menu levels to drill into. Default is 3.</td></tr>
        </tbody>
    </table>
</div>

### Overriding the view

Override the markup for the sub navigation viewlet by providing a view file at `/views/core/navigaton/subNavigation.cfm`. The view will be passed two arguments, `args.menuItems` and `args.rootTitle`. The `args.menuItems` argument is the nested array of menu items. The `args.rootTitle` argument is the title of the root page of the menu (whose children makeup the top level of the menu).

The core view looks like this:

```lucee
<cfoutput>
    <cfloop array="#( args.menuItems ?: [] )#" item="item">
        <li class="<cfif item.active>active </cfif><cfif item.children.len()>has-submenu</cfif>">
            <a href="#event.buildLink( page=item.id )#">#item.title#</a>
            <cfif item.children.len()>
                <ul class="submenu">
                    #renderView( view="/core/navigation/subNavigation", args={ menuItems=item.children } )#
                </ul>
            </cfif>
        </li>
    </cfloop>
</cfoutput>
```

## Crumbtrail

The crumbtrail is the simplest of all the viewlets and is implemented as two methods in the request context and as a viewlet with just a view (feel free to add your own handler if you need one).

The view looks like this:

```lucee
<!-- /preside/system/views/core/navigation/breadCrumbs.cfm -->
<cfset crumbs = event.getBreadCrumbs() />
<cfoutput>
    <cfloop array="#crumbs#" index="i" item="crumb">
        <cfset last = i eq crumbs.len() />

        <li class="<cfif last>active</cfif>">
            <cfif last>
                #crumb.title#
            <cfelse>
                <a href="#crumb.link#">#crumb.title#</a>
            </cfif>
        </li>
    </cfloop>
</cfoutput>
```

>>> Note that again we are only outputting the `<li>` tags in the core view, leaving you free to implement your own list wrapper HTML.

### Request context helper methods

There are two helper methods available to you in the request context, `event.getBreadCrumbs()` and `event.addBreadCrumb( title, link, menuTitle )`.

The `getBreadCrumbs()` method returns an array of the breadcrumbs that have been registered for the request. Each breadcrumb is a structure containing `title`, `link` and `menuTitle` keys.

The `addBreadCrumb()` method allows you to append a breadcrumb item to the current stack. It requires you to pass both a title and a link for the breadcrumb item. The menuTitle is optional, and if omitted or empty will default to the title.

>>> The core site tree page handler will automatically register the breadcrumbs for the current page.
---
id: data-export-templates
title: Data export templates
---

## Overview

As of **10.19.0**, the platform offers the ability for developers to define custom "Export templates". The intention of these templates is to allow developers to hard-code export selectData arguments and column titles for specific export scenarios. These templates can then be used seamlessly with the [[dataexports|Data Export system]] in Preside.

<iframe width="560" height="315" src="https://www.youtube.com/embed/gBlMyEcIhdQ" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Creating a data export template

There are three key elements to creating your own template:

1. A convention based handler, implementing a number of interface methods of your choosing
2. Optional preside form definitions to allow users to configure their export for your template
3. Optional i18n entry to have your template appear nicely to end users when browsing saved exports

### Convention based handler

The convention based handler is the only required element in creating a custom data export template. The handler must live under `/handlers/dataExportTemplates/` and the name of the file will be the ID of the template.

The following code snippet provides documentation on all of the available methods that you can choose to use to define your custom behaviour of your export template:

```luceescript
component {

	/**
	 * Optionally return an array of exporters that your template
	 * supports. Preside comes with "csv" and "excel" exporters out
	 * of the box. You can and may wish to develop further custom
	 * exporters for your template.
	 * 
	 * @objectName The name of the object whose export is being configured
	 */
	private array function getAllowedExporters( event, rc, prc, objectName ) {
		return [ "csv" ];
	}

	/**
	 * Optionally return an array of selectFields to pass to selectData()
	 * 
	 * @objectName     The name of the object whose export is being configured
	 * @templateConfig A struct containing user chosen custom config options for your template
	 */
	private array function getSelectFields( event, rc, prc, objectName, templateConfig, suppliedFields ) {
		
	}

	/**
	 * Optionally return a field to title mapping (struct) for our export
	 *
	 * @objectName     The name of the object whose export is being configured
	 * @templateConfig A struct containing user chosen custom config options for your template
	 * @selectFields   Array of the select fields that will be passed to selectData call
	 */
	private struct function prepareFieldTitles( event, rc, prc, objectName, templateConfig, selectFields ) {
		// e.g.

		return {
			  field_name_a = "Field A"
			, field_name_b = "Field B"
			, // etc.
		}
	}

	/**
	 * Optional method to dynamically get the form name to use when configuring
	 * the export after user hits the "Export" button
	 *
	 * @objectName   The name of the object whose export is being configured
	 * @baseFormName The name of the base form being used. i.e. you should create a form based on this one
	 */
	private string function getConfigFormName( event, rc, prc, objectName, baseFormName ){

	}

	/**
	 * Optional method to dynamically set any renderForm arguments for the
	 * export config form
	 *
	 * @objectName     The name of the object whose export is being configured
	 * @renderFormArgs Struct of arguments for the renderForm() method. Modify this struct to dynamically effect the rendering of the form
	 *
	 */
	preRenderConfigForm( event, rc, prc, objectName, renderFormArgs ){

	}

	/**
	 * Optional method to return user supplied config from any custom
	 * save/configure form submissions for your template.
	 *
	 * @objectName The name of the object whose configuration is being set/saved
	 */
	private struct function getSubmittedConfig( event, rc, prc, objectName ) {
		// e.g.

		return { my_custom_option=rc.my_custom_option ?: "" };
	}

	/**
	 * Optional method to return a struct of data that will be passed
	 * as "meta" to the data exporter. i.e. Excel exporter may use this to 
	 * set meta data on the document.
	 * 
	 * @objectName     The name of the object whose export is being run
	 * @templateConfig A struct containing user chosen custom config options for your template
	 *
	 */
	private struct function getExportMeta( event, rc, prc, objectName, templateConfig ){

	}
	
	/**
	 * Optional method to dynamically effect selectData arguments
	 * just before the data is selected from the db.
	 *
	 * @objectName     The name of the object whose export is being run
	 * @templateConfig A struct containing user chosen custom config options for your template
	 * @selectDataArgs A struct containing the arguments that are about to be sent to selectData(). Modify this struct to effect the outcome
	 *
	 */
	private void function prepareSelectDataArgs( event, rc, prc, objectName, templateConfig, selectDataArgs ){
		// e.g.
		selectDataArgs.savedFilters = selectDataArgs.savedFilters ?: [];
		ArrayAppend( selectDataArgs.savedFilters, "customSavedFilterForMyExportTemplate" );
	}
	
	/**
	 * Optional method to takeover rendering raw records for the export
	 *
	 * @objectName     The name of the object whose export is being run
	 * @templateConfig A struct containing user chosen custom config options for your template
	 * @records        Query containing the records that will be exported. To effect the rendering, loop over these and change the values for any columns you wish to transform
	 */
	private any function renderRecords( event, rc, prc, objectName, templateConfig, records ){
		// e.g.
		for( var i=1; i<=records.recordCount; i++ ) {
			records.my_column[ i ] = renderContent( "renderer", records.my_column[ i ] ); // or something simpler - important to make this as efficient as possible if expecting large data sets
		}
	}
	
	/**
	 * If you have multiple optional exporters, you may implement this optional
	 * method to state the default exporter to set when a user first triggers
	 * the export config form.
	 *
	 * @objectName The name of the object whose export is being configured
	 */
	private string function getDefaultExporter( event, rc, prc, objectName ){

	}
	
	/**
	 * Optional method to return a *default* filename for exporting/saving an export
	 * for your template. If you do not implement this, the system will use the
	 * object name combined with date of the export.
	 *
	 * @objectName The name of the object whose export is being configured
	 *
	 */
	private any function getDefaultFilename( event, rc, prc, objectName ){
		return "my-custom-export";
	}
}
```

### Convention based form definitions

**Note:** when implementing custom configuration fields in convention based forms, you will also want to implement the `getSubmittedConfig()` method in your handler (above).

#### Configure export form

This form is used to render configuration options for the admin user when they first hit the "Export" button from a data table. You can implement this override simply by creating a form at `/forms/dataExportTemplate/{templateId}/config.xml`.

**Note: The form will be merged with the base form provided by the system**: [[form-dataexportexportconfigurationbase]]. 

For example, the "default", system export template implements it as follows:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form i18nBaseUri="cms:dataexport.config.form.">
	<tab id="default">
		<fieldset id="default">
			<field name="exportFields" control="dataExportPanelPicker" required="true" sortorder="20" />
		</fieldset>
	</tab>
</form>
```

#### Save export form

This form is used to render configuration options for the admin user when they are _saving_ an export for scheduling or repeat usage. You can implement this override simply by creating a form at `/forms/dataExportTemplate/{templateId}/save.xml`.

**Note: The form will be merged with the base form provided by the system**: [[form-dataexportsaveexportconfigurationbase]]. 

For example, the "default", system export template implements it as follows:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form>
	<tab id="filters">
		<fieldset id="fields" sortorder="10">
			<field binding="saved_export.fields" control="dataExportPanelPicker" required="true" sortorder="10" />
		</fieldset>
	</tab>
</form>
```

### I18n entries

The system automatically creates an [enum](/devguides/dataobjects.html#enum-properties), `dataExportTemplate` and populates it with the templates available to the system. You can therefore add an entry for each of your templates under `/enum/dataExportTemplate.properties`. For example:

```properties
myExportTemplate.label=My Custom Export Template
```

## Using data export templates

At this point in time, a data export template will only be used when explicitly passed to the `#objectDataTable()#` helper. If you do not specify an export template, the default template will be used (i.e. the system will continue as before). To specify a non-default template, set the `exportTemplate` arg. For example:

```luceescript
#objectDataTable( objectName="invoice", args={ exportTemplate="financeExportTemplate" } )#
```

**Note: A single data table can only use a single export template**. ---
id: csrf
title: CSRF Protection
---

The Preside platform comes with built-in CSRF protection for the admin application and provides APIs for making use of CSRF protection for your front end applications.

For more information on the CSRF attacks and how to prevent them, visit [https://www.owasp.org/index.php/Cross-Site_Request_Forgery_(CSRF)](https://www.owasp.org/index.php/Cross-Site_Request_Forgery_\(CSRF\)).

## Built in admin protection

The system automatically adds CSRF tokens into action URLs and validates them on request **when the admin coldbox action name ends with 'action'**. For this to work, you must use `event.buildAdminLink(...)` to build your URL. For instance:

```lucee
<form action="#event.buildAdminLink( linkto='dashboard.savePreferencesAction' )#">
<!-- ... -->
</form>
```

>>> You should **always** use `event.buildLink()` or `event.buildAdminLink()` to build your URLs!

## Configuring built-in admin protection

As of Preside 10.9.0, it is possible to either turn off admin CSRF protection entirely, or configure the CSRF token timeout. Both are configured in your application's `Config.cfc` file:

```luceescript
// turn off the feature altogether
settings.features.adminCsrfProtection.enabled = false;

// or, configure a different timeout
settings.csrf.tokenExpiryInSeconds = 60 * 60; // 1 hour expiry (default 20m)
```

## Using APIs for custom CSRF protection in your frontend applications

You can use `event.getCsrfToken()` and `event.validateCsrfToken()` to get and validate tokens in your requests. For example, you may have a custom frontend form that looks like this:

```lucee
<form action="#saveDetailsAction#" method="post">
	<input type="hidden" name="csrfToken" value="#event.getCsrfToken()#">
	<!-- ... -->
</form>
```

Then, in your "saveDetailsAction" handler:

```luceescript
function saveDetails( event, rc, prc ) {
	var requestData = event.getCollectionWithoutSystemVars();

	if ( !event.validateCsrfToken() ) {
		requestData.errorMessage = translateResource( "myapp:invalid.csrf.token.error" );
		
		setNextEvent( url=editDetailsUrl, persistStruct=requestData );
	}
}
```---
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
---
id: adminlefthandmenu
title: Modifying the administrator left hand menu
---

## Overview

Preside provides a simple mechanism for configuring the left hand menu of the administrator, either to add new main navigational sections, take existing ones away or to modify the order of menu items.

## Configuration

Each top level item of the menu is stored in an array that is set in `settings.adminSideBarItems` in `Config.cfc`. The core implementation looks like this:

```luceescript
component {

    public void function configure() {

        // ... other settings ...

        settings.adminSideBarItems = [
              "sitetree"
            , "assetmanager"
            , "datamanager"
            , "usermanager"
            , "websiteUserManager"
            , "systemConfiguration"
            , "updateManager"
        ];

        // ... other settings ...

    }
}
```

## Menu items

As of **10.17.0** each menu item should have a corresponding entry in the `settings.adminMenuItems` struct.

See [[adminmenuitems]] for documentation on specifying a menu item.

### Pre 10.17.0 implementation (still supported)

Prior to 10.17.0, all side bar items are implemented as a view that lives under a `/views/admin/layout/sidebar/` folder. This method is still supported, but deprecated in favour of the **Admin menu items** method above.

For example, for a 'sitetree' item, there existed a view at `/views/admin/layout/sidebar/sitetree.cfm` that looked like this:

```luceescript
// /views/admin/layout/sidebar/sitetree.cfm

if ( hasCmsPermission( "sitetree.navigate" ) ) {
    Echo( renderView(
          view = "/admin/layout/sidebar/_menuItem"
        , args = {
              active  = ListLast( event.getCurrentHandler(), ".") eq "sitetree"
            , link    = event.buildAdminLink( linkTo="sitetree" )
            , gotoKey = "s"
            , icon    = "fa-sitemap"
            , title   = translateResource( 'cms:sitetree' )
          }
    ) );
}
```

## Core view helpers

There are two core views that can be used when rendering your menu items, `/admin/layout/sidebar/_menuItem` and `/admin/layout/sidebar/_subMenuItem`.

### /admin/layout/sidebar/_menuItem

Renders a top level menu item.

#### Arguments

<div class="table-responsive">
	<table class="table">
		<thead>
			<tr>
				<th>Argument</th>
				<th>Description</th>
			</tr>
		</thead>
		<tbody>
			<tr><td>active</td>        <td>Boolean. Whether or not the current page lives within this part of the CMS.</td></tr>
			<tr><td>link</td>          <td>Where this menu item points to. Not needed when the menu item has a submenu.</td></tr>
			<tr><td>title</td>         <td>Title of the menu item</td></tr>
			<tr><td>icon</td>          <td>Icon class for the menu item. We use font awesome, so "fa-users" for example.</td></tr>
			<tr><td>subMenu</td>       <td>Rendered submenu items.</td></tr>
			<tr><td>subMenuItems</td>  <td>Array of sub menu items to render (alternative to supplying a rendered sub menu). Each item should be a struct with `link`, `title` and optional `gotoKey` keys</td></tr>
			<tr><td>gotoKey</td>       <td>Optional key that when used in combination with the `g` key, will send the user to the item's link. e.g. `g+s` takes you to the site tree.</td></tr>
		</tbody>
	</table>
</div>

#### Example

```lucee
<cfscript>
    subMenuItems = [];

    if ( hasCmsPermission( "mynewsubfeature.access" ) ) {
        subMenuItems.append( {
            link  = event.buildAdminLink( linkTo="mynewsubfeature" )
            , title = translateResource( uri="mynewsubfeature:menu.title" )
        } );
    }

    if ( hasCmsPermission( "myothernewsubfeature.access" ) ) {
        subMenuItems.append( {
              link  = event.buildAdminLink( linkTo="myothernewsubfeature" )
            , title = translateResource( uri="myothernewsubfeature:menu.title" )
        } );
    }
</cfscript>

#renderView( view="/admin/layout/sidebar/_menuItem", args={
      active       = ReFindNoCase( "my(other)?newsubfeature$", event.getCurrentHandler() )
    , title        = translateResource( uri="mynewfeature:menu.title" )
    , icon         = "fa-world-domination"
    , subMenuItems = subMenuItems
} )#
```

### /admin/layout/sidebar/_subMenuItem

Renders a sub menu item.

#### Arguments

<div class="table-responsive">
	<table class="table">
		<thead>
			<tr>
				<th>Argument</th>
				<th>Description</th>
			</tr>
		</thead>
		<tbody>
			<tr><td>link</td>    <td>Where this menu item points to.</td></tr>
			<tr><td>title</td>   <td>Title of the menu item</td></tr>
			<tr><td>gotoKey</td> <td>Optional key that when used in combination with the `g` key, will send the user to the item's link. e.g. `g+s` takes you to the site tree.</td></tr>
		</tbody>
	</table>
</div>

#### Example

```lucee
<cfif hasCmsPermission( "mynewsubfeature.access" )>
    #renderView( view="/admin/layout/sidebar/_subMenuItem", args={
          link    = event.buildAdminLink( linkTo="mynewsubfeature" )
        , title   = translateResource( uri="mynewsubfeature:menu.title" )
        , gotoKey = "f"
    } )#
</cfif>
```

## Examples

### Adding a new item

Firstly, add the item to our array of sidebar items in your site or extension's Config.cfc:

```luceescript
// ...

settings.adminSideBarItems.append( "mynewfeature" );

// ...
```

Finally, create the view for the side bar item:

```lucee
<!-- /views/admin/layout/sidebar/mynewfeature.cfm -->
<cfif hasCmsPermission( "mynewfeature.access" )>
    <cfoutput>
        #renderView( view="/admin/layout/sidebar/_menuItem", args={
              active       = ReFindNoCase( "mynewfeature$", event.getCurrentHandler() )
            , title        = translateResource( uri="mynewfeature:menu.title" )
            , link         = event.buildAdminLink( linkTo="mynewfeature" )
            , icon         = "fa-world-domination"
            , subMenuItems = subMenuItems
        } )#
    </cfoutput>
</cfif>
```

>>> In order for the calls to `hasCmsPermission()` and `translateResource()` to do anything useful, you will need to have setup the necessary permission keys (see [[permissioning]]) and resource bundle keys (see [[i18n]]).

### Remove an existing item

In your site or extension's `Config.cfc` file:

```luceescript
// ...

// delete the site tree menu item, for example:
settings.adminSideBarItems.delete( "sitetree" );

// ...
```
---
id: workingwithuploadedfiles
title: Working with uploaded files
---

Preside comes with its own Digital Asset Manager (see [[assetmanager]]) and in many cases this will meet your document / image uploading needs. However, there are scenarios in which the users of your website will upload files that will not warrant a presence in your asset manager and the following APIs and practices can be used to deal with these cases.

## The storage provider interface

Preside has a concept of a "Storage Provider" and provides an interface at `/system/services/fileStorage/StorageProvider.cfc`. A storage provider is a an API interface to any implementation of a system that can store and serve files. The system provides a concrete implementation using a regular file system which can be found at `/system/services/fileStorage/FileSystemStorageProvider.cfc`.

>>> The core asset manager system uses storage providers for its file storage.

Distinct storage provider instances can be created through Wirebox by mapping the storage provider class to an id and passing your custom configuration, i.e. the physical directories in which you will store files, or credentials for a CDN API, etc. Below is an example of creating a storage provider instance with your own file path in your application's `Wirebox.cfc` file (`/application/config/Wirebox.cfc`):

```luceescript
component extends="preside.system.config.WireBox" {

    public void function configure() {
        super.configure();

        var settings = getColdbox().getSettingStructure();

        map( "userProfileImageStorageProvider" ).to( "preside.system.services.fileStorage.FileSystemStorageProvider" )
            .initArg( name="rootDirectory" , value=settings.uploads_directory & "/profilePictures" )
            .initArg( name="trashDirectory", value=settings.uploads_directory & "/.trash" )
            .initArg( name="rootUrl"       , value="" );
    }

}
```

>>>>>> Having individual storage provider instances with their own distinct paths is a good way to organise your uploaded files and can provide you with granularity when dealing with permissions, etc.

### Example upload / download code

The following *example* code will upload a file into the storage provider we created in our example above:

```luceescript
property name="storageProvider" inject="userProfileImageStorageProvider";

public string function uploadProfilePicture(
      required string userId
    , required string fileExtension
    , required binary uploadedImageBinary
) {
    var filePath = "/#arguments.userId#.#arguments.fileExtension#";

    storageProvider.putObject( object=fileBinary, path=filePath );

    return filePath;
}
```

Downloading a file can be done through a specific core route (see [[routing]]), i.e. you can build a link to the direct download / serving of the file. The syntax is as follows:

```luceescript
var downloadLink = event.buildLink(
      fileStorageProvider = nameOfStorageProvider
    , fileStoragePath     = storagePathAsStoredInStorageProvider
    , filename            = optionalFileNameUserWillSeeWhenDownloading
);
```

So, for the example above, we might have:

```luceescript
var imageUrl = event.buildLink(
      fileStorageProvider = "userProfileImageStorageProvider"
    , fileStoragePath     = user.profileImagePath
);
```

## Applying access control

There is no built in access control for storage providers. However, the download logic served by the core route handler announces three interception points that you can use to inject your own access control logic. The interception points are:

* preDownloadFile
* onDownloadFile
* onReturnFile304

For access control, your most likely choice will be the `preDownloadFile` interception point. An example implementation might look like this:

```luceescript
component extends="coldbox.system.Interceptor" {

    // note: important to use Wirebox's 'provider' DSL here to delay
    // injection in our interceptors
    property name="websiteLoginService"    inject="provider:websiteLoginService";
    property name="myAccessControlService" inject="provider:myAccessControlService";

    public void function configure() {}

    public void function preDownloadFile( event, interceptData ) {
        var rc              = event.getCollection();
        var storageProvider = rc.storageProvider ?: "";
        var storagePath     = rc.storagePath     ?: "";
        var filename        = rc.filename        ?: ListLast( storagePath, "/" );

        if ( storageProvider == "myStorageProviderWithAccessControl" ) {
            if ( !websiteLoginService.isLoggedIn() ) {
                event.accessDenied( reason="LOGIN_REQUIRED" );
            }

            var hasAccess   = myAccessControlService.hasAccess(
                  documentPath = storagePath
                , userId       = websiteLoginService.getLoggedInUserId()
            );
            if ( !hasAccess ) {
                event.accessDenied( reason="INSUFFICIENT_PRIVILEGES" );
            }
        }
    }
}
```


---
id: healthchecks
title: External service health checks
---

## Introduction

As of **10.10.0**, Preside comes with an external service healthchecking system that allows your code to:

* Periodically check the up status of external services (e.g. every 30 seconds)
* Call `isUp( "myservice" )` or `isDown( "myservice" )` to check the result of the last status check, without calling the external service directly

## Registering a healthcheck

### In Config.cfc

First, you must register your healthcheck in your application or extension's `Config.cfc$configure()` method. The `settings.healthcheckServices` _struct_ is used to configure healtcheck services. The struct keys indicate the service ID, e.g. for an "ElasticSearch" healthcheck:

```luceescript
settings.healthcheckServices.ElasticSearch = {
	interval = CreateTimeSpan( 0, 0, 0, 10 ) // default is 30 seconds
};
```

Possible settings for your healthcheck services are:

* `interval`: must be a `timespan` default is `CreateTimeSpan( 0, 0, 0, 30 )`

### Create corresponding handler

For each configured service, there must be a corresponding handler with a `check()` method at: `/handlers/healtchcheck/serviceid.cfc`. For example, to create an `ElasticSearch` healthcheck, we'd create `/handlers/healthcheck/ElasticSearch.cfc`:

```luceescript
component {
	property name="elasticSearchService" inject="elasticSearchService";

	private boolean function check() {
		return elasticSearchService.ping();
	}
}
```

If the `check` action returns `true` the service is deemed to be up. Any other return value, or error thrown, will lead to the system marking the service as being down.

## Checking service health in your code

### Handlers and views

In your handlers and views, you can use the `isUp( serviceId )` and `isDown( serviceId )` helpers:

```luceescript
if ( isUp( "elasticsearch" ) ) {
	var results = elasticSearchService.search( ... );
} else {
	var results = searchFallBackService.search( ... );
}
```

### Services

Services can use the `$isUp( serviceId )` and `$isDown( serviceId )` methods from the [[api-presidesuperclass]]. See [[presidesuperclass]].

```luceescript
if ( $isDown( "elasticsearch" ) ) {
	var results = searchFallBackService.search( ... );
} else {
	var results = elasticSearchService.search( ... );
}
```

---
id: taskmanager
title: Task manager
---

As of v10.7.0, Preside comes with an built-in task management system designed for running and monitoring scheduled and ad-hoc tasks in the system. For example, you might have a nightly data import task, or an ad-hoc task for optimizing images.

Tasks are defined using convention and run in your full application context so have access to all your data and service layers. Each task is run as a background thread and can be monitored using the real time log view.

![Screenshot of taskmanager live log](images/screenshots/taskmanagerlogs.png)

The documentation is split into two sections:

* [[taskmanager-predefinedtasks]]
* [[taskmanager-adhoctasks]]---
id: taskmanager-adhoctasks
title: Task manager - ad-hoc tasks (10.9.0 and above)
---

As of v10.9.0, Preside allows you to create, run and optionally track, ad-hoc background tasks. For example, the core data export and form builder export functionality now runs in the background and uses a core Preside admin view to track and deliver the final download.

For predefined scheduled tasks, see [[taskmanager-predefinedtasks]].

![Screenshot of ad-hoc task live progress view](images/screenshots/adhoc-task.jpg)

## Creating and running a task

The [[adhoctaskmanagerservice-createtask]] method of the [[api-adhoctaskmanagerservice]] service will register a task and optionally allow you to run it.

>>> To make life easier, this method can be directly accessed in your handlers with just `createTask()`, or in your service objects with [[presidesuperclass-$createtask]]

Example usage:

```luceescript
// a fictional example, run the `Cleanup.cfc$tmpFiles` handler
// as a background task
createTask(
	  event  = "cleanup.tmpfiles"
	, args   = { maxAgeInDays=2 }
	, runNow = true
);
```

## Reporting task progress

The handler event that you use in the [[adhoctaskmanagerservice-createtask]] method receives three extra arguments from the system:

1. `args`: struct of args passed to the [[adhoctaskmanagerservice-createtask]]  method
2. `logger`: a logger object with which you can log progress. The logger uses the same interface as all LogBox loggers.
3. `progress`: a progress object with which you can report progress and set a result for your task (see [[api-adhoctaskprogressreporter]])

Use the `logger` and `progress` objects to log messages against the task, track level of completion and set a final result. Usage example:

```luceescript
// /application/handlers/Cleanup.cfc
component {

	private void function tmpFiles( event, rc, prc, args={}, logger, progress ) {
		var maxAgeInDays  = Val( args.maxAgeInDays ?: 1 )
		var filesToDelete = _getTmpFilesToDelete( maxAgeInDays );
		var totalFiles    = filesToDelete.len();
		var filesDeleted  = 0;

		for( var file in filesToDelete ) {
			FileDelete( file );
			filesDeleted++;

			// log at every 100 files to save DB bandwidth...
			if ( !filesDeleted mod 100 || filesDeleted == totalFiles ) {
				if ( progress.isCancelled() ) {
					abort;
				}

				progress.setProgress( 100 / totalFiles * filesDeleted );
				logger.info( "Deleted [#NumberFormat( filesDeleted )#] out of [#NumberFormat( totalFiles )#] tmp files" );
			}
		}

		progress.setResult( { success=true, filecount=filesDeleted } );
	}
}
```

>>> Notice the `progress.isCancelled()` call. You can optionally use this to abort execution of the task early, making any necessary cleanup code that you may need to execute.

## Delayed execution

You can delay execution of a task with the `runIn` argument. The `runIn` argument must be a `TimeSpan` object and can not be used in conjunction with `runNow=true`. For example:

```luceescript
// Set to run in 5 minutes time from now
createTask(
	  event  = "cleanup.tmpfiles"
	, args   = { maxAgeInDays=2 }
	, runIn  = CreateTimeSpan( 0, 0, 5, 0 )
);
```

## Automatically retrying failures

If your task fails, i.e. throws an error, you can optionally configure it to retry execution to a schedule using the `retryInterval` argument. This argument can either be a single struct, or an array of structs with the following form:

```luceescript
{
	  tries    = 3
	, interval = CreateTimeSpan( 0, 0, 5, 0 )
}
```

The `tries` key describes the number of attempts to make. The `interval` key describes the time to wait between attempts. For example:

```luceescript
// Retry failures after 5 minutes, 20 minutes, 1 hour and finally, 1 day
createTask(
	  event  = "cleanup.tmpfiles"
	, args   = { maxAgeInDays=2 }
	, runNow = true
	, retryInterval = [
		  { tries=1, CreateTimeSpan( 0, 0, 5 , 0) } // retry once after 5m
		, { tries=1, CreateTimeSpan( 0, 0, 20, 0) } // retry once after 20m
		, { tries=3, CreateTimeSpan( 0, 1, 0 , 0) } // retry three x after 1h
		, { tries=1, CreateTimeSpan( 1, 0, 0 , 0) } // retry once after 1d
	  ]
);
```

## Progress tracking UI for admin users

For tasks that require some action on completion and/or monitoring by the admin user that instigated them, you can hook into core admin handlers to follow progress. The following example illustrates the full cycle of this using the form builder export feature as an example:

```luceescript
// inject 'adhocTaskManagerService', required for getting task progress
// in result handler
property name="adhocTaskManagerService" inject="adhocTaskManagerService";

// user instigated 'export submissions' action
public void function exportSubmissions( event, rc, prc ) {
	var formId   = rc.formId ?: "";
	var theForm  = formBuilderService.getForm( formId );

	if ( !theForm.recordCount ) {
		event.adminNotFound();
	}

	// create task and get its ID
	var taskId = createTask(
		  event      = "admin.formbuilder.exportSubmissionsInBackgroundThread"
		, args       = { formId=formId }
		, runNow     = true
		, adminOwner = event.getAdminUserId()
		, title      = "cms:formbuilder.export.task.title"
		, resultUrl  = event.buildAdminLink( linkto="formbuilder.downloadExport", querystring="taskId={taskId}" )
		, returnUrl  = event.buildAdminLink( linkto="formbuilder.manageForm", querystring="id=" & formId )
	);

	// redirect to core 'adhoctaskmanager.progress' page with Task ID
	// this page shows progress bar and redirects to 'resultURL' on success
	setNextEvent( url=event.buildAdminLink(
		  linkTo      = "adhoctaskmanager.progress"
		, queryString = "taskId=" & taskId
	) );
}

// handler action that will perform the ad-hoc task in the background
private void function exportSubmissionsInBackgroundThread( event, rc, prc, args={}, logger, progress ) {
	var formId = args.formId ?: "";

	// here, the formBuilderService takes care of tracking
	// progress with the logger + progress objects
	formBuilderService.exportResponsesToExcel(
		  formId      = formId
		, writeToFile = true
		, logger      = arguments.logger   ?: NullValue()
		, progress    = arguments.progress ?: NullValue()
	);
}

// "result" URL, user automatically redirected here at end of progress
// because defined in "resultUrl" in "CreateTask" method
public void function downloadExport( event, rc, prc ) {
	var taskId          = rc.taskId ?: "";
	var task            = adhocTaskManagerService.getProgress( taskId );
	var localExportFile = task.result.filePath       ?: "";
	var exportFileName  = task.result.exportFileName ?: "";
	var mimetype        = task.result.mimetype       ?: "";

	if ( task.isEmpty() || !localExportFile.len() || !FileExists( localExportFile ) ) {
		event.notFound();
	}

	header name="Content-Disposition" value="attachment; filename=""#exportFileName#""";
	content reset=true file=localExportFile deletefile=true type=mimetype;

	adhocTaskManagerService.discardTask( taskId );
	abort;

}
```

### Configure Progress Tracking UI

As of Preside **10.16.0**, the progress tracking UI has few extra configurable options in query string as below:

- `hideTaskLog` : Send as `true` to hide the log section, default is `false`
- `hideCancel` : Send as `true` to disable cancel button, default is `false`
- `hideReturn` : Send as `true` to disable return button, default is `false`
- `hideBreadCrumbs` : Send as `true` to hide the UI breadcrumb, default is `false`

```luceescript
// ...

var hideTaskLog     = true;
var hideCancel      = true;
var hideReturn      = true;
var hideBreadCrumbs = true;

setNextEvent( url=event.buildAdminLink(
	  linkTo      = "adhoctaskmanager.progress"
	, queryString = "taskId=" & taskId & "hideTaskLog=" & hideTaskLog & "hideCancel=" & hideCancel & "hideReturn=" & hideReturn & "hideBreadCrumbs=" & hideBreadCrumbs
) );

// ...
```---
id: taskmanager-predefinedtasks
title: Task manager - pre-defined scheduled tasks
---

As of v10.7.0, Preside comes with an built-in task management system designed for running and monitoring scheduled and ad-hoc tasks in the system. For example, you might have a nightly data import task, or an ad-hoc task for optimizing images.

This page describes how you can pre-define tasks that will appear in the automatic scheduling UI. For ad-hoc background tasks, see [[taskmanager-adhoctasks]].

![Screenshot of taskmanager task list](images/screenshots/taskmanagertasks.png)


## Defining tasks

The system uses a coldbox handler, `Tasks.cfc`, to define tasks (it also supports a `ScheduledTasks.cfc` handler for backward compatibility).

* Each task is defined as a private action in the `Tasks.cfc` handler and decorated with metadata to give information about the task.
* The action must return a boolean value to indicate success or failure
* The action accepts a `logger` argument that should be used for all task logging - doing so will enable the live log view for your task.

For example:

```luceescript
// /handlers/Tasks.cfc
component {
	property name="elasticSearchEngine" inject="elasticSearchEngine";

	/**
	 * Rebuilds the search indexes from scratch, ensuring that they are all up to date with the latest data
	 *
	 * @priority         13
	 * @schedule         0 *\/15 * * * *
	 * @timeout          120
	 * @displayName      Rebuild search indexes
	 * @displayGroup     search
	 * @exclusivityGroup search
	 */
	private boolean function rebuildSearchIndexes( event, rc, prc, logger ) {
		return elasticSearchEngine.rebuildIndexes( logger=arguments.logger ?: NullValue() );
	}
}
```

### Scheduling tasks

Tasks can be given a default schedule, or defined as _not_ scheduled tasks using the `@schedule` attribute. The attribute expects a value of either `disabled` or an extended (6 point) cron definition in the following format:

```
* * * * * *
| | | | | | 
| | | | | +---- Day of the Week   (range: 1-7, 1 standing for Monday)
| | | | +------ Month of the Year (range: 1-12)
| | | +-------- Day of the Month  (range: 1-31)
| | +---------- Hour              (range: 0-23)
| +------------ Minute            (range: 0-59)
+-------------- Second            (range: 0-59)
```

>>> Note that there are multiple cron formats and most start with the `minute` definition and not `seconds`. However, the principal is the same in all cases. You can read more about Cron here: [https://en.wikipedia.org/wiki/Cron](https://en.wikipedia.org/wiki/Cron).


Some example cron definitions:

```luceescript
/**
 * Every 15 minutes
 * @schedule 0 *\/15 * * * *
 *
 * At 25 minutes past the hour, every 2 hours
 * @schedule 0 25 *\/2 * * *
 *
 * At 4:06 AM, only on Tuesday
 * @schedule 0 06 04 * * 2
 */
```

Note how we need to escape slashes (`/`) in the cron syntax with a backwards slash (`\`). i.e. regular cron syntax: `0 */15 * * * *` vs our escaped version `0 *\/15 * * * *`. This is because the regular syntax would end the CFML comment with `*/` and render everything after that useless.

>>> The UI of the task manager also uses cron syntax for defining the schedule of tasks.

#### Ad-hoc tasks

You can define tasks to explicitly have _no_ schedule, demanding that tasks are then either run programatically or manually through the admin user interface. To do so, set the `@schedule` attribute to disabled:

```luceescript
/**
 *
 * @schedule     disabled
 * @timeout      120
 * @displayName  Optimize images
 */
private boolean function optimizeImages( event, rc, prc, logger ) {
	myAwesomeImageService.doMagic( logger=argumnets.logger ?: NullValue() );
}
```

### Task priority

When tasks run on a schedule, the system currently only allows a single task to run at any one time. If two or more tasks are due to run, the system uses the `@priority` value to determine which task should run first. Tasks with _higher_ priority values will take priority over tasks with lower values.

### Timeouts

>>> As of 10.10.0, timeouts are no longer supported and will be ignored. All tasks will run until they expire themselves or until 100 years, whichever comes first.

Tasks can be given a timeout value using the `@timeout` attribute. Values are in seconds. If the timeout is reached, the system will terminate the running thread for the task using a java thread interrupt.

### Display groups

You can optionally use display groups to break-up the view of tasks in to multiple grouped tabs. For example, you may have a group for maintenance tasks and another group for CRM data syncs. Simply use the `@displayGroup` attribute and tasks with the same "display group" will be grouped together in tabs.

### Exclusivity groups

You can optionally use exclusivity groups to ensure that related tasks do not run concurrently. For example, you may have several data syncing tasks that would be problematic if they all ran at the same time.

By default, the exclusivity group for a task is set to the *display group* of the task.

It you set the exclusivity group of a task to `none`, the task can be run at any point in time.

Use the `@exclusivityGroup` attribute to declare your exclusivity groups per task (or leave alone to use display group).

>>> If no groups are specified, a default group of "default" will be used.

### Invoking tasks programatically

In cases where you need to start a background task as a result of some programmable event, you can call the [[taskmanagerservice-runtask]] method of the [[api-taskmanagerservice]] directly, or use the [[api-presidesuperclass]] [[presidesuperclass-$runtask]] method (see [[presidesuperclass]]). For example:

```luceescript
// /services/AssetManagerService.cfc
/**
 * @presideService
 * @singleton
 */
component {
	// ...

	public boolean function editFolderPermissions( ... ) {
		// ...

		$runTask( taskKey="moveAssets", args={ folder=arguments.folder } )

		// ...
	}

	// ...
}
```

## Gracefully shutting down tasks

As of Preside **10.10.0**, the system provides a helper method for detecting whether or not the current running thread has been "interrupted". For task manager tasks, this might happen because:

* An admin user has hit the "Kill task button"
* A developer has performed a **framework reinit** (`?fwreinit=true` or `reload all`)

When this happens, the system gives you the opportunity to detect shutdown and exit gracefully. You can do this with the [[presidesuperclass-$isinterrupted]] method of the [[api-presidesuperclass]], or by injecting the [[api-threadutil]] service into your handler/service and calling [[threadutil-isinterrupted|threadUtil.isInterrupted()]]. For example:


```luceescript
/**
 * My service
 *
 * @presideservice
 * @singleton
 */
component {

	// ...
	public boolean function runSomeLongTask( logger ) {

		do {
			if ( $isInterrupted() ) {
				logger.warn( "Aborting task gracefully..." );
				break;
			}

			_doMoreWork();
		} while( _moreWorkToDo() );

		return true;
	}
}
```

**AND/OR:**

```luceescript
// /handlers/Tasks.cfc
component {
	property name="threadUtil" inject="threadUtil";
	property name="myService"  inject="myService";


	/**
	 * Does a load of important work
	 *
	 * @priority     13
	 * @schedule     0 *\/15 * * * *
	 * @displayName  Run things
	 * @displayGroup Stuff
	 */
	private boolean function multitask( event, rc, prc, logger ) {
		return myService.taskOne( logger ?: NullValue() )
		    && !threadUtil.isInterrupted()
		    && myService.taskTwo( logger ?: NullValue() )
		    && !threadUtil.isInterrupted()
		    && myService.taskThree( logger ?: NullValue() );
	}
}
```
---
id: enabling-asset-queue
title: Enabling the asset processing queue
---

## Introduction

In **10.11.0**, we introduced a feature to queue the processing of asset derivatives using a simple database queue. The feature is disabled by default. You are able to enable the queue and also configure the background threads that subscribe to the queue.

## Enabling the feature

There are two key features that you can enable, `assetQueue` and `assetQueueHeartBeat`. The `assetQueue` feature controls whether or not asset derivative generation will be pushed to the queue, rather than processed inline. The `assetQueueHeartBeat` feature enables the background thread that will actually process derivative creation. For example, in your Config.cfc:

```luceescript
settings.features.assetQueue.enabled = true;
settings.features.assetQueueHeartBeat.enabled = true; // will not be enabled if assetQueue feature is disabled
```

### Configuring the queue subscriber

You can configure the behaviour of the asset queue "heartbeat" by setting the `settings.assetmanager.queue` struct:

```luceescript
settings.assetmanager.queue = {
	  concurrency = 8   // number of threads that will concurrenctly run and process the queue (default: 1)
	, batchSize   = 100 // number of assets to be processed by a thread before pausing for ~2 seconds (default: 100)
};
```


## Multi server environment example

The following example gives an outline of how you could configure a two server setup where one server will be responsible for serving web pages, and the second server will be responsible for processing images. In `Config.cfc`:


```luceescript
component extends="preside.system.config.Config" {

    public void function configure() {
        super.configure();

        // ...
        settings.features.assetQueue.enabled = true;

        environments.prodweb = "mysite.com";
		environments.prodbackend = "backend.mysite.com";

    }

    public void function prodweb() {
    	settings.features.assetQueueHeartBeat.enabled = false;
    }
    
    public void function prodbackend() {
    	settings.features.assetQueueHeartBeat.enabled = true;
    	settings.features.assetmanager.queue.concurrency = 8;
    }

}
```

>>> The above example uses ColdBox environments to achieve the configuration, but other approaches could be used. For example, you could inject environment variables into your application (see [[config]]).
---
id: assetmanager
title: Working with the asset manager
---

## Introduction

Preside provides an asset management system that allows users of the system to upload, and add information about, multimedia files. Files can be organised into a folder tree and folders can be configured with permission rules and upload restrictions.

![Screenshot showing asset manager homepage](images/screenshots/assetmanager.jpg)

## Data model

The metadata and folder structure of your assets are all stored in your application's database using [[dataobjects]]. The objects and their relationships are modelled below:

![Asset manager database model](images/diagrams/asset_manager_erd.png)

These objects can all be modified to take on requirements of your application. See the links below for reference documentation on each object:

* [[presideobject-asset_storage_location]]
* [[presideobject-asset_folder]]
* [[presideobject-asset]]
* [[presideobject-asset_version]]
* [[presideobject-asset_derivative]]
* [[presideobject-asset_meta]]

When making additions and modifications, you may also want to change the appearance of various forms for uploading and editing assets, folders, etc. Reference documentation on those forms can be found below:

* [[form-assetaddform]]
* [[form-assetaddthroughpickerform]]
* [[form-asseteditform]]
* [[form-assetnewversionform]]
* [[form-assetfolderaddform]]
* [[form-assetfoldereditform]]
* [[form-assetstoragelocationaddform]]
* [[form-assetstoragelocationeditform]]

## Integrating assets in your application

### Link to assets in your data model

To reference an asset in your own data model and page types, you should create a relationship property with the `asset` object. For instance, an 'Author' object that has a profile image property:

```luceescript
component {
    // ...
    property name="profile_image" relationship="many-to-one" relatedTo="asset" allowedTypes="image";
    // ...
}
```

Or a "Consultation" object that has many associated documents:

```luceescript
component {
    // ...
    property name="documents" relationship="many-to-many" relatedTo="asset";
    // ...
}
```

### Allow picking of assets in your forms

The [[formcontrol-assetpicker|Asset picker]] form control provides a GUI for selecting and uploading one or more assets in a form.

![Screenshot showing asset picker](images/screenshots/assetpicker.jpg)

The form control will *automatically* be used for object properties that have a relationship with the `asset` object. However, you can specify the control directly in a form (for a widget, for example) with:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form i18nBaseUri="widgets.mywidget:">
    <tab id="default">
        <fieldset id="default" sortorder="10">
            <field name="images" control="assetpicker" allowtypes="png,jpg" maxFileSize="512" multiple="true" />
        </fieldset>
    </tab>
</form>
```

### Getting a raw link to an asset

This can be done with:

```luceescript
event.buildLink(
      assetId    = idOfAsset
    , derivative = "optionalDerivative"
    , versionId  = optionalVersionId
);
```

Here, `assetId` is the ID of the asset whose link we want to build, `derivative` is the name of a configured asset derivative (see below), and `versionId` is the ID of a specific version of an asset.

### Render assets in your views

The `renderAsset()` helper function will render the asset referenced by the passed asset ID. It is a proxy to the [[assetrendererservice-renderasset]] method of the [[api-assetrendererservice]]. Usage looks like this:

```lucee
<cfoutput>
    <!-- ... -->
    #renderAsset(
          assetId = myauthor.profile_image
        , context = "preview"
        , args    = { derivative="authorprofile" }
    )#

    <!-- ... -->
</cfoutput>
```

### Image asset dimensions

*Introduced in 10.12.0*, the `getAssetDimensions()` helper function will return the dimensions of an image asset. It is a proxy to the [[assetmanagerservice-getAssetDimensions]] method of the [[api-assetmanagerservice]]. Usage looks like this:

```lucee
    dimensions = getAssetDimensions(
          id             = myauthor.profile_image
        , derivativeName = "authorprofile"
    );
```

A struct with `height` and `width` values will be returned (or an empty struct if not available for some reason), which can then be used in your HTML code.

### Create custom contexts for asset rendering

The [[assetrendererservice-renderasset]] method will choose a viewlet with which to render your asset based on:

1. The type of asset, or "super-type" of the asset
2. The supplied context

The type of the asset is simply its extension. A "super type" is the file type group, i.e. "image", "document", etc. Types and super types are configured in your application's `Config.cfc` file (see below).

The asset manager will try to use the most specific viewlet it can find to render your asset. For example, if the supplied asset was a *jpg image* and the supplied context was *"thumbnail"*, the system would go through the following viewlet names and use the first available one:

```
renderers.asset.jpg.thumbnail
renderers.asset.image.thumbnail
renderers.asset.jpg.default
renderers.asset.image.default
renderers.asset.default
```

A "banner" context viewlet for images could therefor be implemented as a view at `/application/views/renderers/asset/image/banner.cfm` and look like:

```lucee
<cfscript>
    id       = args.id    ?: "";
    label    = args.label ?: "";
    imageUrl = event.buildLink( assetId=id, derivative="bannerimage" );
</cfscript>
<cfoutput>
    <div class="banner-image">
        <img src="#imageUrl#" alt="#label#" title="#label#" />
    </div>
</cfoutput>
```

## Configuration

Overall configuration of asset manager behaviour is made in the `settings.assetmanager` struct in your application's `Config.cfc` file.

Valid keys are:

* **maxFileSize** This controls the default maximum file upload size in MB. The default value is 5MB.
* **types** Configures the allowed file types to be uploaded to the asset manager (see File types, below)
* **derivatives** Configures named derivates (see Derivatives, below)
* **folders** Configures system folders that will always be available in your asset manager (see System folders, below)

An example configuration section for the asset manager (`Config.cfc`):

```luceescript
settings.assetmanager.maxFileSize = 10;

settings.assetmanager.types.video.ogv = { serveAsAttachment=true, mimeType="video/ogg" };

settings.assetmanager.derivatives.leadimage = {
      permissions     = "inherit"
    , inEditor        = true
    , transformations = [ { method="resize", args={ width=800, height=400 } } ]
    , autoQueue       = [ "image" ]
};

settings.assetmanager.folders.profileImages = {
      label  = "Profile images"
    , hidden = false
    , autoQueue = []
    , children = {
            members    = { label="Members"    , hidden=false }
          , nonMembers = { label="Non-Members", hidden=false }
      }
};

settings.assetmanager.location.public    = ExpandPath( "/uploads/public" );
settings.assetmanager.location.private   = ExpandPath( "/uploads/private" );
settings.assetmanager.location.trash     = ExpandPath( "/uploads/.trash" );
settings.assetmanager.location.publicUrl = "//static.mysite.com/";
```

## File types

Configured file types allows you to specify the filetypes that are uploadable to the asset manager by default. File types are grouped into "super types", for example "image", and the configuration allows you to specify download behaviour and mimetype of each type. The structure of configuration is as follows:

```luceescript
settings.assetmanager.types.supertype.fileextension = {
      serveAsAttachment = trueOrFalse
    , mimetype          = stringMimeType
};
```

Here is an excerpt from the core configuration to give a fuller picture:

```luceescript
settings.assetmanager.types.image = {
      jpg  = { serveAsAttachment=false, mimeType="image/jpeg" }
    , jpeg = { serveAsAttachment=false, mimeType="image/jpeg" }
    , gif  = { serveAsAttachment=false, mimeType="image/gif"  }
    , png  = { serveAsAttachment=false, mimeType="image/png"  }
};

settings.assetmanager.types.document = {
      pdf  = { serveAsAttachment=true, mimeType="application/pdf"    }
    , csv  = { serveAsAttachment=true, mimeType="application/csv"    }
    , doc  = { serveAsAttachment=true, mimeType="application/msword" }
    , dot  = { serveAsAttachment=true, mimeType="application/msword" }

```

### Labelling

In addition to the file type configuration above, you are also able to supply labels for the file types and super types. These are displayed when choosing file type restrictions for uploading to your asset manager folders.

Labels are added in `/i18n/filetypes.properties` and take the form: `{typeOrSuperType}.picker.label=Human readable label`. For example:

```properties
image.picker.label=Image: any type
gif.picker.label=Image: gif
png.picker.label=Image: png
jpg.picker.label=Image: jpg
jpeg.picker.label=Image: jpeg
```

## Derivatives

Derivatives are transformed versions of an asset. This could be a particular crop of a picture, a preview image of a PDF, etc. They are configured in your application's `Config.cfc`, for example:

```luceescript
settings.assetmanager.derivatives.leadImage = {
      permissions     = "inherit"
    , inEditor        = true
    , autoQueue       = []
    , transformations = [ { method="shrinkToFit", args={ width=800, height=400 } } ]
};
```

Once defined, a derivative can then be used when building a link to an asset and in the core default contexts of `renderAsset()`. For example:

```luceescript
assetUrl = event.buildLink( assetId=myImageId, derivative="leadImage" );
// ...
renderedAsset = renderAsset( assetId=myImageId, args={ derivative="leadImage" } );

```

### Configuration options

#### Permissions

The `permissions` configuration option relates to access permissions defined on the core asset and how they should apply to the derivative. Valid values are "inherit" and "public". The default value is "inherit" and this means that the derivative will share the same access permissions as the asset that it is based on. Derivatives with `permissions` set to "public" will have no permissions checking at all, regardless of the permissions set on the base asset.

#### inEditor

A boolean value indicating whether or not the derivative should be selectable by system editors when embedding images in content. Derivatives with this option set to `true` appear in the "Preset" dropdown in the Image picker:

![Screenshot showing 'Preset' picker](images/screenshots/imagepresetpicker.jpg)

The default value is `false`. If set to `true`, you should also supply a human readable label for the derivative in a `i18n/derivatives.properties` file. This can be done using `{derivativeid}.title=Some title`:

```
leadimage.title=Lead image (800x400)
thumbnail.title=Thumbnail (100x100)
```

#### autoQueue

**As of 10.11.0**, and if the asset processing queue feature is enabled, a derivative can be configured to be automatically processed in the background as soon as a matching asset is uploaded.

The option expects an array of matching file types, or file type groups upon which it will auto queue the derivative for generation. For example:

```luceescript
settings.assetmanager.derivatives.thumnail = {
    autoQueue = [ "image", "pdf" ] // autoqueue for all images + pdfs
    // ...
}
```

See [[enabling-asset-queue]] for more details on the asset processing queue.

#### Transformations

An array of configured transformations that the original asset binary will be passed through in order to create a new version.

A transformation is defined as a CFML structure, with the following keys:

* **method (required)**: Method that matches a method implemented in the [[api-assettransformer]] service object
* **args (optional)**: Structure of arguments passed to the transformation *method*.
* **inputfiletype (optional)**: Only apply this transformation to images of this type. e.g. "pdf".
* **outputfiletype (optional)**: Expected output filetype of the transformation

An example using all of the above arguments, is the admin thumbnail derivative that works for both PDFs and images:

```luceescript
settings.assetmanager.derivatives.adminthumbnail = {
      permissions     = "inherit"
    , inEditor        = false
    , transformations = [
          { method="pdfPreview" , args={ page=1 }, inputfiletype="pdf", outputfiletype="jpg" }
        , { method="shrinkToFit", args={ width=200, height=200 } }
      ]
};
```

For more information on image transformations, see [[transformations]].

### Restricting application of derivatives

As of **10.11.5**, Preside allows you to configure image size limits for derivative generation so that you can protect your server from heavy image transformation operations that would be better performed offline. You can set a max width, height, resolution and even specify a file path to a placeholder image to use instead when images are too large. In `Config.cfc`:

```luceescript

settings.assetmanager.derivativeLimits.maxHeight     = 3000;      // default 0, no limit
settings.assetmanager.derivativeLimits.maxWidth      = 3000;      // default 0, no limit
settings.assetmanager.derivativeLimits.maxResolution = 2000*2000; // default 0, no limit
settings.assetmanager.derivativeLimits.tooBigPlaceholder = "/preside/system/assets/images/placeholders/largeimage.jpg" // this is the default
```

If an image breaches any of these limits, no derivatives will be generated for it. Instead, the placeholder image will be used.

## System folders

System folders are pre-defined asset manager folders that will always exist in your asset manager folder structure. They cannot be deleted through the admin UI and can optionally be completely hidden from the UI. They are configured in `Config.cfc`, for example:

```luceescript
settings.assetmanager.folders.profileImages = {
      label  = "Profile images"
    , hidden = false
    , children = {
            memberProfileImages    = { label="Members"    , hidden=false }
          , nonMemberProfileImages = { label="Non-Members", hidden=false }
      }
};
```

The purpose of system folders is to be able to programatically upload assets directly to a named folder that you know will exist. This can be achieved with the [[assetmanagerservice-addasset]] method:

```luceescript
assetManagerService.addAsset(
      fileBinary = uploadedFileBinary
    , fileName   = uploadedFileName
    , folder     = "memberProfileImages"
    , assetData  = { description="Uploaded profile image for #loggedInMemberName#", title=loggedInMemberName }
);
```
>>>> Asset titles must be unique within any given folder. If you are programatically uploading assets to the asset manager, you need to code for this uniqueness to avoid duplicate key errors.

## Storage providers and locations

The asset manager allows you to define and use multiple storage locations. For example, you might have a shared drive on your server for private documents, and an Amazon Cloudfront CDN for your public images. Once your locations have been configured, you are then able to map folders in the asset manager to different locations.

![Screenshot of storage location selection](images/screenshots/storagelocationselection.jpg)

### Storage providers

The system works with a concept of storage *providers*. The core system implements a single 'file storage' provider for you to use. Custom storage providers can be created by creating a CFC that adheres to the core [[api-storageprovider]] interface and by supplying configuration forms that can be used by administrators of the system to configure an instance of your provider.

Defining a custom provider is as follows:

#### 1. Create a CFC file

Create a CFC that implements the [[api-storageprovider]] interface, i.e.

```luceescript
compoment implements="preside.system.services.fileStorage.StorageProvider" {
    // ...
}
```

You will need to thoroughly read the [[api-storageprovider|interface documentation]] and be sure to implement each method appropriately. In addition, you will almost certainly want to implement an `init()` constructor method to take any configuration that your provider requires (i.e. security credentials, etc.).

#### 2. Declare the provider in config

You must declare the storage provider in your application's `Config.cfc` file, this is simply mapping an ID to a CFC path:

```luceescript
settings.storageProviders.myProvider = {
    class = "app.services.filestorage.MyProvider"
};
```

Here we declare a provider named "myProvider", whose CFC file lives at "app.services.filestorage.MyProvider".

#### 3. Provide a configuration form for the provider

You must provide a configuration form for the provider. This will be used by administrators when managing a specific storage location that uses your provider. By convention, this is expected to live at `/forms/storage-providers/{providerid}.xml`. In our example above, the form would live at `/forms/storage-providers/myProvider.xml`. The form fields defined here must map to arguments passed to your custom provider CFC's init() method.

>>> The form definition will be merged with either [[form-assetstoragelocationaddform]] or [[form-assetstoragelocationeditform]] depending on whether a storage location is being added or edited.

For example:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form i18nBaseUri="storage-providers.filesystem:">
    <tab id="default">
        <fieldset id="filesystem">
            <field sortorder="10" name="rootDirectory"  control="textinput" required="true" />
            <field sortorder="20" name="trashDirectory" control="textinput" required="true" />
        </fieldset>
    </tab>
</form>
```

#### 4. Provider i18n resources to describe the provider and its configuration

By convention, you must create a `.properties` file at `/i18n/storage-providers/{providerid}.properties`. For example: `/i18n/storage-providers/myProvider.properties`. It should contain `title`, `description` and `iconclass` keys to describe the provider itself plus any keys for describing form fields, etc. For example:

```properties
title=File system
description=The file system storage provider stores files in the local file system. Suitable for sites without any clustering requirements.
iconclass=fa-folder

field.rootDirectory.title=Root path
field.rootDirectory.placeholder=e.g. /uploads/assets
field.trashDirectory.title=Trash path
field.trashDirectory.placeholder=e.g. /uploads/.trash

error.creating.directory=The directory, {1}, does not exist and could not be created. Error: {2}. Please note, you must supply full directory paths
```

### Default location

The asset manager system works out of the box without the need to configure any storage locations through the UI. For this, it uses a default configured storage provider through Wirebox. The core configuration of this provider is located at `/system/config/Wirebox.cfc` and looks like this:

```luceescript
map( "assetStorageProvider" ).asSingleton().to( "preside.system.services.fileStorage.FileSystemStorageProvider" ).parent( "baseService" ).noAutoWire()
    .initArg( name="rootDirectory"   , value=settings.assetmanager.storage.public    )
    .initArg( name="privateDirectory", value=settings.assetmanager.storage.private   )
    .initArg( name="trashDirectory"  , value=settings.assetmanager.storage.trash     )
    .initArg( name="rootUrl"         , value=settings.assetmanager.storage.publicUrl );
```

#### Overriding the default storage location

This can be done in two ways. Firstly, you could change `settings.assetmanager.storage` settings to point to different physical paths (or full mapped ftp/s3/etc Lucee paths). This might be a mounted shared drive for example, or just a directory outside of the webroot (recommended). This can also be achieved with environment variables, for example:

```
# env vars:
PRESIDE_assetmanager.storage.public=sftp://user:pass@server.com/public
PRESIDE_assetmanager.storage.private=sftp://user:pass@server.com/private
PRESIDE_assetmanager.storage.trash=sftp://user:pass@server.com/.trash
PRESIDE_assetmanager.storage.publicUrl=//static.mysite.com
```


The second option would be to manually configure an entirely different Storage provider that maps to "assetStorageProvider". This would be done in your site's `/config/Wirebox.cfc` file, for example:

```luceescript
component extends="preside.system.config.WireBox" {

    public void function configure() {
        super.configure();

        var settings = getColdbox().getSettingStructure();

        if ( IsBoolean( settings.myProvider.enabled ?: "" ) && settings.myProvider.enabled ) {

            map( "assetStorageProvider" ).asSingleton().to( "app.services.fileStorage.MyProvider" ).noAutoWire()
                .initArg( name="apiKey"    , value=settings.myProvider.apiKey                 )
                .initArg( name="uploadPath", value=settings.myProvider.uploadPath & "/assets" )
                .initArg( name="trashPath" , value=settings.myProvider.uploadPath & "/.trash" )
                .initArg( name="rootUrl"   , value=settings.myProvider.rootUrl                );

        }
    }

}
```

>>> You should consider that your application may run in multiple environments and need to be able to configure these settings per environment. Using the technique above that uses ColdBox settings to configure your provider could help with that as these are able to be set per environment (see the [ColdBox documentation](https://coldbox.ortusbooks.com/getting-started/configuration/coldbox.cfc/configuration-directives/environments) for further details). If you're super smart and have beautifully setup environments, you could use environment variables to setup the settings, making your default storage provider configuration truly portable.
---
id: transformations
title: Image asset transformations
---

## Introduction

A derivative is defined with an array of configured **transformations** that the original asset binary will be passed through in order to create a new version.

A transformation is defined as a CFML structure, with the following keys:

* **method (required)**: Method that matches a method implemented in the [[api-assettransformer]] service object
* **args (optional)**: Structure of arguments passed to the transformation *method*.
* **inputfiletype (optional)**: Only apply this transformation to images of this type. e.g. "pdf".
* **outputfiletype (optional)**: Expected output filetype of the transformation

An example using all of the above arguments, is the admin thumbnail derivative that works for both PDFs and images:

```luceescript
settings.assetmanager.derivatives.adminthumbnail = {
      permissions     = "inherit"
    , inEditor        = false
    , transformations = [
          { method="pdfPreview" , args={ page=1 }, inputfiletype="pdf", outputfiletype="jpg" }
        , { method="shrinkToFit", args={ width=200, height=200 } }
      ]
};
```

## Available transformations

There are three transformation methods built in to Preside:

* shrinkToFit
* resize
* pdfPreview

### shrinkToFit

**shrinkToFit** will resize an image so it fits within the specified width and height, while maintaining the source image's aspect ratio.

The following settings can be passed to the method in the **args** struct:

* **width (required)**: Maximum width in pixels for the resulting image.
* **height (required)**: Maximum height in pixels for the resulting image.
* **quality (optional)**: The image quality to use when resizing the image. Available values are `highestQuality`, `highQuality`, `mediumQuality`, `highestPerformance`, `highPerformance` and `mediumPerformance`. Defaults to `highPerformance`.

### resize

**resize** will resize and crop an image if necesary, and is probably the more often used transformation.

The following settings can be passed to the method in the **args** struct:

* **width (optional)**: Width in pixels for the resulting image.
* **height (optional)**: Height in pixels for the resulting image.
* **quality (optional)**: The image quality to use when resizing the image. Available values are `highestQuality`, `highQuality`, `mediumQuality`, `highestPerformance`, `highPerformance` and `mediumPerformance`. Defaults to `highPerformance`.
* **maintainAspectRatio (optional)**: Whether or not the aspect ratio of the source image should be maintained when resizing. Defaults to `false`.
* **useCropHint (optional)**: **Introduced in 10.9.0**. Whether or not the image should be cropped according to the crop hint, if one is defined. Defaults to `false`.

Note that while **width** and **height** are both optional, *at least one of them* is required.

#### Resize with width *or* height

If only one dimension is specified, then the image will be resized so it matches that width or height. Setting **maintainAspectRatio** is irrelevant here, as it will always be true: the image is resized proportionally; the unspecified dimension is not constrained.

#### Resize with width *and* height

If both **width** and **height** are specified, but **maintainAspectRatio** is `false`, then the whole image will be resized to those dimensions. If the aspect ratio of the transformation does not match the aspect ratio of the source image, the image will be stretched either vertically or horizontally to fit the new aspect ratio.

If both **width** and **height** are specified, and **maintainAspectRatio** is `true`, then the image will be cropped to the largest area possible that matches the target aspect ratio. By default, this will be based around the centre point of the image. However, **as of 10.9.0**, the asset edit UI includes a **cropping** tab which allows you to set the **focal point** of the image. If this is set, then the cropping process will keep this focal point as close as possible to the centre of the resulting image.

Also **introduced in 10.9.0** are **crop hints**. In the same **cropping** tab of the asset edit UI, you can set an area of the image as a crop hint. If **useCropHint** is set to `true`, then the image will be pre-cropped to the smallest size that includes the whole of the crop hint *before* the resizing is applied.

#### Examples

The following examples show the different results from different **resize** arguments, based on this source image:

![Source image for resize examples](images/transformations/dragonfly.jpg)

---

```luceescript
{ method="resize", args={ width=300 } }
```

![Resized to 300 wide](images/transformations/dragonfly-300.jpg)

---

```luceescript
{ method="resize", args={ width=300, height=300 } }
```

![300x300, maintainAspectRatio=false](images/transformations/dragonfly-300x300-squeezed.jpg)

---

```luceescript
{ method="resize", args={ width=300, height=300, maintainAspectRatio=true } }
```

![300x300, maintainAspectRatio=true](images/transformations/dragonfly-300x300.jpg)

---

```luceescript
{ method="resize", args={ width=300, height=300, maintainAspectRatio=true } }
```

![300x300 with focal point](images/transformations/dragonfly-300x300-focal-point.jpg)

*Focal point set in the asset edit UI towards the left of the image*

---

```luceescript
{ method="resize", args={ width=300, height=300, maintainAspectRatio=true, useCropHint=true } }
```

![300x300 with crop hint](images/transformations/dragonfly-300x300-crop-hint.jpg)

*Crop hint set in the asset edit UI around the centre of the image*

## Developing custom transformations

**As of Preside 10.11.0**, Transformations are created as coldbox handlers with a convention based path of `assettransformers.{transformername}`. For example, the `resize` transformation has a corresponding private handler action at `/handlers/AssetTransformers.cfc$resize()`:

```luceescript
component {
	property name="imageManipulationService" inject="imageManipulationService";

	private binary function resize( event, rc, prc, args={} ) {
		return imageManipulationService.resize( argumentCollection=args );
	}

	// ...
}
```

Create your own handler actions and use the handler name in your transformations. Any arguments set in the derivative transformation config will be passed in the `args` structure sent to the handler action, along with a `binary` `asset` argument.

The handler must return a `binary` object that is the asset binary. A blank example:

```luceescript
// /application/handlers/AssetTransformers.cfc
component {

	private binary function doNothing( event, rc, prc, args={} ) {
		return args.asset;
	}

	// ...
}
```

```luceescript
// /application/config/Config.cfc
component extends="preside.system.config.Config" {

	public void function configure() {
		super.configure();

		// ...

		settings.assetManager.derivatives.example = {
			  permissions = "inherit"
			, transformations = [
				  { method="doNothing"  , args={} } // refers to our custom, pointless, transformation
				, { method="shrinkToFit", args={ width=200, height=200 } }
			  ]
		};
	}

```---
id: dataexports
title: Data exports
---

## Overview

As of **10.8.7**, Preside comes with a data export API with a simple UI built in to admin data tables. This export UI has been implented for all data manager grids, website users and redirect rules grids. The feature is turned off by default but we expect to enable it by default in a future version.

The platform also offers a concept of custom data exporters. A data exporter consists of a single handler action and an i18n `.properties` file to describe it.

As of **10.19.0**, the platform also offers the ability for developers to define custom "Export templates". See [[data-export-templates]]

### Enabling the feature

Enable the feature in your application's `Config.cfc` with:

```
settings.features.dataexport.enabled = true;
```

*Note: `read` operation must be allowed for the object*

### Define default exporter

Add `settings.dataExport.defaultExporter` in your application's `Config.cfc`. Example:

```
settings.dataExport.defaultExporter = "Excel";
```

### Configure save export permission key

As of Preside **10.16.0**, the save export permission key can be configured by `dataManagerSaveExportPermissionKey` annotation (Default value is set to `read`)

```luceescript
/**
 * @dataManagerSaveExportPermissionKey    saveExport
 */
component {
	// ...
}
```


### Customizing default export fields per object

Add the `@dataExportFields` annotation to your preside objects to supply an ordered list of fields that will be used as the _default_ list of fields for exports:

```luceescript
/**
 * @dataExportFields id,title,comment_count,datecreated,datemodifed
 *
 */
component {
	// ...
}
```

### Adding the export feature to your custom admin grids

If you are making use of the core object based data grids (i.e. `renderView( view="/admin/datamanager/_objectDataTable",...`), you can add the `allowDataExport` flag to the passed args to allow default export behaviour:

```luceescript
#renderView( view="/admin/datamanager/_objectDataTable", args={
	  objectName      = "event_delegate"
	, useMultiActions = false
	, datasourceUrl   = event.buildAdminLink( linkTo="ajaxProxy", queryString="action=delegates.getDelegatesForAjaxDataTables", queryString="eventId=" & eventId )
	, gridFields      = [ "active", "login_id", "display_name", "email_address", "last_request_made" ]
	, allowDataExport = true
	, dataExportUrl   = event.buildAdminLink( linkTo="delegates.exportAction", queryString="eventId=" & eventId )
} )#
```

Notice also the `dataExportUrl` argument. Use this to set custom permissions checks and additional filters before proxying to the core `admin.datamanager._exportDataAction` method:

```luceescript
// in /handlers/admin/Delegates.cfc ...

function exportAction( event, rc, prc ) {
	var eventId = rc.eventId ?: "";

	_checkPermissions( event=event, key="export" );

	runEvent(
		  event          = "admin.DataManager._exportDataAction"
		, prePostExempt  = true
		, private        = true
		, eventArguments = {
			  objectName   = "event_delegate"
			, extraFilters = [ { filter={ event=eventId } } ]
		  }
	);
}
```

### Using the export APIs directly

The [[api-dataexportservice]] provides an API to generate a data export file. See the [[dataexportservice-exportData]] method for details. In addition to the documented arguments, the method will also accept any arguments that are acceptable by the [[presideobjectservice-selectdata|PresideObjectService.selectData()]] method. For example:

```luceescript
var exporterDetail = dataExportService.getExporterDetails( "excel" );
var filename       = "Myexport." & exporterDetail.fileExtension;
var filePath       = dataExportService.exportData(
	  exporter     = "excel" // or "csv", or your customer exporter
	, objectName   = "event_booking"
	, selectFields = selectFieldsArray
	, fieldTitles  = { eventName="Event name", ... }
	, filter       = { booked_event=eventId }
	, autogroupby  = true
);

header name="Content-Disposition" value="attachment; filename=""#filename#""";
content reset=true file=filePath deletefile=true type=exporterDetail.mimeType;
abort;
```

The idea here is that you export a preside data object [[presideobjectservice-selectdata]] call directly to a file, using any fields and filters that you desire.

### Creating custom data exporters

The core system comes with a CSV exporter and an Excel exporter. The exporter logic is responsible for accepting data and some metadata about the export and for then producing a file.

#### Step 1: Create exporter handler

All exporter handlers must live under `/handlers/dataExporters/` folder. The name of the handler is considered the ID of the exporter. The CSV exporter, for example, lives at `/handlers/dataExporters/CSV.cfc`.

The handler must declare mime type and file extension in its component attributes and implement an `export` method. For example:

```luceescript
/**
 * @exportFileExtension csv
 * @exportMimeType      text/csv
 *
 */
component {

	property name="csvWriter" inject="csvWriter";

	private string function export(
		  required array  selectFields
		, required struct fieldTitles
		, required any    batchedRecordIterator
		,          struct meta
	) {
		// create a tmp file and instantiate TAB delimited CSV writer
		var tmpFile = getTempFile( getTempDirectory(), "CSVEXport" );
		var writer  = csvWriter.newWriter( tmpFile, Chr( 9 ) );
		var row     = [];
		var data    = "";

		try {
			// create title row
			for( var field in arguments.selectFields ) {
				row.append( arguments.fieldTitles[ field ] ?: "?" );
			}
			writer.writeNext( row );

			// repeatedly call batchedRecordIterator until
			// no data left, adding rows to our CSV
			do {
				data = arguments.batchedRecordIterator();
				for( var record in data ) {
					row  = [];
					for( var field in arguments.selectFields ) {
						row.append( record[ field ] ?: "" );
					}
					writer.writeNext( row );
				}
				writer.flush();
			} while( data.recordCount );

		} catch ( any e ) {
			rethrow;
		} finally {
			writer.close();
		}

		// return filepath of file containing our CSV
		return tmpFile;
	}
}
```

##### Arguments to the EXPORT method

**batchedRecordIterator**

An anonymous function that can be called repeatedly to get the next batch of data (a CFML query object). The function accepts no arguments. Example usage:

```luceescript
var data = "";
do {
	data = batchedRecordIterator();
	// ... your exporter logic for data
} while( data.recordCount );
```

**selectFields**

An array of fieldnames in the data. The order of this array should be respected for table based exports.

**fieldTitles**

A struct of human readable field _titles_ that correspond to the field _names_ in the `selectFields` array. For example:

```luceescript
selectFields = [ "field1", "field2", "field3" ];
fieldTitles  = {
	  field1 = "Field 1"
	, field2 = "Field 2"
	, field3 = "Field 3"
};
```

**meta**

A struct of arbitrary metadata to do with the export. This may be used to embed in a document for example. Keys may include `title`, `author`, `datecreated` and so on. Individual exporters may wish to use this metadata in their exported documents.

#### Step 2: Create exporter .properties file

A corresponding `.properties` file should live at `/i18n/dataExporters/{exporterId}.properties`. Three keys are required, `title`, `description` and `iconClass`. e.g.

```properties
title=CSV File
description=Download data in plain text CSV (Character Separated Values)
iconClass=fa-table
```

## Configuring CSV Export delimiter

The default delimiter used for CSV export is a comma. You can change this in `Config.cfc` by setting `settings.dataExports.csv.delimiter`:

```luceescript
// /application/config/Config.cfc
...
settings.dataExports.csv.delimiter = Chr( 9 ); // tab
...
```

## Configuring Export Fields Permission

As of Preside **10.16.0**, the export fields' permission can be controlled by `limitToAdminRoles` property attribute. It accepts multiple roles by comma delimiter list.

```luceescript
// /preside-objects/my_object.cfc
component {

    // ...
    property name="my_object_field" ... limitToAdminRoles="sysadmin,contentadmin";
    // ...

}
```

## Configuring default exclude fields

As of Preside **10.25.0**, you are able to configure default global fields to be excluded for data export by `settings.dataExports.defaults.excludeFields`:

```luceescript
// /application/config/Config.cfc
...
settings.dataExport.defaults.excludeFields = [ "id", "datecreated" ];
...
```

You also able to set the include or exclude fields for data export in the object attributes by setting `dataExportDefaultIncludeFields` or `dataExportDefaultExcludeFields`:

```luceescript
// /preside-objects/foo.cfc
/**
 * @dataExportDefaultIncludeFields    label,datecreated,datemodified
 */
component {
    ...
}
```

```luceescript
// /preside-objects/bar.cfc
/**
 * @dataExportDefaultExcludeFields    id,datecreated
 */
component {
    ...
}
```

## Configuring "expandable" many-to-one fields

![Screenshot showing example of a expanded many-to-one relationship field in export](images/screenshots/export-expanded-field-example.png)

As of Preside **10.25.0**, you are able to configure `many-to-one` relationship fields to be expanded and available when exporting an object. You able to configure this in the object level or object property level as below.

### Configure at object level

Enable or disable for all many-to-one fields on an individual object using the `dataExportExpandManytoOneFields` annotation:

```luceescript
// /preside-objects/foo.cfc
/**
 * @dataExportExpandManytoOneFields    true
 */
component {
    ...
}
```

### Configure at object property level

Two property attributes control the expansion behaviour:

1. Set `dataExportExpandFields` attribute to `true` on a `many-to-one` property to allow related object fields to be included in a data export, or a set of fields list of related object also allowed.
2. Set `excludeNestedDataExport` attribute to `true` on any property to prevent that property from being included as an option when the object is nested. Note that `excludeDataExport` still applies and excludes a property from any data export.

```luceescript
// /preside-objects/foo.cfc
component {

    // ...
    property name="bar"         relationship="many-to-one" relatedto="bar" dataExportExpandFields=true;
    property name="another_bar" relationship="many-to-one" relatedto="bar" dataExportExpandFields="bar_1,bar_2,bar_3";
    // ...

}


// /preside-objects/bar.cfc
component {

    // ...
    property name="bar_1" ... excludeNestedDataExport=true;
    property name="bar_2" ...;
    property name="bar_3" ...;
    // ...

}
```
---
id: viewlets
title: Viewlets
---

## Overview

Coldbox has a concept of viewlets ([see what they have to say about it in their docs](https://coldbox.ortusbooks.com/the-basics/event-handlers/viewlets-reusable-events)).

Preside builds on this concept and provides a concrete implementation with the `renderViewlet()` method. This implementation is used throughout Preside and is an important concept to grok when building custom Preside functionality (widgets, form controls, etc.).

## The Coldbox Viewlet Concept

Conceptually, a Coldbox viewlet is a self contained module of code that will render some view code after performing handler logic to fetch data. The implementation of a Coldbox viewlet is simply a private handler action that returns the rendered view (the handler must render the view itself). This action will be directly called using the `runEvent()` method. For example, the handler action might look like this:

```luceescript
private any function myViewlet( event, rc, prc, id=0 ) {
    prc.someData = getModel( "someService" ).getSomeData( id=arguments.id );
    return getPlugin( "renderer" ).renderView( "/my/viewlets/view" );
}
```

And you could render that viewlet like so:

```lucee
#runEvent( event="SomeHandler.myViewlet", prePostExempt=true, private=true, eventArguments={ id=2454 } )#
```

## The Preside renderViewlet() method

Preside provides a concrete implementation of viewlets with the `renderViewlet()` method. For the most part, this is simply a wrapper to `runEvent()` with a clearer name, but it also has some other differences to be aware of:

1. If the passed event does not exist as a handler action, `renderViewlet()` will try to find and render the corresponding view
2. It defaults the `prePostExempt` and `private` arguments to `true` (this is the usual recommended behaviour for viewlets)
3. It formalizes how viewlet arguments are passed to the handler / view. When passing arguments to a handler action or view, those arguments will be available directly in the `args` structure

### Example viewlet handler

Below is an example of a Preside viewlet handler action. It is much the same as the standard Coldbox viewlet handler action but receives an additional `args` structure that it can make use of and also passes any data that it gathers directly to the view rather than relying on the `prc` / `rc` (this is recommendation for Preside viewlets).

```luceescript
private any function myViewlet( event, rc, prc, args={} ) {
    args.someData = getModel( "someService" ).getSomeData( id=( args.id ?: 0 ) );

    return getPlugin( "renderer" ).renderView( view="/my/viewlets/view", args=args );
}
```

You could then render the viewlet with:

```lucee
#renderViewlet( event="SomeHandler.myViewlet", args={ id=5245 } )#
```

### Example viewlet without a handler (just a view)

Sometimes you will implement viewlets in Preside without a handler. You might find yourself doing this for custom form controls or widgets (which are implemented as viewlets). For example:

```lucee
<cfparam name="args.title" type="string" />
<cfparam name="args.description" type="string" />

<cfoutput>
    <h1>#args.title</h1>
    <p>#args.description#</p>
</cfoutput>
```

Rendering the viewlet:

```lucee
#renderViewlet( event="viewlets.myViewlet", args={ title="hello", description="world" } )#
```

## Reference

The `renderViewlet()` method is available to your handlers and views directly. In any other code, you will need to use `getController().renderViewlet()` where `getController()` would return the Coldbox controller instance. It takes the following arguments:

<div class="table-responsive">
    <table class="table">
        <thead>
            <tr>
                <th>Argument</th>
                <th>Type</th>
                <th>Required</th>
                <th>Description</th>
            </tr>
        </thead>
        <tbody>
            <tr><td>event</td>         <td>string</td>  <td>Yes</td> <td>Coldbox event string, e.g. "mymodule:myHandler.myAction"</td></tr>
            <tr><td>args</td>          <td>struct</td>  <td>No</td>  <td>A structure of arguments to be passed to the viewlet</td></tr>
            <tr><td>prePostExempt</td> <td>boolean</td> <td>No</td>  <td>Whether or not pre and post events should be fired when running the handler action for the viewlet</td></tr>
            <tr><td>private</td>       <td>boolean</td> <td>No</td>  <td>Whether or not the handler action for the viewlet is a private method</td></tr>
        </tbody>
    </table>
</div>
---
id: admin-applications
title: Creating multiple admin applications
---

As of v10.6.0, Preside offers the ability to define multiple admin applications. The "CMS" is the single default application and, if you define more than one application, your admin interface will receive a new application switcher:


![Screenshot showing an example application switcher](images/screenshots/application_switcher.jpg)

## Defining applications

Applications are defined in your systems `Config.cfc` file. The setting `settings.adminApplications` is an array containing definitions of applications. Applications can be added simply as an ID string, or a structure with detailed information about the application:

```luceescript
// Config.cfc

// simple configuration, using convention for individual settings
settings.adminApplications.append( "ems" );

// detailed configuration, equivalent to the above:
settings.adminApplications.append( {
      id                 = "ems"
    , feature            = "ems"
    , accessPermission   = "ems.access"
    , defaultEvent       = "admin.ems"
    , activeEventPattern = "^admin\.ems\..*"
    , layout             = "ems"
} );
```

### Features and permissions

To work fully, your admin application's will also need to define features and permissions for the application in Config.cfc. A minimum configuration could look like this:

```luceescript
// Config.cfc

settings.adminApplications.append( {
      id                 = "ems"
    , feature            = "ems"
    , accessPermission   = "ems.access"
    , defaultEvent       = "admin.ems"
    , activeEventPattern = "^admin\.ems.*"
    , layout             = "ems"
} );

settings.features.ems             = { enabled=true, siteTemplates=[ "*" ] };
settings.adminPermissions.ems     = [ "access" ];
settings.adminRoles.eventsManager = [ "ems.*" ];
```

See [[api-featureservice]] and [[cmspermissioning]] for more details on features and permissions.

### Layout

The system expects an alternative Coldbox layout for each application and defaults that layout to the ID of your application. This allows you to override the look and feel, and behaviour of the admin UI. For instance, if your application's "ID" was "ems", create a layout file at `/layouts/ems.cfm`. This layout file would be responsible for the entire HTML layout of the admin pages for this application.

>>>>>> The core "admin" layout might be a good place to start when thinking about building a new layout. It can be found at `/preside/system/layouts/admin.cfm`.

### Default event and 'active event pattern'

Your admin application should have a default landing page event handler. By default, this will be `admin.{appid}`, e.g. `admin.ems`. You can also supply a regex pattern that will be matched against the current coldbox event, to determine whether or not your application is active. The default for this is `^admin\.{appid}.*`. For our "ems" example, this means that all Coldbox events beginning with "admin.ems" will lead to the ems application being set as active.


The default handler might be look something like this:

```luceescript
// /handlers/admin/Ems.cfc

// notice that we extend base admin handler
component extends="preside.system.base.AdminHandler" {

// PRE HANDLER

    // preHandler useful for doing basic security checks,
    // and any other handler-wide logic
    function preHandler( event, rc, prc ) {
        super.preHandler( argumentCollection = arguments );

        if ( !isFeatureEnabled( "ems" ) ) {
            event.notFound();
        }

        _checkPermissions( argumentCollection=arguments, key="access" );

        prc.pageIcon = "calendar";
    }

// DIRECT PUBLIC ACTIONS
    public void function index() {
        // any required logic for your landing page
    }

// PRIVATE HELPERS
    private void function _checkPermissions( event, rc, prc, required string key ) {
        var permKey   = "ems." & arguments.key;
        var permitted =  hasCmsPermission( permissionKey=permKey );

        if ( !permitted ) {
            event.adminAccessDenied();
        }
    }
}
```

---
id: workingwiththericheditor
title: Working with the richeditor
---

## Overview

Preside uses [CKEditor](http://ckeditor.com/) for its richeditor.

Beyond the standard install, Preside provides custom plugins to interact with the CMS such as inserting images and documents from the Asset Manager, linking to pages in the site tree, etc. It also allows you to customize and configure the editor from your CFML code.

## Configuration

Default settings and toolbar sets can be configured in your site's `Config.cfc`. For example:

```luceescript
public void function configure() {
    super.configure();

    // ...

    settings.ckeditor = {};

    // default settings
    settings.ckeditor.defaults = {
          stylesheets           = [ "/css/admin/specific/richeditor/" ] // array of stylesheets to be included in editor body
        , configFile            = "/ckeditorExtensions/config.js"       // path is relative to the compiled assets folder
        , width                 = "auto"                                // default width of the editor, in pixels if numeric
        , minHeight             = 0                                     // minimum height of the editor, in pixels if numeric
        , maxHeight             = 300                                   // maximum autogrow height of the editor, in pixels if numeric
        , toolbar               = "full"                                // default toolbar set, see below
        , autoParagraph         = false                                 // should single-line content be wrapped in a <p> element
        , defaultConfigs        = {                                     // other configs can be appended to this default config option
              pasteFromWordDisallow  = [                                // elements to be stripped when pasting from Word
                  "span"  // Strip all span elements
                , "*(*)"  // Strip all classes
                , "*{*}"  // Strip all inline-styles
            ]
            , extraAllowedContent   = "img dl dt dd"                     // additional elements allowed in the editor (will not be stripped from source)
        }
    };



    // toolbar sets, see further documentation below
    settings.ckeditor.toolbars = {};
    settings.ckeditor.toolbars.full = 'Maximize,-,Source,-,Preview'
                                   & '|Cut,Copy,Paste,PasteText,PasteFromWord,-,Undo,Redo'
                                   & '|Find,Replace,-,SelectAll,-,Scayt'
                                   & '|Widgets,ImagePicker,AttachmentPicker,Table,HorizontalRule,SpecialChar,Iframe'
                                   & '|Link,Unlink,Anchor'
                                   & '|Bold,Italic,Underline,Strike,Subscript,Superscript,-,RemoveFormat'
                                   & '|NumberedList,BulletedList,-,Outdent,Indent,-,Blockquote,CreateDiv,-,JustifyLeft,JustifyCenter,JustifyRight,JustifyBlock,-,BidiLtr,BidiRtl,Language'
                                   & '|Styles,Format,Font,FontSize'
                                   & '|TextColor,BGColor';

    settings.ckeditor.toolbars.boldItalicOnly = 'Bold,Italic';
}
```

### Configuring toolbars

Preside uses a light-weight syntax for defining sets of toolbars that translates to the full CKEditor toolbar definition. The following two definitions are equivalent:

**CKEditor config.js**

>>> For `10.11.39` and above you can specify below config within `settings.ckeditor.defaults.defaultConfigs`

```js
CKEDITOR.editorConfig = function( config ) {
    config.toolbar = "mytoolbar"; //Or you can define this config in Config.cfc. e.g. settings.ckeditor.defaults.defaultConfigs.toolbar = "mytoolbar"

    config.toolbar_mytoolbar = [
        [
            [ 'Source', '-', 'NewPage', 'Preview', '-', 'Templates' ],                     // Defines toolbar group, '-' indicates a vertical divider within the group
            [ 'Cut', 'Copy', 'Paste', 'PasteText', 'PasteFromWord', '-', 'Undo', 'Redo' ], // Defines another toolbar group
            '/',                                                                           // Line break - next group will be placed in new line.
            [ 'Bold', 'Italic' ]                                                           // Defines another toolbar group
        ]
    ];
};
```

**Config.cfc equivalent**

```luceescript
public void function configure() {
    super.configure();

    // ...

    settings.ckeditor.defaults = {
        , toolbar = "mytoolbar"
    };

    // in the Preside version of the toolbar configuration, toolbar groups
    // are simply comma separated lists of buttons and dividers. Toolbar groups
    // are then delimited by the pipe ('|') symbol.
    settings.ckeditor.toolbars.mytoolbar = 'Source,-,NewPage,Preview,-,Templates'
                                        & '|Cut,Copy,Paste,PasteText,PasteFromWord,-,Undo,Redo'
                                        & '|/'
                                        & '|Bold,Italic';

    // the above toolbar string all on one line: 'Source,-,NewPage,Preview,-,Templates|Cut,Copy,Paste,PasteText,PasteFromWord,-,Undo,Redo|/|Bold,Italic'
}
```

#### Specifying non-default toolbars for form fields

You can define multiple toolbars in your configuration and then specify which toolbar to use for individual form fields (if you do not define a toolbar, the default will be used). An example, using a Preside form definition:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form>
    <tab>
        <fieldset>
            <field name="description" control="richeditor" toolbar="boldItalicOnly" label="widgets.mywidget:description.label"  />
        </fieldset>
    </tab>
</form>
```

You can also define toolbars inline:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form>
    <tab>
        <fieldset>
            <field name="description" control="richeditor" toolbar="Bold,Italic,Underline|Cut,Copy,Paste,PasteText,PasteFromWord,-,Undo,Redo" label="widgets.mywidget:description.label"  />
        </fieldset>
    </tab>
</form>
```

### Configuring stylesheets

The stylesheets configuration effects how content within the editor is displayed during editing. You will likely want to include your site's core styles so that the WYSIWYG experience is as close to the final product as possible.

Default stylesheets are configured as an array of stylesheet includes (see Config.cfc example above). Each item in the array will be expanded as a [Sticker](https://github.com/pixl8/sticker) include resource. For example:

```luceescript
settings.ckeditor.defaults.stylesheets = [ "/specific/richeditor/", "/core/", "bootstrap-css" ];
```

#### Specifying non-default stylesheets for form fields

You can define specific stylesheets for individual form controls by supplying a comma separated list:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form>
    <tab>
        <fieldset>
            <field name="description" control="richeditor" stylesheets="/specific/myCustomEditorStyles/,/core/" label="widgets.mywidget:description.label" />
        </fieldset>
    </tab>
</form>
```

### Configuring a custom CKEditor config file

For the most flexible configuration tweaking, you can define your own CKEditor `config.js` file:

```js
settings.ckeditor.defaults.configFile = "/path/to/my/custom/config/file.js"; // relative to your root assets folder
```

You can also define this inline:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form>
    <tab>
        <fieldset>
            <field name="description" control="richeditor" customConfig="/path/to/my/custom/config/file.js" label="widgets.mywidget:description.label" />
        </fieldset>
    </tab>
</form>
```

>>> The default configuration file can be found at `/preside/system/assets/ckeditorExtensions/config.js`


## Where the code lives (for maintainers and contributers)

We manage a custom build of the editor, including all the core plugins that we require, through our [own repository on GitHub](https://github.com/pixl8/Preside-Editor). In addition, any Preside specific extensions to the editor are developed and maintained in the [core repository](https://github.com/pixl8/Preside-CMS), they can be found at: `/system/assets/ckeditorExtensions`.

Finally, we have our own custom javascript object for building instances of the editor. It can be found at `/system/assets/js/admin/core/preside.richeditor.js`.

## Customizing the link picker

The richeditor link picker can be customized (as of 10.11.0). Key concepts:

* Link types
* Link Picker categories

### Link types

Link types are visible in the link picker as a list on the left hand side of the dialog. Examples are 'Site tree page', 'URL', etc.

As of 10.11.0, you are able to create your own link types. To do so, you will require the following:

#### 1. Properties file entry

An entry in `/i18n/cms.properties` matching the pattern: `ckeditor.linkpicker.type.{yourtype}`. This will be the title of your link type.

#### 2. Customize the core richeditor link form

Supply your own [[form-richeditorlinkform|/forms/richeditor/link.xml]] file that will **add a fieldset with the id of your link type to the 'basic' tab.**. For example:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form>
    <tab id="basic">
        <fieldset id="yourtype" sortorder="100">
            <field name="article" control="objectpicker" object="article" />
        </fieldset>
    </tab>
</form>
```

#### 3. Create handler for rendering link + default link title

Create a handler at, `/handlers/admin/linkpicker/yourtype.cfc`. It needs to implement _two_ methods. One to render the HREF of the link, the other to render default link text. Each handler method will receive the filled in link form data as its `args` struct. For example:

```luceescript
component {

    private string function getHref( event, rc, prc, args={} ) {
        return event.buildLink( articleid=args.article ?: "" );
    }

    private string function getDefaultLinkText( event, rc, prc, args={} ) {
        return renderLabel( "article", args.article ?: "" );
    }
}
```

#### Link Picker categories

Link picker categories can be applied to a richeditor instance to customize the link types that appear in the link picker. For example, you may have a richeditor for a wiki page that requires only a custom "Wiki" link type, and not the others.

Link picker categories are defined as a struct at `settings.ckeditor.linkPicker`. Each key is the id of a category and is defined as a struct with a single `types` key, an array of Link types.

The default Preside config defines a default category:

```luceescript
settings.ckeditor.linkPicker.default = {
    types = [ "sitetreelink", "url", "email", "asset", "anchor" ]
}
```

You can customize this by appending to the list of types (or removing items from it). You can also then define your own categories:

```
settings.ckeditor.linkPicker.wiki = { types=[ "wikipage" ] };
```

Finally, an instance of a richeditor can be assigned a link picker category with the `linkPickerCategory` attribute:

```<field name="content" control="richeditor" linkPickerCategory="wiki" />```---
id: routing
title: Routing
---

## Overview

Routing is the term used to describe how a URL gets mapped to actions and input variables in your application. In Preside, the action will be a [Coldbox event handler](https://coldbox.ortusbooks.com/the-basics/event-handlers) and the input variables will appear in your request context.

We use Coldbox's own routing system along with a Preside addition for handling dynamic routes. When creating your own custom routes, you are free to use either system.

URLs can be built with `event.buildLink()`. Different routing URLs will be generated depending on the arguments passed to the `buildLink()` function.

## Creating custom routes

To create custom routes for your site, you must create a `Routes.cfm` file in your `/application/config/` directory. In this file, you can create regular [ColdBox routes](https://coldbox.ortusbooks.com/the-basics/routing) as well as Preside routes. The following `routes.cfm` file registers a couple of Preside route handlers:

```luceescript
addRouteHandler( getModel( "myCustomRouteHandler" ) );
addRouteHandler( CreateObject( "app.routeHandlers.anotherCustomRouteHandler" ).init() );
```

### Preside Route Handlers

A Preside Route Handler is any CFC that implements a simple interface to handle routing. The interface looks like this:

```luceescript
interface {
    // match(): return true if the incoming URL path should be handled by this route handler
    public boolean function match( required string path, required any event ) {}

    // translate(): take an incoming URL and translate it - use the ColdBox event object to set variables and the current event
    public void    function translate( required string path, required any event ) {}

    // reverseMatch(): return true if the incomeing set of arguments passed to buildLink() should be handled by this route handler
    public boolean function reverseMatch( required struct buildArgs ) {}

    // build(): take incoming buildLink() arguments and return a URL string
    public string  function build( required struct buildArgs ) {}
}
```

An example route handler, that deals with custom URLs for a "My Profile" area of a website, might look like this:

```luceescript
component implements="preside.system.routeHandlers.iRouteHandler" {

    public boolean function match( required string path, required any event ) {
        return ReFindNoCase( "^/my-profile/", arguments.path );
    }

    public void function translate( required string path, required any event ) {
        var coldboxEventName = ReReplace( arguments.path, "^/my-profile/", "myprofilemodule:myprofile/" );

        coldboxEventName = ListChangeDelims( coldboxEventName, ".", "/" );

        if ( ListLen( coldboxEventName, "." ) lt 2 ) {
            coldboxEventName = coldboxEventName & "." & "index";
        }

        event.setValue( "event", coldboxEventName );
    }

    public boolean function reverseMatch( required struct buildArgs ) {
        return Len( Trim( buildArgs.linkTo ?: "" ) ) and ListFirst( buildArgs.linkTo, "." ) eq "myprofilemodule:myprofile";
    }

    public string function build( required struct buildArgs ) {
        var link = "/my-profile/#ListChangeDelims( ListRest( buildArgs.linkTo, "." ), "/", "." )#/";

        if ( Len( Trim( buildArgs.queryString ?: "" ) ) ) {
            link &= "?" & buildArgs.queryString;
        }

        return link;
    }
}
```

## URL Rewriting

In order for the core routes to work, URL rewrites need to be in place. Preside server distributions ship with the [Tuckey URL rewrite filter](http://tuckey.org/urlrewrite/) installed and expect to find a `urlrewrite.xml` file in your webroot. The Preside site skeleton builder creates one of these for you with the following rules which you are then free to modify and/or augment:

```xml
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE urlrewrite PUBLIC "-//tuckey.org//DTD UrlRewrite 4.0//EN" "http://www.tuckey.org/res/dtds/urlrewrite4.0.dtd">
<urlrewrite>
    <rule>
        <note>
            All request to system static assets that live under /preside/system/assets
            should go through Railo and will be rewritten to /index.cfm
        </note>
        <from>^/preside/system/assets/.*$</from>
        <to>%{context-path}/index.cfm</to>
    </rule>

    <rule>
        <note>
            All request to *.html or ending in / will be rewritten to /index.cfm
        </note>
        <from>^(/((.*?)(\.html|/))?)$</from>
        <to>%{context-path}/index.cfm</to>
    </rule>

    <rule>
        <note>
            Disable Lucee Context except for local requests
        </note>
        <condition type="remote-addr" operator="notequal">^(127\.0\.0\.1|0:0:0:0:0:0:0:1)$</condition>
        <from>^/lucee/.*$</from>
        <set type="status">404</set>
        <to>null</to>
    </rule>

     <rule>
        <note>
            All the following requests should not be allowed and should return with a 404
            We block any request to:

            * the application folder (where all the logic and views for your site lives)
            * the uploads folder (should be configured to be somewhere else anyways)
            * this url rewrite file!
        </note>
        <from>^/(application/|uploads/|urlrewrite\.xml\b)</from>
        <set type="status">404</set>
        <to>null</to>
    </rule>
</urlrewrite>
```

## Out-of-the-box routes

### Site tree pages

Any URL that ends with `.html` followed by an optional query string, will be routed as a site tree page URL. The "directories" and "filename" will correspond to the slugs of the pages in your tree. For example:

```
/about-us/meet-the-team/alex-skinner.html?showComments=true
```

will be routed to:

```luceescript
Coldbox event : core.SiteTreePageRequestHandler
Coldbox RC    : { showComments : true }
Coldbox PRC   : { slug : "about-us.meet-the-team.alex-skinner" }
```

and map to the site tree page:

```
/about-us
    /meet-the-team
        alex-skinner
```

>>>>>> You can build a link to a site tree page with `event.buildLink( page=idOfThePage )`

### Preside Admin pages and actions

Any URL that begins with `/(adminPath)` and ends in a forward slash followed by an optional query string, will be routed as a Preside admin request. Directory nodes in the URL will be translated to the ColdBox event.

>>> Your admin path can be configured in your site's `Config.cfc` file with the `settings.preside_admin_path` setting. The setting defaults to "preside_admin".

For example, assuming that `settings.preside_admin_path` has been set to "acme_cmsarea", the URL `/acme_cmsarea/sitetree/editPage/?id=F4554E4C-9347-4F7E-B5F862595BFC9EBF` will be routed to:

```luceescript
Coldbox event : admin.sitetree.editPage
Coldbox RC    : { id : "F4554E4C-9347-4F7E-B5F862595BFC9EBF" }
```

>>>>>> You can build a link to an admin event with `event.buildAdminLink( linkTo="sitetree.editPage", queryString="id=#pageId#" )` or `event.buildLink( linkTo="admin.sitetree.editPage", queryString="id=#pageId#" )`

### Asset manager assets

Assets stored in the asset manager are served through the application. Any URL that starts with `/asset` and ends with a trailing slash will be routed to the asset manager download action. URLs take the form: `/asset/(asset ID)/` or `/asset/(asset ID)/(ID or name of derivative)/`. So the URL, `/asset/F4554E4C-9347-4F7E-B5F862595BFC9EBF/`, is routed to:

```luceescript
Coldbox event : core.assetDownload
Coldbox RC    : { assetId : "F4554E4C-9347-4F7E-B5F862595BFC9EBF" }
```

and `/asset/F4554E4C-9347-4F7E-B5F862595BFC9EBF/headerImage/` becomes:

```luceescript
Coldbox event : core.assetDownload
Coldbox RC    : { assetId : "F4554E4C-9347-4F7E-B5F862595BFC9EBF", derivativeId : "headerImage" }
```

>>>>>> You can build a link to an asset with `event.buildAdminLink( assetId=myAssetId )` or `event.buildLink( assetId=myAssetId, derivative=derivativeId )`
---
id: adminloginproviders
title: Admin login providers
---

## Introduction

As of **10.10.0**, Preside comes with a system for providing alternative login providers for the admin system. The system expects you to:

* configure what providers are available to the application
* provide a login prompt UI for your provider that will be displayed in the login screen
* process the login with your own handler logic
* complete the login with helper methods provided by Preside

## Configuration

The configured admin login providers are a simple array defined in your application or extension's `Config.cfc` file. The default is:

```luceescript
settings.adminLoginProviders = [ "preside" ]; // 'preside' is the core admin login provider
```

You can override or extend this setting to render multiple login options in the login screen. For example:

```luceescript
public void function configure() {
	// ...

	ArrayAppend( settings.adminLoginProviders, "myCompanyActiveDirectory" );
	// or
	settings.adminLoginProviders = [ "myCompanyActiveDirectory", "preside" ];
	// or
	settings.adminLoginProviders = [ "myCompanyActiveDirectory" ];

	// ...
}
```

## Defining your login provider

The _only_ requirement for a login provider is that it must have a [[viewlets|viewlet]] to render a login prompt in the login form. The location of this viewlet must be `admin.loginprovider.{providerid}.prompt`. i.e. you can either implement a simple view at `/views/admin/loginProvider/myprovider/prompt.cfm` or a handler with `prompt()` method at `/handlers/admin/loginProvider/MyProvider.cfc`.

The viewlet will receive two args in its `args` struct:

* `postLoginUrl`: the ideal URL to redirect to once login is complete
* `position`: the position of the rendered prompt in the admin login screen. You may wish to present the prompt differently when it is the primary provider (e.g. position=1)

A simple example:

```lucee
<!-- /views/admin/loginprovider/oneClickLocalLogin/prompt.cfm -->
<cfoutput>
	<p class="text-center">
		<a class="btn btn-info" href="#event.buildAdminLink( "loginProvider.oneClickLocalLogin.dologin" )#">
			<i class="fa fa-key fa-fw"></i> 
			#translateResource( "cms:one.click.local.login.btn" )#
		</a>
	</p>
</cfoutput>
```

## Processing and completing login

The processing of actual login logic is up to you. However, once you have identified the user, you can log them into Preside with the `event.doAdminSsoLogin()` method.

Let's complete our `oneClickLocalLogin` provider example by providing the `dologin` action that the login button links to:

```luceescript
// /handlers/admin/loginprovider/OneClickLocalLogin.cfc
component {

	public void function dologin( event, rc, prc ) {
		// here we are hardcoding the user
		// so we can do 1 click login
		// for local dev. In practice, this
		// information will have been supplied
		// by your login provider (e.g. Google)

		var hardCodedLoginId  = "sysadmin";
		var hardCodedUserData = {
			  email_address = "test@test.com"
			, known_as      = "The Sys Admin"
		};

		// we call event.doAdminSsoLogin()
		// to log the user in without a password
		// and to complete the rest of the login 
		// logic for us
		event.doAdminSsoLogin( 
			  loginId              = hardCodedLoginId
			, userData             = hardCodedUserData
			, rememberLogin        = true
			, rememberExpiryInDays = 90
		);
	}

}
```---
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

### Update notice: caching and logged in web users

This feature has been patched so that full page caching is **disabled by default** for logged in website users. A new feature flag can be used to allow full page caching for logged in website users:

```luceescript
settings.features.fullPageCachingForLoggedInUsers.enabled = true; // false by default
```

This change was introduced in hotfixes: `10.12.33`, `10.13.25`, `10.14.32` and `10.15.25`. See [PRESIDECMS-2309](https://presidecms.atlassian.net/browse/PRESIDECMS-2309)

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

Obviously, if your site has a login functionality and displays personal information in pages to the logged in user - you need to ensure that these parts of the page are _not_ cached. Use either the `renderViewlet( ..., delayed=true )` technique, and/or, mark your personal info/non-cacheable viewlets with `@cacheable false`. The fact that system page types are _not_ cached by default should help with this also.---
id: selectdataviews
title: SelectData views
---

## Overview

**SelectData Views** are synonymous with SQL Views but for the [[dataobjects|Preside Data Objects system]]. In a nutshell, a SelectData view is a saved set of arguments that can be sent to the [[presideobjectservice-selectdata]] method.

**SelectData Views** were introduced in Preside **10.11.0**.

## Defining a view

**SelectData Views** are defined by implementing a convention based Coldbox handler action: `selectDataViews.{viewName}`. The handler must return a `struct` of arguments to be sent to `selectData()`. For example, the following handler CFC defines two simple views, `activeBlogPosts` and `inactiveBlogPosts`:

```luceescript
// /handlers/SelectDataViews.cfc
component {

    private struct function activeBlogPosts( event, rc, prc ) {
        return {
              objectName   = "blog_post"
            , filter       = { active = true }
            , selectFields = [ "id", "title", "category" ]
        };
    }

    private struct function inactiveBlogPosts( event, rc, prc ) {
        return {
              objectName = "blog_post"
            , filter     = { active = false }
        };
    }

}
```

## Using views

### Direct queries

You can directly query a view with the [[presideobjectservice-selectview]] method. For instance:

```luceescript
var activeBlogPosts = presideObjectService.selectView( "activeBlogPosts" );
```

### Relationship properties

You can also reference views from preside object properties using `relationship="select-data-view" relatedTo="nameOfview"`. The following Preside Object definition is for a `blog_category` object. It has a `one-to-many` relationship with the `blog_post` object and we can now create a relationship to the two views we defined above.

Furthermore, these relationships can be used in things like formula fields that can be used in data exports and data manager tables:


```luceescript
/**
 * @datamanagerGroup Blogs
 * @datamanagerGridFields label,active_post_count,inactive_post_count
 *
 */
component {
    property name="active_posts"   relationship="select-data-view" relatedto="activeBlogPosts"   relationshipKey="category";
    property name="inactive_posts" relationship="select-data-view" relatedto="inactiveBlogPosts" relationshipKey="category";

    property name="active_post_count"   formula="count( ${prefix}active_posts.id )"   type="numeric";
    property name="inactive_post_count" formula="count( ${prefix}inactive_posts.id )" type="numeric";
}
```

---
id: notifications
title: Notifications
---

## Overview

Preside comes with a system for raising notifications for the CMS admin users. These notifications may appear in a user's notification feed (see screenshot, below) and/or trigger notification emails. It is also possible to extend the notifications system so that you can have notifications raised in your team's IM tool of choice (Hipchat, Slack, etc.) or any other integration you can think of.

![Screenshot showing various programatically raised user notifications.](images/screenshots/notifications.png)

## Topics

Notifications are organised into *topics*. A topic might be something like 'Event booking cancelled', or 'User complaint'. In the screenshot above, you can see four notification topics, 'Bookings checked out', 'Invalid CRM contact data', 'Invoice paid' and 'New contact created'.

### Creating a topic

The first step is to register the topic in your application's config file. This can be done by appending its unique id to the `settings.notificationTopics` array. For example:

```luceescript
// /application/config/Config.cfc
component extends="preside.system.config.Config" {

    public void function configure() {
        super.configure();

        // other settings...

        settings.notificationTopics.append( "customerComplaintFiled" );
    }
}
```

In order for the topic to render in the notifications panel, it then needs its own i18n .properties file at `/application/i18n/notifications/idOfTopic.properties`. This file needs to contain keys for `title`, `description` and `iconClass`. For example:

```properties
# /application/i18n/notifications/customerComplaintFiled.properties
title=Customer complaint filed
description=Notifications are raised when customers file complaints through the complaints procedure facility
iconClass=fa-user
```

## Raising a notification

Notifications are raised using the `NotificationService` object's `createNotification()` method. For example, in a ColdBox handler, you might have:

```luceescript
component {

    property name="notificationService" inject="notificationService";

    public void function someAction( event, rc, prc ) {
        // some code
        // ...

        notificationService.createNotification(
              topic = "customerComplaintFiled"
            , type  = "ALERT"
            , data  = { complaintId=newlyCreatedComplaintId }
        );

        // some more code...
    }

}
```

## Rendering notifications

Notifications can appear in various different *contexts* each of which requires its own renderer. These renderers are implemented as :doc:`viewlets` that take the convention of: `renderers.notifications.{idOfNotification}.{context}`. The `args` struct passed to the viewlet, will contain any data that was passed to the `createNotification()` method.

At a bare minimum you must implement viewlets for the **full** and **datatable** contexts (see screenshots below). Additionally, if you want to use a non-default email notification, you can also supply viewlets for the **emailSubject**, **emailHtml** and **emailText** contexts.

![The 'datatable' context is shown in the notifications browser screen when showing many notifications in a table view.](images/screenshots/notification_datatable_context.png)

![The 'full' context allows you to show full details of the notification within the admin interface. The contents of this view is entirely up to you.](images/screenshots/notification_full_context.png)


### Example renderers

The following code provides an example for our 'customer complaint' notification using both a handler and view files for the various renderer viewlets:

```luceescript

// /application/handlers/renderers/notifications/CustomerComplaintFiled.cfc
component {

    property name="customerComplaintsService" inject="customerComplaintsService";

    private string function datatable( event, rc, prc, args={} ) {
        var complaint    = customerComplaintsService.getComplaint( args.complaintId ?: "" );
        var customerName = complaint.customerName ?: "Unknown customer";

        return "A complaint was filed by " & HtmlEditFormat( customerName );
    }

    private string function full( event, rc, prc, args={} ) {
        args.complaint = customerComplaintsService.getComplaint( args.complaintId ?: "" );

        return renderView(
              view = "/renderers/notifications/customerComplaintFiled/full"
            , args = args
        );
    }

    private string function emailSubject( event, rc, prc, args={} ) {
        return "A customer complaint was filed through the website";
    }

    private string function emailHtml( event, rc, prc, args={} ) {
        args.complaint = customerComplaintsService.getComplaint( args.complaintId ?: "" );

        return renderView(
              view = "/renderers/notifications/customerComplaintFiled/emailHtml"
            , args = args
        );
    }

    private string function emailText( event, rc, prc, args={} ) {
        args.complaint = customerComplaintsService.getComplaint( args.complaintId ?: "" );

        return renderView(
              view = "/renderers/notifications/customerComplaintFiled/emailText"
            , args = args
        );
    }

}
```

```lucee
<!-- /views/renderers/notifications/customerComplaintFiled/full.cfm -->
<cfparam name="args.complaint.customerName" type="string" />
<cfparam name="args.complaint.complaint"    type="string" />
<cfparam name="args.complaint.dateMade"     type="string" />

<cfoutput>
    <div class="alert alert-danger">
        <h3><i class="fa fa-fw fa-user"></i> Customer complaint made by #args.complaint.customerName# on #args.complaint.dateMade#</h3>

        <p>#HtmlEditFormat( args.complaint.complaint )#</p>
    </div>
</cfoutput>
```

```lucee
<!-- /views/renderers/notifications/customerComplaintFiled/emailHtml.cfm -->
<cfparam name="args.complaint.customerName" type="string" />
<cfparam name="args.complaint.complaint"    type="string" />
<cfparam name="args.complaint.dateMade"     type="string" />

<cfoutput>
    <p><bold>Customer complaint made by #args.complaint.customerName# on #args.complaint.dateMade#</bold></p>

    <blockquote>#HtmlEditFormat( args.complaint.complaint )#</blockquote>
</cfoutput>
```

```lucee
<!-- /views/renderers/notifications/customerComplaintFiled/emailText.cfm -->
<cfparam name="args.complaint.customerName" type="string" />
<cfparam name="args.complaint.complaint"    type="string" />
<cfparam name="args.complaint.dateMade"     type="string" />

<cfoutput>
Customer complaint made by #args.complaint.customerName# on #args.complaint.dateMade#:

-----

#args.complaint.complaint#
</cfoutput>
```---
id: devguides
title: Developer guides
---

In this chapter, you should find detailed guides on developing with the Preside platform.

* [[config]]
* [[dataobjects]]
* [[dataobjectviews]]
* [[viewlets]]
* [[widgets]]
* [[workingwithpagetypes]]
* [[workingwithmultiplesites]]
* [[workingwiththericheditor]]
* [[datamanager]]
* [[routing]]
* [[cmspermissioning]]
* [[websiteusersandpermissioning]]
* [[editablesystemsettings]]
* [[emailtemplatingv2]]
* [[notifications]]
* [[customerrorpages]]
* [[sitetreenavigationmenus]]
* [[adminlefthandmenu]]
* [[adminsystemmenu]]
* [[adminmenuitems]]
* [[assetmanager]]
* [[workingwithuploadedfiles]]
* [[multilingualcontent]]
* [[presidesuperclass]]
* [[xss]]
* [[restframework]]
* [[formbuilder]]
* [[spreadsheets]]
* [[sessionmanagement]]
* [[presideforms]]
* [[i18n]]
* [[taskmanager]]
* [[auditing]]
* [[rulesengine]]
* [[drafts]]
* [[labelrenderers]]
* [[dataexports]]
* [[adminrecordviews]]
* [[taskmanager]]
* [[fullpagecaching]]
* [[cloning]]
* [[healthchecks]]
* [[adminloginproviders]]
* [[reloadingtheapplication]]
* [[admingritternotifications]]
* [[extensions]]
* [[selectdataviews]]
* [[customdbmigrations]]
* [[systemalerts]]
---
id: auditing
title: Using the audit trail system
---

As of v10.7.0, Preside comes with an audit trail system that allows you to log the activity of your admin users and display that activity in the admin:

![Screenshot showing audit trail in action](images/screenshots/auditTrail.png)

## Creating log entries

You can log an activity in one of two ways:

```luceescript
// in a handler
event.audit(
	  action   = "datamanager_translate_record"
	, type     = "datamanager"
	, recordId = recordId
	, detail   = updatedData
);

// from a service using Preside Super class
$audit(
	  action   = "slack_command_executed"
	, type     = "slackcommands"
	, detail   = { command="deploy", commandArgs=commandArgs }
);
```

Both of these methods proxy to the [[auditservice-log]] method of the [[api-auditservice]] (see links for docs).

## Rendering log entries

For an audit log entry to appear in a useful way for the user, you will want to:

1. Provide i18n properties file entries to describe the audit type and action
2. Provide a custom renderer context for either your audit type or action

### i18n

Each audit "type" should have its own `.properties` file that lives at `/i18n/auditlog/{type}.properties`, e.g. `/i18n/auditlog/datamanager.properties`. At a minimum, it should contain a `title` and `iconClass` entry:

```properties
title=Data manager
iconClass=fa-puzzle-piece
```

In addition, for each audit _action_ within the type, you should supply a `{action}.title`, `{action}.message` and `{action}.iconClass` entry:

```properties
title=Data manager
iconClass=fa-puzzle-piece

datamanager_add_record.title=Add record (Data manager)
datamanager_add_record.message={1} created a new {2}, {3}
datamanager_add_record.iconClass=fa-plus-circle green

datamanager_delete_record.title=Delete record (Data manager)
datamanager_delete_record.message={1} deleted {2}, {3}
datamanager_delete_record.iconClass=fa-trash red
```

### Audit log entry renderer

When audit log entries are rendered, the system uses the `AuditLogEntry` content renderer. It uses the audit log _type_ and/or _action_ as the _context_ for the renderer. This means that the audit log entry will be rendered by one of the following viewlets (whichever exists):

* `renderers.content.AuditLogEntry.{action}`
* `renderers.content.AuditLogEntry.{type}`
* `renderers.content.AuditLogEntry.default`

The _default_ context renderer looks like this:

```lucee
<cfparam name="args.type"        type="string"/>
<cfparam name="args.action"      type="string"/>
<cfparam name="args.datecreated" type="date"/>
<cfparam name="args.known_as"    type="string"/>
<cfparam name="args.userLink"    type="string"/>

<cfscript>
	userLink  = '<a href="#args.userLink#">#args.known_as#</a>';
	message   = translateResource( uri="auditlog.#args.type#:#args.action#.message", data=[ userLink ] );
</cfscript>

<cfoutput>
	#message#
</cfoutput>
```

This means that you can use the default renderer if your audit message could look like this:

```properties
myaction.message={1} did some really cool action
```

If you need a more detailed message, for example: you'd like to replay the *slack command* that was entered in a slack command hook, then you can create a _custom_ context for either your audit type or category. e.g.


```lucee
<!-- /views/renderers/content/auditLogEntry/slackcommand.cfm -->
<cfscript>
	action   = args.action   ?: "";
	known_as = args.known_as ?: "";
	detail   = args.detail   ?: {};
	userLink = '<a href="#( args.userLink ?: '' )#">#args.known_as#</a>';
	command  = '<code>/#( detail.command ?: '' )# #( detail.commandArgs ?: '' )#</code>';

	message = translateResource( uri="auditlog.slackcommand:#args.action#.message", data=[ userLink, command ] );
</cfscript>

<cfoutput>#message#</cfoutput>
```

```properties
# /i18n/auditlog/slackcommand.properties
title=Slack commands
iconClass=fa-slack

command_sent.title=Slack command issued
command_sent.message={1} has issued a command from Slack: {2}
command_sent.iconClass=fa-slack blue
```---
id: workingwithpagetypes
title: Working with page types
---

## Overview

Page types allow developers to wire *structured content* to website pages that are stored in the *site tree*. They are implemented in a way that is intuitive to the end-users and painless for developers.

### Architecture

#### Pages

Pages in a site's tree are stored in the `page` preside object. This object stores information that is common to all pages such as *title* and *slug*.

#### Page types

All pages in the tree must be associated with a page *type*; this page type will define further fields that are specific to its purpose. Each page type will have its own Preside Object in which the specific data is stored. For example, you might have an "event" page type that had *Start date*, *End date* and *Location* fields.

**A one-to-one relationship exists between each page type object and the page object**. This means that every **page type** record must and will have a corresponding **page** record.

## Creating a page type

There are four essential parts to building a page type. The data model, view layer, i18n properties file and form layout(s).

>>>>>> You can scaffold all the parts of a page template very quickly using the Developer console (see :doc:`developerconsole`). Once in the console, type `new pagetype` and follow the prompts.

### The data model

A page type is defined by creating a **Preside Data Object** (see [[dataobjects]]) that lives in a subdirectory called "page-types". For example: `/preside-objects/page-types/event.cfc`:

```luceescript
// /preside-objects/page-types/event.cfc
component {
    property name="start_date" type="date"   dbtype="date"                  required=true;
    property name="end_date"   type="date"   dbtype="date"                  required=true;
    property name="location"   type="string" dbtype="varchar" maxLength=100 required=false;
}
```

Under the hood, the system will add some fields for you to cement the relationship with the 'page' object. The result would look like this:

```luceescript
// /preside-objects/page-types/event.cfc
component labelfield="page.title" {
    property name="start_date" type="date"   dbtype="date"                  required=true;
    property name="end_date"   type="date"   dbtype="date"                  required=true;
    property name="location"   type="string" dbtype="varchar" maxLength=100 required=false;

    // auto generated property (you don't need to create this yourself)
    property mame="page" relationship="many-to-one" relatedto="page" required=true uniqueindexes="page" ondelete="cascade" onupdate="cascade";
}
```

>>> Notice the "page.title" **labelfield** attribute on the component tag. This has the effect of the 'title' field of the related 'page' object being used as the labelfield (see :ref:`presideobjectslabelfield`).
>>> **You do not need to specify this yourself, written here as an illustration of what gets added under the hood.**

### View layer

The page types system takes advantage of auto wired views (see [[dataobjectviews]]). What this means is that we do not need to create a service layer or a coldbox handler for our page type, Preside will take care of wiring your view to your page type data object.

Using our "event" page type example, we would create a view file at `/views/page-types/event/index.cfm`. A simplified example might then look something like this:

```lucee
<!-- /views/page-types/event/index.cfm -->
<cfparam name="args.title"      field="page.title"       editable="true" />
<cfparam name="args.start_date" field="event.start_date" editable="true" />
<cfparam name="args.end_date"   field="event.end_date"   editable="true" />
<cfparam name="args.location"   field="event.location"   editable="true" />

<cfoutput>
    <h1>#page.title#</h1>
    <div class="dates-and-location">
        <p>From #args.start_date# to #args.end_date# @ #args.location#</p>
    </div>
</cfoutput>
```

#### Using a handler

If you need to do some handler logic before rendering your page type, you take full control of fetching the data and rendering the view for your page type.

You will need to create a handler under a 'page-types' folder whose filename matches your page type object, e.g. `/handlers/page-types/event.cfc`. The "index" action will be called by default and will be called as a Preside Viewlet (see [[viewlets]]). For example:

```luceescript
component {

    private string function index( event, rc, prc, args ) {
        args.someValue = getModel( "someServiceOrSomesuch" ).getSomeValue();

        return renderView(
              view          = "/page-types/event/index"
            , presideObject = "event"
            , id            = event.getCurrentPageId()
            , args          = args
        );
    }
}
```

#### Multiple layouts

You can create layout variations for your page type that the users of the CMS will be able to select when creating and editing the page. To do this, simply create multiple views in your page type's view directory. For example:

```
/views
    /page-types
        /event
            _ignoredView.cfm
            index.cfm
            special.cfm
```

>>> Any views that begin with an underscore are ignored. Use these for reusable view snippets that are not templates in themselves.

If your page type has more than one layout, a drop down will appear in the page form, allowing the user to select which template to use.

![Screenshot of a layout picker.](images/screenshots/layout_picker.png)

You can control the labels of your layouts that appear in the dropdown menu by adding keys to your page type's i18n properties file (see UI and i18n below).


### UI and i18n

In order for the page type to appear in a satisfactory way for your users when creating new pages (see screenshot below), you will also need to create a `.properties` file for the page type.


For example, if your page type **Preside data object** was, `/preside-objects/page-types/event.cfc`, you would need to create a `.properties` file at, `/i18n/page-types/event.properties`. In it, you will need to add *name*, *description* and *iconclass* keys, e.g.

```properties
# mandatory keys
name=Event
description=An event page
iconclass=fa-calendar

# keys for the add / edit page forms (completely up to you, see below)
tab.title=Event fields
field.title.label=Event name
field.start_date.label=Start date
field.end_date.label=End date
field.location.label=Location

# keys for the layout picker
layout.index=Default
layout.special=Special layout
```

### Add and edit page forms

The core Preside system ships with default form layouts for adding and editing pages in the site tree. The page types system allows you to modify those forms for specific page types.

![Screenshot of a typical edit page form.](images/screenshots/edit_page.png)

To achieve this, you can either create a single form layout that will be used to modify both the **add** and **edit** forms, or a layout for each form. For example, the following form layout will modify the layout forms for our "event" page type example:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!--
    To use this layout for both edit and add modes, the file would be:

        /application/forms/page-types/event.xml

    For individual add / edit forms:

        /application/forms/page-types/event.add.xml
        /application/forms/page-types/event.edit.xml
-->
<form>
    <tab id="main">
        <fieldset id="main">
            <!-- modify the label for the 'title' field to be event specific (uses a key from our i18n properties file above) -->
            <field name="title" label="page-types.event:field.title.label" />

            <!-- delete some fields that we don't want to see for event pages -->
            <field name="parent_page" deleted="true" />
            <field name="active"      deleted="true" />
            <field name="slug"        deleted="true" />
            <field name="layout"      deleted="true" />
        </fieldset>
    </tab>

    <!-- add some new fields in a new tab -->
    <tab id="event-fields" title="page-types.event:tab.title">
        <fieldset id="event-fields">
            <field binding="event.start_date" label="page-types.event:field.start_date.label" />
            <field binding="event.end_date"   label="page-types.event:field.end_date.label" />
            <field binding="event.location"   label="page-types.event:field.location.label" />
        </fieldset>
    </tab>
</form>
```

### Controlling behaviour in the tree

There are a number of flags that you can set in your page type object files to determine how the pages can be used and viewed within the tree.

#### Limiting child and parent page types

A common scenario is to limit child page and parent types to related pages, for example, **blog** and **blog post** pages. You can control this behaviour by adding `@allowedParentPageTypes` and `@allowChildPageTypes` annotations to your page type objects.

For example, to create an exclusive relationship bewteen parent and child types, you would add the following metadata to your object files:

```luceescript

// /preside-objects/page-types/blog.cfc
/**
 * @allowedParentPageTypes *
 * @allowedChildPageTypes  blog_post
 *
 */
component {
  // ...
}

// /preside-objects/page-types/blog_post.cfc
/**
 * @allowedParentPageTypes blog
 * @allowedChildPageTypes  none
 *
 */
component {
  // ...
}
```

#### Externalizing management of pages (hiding from the tree)

Another common scenario is to want to manage certain page types _outside_ of the site tree. For example, if you have 10,000 article pages, managing them in the tree UI is particularly impractical. This can be achieved using the `showInSiteTree` and `sitetreeGridFields` annotations in your page type objects.

Again, using a blog post page type as an example:

```luceescript
// /preside-objects/page-types/blog_post.cfc

/**
 * @allowedParentPageTypes blog
 * @allowedChildPageTypes  none
 * @showInSiteTree         false
 * @sitetreeGridFields     page.title,blog_post.post_date,page.active
 *
 */
component {
  // ...
}
```

This results in the "Manage blog post pages..." UI in the tree as seen below:

![Screenshot of a managed pages link](images/screenshots/sitetree_managedpages.jpg)

And a grid view of the blog pages that appears as below:

![Screenshot of a managed pages grid](images/screenshots/sitetree_managedpagesgrid.jpg)

---
id: labelrenderers
title: Label renderers
---

## Overview

When an [[formcontrol-objectPicker|Object Picker]] is displayed, by default the text on both the selectable and selected options is taken from the record's label (either the `label` field or whatever fields has been defined on the object using the `@labelField` annotation).

However, there are times when you will need more control over what gets displayed as the label. You might want to combine more than one field to identify the record accurately; you might even want to add an icon, picture or other HTML into the label.

Preside's custom label rendering (new in 10.8.0) allows you to do just this. Simply set up a label renderer handler in `/handlers/renderers/labels/`, and then either add the `labelRenderer` attribute to a field in your form definition, or - if you want this renderer to be used always for an object - via the `@labelRenderer` annotation on the preside object itself.

## Example

Let's say we are running an event, and the session categories are colour-coded. We might want to display that colour-coding in the object picker when selecting a category.

We would create a label renderer handler like this:

```luceescript
// /handlers/renderers/labels/session_category.cfc

component {

	private array function _selectFields( event, rc, prc ) {
		return [
			    "label"
			  , "colour"
		];
	}

	private string function _orderBy( event, rc, prc ) {
		return "label";
	}

	private string function _renderLabel( event, rc, prc ) {
		var label  = arguments.label ?: "";
		var colour = '<i style="display:inline-block;width:15px;height:15px;background-color:rgb(#arguments.colour#);"></i>';

		return colour & " " & htmlEditFormat( label );
	}

}
```

There are three methods defined in this handler.

`_selectFields()` should return an array of all the fields that will be required to build the label. They don't all have to come from the object in question - you can use fields from related objects, using the same `selectFields` syntax as if you were doing a `selectData()` call. In this case, we are retreiving the name of the category (stored in the object's `label` field) and the colour that has been assigned to it.

`_orderBy()` simply returns a string representing the SQL sort order that we want to use for the records in our object picker. In this case, we want them to be sorted by the category name. Again, this is just as in `selectData()`.

Finally, `_renderLabel()` defines how the various bits of data are combined to construct the label. Here we are creating a coloured square which is displayed in front of the category name.

>>>> If you are using a label renderer, the generated label will be output exactly as returned from this method (normally, labels are escaped before being displayed to allow for problematic characters). This means that you are responsible for ensuring that any text parts of the label are escaped as part of the `_renderLabel()` method. Here, we have used `htmlEditFormat()` to escape the category name.

All we need to do now is instruct your application to use our custom label renderer. In this case, we want to use this whenever this object appears in an object picker, so we will use an annotation:

```luceescript
// /preside-objects/session_category.cfc

/**
 * @labelRenderer session_category
 */

component  {
	property name="description" type="string" dbtype="text";
	property name="colour"      type="string" dbtype="varchar" maxlength=12 required=true;
}
```

If we only wanted to use it on a particular form, we would set it up in the form's XML definition:

```xml
<field binding="event_session.session_category" sortorder="10" labelRenderer="session_category" />
```

The resulting object picker would then look like this:

![Screenshot showing an object picker using a custom label renderer](images/screenshots/label-renderer-example.png)---
id: i18n
title: i18n
---

## i18n (Internationalization)

The term i18n comes from the desire not to write down the rather long word, internationalization, which starts with an *i* followed by 18 other letters before ending with an *n* - i18n. The subject of i18n deals with making your content and/or interface usable across nations, dialects and cultures. This includes, but is not limited to:

* Translated labels and other content
* Formatting of numbers
* Formatting of dates

The Preside admin interface provides a translation system to allow you to define the system's labels and descriptions in a standard way that allows translation. Date and number formatting is a work in progress.

>>> This is a work in progress and requires further work. Checkout the [[about]] page if you're keen on contributing.



In .properties file you need to escape special characters to Unicode-Entities. Here are the most common ones:

<div class="table-responsive">
	<table class="table">
		<thead>
			<tr>
				<th>Unicode - Escapes</th>
				<th>Character</th>
			</tr>
		</thead>
		<tbody>
			<tr>
				<td><code>\u00A1</code></td>
				<td>¡</td>
			</tr>
			<tr>
				<td><code>\u00A2</code></td>
				<td>¢</td>
			</tr>
			<tr>
				<td><code>\u00A3</code></td>
				<td>£</td>
			</tr>
			<tr>
				<td><code>\u00A4</code></td>
				<td>¤</td>
			</tr>
			<tr>
				<td><code>\u00A5</code></td>
				<td>¥</td>
			</tr>
			<tr>
				<td><code>\u00A6</code></td>
				<td>¦</td>
			</tr>
			<tr>
				<td><code>\u00A7</code></td>
				<td>§</td>
			</tr>
			<tr>
				<td><code>\u00A8</code></td>
				<td>¨</td>
			</tr>
			<tr>
				<td><code>\u00A9</code></td>
				<td>©</td>
			</tr>
			<tr>
				<td><code>\u00AA</code></td>
				<td>ª</td>
			</tr>
			<tr>
				<td><code>\u00AB</code></td>
				<td>«</td>
			</tr>
			<tr>
				<td><code>\u00AC</code></td>
				<td>¬</td>
			</tr>
			<tr>
				<td><code>\u00AD</code></td>
				<td>­</td>
			</tr>
			<tr>
				<td><code>\u00AE</code></td>
				<td>®</td>
			</tr>
			<tr>
				<td><code>\u00AF</code></td>
				<td>¯</td>
			</tr>
			<tr>
				<td><code>\u00B0</code></td>
				<td>°</td>
			</tr>
			<tr>
				<td><code>\u00B1</code></td>
				<td>±</td>
			</tr>
			<tr>
				<td><code>\u00B2</code></td>
				<td>²</td>
			</tr>
			<tr>
				<td><code>\u00B3</code></td>
				<td>³</td>
			</tr>
			<tr>
				<td><code>\u00B4</code></td>
				<td>´</td>
			</tr>
			<tr>
				<td><code>\u00B5</code></td>
				<td>µ</td>
			</tr>
			<tr>
				<td><code>\u00B6</code></td>
				<td>¶</td>
			</tr>
			<tr>
				<td><code>\u00B7</code></td>
				<td>·</td>
			</tr>
			<tr>
				<td><code>\u00B8</code></td>
				<td>¸</td>
			</tr>
			<tr>
				<td><code>\u00B9</code></td>
				<td>¹</td>
			</tr>
			<tr>
				<td><code>\u00BA</code></td>
				<td>º</td>
			</tr>
			<tr>
				<td><code>\u00BB</code></td>
				<td>»</td>
			</tr>
			<tr>
				<td><code>\u00BC</code></td>
				<td>¼</td>
			</tr>
			<tr>
				<td><code>\u00BD</code></td>
				<td>½</td>
			</tr>
			<tr>
				<td><code>\u00BE</code></td>
				<td>¾</td>
			</tr>
			<tr>
				<td><code>\u00BF</code></td>
				<td>¿</td>
			</tr>
			<tr>
				<td><code>\u00C0</code></td>
				<td>À</td>
			</tr>
			<tr>
				<td><code>\u00C1</code></td>
				<td>Á</td>
			</tr>
			<tr>
				<td><code>\u00C2</code></td>
				<td>Â</td>
			</tr>
			<tr>
				<td><code>\u00C3</code></td>
				<td>Ã</td>
			</tr>
			<tr>
				<td><code>\u00C4</code></td>
				<td>Ä</td>
			</tr>
			<tr>
				<td><code>\u00C5</code></td>
				<td>Å</td>
			</tr>
			<tr>
				<td><code>\u00C6</code></td>
				<td>Æ</td>
			</tr>
			<tr>
				<td><code>\u00C7</code></td>
				<td>Ç</td>
			</tr>
			<tr>
				<td><code>\u00C8</code></td>
				<td>È</td>
			</tr>
			<tr>
				<td><code>\u00C9</code></td>
				<td>É</td>
			</tr>
			<tr>
				<td><code>\u00CA</code></td>
				<td>Ê</td>
			</tr>
			<tr>
				<td><code>\u00CB</code></td>
				<td>Ë</td>
			</tr>
			<tr>
				<td><code>\u00CC</code></td>
				<td>Ì</td>
			</tr>
			<tr>
				<td><code>\u00CD</code></td>
				<td>Í</td>
			</tr>
			<tr>
				<td><code>\u00CE</code></td>
				<td>Î</td>
			</tr>
			<tr>
				<td><code>\u00CF</code></td>
				<td>Ï</td>
			</tr>
			<tr>
				<td><code>\u00D0</code></td>
				<td>Ð</td>
			</tr>
			<tr>
				<td><code>\u00D1</code></td>
				<td>Ñ</td>
			</tr>
			<tr>
				<td><code>\u00D2</code></td>
				<td>Ò</td>
			</tr>
			<tr>
				<td><code>\u00D3</code></td>
				<td>Ó</td>
			</tr>
			<tr>
				<td><code>\u00D4</code></td>
				<td>Ô</td>
			</tr>
			<tr>
				<td><code>\u00D5</code></td>
				<td>Õ</td>
			</tr>
			<tr>
				<td><code>\u00D6</code></td>
				<td>Ö</td>
			</tr>
			<tr>
				<td><code>\u00D7</code></td>
				<td>×</td>
			</tr>
			<tr>
				<td><code>\u00D8</code></td>
				<td>Ø</td>
			</tr>
			<tr>
				<td><code>\u00D9</code></td>
				<td>Ù</td>
			</tr>
			<tr>
				<td><code>\u00DA</code></td>
				<td>Ú</td>
			</tr>
			<tr>
				<td><code>\u00DB</code></td>
				<td>Û</td>
			</tr>
			<tr>
				<td><code>\u00DC</code></td>
				<td>Ü</td>
			</tr>
			<tr>
				<td><code>\u00DD</code></td>
				<td>Ý</td>
			</tr>
			<tr>
				<td><code>\u00DE</code></td>
				<td>Þ</td>
			</tr>
			<tr>
				<td><code>\u00DF</code></td>
				<td>ß</td>
			</tr>
			<tr>
				<td><code>\u00E0</code></td>
				<td>à</td>
			</tr>
			<tr>
				<td><code>\u00E1</code></td>
				<td>á</td>
			</tr>
			<tr>
				<td><code>\u00E2</code></td>
				<td>â</td>
			</tr>
			<tr>
				<td><code>\u00E3</code></td>
				<td>ã</td>
			</tr>
			<tr>
				<td><code>\u00E4</code></td>
				<td>ä</td>
			</tr>
			<tr>
				<td><code>\u00E5</code></td>
				<td>å</td>
			</tr>
			<tr>
				<td><code>\u00E6</code></td>
				<td>æ</td>
			</tr>
			<tr>
				<td><code>\u00E7</code></td>
				<td>ç</td>
			</tr>
			<tr>
				<td><code>\u00E8</code></td>
				<td>è</td>
			</tr>
			<tr>
				<td><code>\u00E9</code></td>
				<td>é</td>
			</tr>
			<tr>
				<td><code>\u00EA</code></td>
				<td>ê</td>
			</tr>
			<tr>
				<td><code>\u00EB</code></td>
				<td>ë</td>
			</tr>
			<tr>
				<td><code>\u00EC</code></td>
				<td>ì</td>
			</tr>
			<tr>
				<td><code>\u00ED</code></td>
				<td>í</td>
			</tr>
			<tr>
				<td><code>\u00EE</code></td>
				<td>î</td>
			</tr>
			<tr>
				<td><code>\u00EF</code></td>
				<td>ï</td>
			</tr>
			<tr>
				<td><code>\u00F0</code></td>
				<td>ð</td>
			</tr>
			<tr>
				<td><code>\u00F1</code></td>
				<td>ñ</td>
			</tr>
			<tr>
				<td><code>\u00F2</code></td>
				<td>ò</td>
			</tr>
			<tr>
				<td><code>\u00F3</code></td>
				<td>ó</td>
			</tr>
			<tr>
				<td><code>\u00F4</code></td>
				<td>ô</td>
			</tr>
			<tr>
				<td><code>\u00F5</code></td>
				<td>õ</td>
			</tr>
			<tr>
				<td><code>\u00F6</code></td>
				<td>ö</td>
			</tr>
			<tr>
				<td><code>\u00F7</code></td>
				<td>÷</td>
			</tr>
			<tr>
				<td><code>\u00F8</code></td>
				<td>ø</td>
			</tr>
			<tr>
				<td><code>\u00F9</code></td>
				<td>ù</td>
			</tr>
			<tr>
				<td><code>\u00FA</code></td>
				<td>ú</td>
			</tr>
			<tr>
				<td><code>\u00FB</code></td>
				<td>û</td>
			</tr>
			<tr>
				<td><code>\u00FC</code></td>
				<td>ü</td>
			</tr>
			<tr>
				<td><code>\u00FD</code></td>
				<td>ý</td>
			</tr>
			<tr>
				<td><code>\u00FE</code></td>
				<td>þ</td>
			</tr>
			<tr>
				<td><code>\u00FF</code></td>
				<td>ÿ</td>
			</tr>
		</tbody>
	</table>
</div>
---
id: validation-framework
title: Validation framework
---

The Preside platform provides its own validation framework. This framework is used in the forms system without the need of any specific knowledge of its working. However, you may find yourself requiring custom validation and wanting to use the framework directly. The guide below provides a comprehensive reference for the framework's APIs.

# Core concepts

There are four core concepts to the API:

1. **Rules**: A _rule_ is a constraint on a given field - e.g. "password must be longer than 15 characters".

2. **Rulesets**: A _ruleset_ is a collection of rules.

3. **Validators**: A _Validator_, is a _named process_ that takes the submitted data and returns an indication of whether or not the data is valid. For example, `isValidEmail`, `minValue`, `required`, etc. The API supplies a set of core validators that can be easily supplemented and overriden with your own custom validators. Every _rule_ must have a _single validator_.

4. **Validation providers**: A `Validator Provider` is a CFC file that provides a collection of _validators_ (public methods).

![Overview of the Validation system](images/diagrams/validation-engine-overview.jpg)

# Working with the API

The core validation API is used by Preside when rendering and processing forms. It does this under-the-hood so that, in general, you do not need to deal with it directly. An exception to this might occur should you wish to do some custom code that will not use the Preside Abstractions.The API has four core methods that allow you to:

* Register custom validator providers
* Register rulesets
* Validate some data against a ruleset
* Produce client-side validation code for a given ruleset

See [[api-validationengine]] for API docs.

## Examples

The following code samples show working with the API directly. This is rough code and is intended to illustrate the shape of using the API.

```luceescript

// registering some custom validators through a validation provider
validationEngine.newProvider( getModel( "cfcWithCustomValidatorMethods" ) );

// long hand way of defining a ruleset (can be provided as json, file containing json or array of structs)
var ruleset = [];

ruleset.append( { fieldName="emailAddress"   , validator="required" } );
ruleset.append( { fieldName="emailAddress"   , validator="email"    } );
ruleset.append( { fieldName="password"       , validator="required" } );
ruleset.append( { fieldName="confirmPassword", validator="required" } );
ruleset.append( { fieldName="password"       , validator="minLength", params={ length = 6          } } );
ruleset.append( { fieldName="confirmPassword", validator="sameas"   , params={ field  = "password" } } );

validationEngine.newRuleset( "myCustomFormRules", ruleset );

// validating a form submission
var validationResult = validationEngine.validate( "myCustomFormRules", form );
if ( validationResult.validated() ) {
    // ...
} else {
    // ...
}
```

```lucee
<!-- HTML and client side validation -->
<cfoutput>
    <form id="myCustomForm" method="post" action="#urlToProcessFormSubmission#">

        <!-- outputting an error message for a field -->
        <cfif validationResult.fieldHasError( "emailAddress" )>
            <p class="error-message">#validationResult.getError( "emailAddress" )#</p>
        </cfif>

    </form>

    <!-- generating js for client side validation -->
    <script type="text/javascript">
        ( function( $ ){
            var validateOptions = #validationEngine.getJqueryValidateJs( "myCustomFormRules", "jQuery" )#;
            $( '##myCustomForm' ).validate( validateOptions );
        } )( jQuery );
    </script>
</cfoutput>
```

# Rules and Rulesets

## Rules

A rule defines a constraint for a named field. e.g. the field named "username" must be longer than three characters. A single rule can be made up of the following attributes:

* **fieldName (required):** The name of the field to which the rule applies
* **validator (required):** The name of the validator with which to validate the field, i.e. "minLength"
* **params (optional):** Optional structure of parameters to send to the validator. i.e. the minLength validator requires a "length" parameter
*message (optional):* Optional message to display should the rule be broken. This will default to the default message associated with the validator.
* **serverCondition (optional):** CFML to evaluate whether or not the rule should be run, e.g. only run the "required" rule for "retypeNewPassword" when "oldPassword" and "newPassword" have been filled in
* **clientCondition (optional):** JavaScript for conditionally running rules client-side (in produced javascript)

### Examples

```luceescript
// required field
{
      fieldName : "username"
    , validator : "required"
    , message   : "Username is required"
}

// field should be between 3 and 10 characters long
{
      fieldName : "username"
    , validator : "rangeLength"
    , params    : { minLength : 3, maxLength : 10 }
}

// field is only required when the "Where did you hear" field is equal to "other"
{
      fieldName : "whereDidYouHearOther"
    , validator : "required"
    , serverCondition : "${whereDidYouHear} eq 'other'"
    , clientCondition : "${whereDidYouHear}.val() === 'other'"
}
```

### Conditional rules, referencing other fields

As shown above, conditional rules allow you to conditionally run a rule based on just about any logic you can think of. For ease and information hiding, the API provides the `${fieldname}` syntax for accessing other fields in the form / dataset.

For server side validation, the macro will evaluate to the _value_ of the field, i.e. `${password}` will be translated to something like: `arguments.data[ 'password' ]`.

In client-side validation, the macro will evaluate to the jQuery object for the form field, i.e. `${username}` will be translated to something like `$( elementBeingValidated ).nearest( 'form' ).find( '[name="username"]' )`.

## Registering rulesets to the engine

A ruleset is an array of rules that are registered, with a unique name, to the core validation engine using the `newRuleset()` method. The set of rules for the ruleset can be defined in three ways:

1. As a CFML array of structures (each structure containing the rule attributes described above)
2. As a JSON string that evaluates to an array of structs
3. As a file path pointing to a file that contains a JSON string that evaluates to CFML array of structs

### Examples

```luceescript
// register a ruleset with the name "myRuleset", using an array of structs
ruleset = validationEngine.newRuleset( "myRuleset", [{fieldName="username", validator="required"}, {fieldName="password", validator="required" }] );

// register a ruleset with the name "myRuleset", using a json string
ruleset = validationEngine.newRuleset( "myRuleset", '[{"fieldName":"username", "validator":"required"}, {"fieldName":"password", "validator":"required" }]' );

// register a ruleset with the name "myRuleset", using a filepath
ruleset = validationEngine.newRuleset( "myRuleset", ExpandPath( "/myrulesets/myruleset.json" ) );
```

## Custom validators and validator providers

Custom validators can be passed to the engine by passing an _instantiated_ CFC that contains public _validator methods_. For example, you might have:

```luceescript
myValidatorCfc = getModel( "someComponentThatHasValidatorMethods" );

validationEngine.newProvider( myValidatorCfc );
```

The _public_ methods in a component can be marked as being _validators_. The name of the method will be the name of the registered _validator_. A component can provide validator methods in two ways:

1. By adding the `validationProvider="true"` attribute to the component tag, all public methods will then be considered validators
2. By adding the `validator="true"` attribute to the function tag of the method that should be a validator

Default error messages can be provided for a validator method by adding the `validatorMessage="some message"` attribute to the function tag.

### Format of a validator method

Any method that is registered as a validator should return a boolean value. By returning `true`, the method is asserting that the provided data was valid.

The method will always be given the following three arguments:

* **fieldName:** The name of the field being validated
* **value:** The value of the field being validated
* **data:** The entire data structure that is being validated

Additionally, you can define your own custom arguments that will need to be defined in the `params` attribute of any rules that use your validator.

Example method:

```luceescript
/**
 * @validator
 * @validatorMessage This is not a slug (or a snail)
 */
public boolean function slug(
      required string  fieldName
    , required any     value
    , required struct  data
    , required boolean allowMixedCase // custom argument
) {
    var aToZ = arguments.allowMixedCase ? "a-zA-Z" : "a-z";

    // if empty input, do not perform custom validation
    if ( !IsSimpleValue( arguments.value ) || !Len( Trim( arguments.value ) ) ) {
        return true;
    }

    return ReFind( "^[#aToZ#0-9\-]+$", arguments.value );
}

// ...

// usage in a rule
ruleset.append( { fieldName="eventSlug", validator="slug", params={ allowMixedCase = true } } );
```

### Providing client side logic for custom validators

The API allows you to define javascript logic for your custom validators. This logic will be used when creating the javascript for a given ruleset when rendering a form. The javascript itself must be any valid javascript that could be provided as a custom validator to the jQuery Validate plugin.

To define the javascript in your provider, simply create a method with the same name as your validator but with "_js" appended. The method should return a string containing the javascript. For the slug example, above, the js validator method could look like this:

```luceescript
public boolean function slug_js() {
    return "function( value, elem, params ){
                var regex = params.allowMixedCase ? /^[a-zA-Z0-9\-]+$/ : /^[a-z0-9\-]+$/;
                return !value.length || value.match( regex ) !== null;
            }"
}
```

### Example provider CFCs

```luceescript
/**
 * All public methods in this CFC will be assumed
 * to be validators because I am tagged with @validationProvider
 *
 * @validationProvider
 */
component {

    /**
     * @validatorMessage customvalidators:slug.message
     */
    public boolean function slug(
          required string  fieldName
        , required any     value
        , required struct  data
        , required boolean allowMixedCase // custom argument
    ) {
        var aToZ = arguments.allowMixedCase ? "a-zA-Z" : "a-z";

        // if empty input, do not perform custom validation
        if ( !IsSimpleValue( arguments.value ) || !Len( Trim( arguments.value ) ) ) {
            return true;
        }

        return ReFind( "^[#aToZ#0-9\-]+$", arguments.value );
    }

    public boolean function slug_js() {
        return "function( value, elem, params ){
                    var regex = params.allowMixedCase ? /^[a-zA-Z0-9\-]+$/ : /^[a-z0-9\-]+$/;
                    return !value.length || value.match( regex ) !== null;
                }"
    }
}
```

Any old CFC with ad-hoc validation methods:


```luceescript
component {

    /**
     * This is not a validator, as it is not
     * tagged with @validator (and the CFC is not
     * tagged with @validationProvider)
     *
     */
    public any function someFunction() {
        // do stuff
    }

    /**
     * A method that will be used as a validator
     * because tagged with @validator, below
     *
     * @validator
     * @validatorMessage customvalidators:slug.message
     */
    public boolean function membershipNumber(
          required string  fieldName
        , required any     value
    ) {
        if ( !Len( Trim( arguments.value ) ) ) {
            return true;
        }

        return ReFind( "^M[0-9]{8}$", arguments.value );
    }

    /**
     * js version of the membershipNumber validator method
     * note: we do not need to flag this with @validator
     *
     */
    public boolean function membershipNumber_js() {
        return "function( value ){ return !value.length || value.match( /^M[0-9]{8}$/ ) !== null; }";
    }
}
```

## Server-side validation

Once you have your rulesets and any custom validators registered, validating a set of data (structure) is as straight forward as:

```luceescript
result = validationEngine.validate( "nameOfRuleset", data );
if ( result.validated() ) {
    // ... proceed
}
```

As you might gather from the code above, the `validate()` method returns a [[api-validationresult]] object (see API docs for its method signatures).

## Client-side validation

The `getJqueryValidateJs( ruleset, jqueryReference )` method, will return JavaScript to build all the required options for the jQuery Validate plugin. The javascript itself is an executed anonymous function that registers any custom validators with jQuery Validate and then returns an object that can be passed to the validate() method. An example of the produced js (with added comments), could look like this:

```js
( function( $ ){
    // translateResource() for i18n w/ error messages
    var translateResource = ( i18n && i18n.translateResource ) ? i18n.translateResource : function(a){ return a };

    // register custom validators
    $.validator.addMethod( "validator1", function( value, element, params ){ return false; }, "" );
    $.validator.addMethod( "validator2", function( value, element, params ){ return true; }, "" );

    // return the options to be passed to validate()
    return {
        rules : {
            "field1" : {
                "required" : { param : [] },
                "validator1" : { param : [], depends : function( el ){ return $( this.form ).find( "[name=''field1'']" ).val() === "whatever"; } }
            },
            "field2" : {
                "validator2" : { param : [ "test", false ] }
            }
        },
        messages : {
            "field1" : {
                "required" : translateResource( "Not there", { data : [] } ),
                "validator1" : translateResource( "validation:another.message.key", { data : [] } )
            },
            "field2" : {
                "validator2" : translateResource( "validation:some.error.key", { data : [ true ] } )
            }
        }
    };
} )( jQuery )
```

An example usage of the generated javascript might then look like:

```js
( function( $ ){
    // auto generate the rules and messages for validate()
    var validateOptions = #validationEngine.getJQueryValidateJs( "myRuleset", "jQuery" )#;

    // add any other options you need
    validateOptions.debug = true;
    validateOptions.submitHandler = myCustomSubmitHandler;

    // apply to the form
    $( '##myFormId' ).validate( validateOptions );
} )( jQuery );
```

## i18n

The validation API does not take any responsibility for i18n. If you wish to have translatable error messages, simply provide the resource bundle key of the message (see the core Preside i18n page for more details on resource bundles, etc.). For example:

```luceescript
// non-i18n version
ruleset.append( { fieldName="username", validator="minLength", message="Username must be less than 3 characters", params={length=3} } );

// i18n version
ruleset.append({ fieldName="username", validator="minLength", message="validationMessages:myform.username.minLength", params={length=3} } );
```

The generated client side code will automatically try to translate the message using the core Preside i18n functionality. To manually translate the message server-side, you would do:

```lucee
<p class="error-message">
    #translateResource(
          uri          = validationResult.getError( "myField" )
        , defaultValue = validationResult.getError( "myField" )
        , data         = validationResult.listErrorParameterValues( "myField" )
    )#
</p>
```

### Dynamic parameters for translations

Translatable texts often require dynamic variables. An example validation message requiring dynamic values might be: `"Must be at least {1} characters"`. Depending on the configured minimum character count, the message would substitue `"{1}"` for the minimum length.

For this to work, the method that translates the message must accept an array of dynamic parameters. These parameters can be retrieved using the `listErrorParameterValues( fieldName )` method of the [[api-validationresult]] object (see the example, above). The parameters themselves will be any custom parameters defined in your validator, **in the order that they are defined in the validator method**. For example:

```luceescript
// validator definition
public boolean function rangeLength(
    required string  fieldName // core
    required string  value     // core
    required struct  data      // core
    required numeric minLength // custom
    required numeric maxLength // custom
) {
    var length = Len( Trim( arguments.value ) );

    return !length || ( length >= arguments.minLength && length <= arguments.maxLength );
}

// ...

// rule definition
ruleset.append( { fieldName="someField", validator="rangeLength", params={ minLength=10, maxLength=200 } } );

// validation result error message generation
var errorMessage    = validationResult.getError( "someField" ); // e.g. validationmessages:rangelength.message
var parameterValues = validationResult.listErrorParameterValues( "someField" ); // [ 10, 200 ]

errorMessage = translateResource(
      uri          = errorMessage
    , defaultValue = errorMessage
    , data         = parameterValues
);

// if the resource bundle message for 'validationmessages:rangelength.message'
// was: "Must be between {1} and {2} characters long", then errorMessage would
// be "Must be between 10 and 200 characters long"

```---
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
```---
id: adminsystemmenu
title: Modifying the administrator system menu
---

## Overview

Preside provides a simple mechanism for configuring the "System" menu of the admin interface, either to add new main navigational items, take existing ones away or to modify the order of menu items.

## Configuration

Each item of the menu is stored in an array that is set in `settings.adminConfigurationMenuItems` in `Config.cfc`. The core implementation looks like this:

```luceescript
component {

    public void function configure() {

        // ... other settings ...

        settings.adminConfigurationMenuItems = [
              "usermanager"
            , "notification"
            , "passwordPolicyManager"
            , "systemConfiguration"
            , "rulesEngine"
            , "links"
            , "urlRedirects"
            , "errorLogs"
            , "auditTrail"
            , "maintenanceMode"
            , "taskmanager"
            , "savedexport"
            , "apiManager"
            , "systemInformation"
        ];

        // ... other settings ...

    }
}
```

## Menu items

As of **10.17.0** each menu item should have a corresponding entry in the `settings.adminMenuItems` struct.

See [[adminmenuitems]] for documentation on specificying a menu item.

### Pre 10.17.0 implementation (still supported)

Prior to 10.17.0, all menu items are then implemented as a view that lives under a `/views/admin/layout/configurationMenu/` folder. For example, for the 'errorLogs' item, there existed a view at `/views/admin/layout/configurationMenu/errorLogs.cfm` that looked like this:

```lucee
<!--- /views/admin/layout/configurationMenu/errorLogs.cfm --->

<cfif ( isFeatureEnabled( "errorlogs" ) && hasCmsPermission( "errorlogs.navigate" ) )>
    <cfoutput>
        <li>
            <a href="#event.buildAdminLink( linkTo="errorlogs" )#">
                <i class="fa fa-fw fa-exclamation-circle"></i>
                #translateResource( 'cms:errorlogs' )#
            </a>
        </li>
    </cfoutput>
</cfif>
```

## Formatting

Each item in the list should fit in a Twitter Bootstrap 3 drop down menu and should render its own `<li>` element. We recommend the following markup for consistency:

```html
<li>
    <a href="#"> <!-- a real link -->
        <i class="fa fa-fw fa-your-icon"></i>
        Title of item
    </a>
</li>
```---
id: drafts
title: Drafts system
---

As of Preside 10.7.0, the core versioning system also supports draft changes to records. The site tree will automatically have this feature activated whereas data manager objects will need the feature activated should you wish to use it.

To activate drafts in an object managed in the Data manager, you must annotate your object with the `datamanagerAllowDrafts` attribute (it defaults to `false`). For example:

```luceescript
/**
 * @labelfield             name
 * @dataManagerGroup       widget
 * @datamanagerAllowDrafts true
 */
component {
    property name="name"         type="string" dbtype="varchar" required="true";
    property name="job_title"    type="string" dbtype="varchar";
    property name="biography"    type="string" dbtype="text";
    property name="organisation" type="string" dbtype="varchar";

    property name="image" relationship="many-to-one" relatedTo="asset" allowedtypes="image";
}
```---
id: xss
title: XSS protection
---

Preside comes with XSS protection out of the box using the AntiSamy project. This protection will automatically strip unwanted HTML from user input in order to prevent the possibility of successful cross site scripting attacks. See also [[csrf]].

## Configuring protection

The protection is turned on by default but bypassed by default when the logged in user is a CMS administrator. These settings, and also the AntiSamy profile to be used, can be edited in your sites `Config.cfc` file:

```luceescript

public void function configure() {
    super.configure();

    // turn off antisamy (don't do this!)
    settings.antiSamy.enabled = false;

    // use the "tinymce" AntiSamy policy (default is preside as of 10.8.24, myspace before that)
    settings.antiSamy.policy  = "tinymce";

    // do not bypass antisamy, even when logged in user is admin
    settings.antiSamy.bypassForAdministrators = false;

    // ...
}
```

The list of possible policies to use are:

* preside (added in 10.8.24)
* antisamy
* ebay
* myspace
* slashdot
* tinymce

For more information on the AntiSamy project, visit [https://www.owasp.org/index.php/Category:OWASP_AntiSamy_Project](https://www.owasp.org/index.php/Category:OWASP_AntiSamy_Project).---
id: configurableconsolekey
title: Configuring the developer console key
---

Keyboard layouts vary. The default key code that is used to toggle the developer console is `96` which on a UK keyboard layout maps to the backtick key (`).

In order to accomodate different layouts, Preside allows you to configure the keycode that will trigger the Preside developer console to be toggled. In your application's `Config.cfc`, add the following entry:

```luceescript
component extends="preside.system.config.Config" {

	public void function configure() {
		super.configure();

		// ...

		settings.devConsoleToggleKeyCode = 96; // replace 96 with the keycode you wish to use

		// ...
	}

}
```

## Finding out your desired keycode

The keycode we need is the one that is fired by JavaScript on the `onKeyPress` event, and the one that is mapped to the `event.which` variable.

One quick method to get the correct keycode, is to visit the following web page that has a javascript based form that displays keycodes of the keys you press: [http://www.asquare.net/javascript/tests/KeyCode.html](http://www.asquare.net/javascript/tests/KeyCode.html).

See the relevant section from which to extract the keycode, below:

![Screenshot showing use of the keycode test tool](images/screenshots/discoverkeycode.png)

---
id: cloning
title: Record cloning
---

## Introduction

In Preside 10.10.0, we introduced APIs and foundations for Preside object record cloning as well as concrete implementations in the Data Manager, Email Centre and Site tree. This guide provides information on getting the most out of the cloning system and how to configure your objects.

## Making my object cloneable, or not

By default, the system attempts to calculate whether or not an object is cloneable by seeing if it has any cloneable properties (see below). If you want to explicitly define whether or not your object is cloneable, however, you can do so with the `@cloneable` annotation on the component. For example:

```luceescript
/**
 * @cloneable false
 *
 */
component {
	// ...
}
```

## Making properties cloneable, or not

You can explicitly mark a property as being "cloneable" by using the `cloneable` annotation on the property, setting to either `true` or `false`:

```property name="my_prop" cloneable=true // ...```

By default, however, the system uses the following rules to decide whether or not your property will be cloneable.

### Rules for properties that can never be cloned

* The property is either the `id`, `datemodified` or `datecreated` field
* The property is a formula field (these will *never* be cloneable)

### Rules for properties that are not cloneable by default

* The property is part of a unique index
* The property is a `one-to-many` relationship

### Rules for properties that are cloneable by default

All properties that do not match the criteria, above, are cloneable by default.

## Supplying alternative logic for cloning

You can use the `@cloneHandler` annotation on your Preside object component to specify a private Coldbox handler action that will be run to clone a record. This handler will be passed the following arguments:

* `objectName` Name of object whose record is to be cloned
* `recordId` ID of record to be cloned
* `data` Additional data that should be included in the new record

## Other customizations

See the "Cloning" customizations in the [[customizingdatamanager]] page.

## Using the API directly

See [[api-presideobjectcloningservice]].


---
id: rulesengine
title: Rules engine
---

## Overview

As of Preside **10.7.0**, a standardised Rules Engine is provided by the core system. Currently, we provide a system for creating editorially configurable and complex _conditions_, several touch points for granting access to resources or content based on the evaluation of conditions, and APIs to use conditions in your custom application logic.

As of Preside **10.8.0**, the concept of _filters_ was also added to the rules engine along with auto generated expressions for preside objects. The rules engine is also now enabled by default (it was disabled by default in 10.7.0).

![Screenshot showing rule condition builder](images/screenshots/rulesEngineConditionBuilder.jpg)

## Terminology

### Conditions

Conditions are a user-configured combination of one or more logical _expressions_, grouped into sets that are combined with `and` or `or` joins. Administrative users of the platform can create conditions and save them with a unique name for later use in various scenarios, e.g. to grant access to a restricted page. Conditions are evaluated at runtime.

### Condition contexts

A condition context represents the context in which a condition will be run. For example, a "web request" condition can be evaluated in the context of a web request and a "user" condition can be evaluated in any context related to a single user.

Some contexts can encompass other contexts. For example, a "web request" context is expected to encompass "user" and "page" contexts with those contexts being populated with the currently logged in user, or visited page.

See [[rulesenginecontexts]] for a full guide.

### Filters

Similar to conditions, filters are a user-configured combination of one or more logical _filter_ expressions, grouped into sets that are combined with `and` or `or` joins. Administrative users of the platform can create filters and save them with a unique name for later use in various scenarios, e.g. to filter recordsets in admin data views, or for use in _conditions_ that control access to pages, etc.

Unlike conditions, filters must apply to a single [[dataobjects|preside data object]] and are used to create a database filter that is then applied to a [[presideobjectservice-selectdata]] query.

>>>>>> Filters can be used as conditions but conditions can not be used as filters.

### Expressions

Expressions are a single, configurable item that can be evaluated to true or false at runtime for conditions and/or evaluated to an array of preside object filters for use in filters.

Expressions are tied to one or more contexts so that only relevant expressions can be used to build a condition or filter that is targeted at a particular context. A context can be either a preside object or other custom / special contexts such as "webrequest".

The core system provides a basic set of expressions and developers are able to create additional expressions to enrich the system with customer-specific requirements. As of **10.8.0** the system also auto generates expressions to be used as filters for preside objects.

Expressions are combined by users to form conditions and filters. See [[rulesengineexpressions]] for a full guide.

### Expression fields

An expression can contain zero or more configurable fields that allow end-users to configure the expression in detail. A simple example:

```
user {_is} logged in
```

Here, the `{_is}` is an expression field that users can configure to be *is* or *is not*. More complex expressions can have many fields.

### Expression field types

Expression fields are typed so that the user experience of configuring the field can be tailored to the type of field. For example, `boolean` types are configured with just a single click to toggle them from `true` to `false`. `object` types will present the user with a record picker with data selected from the configured preside object for the field.

See [[rulesenginefieldtypes]] for a full guide.

![Screenshot showing configuration of an object type field](images/screenshots/rulesEngineObjectFieldConfiguration.jpg)


## Further reading

* [[rulesengineexpressions]]
* [[rulesenginefieldtypes]]
* [[rulesenginecontexts]]
* [[rulesengineapis]]
* [[rulesengineautogeneration]]

---
id: rulesengineapis
title: Rules engine APIs for evaluating conditions and generating filters
---

## Rules engine APIs for evaluating conditions and generating filters

### Evaluating conditions

The [[rulesengineconditionservice-evaluatecondition||rulesEngineConditionService.evaluateCondition()]] method allows you to evaluate a saved condition at runtime.

For example, let's imagine that we have a `slideshow_slide` object that allows you to configure `picture`, `link`, `title`, etc. for a slide in a slide show. It would be great if we could configure it to show only when the chosen _condition_ is true (e.g. only show the promo for our Conference if you have not already booked on it). Our Preside Object might look like this:

```luceescript
// slideshow_slide.cfc
component {
    // ...

    // ruleContext below tells the auto generated condition picker
    // formcontrol to limit conditions to "webrequest" compatible conditions
    property name="condition" relationship="many-to-one" relatedTo="rules_engine_condition" ruleContext="webrequest";
    // ...
}
```

The logic to then decide whether or not to show the slide:

```luceescript
// /handlers/somehandler.cfc
component {
    property name="slidesService"               inject="slidesService";
    property name="rulesEngineConditionService" inject="rulesEngineConditionService"; 

    private string function slides() {
        var slides         = slidesService.getMySlides( ... );
        var renderedSlides = "";

        for( var slide in slides ) {
            // show the slide if it has no condition, or the condition evaluates
            // to true. notice the "webrequest" context that matches the conditions
            // that we are allowed to choose (see object definition, above)
            var showSlide = !Len( Trim( slide.condition ) ) || rulesEngineConditionService.evaluateCondition( 
                  conditionId = slide.condition
                , context     = "webrequest" 
            );
            if ( showSlide ) {
                renderedSlides &= renderView( view="/slides/_slide", args=slide );
            }
        }

        return renderedSlides;
    }
}
```

>>> The default form control for properties that relate to `rules_engine_condition` and that define a `ruleContext` is [[formcontrol-conditionpicker]]. You can also use this control and its options directly in your form definitions if you so need.

### Using saved filters

You can use saved filters in your everyday code to enhance the user experience and flexibility of your systems. Given a saved filter ID (from the `rules_engine_condition` object), you can use the [[rulesenginefilterservice-preparefilter|RulesEngineFilterService.prepareFilter()]] method to get an `extraFilters` filter array to pass to your `selectData()` call.

A useful example of this is a "Latest news" widget that allows you to choose a dynamic filter with which to filter the news to show. The widget form could look like this (see [[formcontrol-filterpicker]] for documentation on the filter picker):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form i18nBaseUri="widgets.latestnews:">
    <tab id="default" sortorder="10">
        <fieldset id="default" sortorder="10">
            <field name="title"  control="textinput" />
            <field name="filter" control="filterpicker" filterobject="news" />
        </fieldset>
    </tab>
</form>
```

The service logic to use the saved filter might then look like this:

```luceescript
// /services/NewsService.cfc
component {
   
    // ...

    public query function getLatestNews( string filter="" ) {
        var extraFilters = [];

        if ( arguments.filter.len() ) {
            extraFilters.append( rulesEngineFilterService.prepareFilter(
                  objectName = "news"
                , filterId   = arguments.filter
            ) );
        }

        return newsDao.selectData(
              filter       = { published = true }
            , extraFilters = extraFilters
            , orderby      = "publish_date desc"
        );
    }

    // ...

}
```

If you are persisting a filter choice to the database (as opposed to just using in a widget), create a property with a relationship to the `rules_engine_condition` object. e.g.

```luceescript
// /preside-objects/my_object.cfc
component {
    
    // ...

    property name="required_filter"  relationship="many-to-one"  relatedto="rules_engine_condition" control="filterpicker" filterobject="my_object";
    property name="optional_filters" relationship="many-to-many" relatedto="rules_engine_condition" relatedvia="my_object_optional_filter" control="filterpicker" filterobject="my_object" multiple=true;

    // ...

}
```---
id: rulesengineexpressions
title: Creating a rules engine expression
---

## Summary

Rules engine expressions are a combination of an i18n resource file (`.properties` file) and a convention based handler that implements an `evaluateExpression` action and, optionally, a `prepareFilters` action should the expression be available for building filters.

>>> An expression can be scaffolded using the dev console `new ruleexpression` command


## i18n resource file

By convention, expression resource files must live at: `/i18n/rules/expressions/{idOfExpression}.properties`. This file must, at a minimum, declare two keys, `label` and `text`:

```properties
label=User cancelled their place on an event
text=User {_has} cancelled their place on the event: {emsEvent}
```

The `label` item is used in the expression library selection box:

![Screenshot showing expression library selection box](images/screenshots/rulesEngineExpressionLibrary.jpg)

The `text` item is used in the condition builder, with `{somevar}` placeholders switched out for configurable fields:

![Screenshot showing expression being configured in condition builder](images/screenshots/rulesEngineExpressionInBuilder.jpg)

Default expression field texts (for required fields that have yet to be configured) can also be declared by convention in the `.properties` file. In the example above, the `{emsEvent}` field label is declared thus:

```properties
label=User cancelled their place on an event
text=User {_has} cancelled their place on the event: {emsEvent}

field.emsEvent.label=select an event
```

>>> Note the `{_has}` field. Chances are, if a field starts with an underscore, `_`, it is a "magic" system field that is automatically configured for you. See "Magic field names", in [[rulesenginefieldtypes]].

## The evaluateExpression handler action

Each expression must implement a handler with an `evaluateExpression` action (method) that returns `true` or `false` depending on the payload and configured expression field values. The handler must live at `/handlers/rules/expressions/{idOfExpression}.cfc`:

```luceescript
// /handlers/rules/expressions/userIsLoggedIn.cfc
/**
 * Expression handler for "User is/is not logged in"
 *
 * @feature websiteUsers
 * @expressionContexts webrequest
 */
component {

    private boolean function evaluateExpression( boolean _is=true ) {
        return arguments._is == isLoggedIn();
    }

}
```

### Expression context

The handler CFC file can be annotated with an `expressionContexts` attribute that will define in what contexts the expression can be used.

### Arguments passed to the evaluateExpression method

Because it is a ColdBox handler action, the method will always receive `event`, `rc` and `prc` arguments for you to use when relevant. In addition, the method will also always receive a `payload` argument that is a structure containing data relevant to the _context_ in which the expression is being evaluated. For example, the **webrequest** context provides a payload with `page` and `user` keys, each with a structure containing details of the current page and logged in user, respectively.

Any further arguments are treated as **expression fields** and should map to the `{placeholder}` fields defined in your expression resource file's `text` key. These arguments can also be decorated to configure the field further. For example, you may wish to define the field type + any further arguments that the field type requires:

```luceescript
/**
 * @expressionContexts user
 */
component {

    property name="emsUserQueriesService" inject="emsUserQueriesService";

    /**
     * @emsEvent.fieldType object
     * @emsEvent.object    ems_event
     * @emsEvent.multiple  false
     *
     */
    private boolean function evaluateExpression(
          required string  emsEvent
        ,          boolean _has = true
    ) {
        var userId = payload.user.id ?: "";

        if ( !userId.len() || !emsEvent.len() ) {
            return !_has;
        }

        var hasCancelled = emsUserQueriesService.userHasCancelledAttendance( userId, emsEvent );

        return hasCancelled == _has;
    }

}

```

Notice the annotations around the `emsEvent` argument above. Here they define the `object` field type and specify that the object for the field type is `ems_event` and that multiple selection is turned off.

>>>>>> We prefer to leave the `event`, `rc`, `prc` and `payload` arguments out of the function definition to show the expression fields more cleanly; this is a preference though, and you can define them if you wish.

## The prepareFilters handler action

The `prepareFilters()` handler action accepts the same dynamic arguments based on the configured expression as the `evaluateExpression()` action. However, instead of returning a boolean result, the method must return an array of **preside data object filters**. A simplistic example:

```luceescript
component {

    // ...
    /**
     * @objects event_session
     *
     */
    private boolean function prepareFilters(
          required string eventId           // arguments from configured expression 
        , required string objectName        // always passed to prepareFilters()
        ,          string filterPrefix = "" // always passed to prepareFilters() before 10.18.22. As of 10.20.4, 10.19.11 & 10.18.22 *this is always empty and can be ignored*
    ) {
        var paramName   = "eventId" & CreateUUId();  // important to avoid clashing SQL param names
        
        /* prior to 10.18.22: 
            var fieldPrefix = arguments.filterPrefix.len() ? arguments.filterPrefix : arguments.objectName;

            return [ {
                filter       = "#fieldPrefix#.event = :#paramName#"
                filterParams = { "#paramName#" = arguments.eventId }
            } ];
        */
        
        // from 10.18.22, 10.19.11 and 10.20.4 onwards:
        return [ {
            filter       = "#arguments.objectName#.event = :#paramName#"
            filterParams = { "#paramName#" = arguments.eventId }
        } ];
    }

}

```

### Annotations

The `prepareFilters()` method expects an `objects` annotation that is a comma separated list of objects that the filter can apply to. You may have some common fields across different objects that require a custom expression, specifying multiple objects will make this possible. e.g.

```luceescript
/**
 * @expressionContexts page,event,profile,article
 */
component {

    private boolean function evaluateExpression() {
        // ...
    }

    /**
     * @objects page,event,profile,article
     *
     */
    private array function prepareFilters() {
        // ...
    }    
}

```

Notice how the `@expressionContexts` for the CFC is also likely to be the same list of objects.

### Arguments

Your `prepareFilters()` method will _always_ receive `objectName` and `filterPrefix` arguments (prior to latest hotfixes of 10.18, 10.19 and 10.20 onwards). 

`objectName` is the name of the object being filtered. 

`filterPrefix` **ONLY PRIOR TO latest hotfixes of 10.18, 10.19 and 10.20 ONWARDS - IGNORE FOR LATEST** is a calculated prefix that should be put in front of any fields on the object that you use in filters. If the prefix is empty, then we are filtering _directly_ on the object (you may then wish to use the object name as a prefix as we have done in the example above). This is to allow filters to be nested and to be able to be buried deep in a traversal of the database entity relationships.

Any other arguments will by dynamically generated based on the expression's `evaluateExpression` definition and the user configured expression fields.

### A complex filter example

A rules engine filter can get a little complicated quite easily. For example, we may need to join on subqueries to be able to use some kind of statistical filter in conjunction with other dynamically generated filters. What follows is a more realistic example. Here we are filtering on whether or not website users have cancelled their place on a specific event:

```luceescript
component {

    // ...

    /**
     * @objects website_user
     */
    private boolean function prepareFilters(
          required string  eventId       // arguments from configured expression 
        , required boolean _has          // arguments from configured expression 
        , required string  objectName    // always passed to prepareFilters()
        ,          string  filterPrefix = ""
    ) {
        // setup params and filter clause for the passed eventId
        var paramName     = "eventId" & CreateUUId();
        var params        = { "#paramName#"={ value=arguments.eventId, type="cf_sql_varchar" } };
        var subQueryAlias = "eventCancellations" & CreateUUId();
        var filterSql     = "#subQueryAlias#.cancellation_count #( arguments._has ? '>' : '=' )# 0";
        var fieldPrefix   = arguments.filterPrefix.len() ? arguments.filterPrefix : arguments.objectName; // only necessary prior to latest 10.18

        // generate a subquery with user ID and cancellation count
        // fields filtered by the passed eventID.
        // notice the 'getSqlAndParamsOnly' argument (added in 10.8.0)
        var subQuery = eventCancellationDao.selectData(
              getSqlAndParamsOnly = true
            , selectFields        = [ "Count( id ) as cancellation_count", "website_user as id" ]
            , groupBy             = "website_user"
            , filter              = "event = :#paramName#"
            , filterParams        = params
        );

        // return a preside object data filter that includes 'extraJoins'
        // array to allow us to join on our subquery
        return [ { filter=filterSql, filterParams=params, extraJoins=[ {
              type           = "left"
            , subQuery       = subQuery.sql
            , subQueryAlias  = subQueryAlias
            , subQueryColumn = "id"
            , joinToTable    = fieldPrefix
            , joinToColumn   = "id"
        } ] } ];

    }

}

```
---
id: rulesenginefieldtypes
title: Rules engine field types
---

## Summary

Field types provide different UIs and option sets for configurable fields in rules engine expressions (see [[rulesengine]] for a higher level overview of the rules engine).

## System field types

The system comes with several built in expression field types. These may be automatically configured based on your expression handlers argument _type_ or they may need strict configuration. See the documentation for each for further details:

* `Asset`: TODO
* `Boolean`: TODO
* `Condition`: TODO
* `Date`: TODO
* `Number`: TODO
* `Object`: TODO
* `Operator`: TODO
* `Page`: TODO
* `PageType`: TODO
* `Select`: TODO
* `Text`: TODO
* `TimePeriod`: TODO
* `WebsiteUserAction`: TODO

## Creating custom field types

New field types can be created for your expressions. They are defined by creating a ColdBox handler at `/handlers/rules/fieldtypes/{idOfFieldType}.cfc`, that the following actions:

* `renderConfiguredField()` (required) should return a string that is a rendered representation of the configured field. This will appear in the condition builder
* `renderConfigScreen()` (required) should return a string with a render configuration screen (just the innards of a form). The most simple implementation is to render a form with a single field named 'value'. If you do so, the system will take care of the rest
* `prepareConfiguredFieldData()` (optional) Allows you to prepare a configured value at runtime before it is passed to the `evaluateExpression()` method of an expression. The raw value from the config form will be used by default if this method is not provided.

Here is the handler for our most complex field type, the `TimePeriod` type:

```luceescript
// /handlers/rules/fieldtypes/TimePeriod.cfc
component {

    property name="presideObjectService" inject="presideObjectService";
    property name="timePeriodService"    inject="rulesEngineTimePeriodService";

    private string function renderConfiguredField( string value="", struct config={} ) {
        var timePeriod = {};
        var data       = [];
        var type       = "alltime";

        try {
            timePeriod = DeserializeJson( arguments.value );
        } catch( any e ){
            timePeriod = { type="alltime" };
        };

        switch( timePeriod.type ?: "alltime" ){
            case "between":
                type = timePeriod.type;
                data = [ timePeriod.date1 ?: "", timePeriod.date2 ?: "" ];
            break;
            case "since":
            case "before":
            case "until":
            case "after":
                type = timePeriod.type;
                data = [ timePeriod.date1 ?: "" ];
            break;
            case "recent":
            case "upcoming":
                type = timePeriod.type;
                data = [
                      NumberFormat( Val( timePeriod.measure ?: "" ) )
                    , translateResource( "cms:time.period.unit.#( timePeriod.unit ?: 'd' )#" )
                ];
            break;
            default:
                type = "alltime";
        }

        return translateResource( uri="cms:rulesEngine.time.period.type.#type#.configured", data=data );
    }

    private string function renderConfigScreen( string value="", struct config={} ) {
        return renderFormControl(
              name         = "value"
            , type         = "timePeriodPicker"
            , pastOnly     = IsTrue( config.pastOnly   ?: "" )
            , futureOnly   = IsTrue( config.futureOnly ?: "" )
            , label        = translateResource( config.fieldLabel ?: "cms:rulesEngine.fieldtype.timePeriod.config.label" )
            , savedValue   = arguments.value
            , defaultValue = arguments.value
            , required     = true
        );
    }

    private struct function prepareConfiguredFieldData( string value="", struct config={} ) {
        return timePeriodService.convertTimePeriodToDateRange( arguments.value );
    }

}
```

## Magic field names

The system provides a set of core expression field names that will auto-configure themselves so that you do not need to provide resource translations or configure the field through annotations in your handler.

## Boolean fields

These magic fields will always evaluate to `true` or `false` but show different labels in the expression builder depending on the name of the field (as shown below). End users can between states of these fields just by clicking on them within the condition builder.

* `_is`: "is" or "is not"
* `_has`: "has" or "has not" (refers to has/has not performed some action)
* `_possesses`: "has" or "does not have"
* `_did`: "did" or "did not" (e.g. do some action)
* `_was`: "was" or "was not"
* `_are`: "are" or "are not"
* `_will`: "will" or "will not"
* `_ever`: "ever" or "never"
* `_all`: "all" or "any"

## Operator fields

These special fields provide the user with a way to configure an operator that may relate to another field. i.e. "more than" "5".

* `_stringOperator`: gives the user a list of different string comparisons to choose from (contains, equals, etc.)
* `_dateOperator`: gives the user a list of date comparisons to choose from
* `_numericOperator`: gives the user a list of number comparisons to choose from
* `_periodOperator`: gives the user a list of time period based numeric comparisons to choose from

To use these fields in your expressions, the core provides a helper service, [[api-rulesengineoperatorservice]], that can be injected into your handler and used to evaluate whether or not the combination of comparison operator and configured value is true or false:

```luceescript
/**
 * @expressionContexts user
 */
component {

    property name="emsUserQueriesService"      inject="emsUserQueriesService";
    property name="rulesEngineOperatorService" inject="rulesEngineOperatorService";

    private boolean function evaluateExpression(
          required numeric count
        ,          string  _numericOperator = "gt"
    ) {
        var userId       = payload.user.id ?: "";
        var bookingCount = 0;

        if ( userId.len() ) {
            bookingCount = emsUserQueriesService.getUserBookingCount( userId=userId );
        }

        // we can use the rulesEngineOperatorService to do comparison with
        // our value, configured limit and operator:
        return rulesEngineOperatorService.compareNumbers( bookingCount, arguments._numericOperator, arguments.count );
    }
}
```

## Date comparison fields

These fields all give the user a date range picker to configure the field and provide your expression at runtime with a `struct` potentially containing `from` and `to` date values (it could also be an empty `struct` or contain only one of the keys).

* `_time`: Gives a date range picker that can be configured for both future and past ranges
* `_pastTime`: Gives a date range picker that is limited to past time ranges
* `_futureTime`: Gives a date range picker that is limited to future time ranges

Example usage:

```luceescript
/**
 * Expression to evaluate a logged in user's spend on events
 *
 * @expressionContexts user
 */
component {

    property name="emsUserQueriesService"      inject="emsUserQueriesService";
    property name="rulesEngineOperatorService" inject="rulesEngineOperatorService";

    /**
     * @eventType.fieldtype   object
     * @eventType.object      ems_event_type
     * @eventType.multiple    false
     *
     */
    private boolean function evaluateExpression(
          required numeric amount
        ,          string  _numericOperator = "gt"
        ,          string  eventType = ""
        ,          struct  _pastTime // our past time date range Magic field
    ) {
        var userId        = payload.user.id ?: "";
        var bookingAmount = 0;

        if ( userId.len() ) {
            bookingAmount = emsUserQueriesService.getTotalBookingAmountForUser(
                  userId       = userId
                , dateFrom     = _pastTime.from ?: "" // from may not exist
                , dateTo       = _pastTime.to   ?: "" // to may not exist
                , eventType    = eventType
            );
        }

        return rulesEngineOperatorService.compareNumbers( bookingAmount, arguments._numericOperator, arguments.amount );
    }

}
```

By default, the interface will be based around datetime values. *10.13.0* adds the attribute `@_time.isDate`: if set, the interface will present simple date pickers, and comparisons will exclude time periods. Automatically generated rules will base this setting on the `dbtype` of the property.---
id: rulesenginecontexts
title: Rules engine contexts
---

## Creating custom contexts

Rules engine contexts are created and defined in `Config.cfc`, should have `i18n` label entries in `/i18n/rules/contexts.properties` and optionally provide a convention based handler for getting the context payload.


## Config.cfc definition

Here is the core configuration in `Config.cfc$configure()` for contexts:

```luceescript
settings.rulesEngine = { contexts={} };
settings.rulesEngine.contexts.webrequest = { subcontexts=[ "user", "page" ] };
settings.rulesEngine.contexts.page       = { object="page" };
settings.rulesEngine.contexts.user       = { object="website_user" };
``` 

### Contexts with subcontexts

Notice how the `webrequest` context is made up of two subcontexts, `page` and `user`. In theory, this can be endlessly nested, though the practical uses of that may be limited. The idea here is that contexts like `webrequest` want payloads from other sources such as page, currently logged-in user, and perhaps form builder form submission (in the future).

### Context object

If a context defines an object, it is expected that this context should work with _filters_ that are saved against the object. Also, it is expected that the payload for the context be a structure with a single key whose name is the object. e.g. the payload for `user` context should look like this:

```luceescript
userContext = { 
	website_user = {
		  id           = '...'
		, display_name = 'bob'
		, ...
	} 
}
```

If no object is defined, and the name of the context is an existing object, the context name will be used as a default.

## i18n labelling

i18n properties for contexts live at `/i18n/rules/contexts.properties` and look like this:

```properties
webrequest.title=Web request
webrequest.description=Conditions that apply to a web page request (includes user and web page expressions)
webrequest.iconClass=fa-globe

page.title=Web page
page.description=Conditions that apply to a site tree page
page.iconClass=fa-file-o

user.title=User
user.description=Conditions that apply to a user
user.iconClass=fa-user
```

Each context should have a `title`, `description` and `iconclass` key prefixed with `{contextid}.`.

## Handler

To supply the logic for retrieving a context payload when evaluating a condition, you must implement a handler at `/handlers/rules/contexts/{contextId}.cfc`. e.g. for the `page` context, we implement `/handlers/rules/contexts/Page.cfc`. The handler needs to supply a single method that returns a struct. For example, our core `page` handler looks like this:

```luceescript
/**
 * Handler for the page rules engine context
 *
 */
component {

	private struct function getPayload() {
		return { page = ( prc.presidePage ?: {} ) };
	}

}
```

Notice how we return a struct with a single key, `page`. This is important as it isolates the payload so that we can combine payloads for contexts that consist of multiple other contexts.

---
id: rulesengineautogeneration
title: Auto-generated filters
---

As of 10.8.0, Preside will auto generate basic filters for your preside objects. The system will iterate over your objects and generate multiple filter expressions for each of the object's properties.

## Bypassing filter expression generation

You can tell the system to NOT auto generate filter expressions for a property by adding the `autofilter=false` attribute to the property:

```luceescript
property name="description" ... autofilter=false;
```

## Configure filter expression generation

As of Preside **10.16.0**, you can tell the system to NOT auto generate filter one or more expressions of a property by adding the `excludeAutoExpressions="{one or more expression keys}"` attribute to the property:

```luceescript
property name="example" ... excludeAutoExpressions="manyToOneFilter,manyToManyCount";
```

### Filter expression role permission

As of Preside **10.16.0**, you can configure which filter expressions of a property are auto generate for specific admin role by adding the `autoFilterExpressions:{admin role}="{one or more expression keys}"`

```luceescript
property name="example" ... autoFilterExpressions:contentadmin="propertyIsNull,datePropertyInRange" autoFilterExpressions:contenteditor="datePropertyInRange";
```


## Auto-adding filters for related objects

The system can also add automatically generated filter expressions for `many-to-one` related objects. This means, for example, you can use filters for various `contact` object properties on a `user` object when the `user` object has a `many-to-one` relationship with `contact`.

The system will do this _automatically_ for any `many-to-one` relationships that also have a unique index (effectively a `one-to-one` relationship). However, you can also add the `autoGenerateFilterExpressions=true` attribute to the property to force this behaviour:

```luceescript
poperty name="category" relationship="many-to-one" autoGenerateFilterExpressions=true ...;
```

### Going multiple levels deep into relationships

If you want to auto generate filter expressions for related objects that are more than a single level deep, you can use the `@autoGenerateFilterExpressionsFor` attribute on the _object_ definition. 

For example, we may have the following related objects (each a `many-to-one` relationship): `event_delegate -> website_user -> contact -> organisation`. If we wanted our users to be able to easily filter `event_delegate` records by `contact` and `organisation` fields, we could add the `@autoGenerateFilterExpressionsFor` attribute as follows:

```luceescript
/**
 * event_delegate.cfc
 *
 * @autoGenerateFilterExpressionsFor website_user.contact, website_user.contact.organisation
 */
component {
	property name="website_user" relationship="many-to-one" relatedto="website_user";

	// ...
}
```

The syntax is a comma separated list of relationship chains that use the `many-to-one` property name at each stage of the relationship to define the path to the related object.

#### Customize the labeling used for multi-level filters

By default, auto generated filter expressions for related objects will be prefixed by the object name, e.g. `Organisation: city contains text`. 

However, you may find that you have multiple relationships to the same object and want to customize the prefix that appears to indicate which relationship is being filtered on. To do so, use the relationship path specified in your `@autoGenerateFilterExpressionsFor` attribute inside your object's i18n `.properties` file to provide an alternative:

```properties
filter.prefix.website_user.contact.organisation=User organisation
filter.prefix.sponsor.organisation=Sponsor organisation
```

>>> Each relationship path is prefixed with `filter.prefix.`.


## Customizing language for many-to-many and one-to-many filters

Auto-generated filter expressions for relationship fields look something like this (in English):

```
Attendee has any sessions
Attendee has (x) sessions
Attendee has sessions
```

This may be _ok_ in many scenarios, but we can customize this language slightly to make it more accurate by changing the `has` to something different. To do so, edit the `.properties` file for your preside object and add the following keys: `field.{relationshipPropertyName}.possesses.truthy` and `field.{relationshipPropertyName}.possesses.falsey`. e.g.

```properties
field.sessions.possesses.truthy=is signed up to
field.sessions.possesses.falsey=is not signed up to
```

This will then result in filter expressions that appear more naturally:

```
Attendee is signed up to any sessions
Attendee is signed up to (x) sessions
Attendee is signed up to sessions
```---
id: systemalerts
title: System Alerts
---

## Overview

System alerts were introduced in Preside **10.20** and allow developers to alert users of the admin system to problems that require resolving. For example, when there is missing system config such as the "Default from email address" that will lead to errors with the full working of the system.

Developers register alerts by providing a convention based handler with an accompanying i18n properties file.

## Implementation

### The system alert handler

System Alert handlers are stored by convention in the `admin.systemAlerts` directory, and are discovered automatically. For example, if I wish to create a "checkDataMappings" alert, I would create a handler file at `/handlers/admin/systemAlerts/CheckDataMappings.cfc`.

The following is a self-documenting example of a system alert handler:

```luceescript
component {

  /**
   * Required. The runCheck( check ) method is used to perform your health
   * check. Use the passed `check` object to report failure or success
   */
  private void function runCheck( required systemAlertCheck check ) {
    var type      = check.getType(); // optional
    var reference = check.getReference(); // optional, used for context specific checks

    if ( _someLogicFails( reference ) ) {
      check.fail(); // required to mark as failed
      check.setLevel( "critical" ); // not required
      check.setData( { customData="canBeAdded" } ); // not required
    }
	// Note that the check is in a "passing" state by default, so we do not need to
	// explicitly set it as passing, unless we are overriding a previous instruction
  }

  /**
   * Optional, but recommended. Renders the alert in the admin
   * Should provide detail for the user about how to resolve the
   * issue
   *
   * args struct contains any data passed to check.setData() in runCheck
   */
  private string function render( event, rc, prc, args={} ) {
    return renderView( view="/admin/systemAlerts/myAlert/render", args=args );
  }


// CONFIG SETTINGS
  /**
   * Optional. Implement this method and return true to have the check run at startup
   *
   */
  private boolean function runAtStartup() {
    return true;
  }

  /**
   * Optional. Implement this method to have your check run on a schedule.
   * Must return a valid 6 point cron expression.
   *
   */
  private string function schedule() {
    return "0 0 */2 * * *"; // every two hours
  }

  /**
   * Optional. Implement this method to return an array of system category settings
   * to watch. If the settings change, then the check is run.
   *
   */
  private array function watchSettingsCategories() {
    return [ "email" ];
  }

  /**
   * Optional (default is warning). Implement this method to set
   * the default level of alert for all alerts raised using this check
   *
   */
  private string function defaultLevel() {
    return "info";
  }

  /**
   * Optional (default to empty, meaning 'global'). should return
   * a string, denoting the area of the application for which the
   * alert is relevant. If not specified, the system alert will
   * relate to the application as a whole.
   */
  private string function context() {
    return "events";
  }

  /**
   * Optional. should return an array of reference values, which
   * will be passed in turn to the `runCheck()` function to run
   * multiple checks. This will be done IF the `references()` method
   * is defined AND the `runCheck()` method is called without otherwise
   * specifying a reference. So, as an example, the method might return
   * an array of IDs of all events set to take place in the future, and
   * the check can then be run against each in turn.
   *
   * The method is passed one argument, `trigger`, which tells you how the
   * check was called (for instance, you may want different logic if the
   * check is being run at startup).
   *
   */
  private array function references( string trigger ){
    return _getEventIdsToCheckForGlobalRecheck();
  }

}
```

### i18n properties file

In addition to the handler, you should supply a `.properties` file to match at `/i18n/systemAlerts/{alertName}.properties`. It is only required to provide a title key (but you can use the file to provide any additional text for your alert rendering). For example:

```properties
# /i18n/systemAlerts/eventSetup.properties
title=Event setup
```


## Running a check

Aside from running checks automatically, they may also be called programmatically with the `runSystemAlertCheck()` helper method or `$runSystemAlertCheck()` superclass method, which proxy to the [[systemalertsservice-runcheck]] method of the [[api-systemalertsservice]].

The first argument, `type`, is required and is the handler name of the system alert.

The second argument, `reference` is optional. If a check specifies a `references()` method, then omitting this argument will run the check against all of those references.

The third argument, `async`, is a boolean that defaults to true. If true, the check will be run asynchronously in the background; if false, it will run immediately.

The fourth argument, `trigger`, is an optional string that reports how the check is being called. By default, the value is `code`, denoting it is being called explicitly via code.

If being run globally or against a single reference, the return value is the resulting `systemAlertCheck` object, to help you provide feedback to the user (any alert will have been raised or cleared automatically by the function). Otherwise, null is returned.


## The systemAlertCheck object

For each check that is run, a `systemAlertCheck` object is instantiated and passed into the `runCheck()` method. It is initialised with the type of the system alert, the default level, any reference that was passed in, how the check was triggered, and when the check was last run.

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
- `getTrigger()`: returns a string informing how the check was triggered. Possible values are `startup`, `settings`, `schedule`, `rerun` or (default) `code`

These methods should be used to manipulate the check object when running a check. Based on the result passed back to the service, an alert will either be raised or cleared.


## The system alert check log

Behind the scenes, there is an object `system_alert_log`, which stores logging information about when checks have been run. This may be useful for troubleshooting.

Values stored are:

- `type`
- `reference`
- `trigger`
- `ms` - the running time of the check, in milliseconds
- `run_at` - the datestamp of the running of the check---
id: restframework
title: REST framework
---

## Introduction

Preside provides a framework for developing REST APIs that work inline and seamlessly with the rest of the ecosystem. It has taken inspiration from the [Taffy REST Framework](http://taffy.io/) by Adam Tuttle, and follows several of its patterns.

The current version of the framework provides you with the conventions, services and routing layer to help you easily author your own REST APIs; further tooling such as documentation generation and user management are planned for future releases.

>>> The documentation here will not attempt to teach the ins and outs of RESTful APIs; rather document how Preside implements RESTful concepts. We can highly recommend Adam Tuttle's book, [REST Assured](http://restassuredbook.com/) as a primer and go-to resource for authoring REST APIs.

## APIs and Resources

Creating a new REST API in Preside is a case of creating a directory containing coldbox handler CFCs. Each handler represents a resource in your API. These APIs and resources must all live under your application's `/handlers/rest-apis/` folder. For example:

```
/application/handlers/rest-apis
    /my-cool-api
        /v1
            SomeResource.cfc
```

The structure above defines a resource, `SomeResource`, beneath the `/my-cool-api/v1` API.

## Defining a resource

Resource CFCs are simple ColdBox handlers with some additional annotations to define how they should work within the REST API. An example:

```luceescript
/**
 * @restUri /someresource/{variable}/{variable2}/
 *
 */
component {

	property name="pageDao" inject="presidecms:object:page";

	private void function get( required string variable, required string variable2 ) {
		var records = someDao.selectData(
			  selectFields = [ "id", "title" ]
			, savedFilters = [ "livePages" ]
		);

		restResponse.setData( QueryToArray( records ) )
		            .setStatus( 200, "Awesome" )
		            .setHeader( "X-Rocking", true );
	}

	private void function post( required string variable, required string variable2 ) {
		// ...
	}

	/**
	 * @restVerb push
	 *
	 */
	private void function anotherNameForPush( required string variable, required string variable2 ) {
		// ...
	}

	// etc.
}

```

## Routing and the REST URI definition

The `@restUri` annotation defines URL patterns that will be matched by this resource. It can optionally contain wildcards that map to variable names indicated by curly braces `{somevariable}`. Individual patterns are separated with a comma.

The entire URL path for routing a REST request to a resource will be made up of three parts:

1. The configured REST path that tells Preside that this is a REST request. The default is `/api`.
2. The path to the specific API that the resource lives under, i.e. the folder structure beneath `/handlers/rest-apis`
3. The path that will match the specific resource

For example, if your resource lived at `/handlers/rest-apis/myapi/v1/Page.cfc` and defined the `@restUri` pattern as `/pages/,/pages/{slug}/{pageid}/`, it would match the following URL paths:

```
/api/myapi/v1/pages/
/api/myapi/v1/pages/some-slug/359860837568/
```

>>>>>> You can configure the path that the framework uses to recognize rest requests by setting the `settings.rest.path` variable in your site's `Config.cfc` file. e.g. `settings.rest.path = "/rest";`.

## Mapping HTTP Methods (Verbs) to resource handler actions

By providing methods on your resource CFC that match the names of HTTP Methods, you can route a request to a specific function based on the HTTP method used by the request. For example, to handle a request to your resources URI using the HTTP DELETE method, you would implement a `delete` handler action:

```luceescript
/**
 * @restUri /blogcategories/,/blogcategories/{slug}/{id}/
 *
 */
component {

	property name="blogCategoryDao" inject="presidecms:object:blog_category";

	private void function delete( required string id ) {
		blogCategoryDao.deleteData( id=arguments.id );

		restResponse.noData().setStatus( 200, "OK" );
	}
}
```

### Using different method names

If you prefer, or need, to use different method names, you can map HTTP methods to your handler actions with the `@restVerb` annotation against the handler action itself. e.g. here we map the `deleteCategory` method to the `DELETE` verb:

```luceescript
/**
 * @restUri /blogcategories/,/blogcategories/{slug}/{id}/
 *
 */
component {

	property name="blogCategoryDao" inject="presidecms:object:blog_category";

	/**
	 * @restVerb DELETE
	 *
	 */
	private void function deleteCategory( required string id ) {
		blogCategoryDao.deleteData( id=arguments.id );

		restResponse.noData().setStatus( 200, "OK" );
	}
}
```

## Accepting arguments

Because your REST API resources are defined as ColdBox handlers, your handler actions will always receive the usual `event`, `rc` and `prc` arguments.

### REST Request and Response objects

In addition to the standard ColdBox arguments, the REST framework provides your handler action with `restRequest` and `restResponse` arguments. You can use the `restResponse` object to set data, mime type, renderer, status code and HTTP headers for the response of the REST request. The `restRequest` argument can be used to discover information about the request, and to prematurely end the request with `restRequest.finish()`.

See the reference docs for [[api-presiderestrequest]] and [[api-presiderestresponse]] for full details.


```luceescript
/**
 * @restUri /events/
 *
 */
component {
	private void function get() {
		restResponse.setError(
			  errorCode = 501
			, title     = "Not implemented"
			, message   = "The /events/ GET api has not yet been implemented."
		);
	}
}
```

>>>>>> We prefer not to include the `event`, `rc`, `prc`, `restRequest` and `restResponse` arguments in the function *definition* to help with readability.

### REST URI Tokens

If your resource defines a URI mapping that includes tokens, these will also be passed to your handler actions when available, for instance:

```luceescript
/**
 * @restUri /events/,/events/{id}/
 *
 */
component {

	// here, the 'id' argument is automatically
	// passed to the action when it is present
	// in the rest URI
	private void function get( string id="" ) {
		// ...
	}
}
```

### URL Parameters

Finally, any query string or POST parameters will also be available as individual arguments (in addition to being available in `rc`). This will help future development in the API where we would like to automatically raise friendly errors for missing parameters, etc.

For example:

```luceescript
/**
 * @restUri /events/,/events/{id}/
 *
 */
component {

	private void function get(
		  string  id       = ""
		, numeric page     = 1
		, numeric pageSize = 50
	) {
		// here we expect URLs like /events/?page=3&pageSize=10
		// or /events/34583745/
	}
}
```

## Configuring your APIs

Any additional configuration of the REST APIs can be made in your site's `Config.cfc` file. There is a core settings structure for REST that looks like:

```luceescript
settings.rest = {
	  path        = "/api"
	, corsEnabled = false
	, apis        = {}
};
```

Additional settings can be defined either globally, or per API. Currently there is only a single setting, `corsEnabled` which is turned off by default. An example of turning CORS on globally would look like this:

```luceescript
settings.rest.corsEnabled = true
```

Or, to turn it on only for a specific API:

```luceescript
settings.rest.apis[ "/myapi/v2" ] = { corsEnabled=true };
```

## Basic caching

The framework automatically adds `ETag` response headers for GET and HEAD REST requests. These are a simple MD5 hash of the serialized response body. In addition, if the REST request includes a `If-None-Match` request header whose value matches the generated `ETag`, the framework will set an empty response body and set the status of the response to `304 Not modified`.

More advanced caching can be achieved using the CacheBox framework that is built in to ColdBox (and therefore Preside). See the [ColdBox docs](https://coldbox.ortusbooks.com/getting-started/configuration/coldbox.cfc/configuration-directives/cachebox) for further details.

## HEAD requests

The framework deals with HEAD requests for you, without you needing to implement a resource handler action for the verb. Simply, when responding to a HEAD request, the system will call the GET action for your resource and empty the body data before rendering the response.

## CORS support

[CORS (Cross-Origin Request Sharing)](http://www.w3.org/TR/cors/) is used to validate that a resource can be used by a system from another origin. This is relevant for browser based JavaScript requests to your API where the requesting page resides at a domain that differs to that of the API.

Before requesting the remote resource fully, a browser will send a "pre-flight" request using the `OPTIONS` HTTP Method along with headers to describe the intentions of the upcoming request. The Preside Rest framework detects these requests for you and responds appropriately based on:

1. Whether or not CORS is enabled for the API (currently, we only allow enabling or disabling CORS globally for all domains)
2. Whether or not the matching resource supplies a method for responding to the given HTTP Method

If the framework detects an `OPTIONS` request without the prerequisite CORS headers, it will respond with a `400 Bad request` status. If the request is valid, but CORS disallowed for either of the reasons above, a `403 Forbidden` status will be returned. Finally, if the request is valid and the CORS request allowed, a `200 OK` status will be returned, along with the relevant `Access-Control` response headers to inform the calling system that the CORS request is valid.

## Interception points

Your application can listen into several core interception points to enhance the features of the REST platform, e.g. to implement custom authentication. See the [ColdBox Interceptor's documentation](https://coldbox.ortusbooks.com/the-basics/interceptors) for detailed documentation on interceptors.

For example, an interceptor that listens for the `onUnsupportedRestMethod` interception point and changes the REST response to something other than the default:

```luceescript
component extends="coldbox.system.Interceptor" {

	public void function configure() {}

	public void function onUnsupportedRestMethod( event, interceptData ) {
		var response = interceptData.restResponse;

		response.setStatus( 405, "This is not the method you are looking for" )
		        .setBody( "nope" )
		        .setRenderer( "plain" )
		        .setMimeType( "text/plain" );
	}
}
```

The Interception points are:

### onRestRequest

Fired at the beginning of a REST request. Takes `restRequest` and `restResponse` objects as arguments.

### onRestError

Fired whenever an unhandled exception occurs during execution of the request. Takes `error`, `restRequest` and `restResponse` objects as arguments.

### onMissingRestResource

Fired when no resource matches the incoming URL Path. Takes `restRequest` and `restResponse` objects as arguments.

### onUnsupportedRestMethod

Fired when the matched resource does not support the used HTTP Method. Takes `restRequest` and `restResponse` objects as arguments.

### preInvokeRestResource

Fired before the resource's handler action is called. Takes `args` structure, and `restRequest` and `restResponse` objects as arguments. The `args` structure are the arguments that will be passed to the resource's handler action.

### postInvokeRestResource

Fired after the resource's handler action is called. Takes `args` structure, and `restRequest` and `restResponse` objects as arguments. The `args` structure represents the arguments that were passed to the resource's handler action.

## Authentication

The REST framework comes with a system for providing authentication handlers that can optionally be configured through a user interface.

### Creating an authentication provider

An authentication provider is made up of:

1. A convention based handler providing the authentication logic and optional configuration logic
2. A convention based i18n file to provide user friendly text for the provider

Note, in order for configuration to be activated, the `apiManager` feature is required (`settings.features.apiManager.enabled = true`).

#### The handler

Create a handler at `/handlers/rest/auth/{IdOfProvider}.cfc`. Example (from core "Token" provider):

```luceescript
/**
 * Handler for authenticating with token authentication
 *
 */
component {

	property name="authService" inject="presideRestAuthService";

	/**
	 * Invoked at the start of any REST API request
	 * for a REST api configured to use this authentication
	 * provider
	 *
	 */
	private string function authenticate() {
		var headers    = getHTTPRequestData( false ).headers;
		var authHeader = headers.Authorization ?: "";
		var token      = "";

		try {
			authHeader = toString( toBinary( listRest( authHeader, ' ' ) ) );
			token      = ListFirst( authHeader, ":" );

			if ( !token.trim().len() ) {
				throw( type="missing.token" );
			}
		} catch( any e ) {
			// returning empty string, not authenticated
			return "";
		}

		var userId = authService.getUserIdByToken( token );
		if ( userId.len() && authService.userHasAccessToApi( userId, restRequest.getApi() ) ) {
			
			// if authentication is successful, return ID of the user
			return userId;
		}

		// returning empty string, not authenticated
		return "";
	}

	/**
	 * Invoked when a user clicks on "configure" link in the API manager
	 * besides the API they wish to configure
	 *
	 */
	private string function configure() {
		setNextEvent( url=event.buildAdminLink( "apiusermanager" ) );
	}

}
```

#### i18n file

Create a `.properties` file at `/i18n/rest/auth/{IdOfProvider}.properties`. e.g. (from core Token provider):

```properties
title=Basic token authentication
description=REST users are assigned tokens that can be used to authenticate
iconClass=fa-tag
```

### Using an authentication provider

To make use of a custom authentication provider, you must configure your REST api in Config.cfc. For example,
if you have a REST API at `/handlers/rest-apis/my-api/v1` and wish to use the built-in "token" authentication 
provider:


```luceescript
settings.rest.apis[ "/my-api/v1" ] = {
	  authProvider = "token"
	, description  = "My API with its lovely description"
}
```

#### Getting the user ID during a REST request

In any REST route handler, you are able to get the ID of the authenticated user with `restRequest.getUser()`.
This will be the user ID as returned from the `authenticate()` method of your authentication provider's handler.
---
title: Preside documentation
---

## Welcome

<img src="images/preside-icon.png" height="200" width="200" style="margin-left: 20px;margin-bottom: 10px;" class="pull-right no-border">

Welcome to the official [Preside](https://www.preside.org) documentation for Developers. The documentation here aims to provide both a thorough reference and guide to developing applications with the Preside platform.

* [[quickstart]] for first time developers
* [[devguides]] for detailed guides
* [[reference]] for looking up specific functions, forms, etc.
* [[contribguides]] for help with getting involved
* [[upgradenotes]] for detailed notes on major upgrades
* [[about]] for help with editing the docs


## Getting help

If you're struggling with something, or finding issues with the documentation or software, head over to our [community forums](https://community.preside.org/) where someone will be happy to help you out.---
id: 10-21-upgrade-notes
title: Upgrade notes for 10.20 -> 10.21
---

## Summary

The 10.21.0 release is another super focused release with just four tickets. There are no upgrade concerns (but do checkout the [release notes](https://www.preside.org/release-notes/release-notes-for-10-21-0.html) to understand the new features).
---
id: 10-18-upgrade-notes
title: Upgrade notes for 10.17 -> 10.18
---

## Summary

The 10.18.0 release is a maintenance release with 11 tickets covering minor development feature enhancements, performance improvements and minor bug fixes.

There are no known compatibility issues or concerns with regards to upgrading from the previous stable version of Preside.
---
id: 10-20-upgrade-notes
title: Upgrade notes for 10.19 -> 10.20
---

## Summary

The 10.20.0 release is a super focused release with just four tickets. There are no upgrade concerns (but do checkout the [release notes](https://www.preside.org/release-notes/release-notes-for-10-20-0.html) to understand the new features).
---
id: 10-9-upgrade-notes
title: Upgrade notes for 10.8 -> 10.9
---

## General notes

The 10.9 release has a small number of changes that require special consideration for upgrade:

* Lucee restart
* Coldbox 4
* Admin interfaces that have been built with the "crudadmin" tool


## Lucee restart

If you are upgrading to Preside 10.9 from previous versions, you should restart Lucee after upgrading your code to avoid various issues.

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

10.9.0 Comes with a whole new system for [[customizingdatamanager|customizing the data manager]] that makes the `crudadmin` tool redundant. If you have built admin sections with the `crudadmin` tool, you should add the following attribute to your object definitions to ensure no problems:

```
@datamanagerEnabled true
```---
id: 10-16-upgrade-notes
title: Upgrade notes for 10.15 -> 10.16
---

## Summary

The 10.16.0 release brings a number of improvements to the platform that should be bought to the attention of developers, in particular with regards to custom features that they may have developed. There are no known compatibility issues.

## Asset image alt text

There is now an out-of-the-box alt text field for assets. In addition, all of our default asset renderers now use this alternative text when it is available.

You should check your code-base for any customised asset renderers and update them to get the alt text from the `alt_text` field on the `asset` record. For example:

```lucee
<!--- /views/renderers/asset/image/default.cfm --->
<cfscript>
	imageUrl = event.buildLink( assetId=args.id ?: '', derivativ=args.derivative ?: "" );
	altText  = Len( Trim( args.alt_text ?: "" ) ) ? args.alt_text : ( args.title ?: "" );
</cfscript>
<cfoutput>
	<img src="#imageUrl#"
		<cfif Len( Trim( altText ) ) > alt="#( altText )#"</cfif>
		<cfif Len( Trim( args.label ?: "" ) ) > title="#( args.label )#"</cfif>
		<cfif Len( Trim( args.class ?: "" ) ) > class="#( args.class )#"</cfif>
	/>
</cfoutput>
```

## Datamanager delete record prompts

In 10.16.0, we added the ability to easily prompt users to type a confirmation text when deleting records from the Datamanager screens:

![Screenshot of a delete record prompt](images/screenshots/deleteprompt.png)

This feature is turned off by default for single record deletes, and turned _on_ by default for multi-record deletes.

See the [[customizing-deletion-prompt-matches]] guide for more details about configuring this feature.

## Datamanager listing batch operations

In Preside 10.16.0, two tickets brought some more robust handling of the batch edit and delete functionalities when triggered from datamanager listing tables. If you are customising the batch operations, or implementing pre/post delete record customisations, then you may need to take action:

* [PRESIDECMS-2213](https://presidecms.atlassian.net/browse/PRESIDECMS-2213) Batch edit/delete: perform in background thread and show progress bar
* [PRESIDECMS-2214](https://presidecms.atlassian.net/browse/PRESIDECMS-2214) Datamanager batch operations: allow option to select all records matching current filters

![Screenshot of "select all matching filter" feature in datatables](images/screenshots/batchselectall.png)

### Pre and post delete customisations

Previously, during the batch delete process, the [[datamanager-customization-predeleterecordaction]] and [[datamanager-customization-postdeleterecordaction]] customisations would be fired for objects that implemented them. 

**THIS IS NO LONGER THE CASE FOR BATCH DELETE**. Instead, we now execute the following new customisations for objects that implement them:

* [[datamanager-customization-prebatchdeleterecordsaction]]
* [[datamanager-customization-postbatchdeleterecordsaction]]

>>> You should search your code bases for handler implementations of the pre/postdeleteRecordAction customisations and update accordingly to support batch delete if needed.

### Custom batch record operations

If your codebase has supplied custom batch operations using one of the customisations below, you should consider supporting the new "Select all records matching the current filter" functionality. If you do nothing, this feature will not work for your batch operation:

* [[datamanager-customization-listingmultiactions|listingMultiActions]]
* [[datamanager-customization-getlistingmultiactions|getListingMultiActions]]
* [[datamanager-customization-getextralistingmultiactions|getExtraListingMultiActions]]

See [[datamanager-customization-multirecordaction]] for an updated guide to creating batch operations. Scanning your codebase for references to `multiRecordAction(` will give you an indication of where this has been customised.

---
id: 10-11-upgrade-notes
title: Upgrade notes for 10.10 -> 10.11
---

## Lucee version

Bugs in earlier versions of Lucee 5 mean that Preside 10.11 may refuse to start. The earliest known Lucee 5 version to work with Preside is Lucee **5.2.9.20**. However, we recommend running at least **5.3.3.63**. We no longer recommend running Lucee 4.5.

## CfConcurrent

A new mapping was added to **10.11.0**, `/cfconcurrent`. Unfortunately, this mapping actually already existed but pointed to an empty directory. This may cause the need for a Lucee restart after upgrading from a previous version.

If you see the error, `invalid component definition, can't find component [cfconcurrent.ExecutorService]`, you will need to restart Lucee.

## Asset file names

In 10.11.0, we introduced a feature to save assets and derivatives using a configured file name. By default this is set as `$slugify( title )` when the asset is uploaded. Content editors are able to edit this file name in the admin and this results in a file name change.

**Existing assets are not automatically renamed when upgrading**. If you want to automate this, you will need to provide a script that renames each asset that is not already renamed. This script should use the code below to ensure files are renamed and moved in the process:

```luceescript
assetManagerService.editAsset( id=asset.id, data={ file_name=myGeneratedFileName } );
```

## Asset queue

10.11.0 introduced the concept of the [[enabling-asset-queue|Asset processing queue]] however it is disabled by default. We highly encourage you to enable it and test as early as possible. See the full guide: [[enabling-asset-queue]].

## Cache configurations

Several changes were made to caching in Preside. Key headlines that you should be aware of:

1. Full page cache, `presidePageCache` changed from a memory storage to _disk_ storage that saves to the Lucee tmp directory by default
2. Several caches were removed entirely due to not really being caches
3. A configuration option was added to allow preside objects to each have their own query cache. This is disabled by default and we recommend turning it on and configuring. See: [Cache per object](https://docs.preside.org/devguides/dataobjects.html#cache-per-object).

We recommend reviewing `/preside/system/config/Cachebox.cfc` against your own `/application/config/Cachebox.cfc` to check for any issues that might arise from the changes.

---
id: preparing-for-an-upgrade
title: Preparing for an upgrade
---

# Preparing for an upgrade

Whenever you are upgrading Preside, you should bear in mind that you are upgrading an underlying platform and that your application will require testing for any conflicting changes. With that in mind, we urge you to always test both:

* performing the upgrade
* application functionality after the upgrade

Always read the [release notes](https://www.preside.org/release-notes.html) and [[upgradenotes|upgrade notes]] for all the releases between your current version and the target version to be sure that you are fully aware of what the upgrade consists of. This will help you plan your testing and prepare you for any large changes that might otherwise cause a surprise.

## Maintenance mode

We recommend that you always use Maintenance Mode for upgrading Preside (see [[customerrorpages]]). This ensures that live traffic to the site does not affect the upgrade process and that the end-user experience is as smooth as it can be. It will also make sure that any error messages / warnings / SQL upgrade messages that arise from the upgrade will *not* be visible to your users.

## Database upgrades

Upgrades that require changes to the database deserve special care and attention. The Preside platform has the ability to automatically synchronize your database schema but the default setting is to turn this _off_ except for local development environments. This is controlled through settings in `Config.cfc`:

```
settings.syncDb     = true;
settings.autoSyncDb = false;
```

When `settings.syncDb` is set to `false`, the application will make **no attempt** to synchronise the database. You will be responsible for maintaining your database schema. The default value for this setting is `true`.

If `settings.syncDb` is set to `true` and `settings.autoSyncDb` is set to `false`, the application will create an upgrade SQL script that you can then run directly on your database. The script will be saved at `/{webroot}/logs/sqlupgrade.sql` and a message will appear informing you that it has been generated. It is strongly advised to check the content of the script before running it against your database. Once the script has been run, you can reload your application again and you are all done.

Finally, if `settings.syncDb` is set to `true` and `settings.autoSyncDb` is set to `true`, the application will directly modify your database's schema during the application reload/startup process. We recommend this for local/dev environments only.


### Schema sync script generator extension

You may also wish to use our [DB Upgrade Script Generator](https://github.com/pixl8/preside-ext-dbupgradescriptgenerator) extension. This allows you to generate an upgrade script ahead of performing your upgrade. The extension provides an admin UI that allows you to enter the details of the target database before generating the script. 

This process should be run from either a local or testing server that is running the **exact preside version and application version** that your live server will be running **after the upgrade**. 

This reduces the time to perform your upgrade in your live environment, especially for sites with large databases. It can also be used to help test upgrades by being able to run the script against a recent backup of the live database, etc.
---
id: 10-12-upgrade-notes
title: Upgrade notes for 10.11 -> 10.12
---

## Version tables and drafts

The 10.12 release addressed an issue with unwanted `_version_is_latest_draft`, etc. columns on version tables for objects that were not using drafts:

[https://presidecms.atlassian.net/browse/PRESIDECMS-1894](https://presidecms.atlassian.net/browse/PRESIDECMS-1894)

Upgrading may therefore lead to a significant number of database changes that deprecate these columns. In addition, you may wish to check your code for any manual reference to these columns and make additional smoke screen tests around your custom code that uses them:

* `_version_is_draft`
* `_version_has_drafts`
* `_version_is_latest_draft`

## Preside session management

The 10.12 release added a Preside implementation of session management to replace native Lucee session management in your Preside applications:

* [https://presidecms.atlassian.net/browse/PRESIDECMS-1844](https://presidecms.atlassian.net/browse/PRESIDECMS-1844)
* [https://docs.preside.org/devguides/sessions.html#turning-on-presides-session-management](https://docs.preside.org/devguides/sessions.html#turning-on-presides-session-management)

Enabling this feature should work without any further modifications to your code. However, you should check for any direct references in your code to the `session` scope if you wish to use this feature. Direct session scope should be replaced with use of the session storage proxy: [https://docs.preside.org/devguides/sessions.html#using-the-session-storage-plugin](https://docs.preside.org/devguides/sessions.html#using-the-session-storage-plugin).

### Persisting validationResult across requests

Finally, due to serialization changes, you may experience issues with the ValidationResult object when persisting across requests if you use something other than `rc.validationResult` as an exact variable name. For example, you may have some custom validation logic that persists an array to `rc.validationResults` (note the _s_):

```luceescript
// ...

var validationResults = [];
var validated = true;

for( var i=1; i<something; i++ ) {
	var result = customValidationLogic( i );
	validationResults.append( result );
	validated = validated && result.validated();
}

if ( !validated ) {
	setNextEvent( url=pageUrl, persistStruct={ validationResults=validationResults } );
}

// ...
```

With the code above, `rc.validationResults` in the next request will not be serialized/deserialized correctly automatically for you. To fix this, in the resulting page (at `pageUrl`), you would need to do something along the lines of the following:

```luceescript
rc.validationResults = rc.validationResults ?: [];

// deserialize persisted validation results...
for( var i=1; i<=rc.validationResults.len(); i++ ) {
	var message  = rc.validationResults[ i ].generalMessage ?: "";
	var messages = StructCopy( rc.validationResults[ i ].messages ?: {} );
	var result   = validationEngine.newValidationResult();

	result.setGeneralMessage( message );
	result.setMessages( messages );

	rc.validationResults[ i ] = result;
}
```

>>> IF you use `persistStruct={ validationResult=validationResult }` with a validationResult object, this conversion will be taken care of for you. i.e. the auto-conversion will only happen when you use the _exact_ variable name `rc.validationResult`.
---
id: 10-13-upgrade-notes
title: Upgrade notes for 10.12 -> 10.13
---

The 10.13.0 release introduces a swathe of new features for users and developers. As always, we have made a conscious effort to reduce any the need for any breaking changes and we are very happy to report that there are no compatibility issues that we are aware of with this release.

The notes below are for finessing integration with the new Form builder data model for those that have custom item types.


## Form builder data model v2

The 10.13 release adds a new data model for form builder that offers a shared global library of questions and normalized data storage of answers. 

This feature must be enabled with `settings.features.formbuilder2.enabled=true` and will work out of the box once enabled.

However, if you have custom form builder item types, you may want to implement v2 features to ensure that they are stored optimally in the database and will work well with the new system. See:

* [renderV2ResponsesForDb()](devguides/formbuilder/itemtypes.html#renderv2responsesfordb)
* [getQuestionDataType()](devguides/formbuilder/itemtypes.html#getquestiondatatype)---
id: 10-17-upgrade-notes
title: Upgrade notes for 10.16 -> 10.17
---

## Summary

The 10.17.0 is a minor release with no backward-compatibility concerns for developers. Some changes that you may want to be aware of, however, are listed below.

## Database indexes

The 10.17 release adds database indexes to foreign key fields in version tables (these fields are full foreign keys in the main table but have their FK contstraints removed in the version table). If you have particularly large version tables, you may want to plan for the potentially slow addition of indexes to these existing version tables:

[PRESIDECMS-2233](https://presidecms.atlassian.net/browse/PRESIDECMS-2233) - Version tables: no indexes on columns that were FKs

## New admin menu system

[PRESIDECMS-2293](https://presidecms.atlassian.net/browse/PRESIDECMS-2293) - Admin main menu: create more portable configuration system

This ticket has been developed with backward-compatibility in mind, and you are not required to update any code. However, you may wish to acquaint yourself with the changes which are documented here:

[[adminmenuitems]]

---
id: 10-15-upgrade-notes
title: Upgrade notes for 10.14 -> 10.15
---

The 10.15.0 release is a maintenance release with 30 tickets covering minor development feature enhancements, performance improvements and minor bug fixes. 

There are no known compatibility issues or concerns with regards to upgrading from the previous stable version of Preside.---
id: 10-10-upgrade-notes
title: Upgrade notes for 10.9 -> 10.10
---

## Coldbox upgrade

The 10.10 release upgrades Coldbox from 4 to 5.2, so please the [Coldbox upgrade notes](https://coldbox.ortusbooks.com/intro/introduction/whats-new-with-5.0.0) for any issues that might affect your application. That said, we have not come across issues with the applications that we have upgraded so far.

## Taskmanager overhaul

The way in which the Preside task manager schedules tasks has been completely overhauled. It no longer relies on the Lucee task scheduler to repeatedly check for tasks to run. Instead, the platform spawns a long lived "heartbeat" background thread to check _every second_ for tasks to run.

The changes mean:

* You can schedule tasks to run as much as every second (previous limitation was 30s, but practically 1m)
* Thread dumps will be much more revealing. Instead of seeing lots of threads named cfthread-49 etc, you will see meaninfully named threads, including that task name that is running
* The scheduled task in Lucee will no longer be used - you could/should delete it with the Lucee administrator (or directly in Lucee's xml web context file)

## Email center logging

There has been a minor change to email center logging that requires a data migration. Your first reload of your application may therefor take some time, especially if you have a large number of records in your `psys_email_template_send_log` table.

## Multi threaded email sending

There has been a change to the way we queue and send mass emails in the email center. There is no longer a task in the Preside task manager and you are now able to configure how many background threads will be dedicated to sending out emails from the queue (the default is 1). To configure more threads, use the following in your Config.cfc file:

```luceescript
settings.email.queueConcurrency = 8; // or whatever
```
---
id: 10-25-upgrade-notes
title: Upgrade notes for 10.24 -> 10.25
---

## Summary

The 10.25.0 release introduces a few new features. While it has *no known compatibility issues or upgrade concerns*, please see below for areas to check in your application.

Please also check out the [release notes](https://www.preside.org/release-notes/release-notes-for-10-25-0.html) to understand the new features.


## Render formcontrol with extra HTML attributes

The core-supplied form control views have all been updated ([PRESIDECMS-2591](https://presidecms.atlassian.net/browse/PRESIDECMS-2591)) to allow the rendering of additional HTML attributes, so if you have overridden these views in your application you may want to apply the changes there too. In addition, you might like to add this functionality to your own custom form controls.

The general change is to define `htmlAttributes` and then insert the result in the HTML form control tag:

```lucee
<cfscript>
	htmlAttributes = renderHtmlAttributes(
		  attribs      = ( args.attribs      ?: {} )
		, attribNames  = ( args.attribNames  ?: "" )
		, attribValues = ( args.attribValues ?: "" )
		, attribPrefix = ( args.attribPrefix ?: "" )
	);
</cfscript>

<cfoutput>
	<!-- example control: -->
	<input type="text" ... #htmlAttributes#>
</cfoutput>
```---
id: 10-24-upgrade-notes
title: Upgrade notes for 10.23 -> 10.24
---

## Summary

The 10.24.0 release is another super focused release with *no known compatibility issues or upgrade concerns*. Do however check out the [release notes](https://www.preside.org/release-notes/release-notes-for-10-24-0.html) to understand the new features.
---
id: 10-26-upgrade-notes
title: Upgrade notes for 10.25 -> 10.26
---

## Summary

The 10.26.0 release introduces a a trio of enhancements, none of which require any technical changes on behalf of your application. However, the Email statistics feature warrants a note around data migration (see below).

If you haven't already, check out the release post and video describing the changes: [https://www.preside.org/resource/preside-10-26-released.html](https://www.preside.org/resource/preside-10-26-released.html).


## Data migration to enhanced email logging

There is an asynchonous data migration that will execute after upgrading to 10.26. This migration will loop through each email template in turn and generate the "summary tables" data from their raw logs. Should this process be interrupted by a redeployment or other application reload, it will pick up where it left off.

Email templates that have not yet completed migration, will continue to behave as they did before the change. Once migrated, you will see the new statistics views for the templates.

If your application has a LOT of email activity, you might expect this to take several hours (or more). The migration will log its progress to the console.

## Email bot detection

Email bot detection is disabled by default due to its experimental nature. You can enable it with:

```cfc
settings.features.emailTrackingBotDetection.enabled = true;
```

---
id: 10-19-upgrade-notes
title: Upgrade notes for 10.18 -> 10.19
---

## Summary

The 10.19.0 release is a maintenance release with 18 tickets covering minor development feature enhancements, performance improvements and minor bug fixes.

There are no known compatibility issues or concerns with regards to upgrading from the previous stable version of Preside.
---
id: 10-7-upgrade-notes
title: Upgrade notes for 10.6 -> 10.7
---

## General notes

The **10.7.0** release introduces a handful of new features that warrant some attention during upgrades. In particular:

* The introduction of [[drafts|drafts]]
* The introduction of the [[rulesengine|rules engine framework]]
* Integration of the **preside-ext-taskmanager** extension into core (see [[taskmanager]])

>>>>> Please ensure that you have read and understood the general [[preparing-for-an-upgrade]] notes that apply to any Preside upgrade.

&nbsp;
>>>>>> We recommend upgrading directly to **10.8.0** if possible as this is a more-or-less straight forward upgrade from 10.7.0 and brings a lot of improvements. If you do opt to upgrade directly to **10.8.0**, the notes below are still relevent and should be read thoroughly.



## Preparing for upgrade

### Drafts

The new draft system brought around some fundamental database schema changes with regards to _versioning_. These changes require a data upgrade script to run and this will run as part of the application reload. To prepare for upgrade:

* Check for large version database tables
* Test the upgrade on a non-live version of the application that is using a restored backup of live data

#### Large version tables

**Important**: If you have version tables with a large number of rows, you should consider cleaning that data up and ensuring that your application is only making version changes when necessary **before running the Preside upgrade**. You can see database table sizes in MySQL with:

```sql
select   table_name
       , round( ( ( data_length + index_length ) / 1024 / 1024 ), 2 ) size_in_mb
from     information_schema.tables 
where    table_schema = '$db_name' -- your db name here
order by size_in_mb desc
```

If you find some surprisingly large version tables, you can use the following SQL to quickly debug problems with versioning changes to fields that we shouldn't care about for versioning (e.g. 'last logged in' date):

```sql
select    count(*) as _record_count
        , _version_changed_fields
from      _version_pobj_my_table 
group by  _version_changed_fields
order by  _record_count desc;
```

If you find large numbers of version changes for fields that should not count as a new version record, you can add the `ignoreChangesForVersioning=true` attribute to the property, e.g.

```luceescript
component {
    // ...
	property name="last_logged_in" type="date" dbtype="datetime" ignoreChangesForVersioning=true;
	// ...
}
```

If your tables are _very_ large, you will need to plan your approach to deleting records that you no longer wish to keep (i.e. either old records or records that are recording redundant changes). 

**DO NOT SIMPLY TRUNCATE A VERSION TABLE THAT IS IN USE**. Each record requires at least one corresponding version record as of 10.7.0.

If you find that you have version tables for objects that do not require versioning, you can simply add the `@versioned false` annotation to your Preside Object CFC. Once the application has been deployed and reloaded, you should be able to drop the redundant version table(s). e.g.

```luceescript
// /application/preside-objects/some_log_object.cfc
/**
 * @versioned false
 *
 */
component {
	// ...
}
```


### Task manager

If you have the `preside-ext-taskmanager` extension installed, you will need to **remove it** before upgrading to 10.7.0 and above. 

Firstly, remove its entry in `/application/extensions/extensions.json`. Then remove the `/application/extensions/preside-ext-taskmanager` folder from your application entirely; how you do that will depend on how you have installed the extension. If you have installed as a git submodule:

```
git submodule deinit application/extensions/preside-ext-taskmanager
git rm application/extensions/preside-ext-taskmanager
```

If you have installed as a commandbox dependency using `box.json`, simply remove any references to it from that file.

### Rules engine

The new rules engine system in 10.7.0 allows you to restrict content based on rules about the currently logged in user. In 10.8.0, this feature is moved forward considerably and we recommend not using the feature in 10.7.0 unless you / your client are well prepared to use it.

The feature is turned off by default in 10.7.0 (turned on in 10.8.0) and you can ensure that it is turned off with the following in `Config.cfc`:

```
settings.features.rulesEngine.enabled = false;
```

If you _do_ opt to turn it on, familiarize yourself with the changes it brings in your testing environments and your system users for the changes.---
id: 10-14-upgrade-notes
title: Upgrade notes for 10.13 -> 10.14
---

The 10.14.0 release is focused around performance and admin security. A change to how we implement `renderView()`, _may_ cause unexpected bugs with variables not found. In addition, the `request.http.body` variable is no longer set on every request. See details below.

## renderView() changes

We have early adopted changes from Coldbox 6 `renderView()` that means that view renders are better encapsulated. What this means is that local variables set in a view, are only available to that view and do not "escape".

You may have in your code some accidental misuse of a previous behaviour that was undesirable. In this case, you may receive "variable not found" errors. The below code samples illustrate the problem:


```lucee
// /views/view_a.cfm
<cfscript>
   unscopedVariable = "Exists";
</cfscript>

<cfoutput>#renderView( "view_b" )#</cfoutput>
```

```lucee
// /views/view_b.cfm
<cfoutput>#( unscopedVariable ?: "Should not exist" )#</cfoutput>
```

In Preside 10.13 and below, the output would be "Exists". In 10.14, the output will be "Should not exist".

## request.http.body changes

Preside used to set `request.http.body` on every request. This variable was used in the request context method: `event.getHttpContent()`. The variable is no longer set (see [PRESIDECMS-2017](https://presidecms.atlassian.net/browse/PRESIDECMS-2017)). Any custom code that is attempting to use `request.http.body` directly should be refactored to use `event.getHttpContent()`.
---
id: upgradenotes
title: Upgrade/Release notes
---

The Preside team use [Semantic Versioning](https://semver.org/) for their release versions. Our version numbers look like this: `MAJOR.MINOR.PATCH`. Where:

* **MAJOR** means a version when we make incompatible API changes
* **MINOR** means a version when we add functionality in a backward compatible manner
* **PATCH** means a version when we make backward compatible bug fixes

It is worth noting, that we have NEVER made a MAJOR release. Backward compatibility is very important to us. If and when we DO create a new release, it will be for really good reasons and we'll STILL be considering compatibility with the utmost effort.

We release **minor** versions with relative frequency, currently around 8 releases a year. You will find upgrade notes between minor versions in this chapter.

We release **patch** versions very frequently - once we have validated bugfixes, we don't tend to hang around to release them. Release notes for every minor and patch release can be found on the Preside website: [https://www.preside.org/developers/release-notes.html](https://www.preside.org/developers/release-notes.html)

## General upgrade guides

* [[preparing-for-an-upgrade]]

## Individual upgrade guides

Note: If you are updating over multiple major versions, e.g. from `10.6.x` to `10.8.x`, you should read the upgrade notes for each release in between.

* [[10-26-upgrade-notes]]
* [[10-25-upgrade-notes]]
* [[10-24-upgrade-notes]]
* [[10-23-upgrade-notes]]
* [[10-22-upgrade-notes]]
* [[10-21-upgrade-notes]]
* [[10-20-upgrade-notes]]
* [[10-19-upgrade-notes]]
* [[10-18-upgrade-notes]]
* [[10-17-upgrade-notes]]
* [[10-16-upgrade-notes]]
* [[10-15-upgrade-notes]]
* [[10-14-upgrade-notes]]
* [[10-13-upgrade-notes]]
* [[10-12-upgrade-notes]]
* [[10-11-upgrade-notes]]
* [[10-10-upgrade-notes]]
* [[10-9-upgrade-notes]]
* [[10-8-upgrade-notes]]
* [[10-7-upgrade-notes]]
---
id: 10-22-upgrade-notes
title: Upgrade notes for 10.21 -> 10.22
---

## Summary

The 10.22.0 release is another super focused release with just five tickets. There are no upgrade concerns (but do checkout the [release notes](https://www.preside.org/release-notes/release-notes-for-10-22-0.html) to understand the new features).
---
id: 10-23-upgrade-notes
title: Upgrade notes for 10.22 -> 10.23
---

## Summary

The 10.23.0 release is another super focused release with *no known compatibility issues or upgrade concerns*. Do however check out the [release notes](https://www.preside.org/release-notes/release-notes-for-10-23-0.html) to understand the new features.
---
id: 10-8-upgrade-notes
title: Upgrade notes for 10.7 -> 10.8
---

## General notes

The 10.8 release has a small number of changes that require special consideration for upgrade:

* Email centre - creating layouts, migrating SMTP settings and custom system email templates
* Rules engine filters - ensuring auto generated filters make sense
* Task manager exclusivity groups - checking your setup

>>>>> Please ensure that you have read and understood the general [[preparing-for-an-upgrade]] notes that apply to any Preside upgrade.

## Email Centre

### SMTP settings

The one **critical** upgrade note for the 10.8 release is that your old SMTP settings for sending email will need to be manually migrated through the new email centre UI.

After upgrade, navigate to **Email Centre > Settings > SMTP (tab)**. Any previous SMTP server settings should be entered here and saved before email sending will work again.

>>>>>> You may also wish to consider our [Mailgun](https://github.com/pixl8/preside-ext-mailgun) extension for better stats reporting + email sending.

### Create a layout / multiple layouts

If your existing application has programmed an email layout, you should migrate it using the new layouts system, see [[creatingAnEmailLayout]]. This will allow end users to use and configure the layout for custom emails as well as prepare you for migrating your custom system email templates to the new system.

### Migrate system email templates

The [[emailtemplating|legacy email template system]] will continue to work. However, we would advise migrating any templates you have to the new system to make the end-user experience as good as it can be (and avoid future maintenance headaches).

See [[systemEmailTemplates]] for a full guide to creating system email templates in 10.8.0.

## Rules engine filters

The rules engine in general is now **enabled by default** and with that comes the rules engine filter system with auto-generated expressions (you'll notice this in datamanager grids, for example).

### Tidy up

You may wish to go through each of your data table grids and check the filter expressions that are generated for your objects. This may point out gaps in your `i18n` entries for object properties, or reveal some auto generated filters for fields that don't make sense as filters.

To stop an object property from automatically having filter expressions generated, use the `autoFilter` attribute:

```
property name="color" type="string" ... autoFilter=false;
```

### Existing custom expressions

If you are upgrading from 10.7.0 and have existing custom expressions, you may wish to re-evaluate them and **remove them** if there is now an auto generated expression that does the same job (be sure to find out where your expressions are being used and be prepared to fix those saved conditions that are already using them).

## Task manager exclusivity groups

There is now an `@exclusivityGroup` annotation for task manager tasks (see [[taskmanager]]) and its value defaults to the value of the `@displayGroup` of your task.

This means that, by default, after you upgrade to 10.8.0, your exclusivity groups for auto running tasks will match the tabs that you see when you go to the **Task manager** UI in the admin.

What this means is that **no two tasks** in the same exclusivity group will run at the same time when running on a schedule. Before 10.8.0, **no two tasks AT ALL** would run at the same time.

You should check your tasks and ensure that any tasks that should not be run while other specific tasks are running are set to be in the same exclusivity group.
---
title: Build
id: docs-build
---

## Prerequisites

The only dependency required is [CommandBox](https://www.ortussolutions.com/products/commandbox). Ensure that commandbox is installed and that the `box` command is in your path.

## Building the static documentation output

The purpose of the structure of the documentation is to allow a human readable and editable form of documentation that can be built into multiple output formats. At present, there is a single "HTML" builder, found at `./builders/html` that will build the documentation website.

To run the build and produce a static HTML version of the documentation website, execute the `build.sh` file found in the root of the project, i.e.

	documentation>./build.sh

Once this has finished, you should find a `./builds/html` directory with the website content.

## Running a server locally

We have provided a utility server whose purpose is to run locally to help while developing/writing the documentation. To start it up, execute the `serve.sh` file found in the root of the project, i.e.

    documentation>./serve.sh

This will spin up a server using CommandBox on port 4040 and open it in your browser. You should also see a tray icon that will allow you to stop the server. Changes to the source docs should trigger an internal rebuild of the documentation tree which may take a little longer than regular requests to the documentation.---
title: Documentation structure
id: docs-structure
---

All of the source files for this documentation can be found in the `/docs` folder of the public repository; i.e. [https://github.com/pixl8/Preside-CMS/tree/stable/support/docs/docs](https://github.com/pixl8/Preside-CMS/tree/stable/support/docs/docs).

The content is organised by a very simple system of folders and markdown files.

## Folders

Folders containing a single markdown file represent a page of documentation. Subfolders are used to place pages beneath other pages to form a documentation tree. 

Special folder naming rules:

* Folders whose name begin with a number followed by a period are treated as pages that will appear in main navigation - the number indicating the relative order in which the page should appear

* Folders and markdown files whose names begin with an underscore, `_`, are ignored by the tree system and may be used by particular page types to provide more structured content

## Page types

Page types are indicated by the **name** of the markdown file within the page's folder. 

For example, if we are creating a function reference page, you would expect the following folder and file structure:

```
/nameoffunction
    function.md
```

The various build systems can use the page types to format the output in different ways.


## Page IDs

Page IDs are used for cross referencing and are specified in the page's markdown file using YAML front matter. e.g.

```html
---
id: function-abs
title: Abs()
---
```

>>>>>> The name of the folder, without any preceding order number, will be used when an ID is not supplied in the markdown file's YAML front matter.
See [[docs-markdown]] for a full guide to cross referencing and YAML front matter. ---
title: Preside-flavoured Markdown
id: docs-markdown
---

The base markdown engine used is [pegdown](https://github.com/sirthias/pegdown). Please see both the [official markdown website](http://daringfireball.net/projects/markdown/) and the the [pegdown repository](https://github.com/sirthias/pegdown) for the supported syntax.

On top of this base layer, the Preside Documentation system processes its own special syntaxes for syntax highlighting, cross referencing and notice boxes. It also processes YAML front matter to glean extra metadata about pages.

## Syntax highlighting

Syntax highlighted code blocks start and end with three backticks on their own line with an optional lexer after the first set of ticks.

For example, a code block using a 'luceescript' lexer, would look like this:

<pre>
```luceescript
x = y;
WriteOutput( x );
```
</pre>

A code block without syntax higlighting would look like this:

<pre>
```
x = y;
WriteOutput( x );
```
</pre>

>>> We have implemented two lexers for Lucee, `lucee` and `luceescript`. The former is used for tag based code, the latter, script based. For a complete list of available lexers, see the [Pygments website](http://pygments.org/docs/lexers/).

## Cross referencing

Cross referencing between pages can be achieved using a double square bracket syntax surrounding the id of the page you wish to link to. For example:

```html
[[function-abs]]
```

When the link is rendered, the title of the page will be passed to the renderer. To provide a custom text for the link, use the following syntax:

```html
[[function-abs|Custom link text]]
```

## Notice boxes

Various "notice boxes" can be rendered by using a nested blockquote syntax. The nesting level dictates the type of notice rendered.

### Info boxes

Info boxes use three levels of blockquote indentation:

```html
>>> An example info box
```

>>> An example info box

### Warning boxes

Warning boxes use four levels of blockquote indentation:

```html
>>>> An example warning box
```

>>>> An example warning box

### Important boxes

Important boxes use five levels of blockquote indentation:

```html
>>>>> An example 'important' box
```

>>>>> An example 'important' box

### Tip boxes

Tip boxes use six levels of blockquote indentation:

```html
>>>>>> An example tip box
```

>>>>>> An example tip box

## YAML Front Matter

YAML Front Matter is used to add metadata to pages that can then be used by the build system. The syntax takes the form of three dashes `---` at the very beginning of a markdown document, followed by a YAML block, followed by three dashes on their own line. For example:

```html
---
variableName: value
arrayVariable:
    - arrayValue 1
    - arrayValue 2
---
```

### Standard metadata

The system relies upon an **id** variable and **title** variable to be present in all pages in order to build its tree and perform cross referencing tasks. It will also allow you to tag pages with categories and 'related' links.

A full example might look like:

```html
---
id: function-abs
title: Abs()
related:
    - "[Problem with Abs()](http://someblog.com/somearticle.html)"
categories:
    - number
    - math
```

Category links will be rendered as ```[[category-categoryname]]```. Related links will be rendered using the markdown renderer so can use any valid link format, including our custom cross referencing syntax (see above, and note the required double quotes to escape the special characters).

---
title: Content
id: docs-content
---

The content of the Preside documentation is our number one priority. This chapter deals with how the documentation content is organised and written and should provide a thorough reference for anyone wishing to contribute to the content of the docs.

## Overview

The documentation system is largely based on the [Grav](http://getgrav.org) static CMS. This system uses folders to represent pages, and markdown files within those folders to provide the page content.

All of the source files for this documentation can be found in the `/docs` folder of the public repository; i.e. [https://github.com/pixl8/Preside-Documentation/tree/master/docs](https://github.com/pixl8/Preside-Documentation/tree/master/docs)

For more information on how the folder structure and various page types work, see [[docs-structure]].

## Markdown

The system uses markdown files to provide the bulk of the documentation.

In addition to plain markdown, we are also using the popular [YAML front matter](https://duckduckgo.com/?q=YAML+front+matter) format to provide additional meta data for our pages (such as category tagging) and [Python Pygments](http://pygments.org/) to provide syntax highlighting.

For more information on our "Preside-flavoured" Markdown, see [[docs-markdown]].

## Reference pages

Documentation pages that provide pure reference material (i.e. internal Preside reference material) are 100% auto-generated and non-editable.
---
title: About the docs
id: about
---

## Mission statement

Good documentation is at the heart of all successful open source projects. With this platform, we aim to:

* Provide a platform that is easy to contribute to and maintain
* Provide documentation that is a joy to read and navigate
* Provide a system that can build the same documentation source to multiple output formats
* Provide stewardship such that the documentation is well kept and ever-growing

## Contributing

You'll find information on ways in which you can contribute in the [[docs-content]] and [[docs-build]] sections. The quickest and easiest way to get started is fixing mistakes and omissions by finding the **pencil** icon in pages and editing directly in GitHub then submitting a Pull Request (the GitHub UI takes care of most of this for you).

## Technology

### Lucee

The documentation build is achieved using Lucee code. The only dependency required to build and locally run the documentation is [CommandBox](https://www.ortussolutions.com/products/commandbox).

### Markdown

We chose to use [Markdown](http://daringfireball.net/projects/markdown/) with a few common and custom enhancements.

We also based the system on a popular open source static CMS system called [Grav](http://getgrav.org). This gives us a proven foundation to build the source from and should help make contributing as easy as it can be.

For more information on how the documentation is formatted, see the [[docs-content]] section.
---
id: reference
title: Reference docs
---

In this section, you will find auto generated documentation providing reference material for system services, preside objects and forms.

* [[systemservices]]
* [[systempresideobjects]]
* [[systemforms]]
* [[systemformcontrols]]
---
id: formcontrol-textInput
title: "Form control: Text Input"
---

The `textInput` control presents the user with a standard HTML input with `type="text"`.

### Arguments

<div class="table-responsive">
    <table class="table">
        <tbody>
            <tr>
                <th>placeholder (optional)</th>
                <td>Placeholder text to appear in the input when there is no content. Can be an i18n resource URI</td>
            </tr>
        </tbody>
    </table>
</div>

### Example

```xml
<field name="title" control="textinput" placeholder="my.resource:property.title" />
```
---
id: formcontrol-objectPicker
title: "Form control: Object Picker"
---
The `objectPicker` control allows users to select one or multiple records from a given preside object. Configuration options also allow you to add new records and edit existing records from within the form control.

### Set object picker default sort order

To specify object default sort order for object picker, use the `@objectPickerDefaultSortOrder` annotation. For example:

```luceescript
// /application/preside-objects/author.cfc

/**
 * @objectPickerDefaultSortOrder    post_count desc
 */
component {
    property name="name" type="string" dbtype="varchar" maxlength="200" required=true uniqueindexes="name";
    property name="posts" relationship="one-to-many" relatedto="blog_post" relationshipkey="blog_author";
    property name="post_count" type="numeric" formula="Count( ${prefix}posts.id )";
}
```

### Arguments
<div class="table-responsive">
    <table class="table">
        <tbody>
            <tr>
                <th>object (required)</th>
                <td>Name of the object whose records the user can select</td>
            </tr>
            <tr>
                <th>ajax (optional)</th>
                <td>True (default) or false. Whether or not to fetch records for the picker using Ajax.</td>
            </tr>
            <tr>
                <th>objectFilters (optional)</th>
                <td>String list of saved preside object filters. See [[dataobjects]]</td>
            </tr>
            <tr>
                <th>prefetchUrl (optional)</th>
                <td>When ajax is set to "true", you can additionally supply a specific URL for fetching records to pre-populate the drop down</td>
            </tr>
            <tr>
                <th>remoteUrl (optional)</th>
                <td>When ajax is set to "true", you can additionally supply a specific URL for fetching records to match typed searches</td>
            </tr>
            <tr>
                <th>useCache (optional)</th>
                <td>True (default) or false. Whether to use caching when selecting data for this form field and its respective ajax lookup and prefetch.</td>
            </tr>
            <tr>
                <th>orderBy (optional)</th>
                <td>Specify which column(s) to sort the select list on. Default is "label", which sorts alphabetically on the text displayed in the picker.</td>
            </tr>
            <tr>
                <th>placeholder (optional)</th>
                <td>Message to appear prompting the user to search for records</td>
            </tr>
            <tr>
                <th>multiple (optional)</th>
                <td>True of false (default). Whether or not to allow multiple record selection</td>
            </tr>
            <tr>
                <th>sortable (optional)</th>
                <td>True or false (default). Whether or not to allow multiple selected records to be sortable within the control.</td>
            </tr>
            <tr>
                <th>searchable (optional)</th>
                <td>True (default) or false. Whether or not the search feature of the control is enabled.</td>
            </tr>
            <tr>
                <th>resultTemplate (optional)</th>
                <td>A Mustache template for rendering items in the drop down list. The default is "{{text}}". This can be used in conjunction with a custom remote URL for providing a highly customized object picker.</td>
            </tr>
            <tr>
                <th>selectedTemplate (optional)</th>
                <td>A Mustache template for rendering selected items in the control. The default is "{{text}}". This can be used in conjunction with a custom remote URL for providing a highly customized object picker.</td>
            </tr>
            <tr>
                <th>quickAdd (optional)</th>
                <td>True of false (default). Whether or not the quick add record feature is enabled. If enabled, you should create a /forms/preside-objects/(objectname)/admin.quickadd.xml form that will be used in the quick add dialog.</td>
            </tr>
            <tr>
                <th>quickAddUrl (optional)</th>
                <td>If quickAdd is enabled, you can additionally set a custom URL for providing the quick add form.</td>
            </tr>
            <tr>
                <th>superQuickAdd (optional, 10.10.38 and above)</th>
                <td>True of false (default). Whether or not the <em>super</em> quick add record feature is enabled. The super quick add feature allows you to add records inline when the search text
                entered does not exactly match any existing records. <strong>Note: the target object must be enabled for data manager.</strong></td>
            </tr>
            <tr>
                <th>superQuickAddUrl (optional, 10.10.38 and above)</th>
                <td>If superQuickAdd is enabled, you can additionally set a custom URL for processing the super quick add request. The URL will receive a POST request with a <code>value</code> field and should return a json object with <code>text</code> (<em>label</em>) and <code>value</code> (<em>id</em>) fields.</td>
            </tr>
            <tr>
                <th>quickEdit (optional)</th>
                <td>True of false (default). Whether or not the quick edit record feature is enabled. If enabled, you should create a /forms/preside-objects/(objectname)/admin.quickadd.xml form that will be used in the quick edit dialog.</td>
            </tr>
            <tr>
                <th>quickEditUrl (optional)</th>
                <td>If quickEdit is enabled, you can additionally set a custom URL for providing the quick edit form.</td>
            </tr>
            <tr>
                <th>bypassTenants (optional)</th>
                <td>A comma separated list of tenants to <strong>ignore</strong> when populating the dropdown. See [[data-tenancy]].</td>
            </tr>
            <tr>
                <th>filterBy (optional)</th>
                <td>An optional comma separated list of fields to filter the selectable data on. These fields can be present in either the form, URL parameters, or in any data set using event.includeData().</td>
            </tr>
            <tr>
                <th>filterByField (optional)</th>
                <td>An optional comma separated list of database field names to correspond with the fields defined in the filterBy attribute. Only necessary when the database fieldnames differ from the field names used to get the values for the filter.</td>
            </tr>
            <tr>
                <th>disabledIfUnfiltered (optional)</th>
                <td>true or false and only to be used in conjunction with the filterBy attribute. If true and the filterBy field(s) are empty, the control will be disabled until the field(s) have value.</td>
            </tr>
        </tbody>
    </table>
</div>

### Example
```xml
<field name="categories" control="objectPicker" object="blog_category" multiple="true" sortable="true" quickAdd="true" quickEdit="true" />
```
### Example with caching disabled
```xml
<field name="categories" useCache="false" control="objectPicker" object="blog_category" multiple="true" sortable="true" quickAdd="true" quickEdit="true" />
```
![Screenshot of object picker](images/screenshots/objectPicker.png)
---
id: formcontrol-password
title: "Form control: Password"
---

The `password` control is a variation on the [[formcontrol-textinput|text input control]] that uses `type="password"` on the `<input>` element. It also provides some configurable functionality around providing feedback and validation against password policies


### Arguments

See arguments that can be passed to the [[formcontrol-textinput|text input control]]. In addition:

<div class="table-responsive">
    <table class="table">
        <tbody>
            <tr>
                <th>passwordPolicyContext (optional)</th>
                <td>Either 'admin', or 'website'. If set, a password strength validator and indicator will be provided to match either the website or admin password policy set in the Preside administrator.</td>
            </tr>
            <tr>
                <th>outputSavedValue (optional)</th>
                <td>True of false (default). Whether or not to insecurely output the saved password in the form field when editing a saved record.</td>
            </tr>
        </tbody>
    </table>
</div>

### Example

```xml
<field name="password" control="password" required="true" passwordPolicyContext="website" />
```---
id: formcontrol-assetFolderPicker
title: "Form control: Asset folder picker"
---

The `assetFolderPicker` control is a specially formatted [[formcontrol-objectPicker| object picker]] especially for picking folder records from the asset manager.

### Arguments

You can use any arguments that can be used with the [[object picker]]. It expects no special arguments of its own.

### Example

```xml
<field name="folders" control="assetFolderPicker" multiple="true" sortable="true" />
```

![Screenshot of a folder picker](images/screenshots/assetFolderPicker.png)
---
id: formcontrol-radio
title: "Form control: Radio"
---

The `radio` control allows the single choice selection from a pre-defined set of options.

### Arguments

<div class="table-responsive">
    <table class="table">
        <tbody>
            <tr>
                <th>values (required)</th>
                <td>Either a comma separated list or array of values for the radio options</td>
            </tr>
            <tr>
                <th>labels (optional)</th>
                <td>Either a comma separated list or array of labels that correspond with the values for each radio button (must be same length as the values list/array). If not supplied, the values will be used for the labels</td>
            </tr>
        </tbody>
    </table>
</div>

### Example

```xml
<field name="number" control="radio" values="1,2,3" labels="One,Two,Three"/>
```
---
id: formcontrol-manyToManySelect
title: "Form control: Many to many select"
---

The `manyToManySelect` control is a special wrapper to the standard [[formcontrol-objectPicker|object picker control]], used by the system when creating setting automatically mapped form controls from preside object properties with `many-to-many` relationships.

If in doubt, use the [[formcontrol-objectPicker|object picker control]] when manually setting form controls in your form.
---
id: formcontrol-readonly
title: "Form control: Read only"
---

The `readonly` form control will output any saved data without rendering any form controls. This can be useful for edit forms where you would like to show the content of a field that cannot be edited.

If the object property being rendered is a `date` or `datetime`, the control will automatically use the appropriate core renderer to display the data. Alternatively, you can specify a custom renderer to use.

### Arguments

<div class="table-responsive">
    <table class="table">
        <tbody>
            <tr>
                <th>renderer (optional)</th>
                <td>The name of the content renderer to use to format the data on screen.</td>
            </tr>
            <tr>
                <th>rendererContext (optional)</th>
                <td>The renderer context to use to render the data - for example, in admin screens you may wish to use the `admin` context. Default is "readonly" (which will fall back to "default" if the readonly contet is not defined).</td>
            </tr>
        </tbody>
    </table>
</div>

### Example

```xml
<field binding="my_protected_object.title"               control="readonly"   />
<field binding="my_protected_object.date"                control="readonly"   renderer="custom_date_renderer" rendererContext="admin" />
<field binding="my_protected_object.website_description" control="richeditor" />
```
---
id: formcontrol-imagedimensions
title: "Form control: Image Dimensions"
---

The `imageDimensions` form control provides a neat interface for inputting dimensions. The value it provides, and expects as input, takes the form "(width)x(height)", e.g. `1920x1080`.

### Arguments

The control does not accept any arguments.

### Example

```xml
<field name="dimensions" control="imageDimensions" required="true" />
```

![Screenshot of image dimensions control](images/screenshots/dimensionsPicker.png)
---
id: formcontrol-conditionpicker
title: "Form control: Condition picker"
---

The `conditionPicker` control is an [[formcontrol-objectPicker| object picker]] with custom options and interface specific to rules engine conditions.

### Arguments

You can use any arguments that can be used with the [[object picker]]. In addition, the control accepts a single option, `ruleContext` indicating the [[rulesenginecontexts|rules engine context]] with which to filter the available conditions (see [[rulesengine]] for more details on condition contexts). The default `ruleContext` is `webrequest`.


### Example

```xml
<field name="access_condition" control="conditionPicker" ruleContext="user" />
```---
id: formcontrol-emailInput
title: "Form control: Email Input"
---

The `emailInput` control is a variation on the [[formcontrol-textinput|text input control]] that uses `type="email"` on the `<input>` element. 


### Arguments

See arguments that can be passed to the [[formcontrol-textinput|text input control]].

### Example

```xml
<field name="emailAddress" control="emailInput" required="true" />
```---
id: formcontrol-fileTypePicker
title: "Form control: File Type Picker"
---

The `fileTypePicker` control allows users to select from a list of file types that have been configured for the asset manager (see [[assetmanager]]). It is an extension of the [[formcontrol-select|select control]].

### Arguments

The control accepts no custom arguments, though all arguments that can be passed to [[formcontrol-select|select control]] can be used.

### Example

```xml
<field name="filetypes" control="fileTypePicker" multiple="true" sortable="true" />
```

![Screenshot of filetype picker](images/screenshots/fileTypePicker.png)---
id: formcontrol-textarea
title: "Form control: Text area"
---

The `textarea` control presents the user with a standard HTML text area.

### Arguments

<div class="table-responsive">
    <table class="table">
        <tbody>
            <tr>
                <th>placeholder (optional)</th>
                <td>Placeholder text to appear in the textarea when there is no content. Can be an i18n resource URI</td>
            </tr>
            <tr>
                <th>maxLength (optional)</th>
                <td>Character count limit. If set, the control will show a character counter that changes as you type.</td>
            </tr>
        </tbody>
    </table>
</div>

### Example

```xml
<field name="description" control="textarea" placeholder="e.g. Lorem ipsum" maxlength="200" />
```---
id: formcontrol-parentPagePicker
title: "Form control: Site tree page picker"
---

The `parentPagePicker` is a utility form control that is an extension of the [[formcontrol-siteTreePagePicker|site tree page picker control]].

In addition to the regular site tree page picker, this control will set the `childPage` option for you based on the value of `rc.id`. i.e. use this form control in an "edit page" screen where the page ID is in the url so that users can only pick valid parent pages for the current page.

### Arguments

See [[formcontrol-siteTreePagePicker]].

### Example

```xml
<field name="parent_page" control="parentPagePicker" />
```---
id: formcontrol-oneToManyConfigurator
title: "Form control: One-to-many configurator"
---

The `oneToManyConfigurator` control is rather like a hybrid of the [[formcontrol-oneToManySelect|One-to-many Select]] and the [[formcontrol-manyToManySelect|Many-to-many Select]] form controls. It allows you to link objects as with a many-to-many join, but also to add extra extra information that further defines each specific join.

These two scenarios will give you an idea of where you would use a one-to-many configurator:

#### Scenario 1

You are running an event management system. You have an `event_ticket` object and an `event_session_category` object. A ticket will give you a defined quota of sessions from different categories. So, you effectively want a many-to-many join between the two objects, while also recording how many sessions from the linked category are allowed by that particular ticket.

#### Scenario 2

You have a library of image assets, which you want to link to an article object. But when you link an image, you want to specify whether it is the master image for that particular article, and maybe also override the image's default title and caption.


### Arguments

<div class="table-responsive">
    <table class="table">
        <tbody>
            <tr>
                <th>formName (required)</th>
                <td>
                    The name of the form to be used to configure the object. Can also be defined as an annotation on the configurator object, in which case it may be omitted.
                </td>
            </tr>
            <tr>
                <th>labelRenderer (required)</th>
                <td>
                    The label renderer to be used to generate the label text to display in the form control. Can also be defined as an annotation on the configurator object, in which case it may be omitted.
                </td>
            </tr>
            <tr>
                <th>fields (optional)</th>
                <td>
                    A comma-separated list of fields on the main form which should have their values passed through to the configurator form.
                </td>
            </tr>
            <tr>
                <th>targetFields (optional)</th>
                <td>
                    A comma-separated list of fields on the configurator form that the fields defined above should be mapped to. If omitted, the fields names will be the same on both forms.
                </td>
            </tr>
            <tr>
                <th>multiple (optional)</th>
                <td>True of false (default). Whether or not to allow multiple record selection</td>
            </tr>
            <tr>
                <th>sortable (optional)</th>
                <td>True or false (default). Whether or not to allow multiple selected records to be sortable within the control. Note that you will explicitly need to define a <code>sort_order</code> property on your configurator object.</td>
            </tr>
        </tbody>
    </table>
</div>

### Example

First, let's set up our configurator Preside object:

```luceescript
// /preside-objects/event_ticket_session_category.cfc

/**
 * @nolabel
 * @oneToManyConfigurator
 * @labelRenderer           event_ticket_session_category
 * @configuratorFormName    preside-objects.event_ticket_session_category.configurator
 */
component  {
	property name="event_ticket"           relationship="many-to-one" relatedTo="event_ticket"           required=true;
	property name="event_session_category" relationship="many-to-one" relatedTo="event_session_category" required=true;

	property name="allowance"  type="numeric" dbtype="int";
	property name="sort_order" type="numeric" dbtype="int";
}
```
A few things to note here:

- Both objects to be linked are set as having many-to-one relationships.
- We have specified `@nolabel` as the label for this object will be generated by the label renderer
- The configurator object must have the `@oneToManyConfigurator` annotation
- `@labelRenderer` defines the label renderer to be used to build the labels
- `@configuratorFormName` is the form definition to be used by the form control to create the link

The relationship to this object is defined on the `event_ticket` object, just like a normal one-to-many relationship:

```luceescript
// /preside-objects/event_ticket.cfc
...
property name="session_categories" relationship="one-to-many" relatedTo="event_ticket_session_category" relationshipKey="event_ticket";
...
```

We then set up the field in the `event_ticket` form definitions. Note that we have omitted `formName` and `labelRenderer` attributes, as they are defined on the configurator object. Also, `control="oneToManyConfigurator"` is not strictly necessary, but it makes it easier to remember that the configurator form control will be used.

By specifying `fields="eventId"`, we are saying we want the `eventId` value from this form to be passed through into `eventId` on the configurator form. This will often not be needed.

```xml
<!-- /forms/preside-objects/event_ticket/admin.edit.xml -->
<!-- /forms/preside-objects/event_ticket/admin.add.xml -->
<!-- ... -->
<field binding="event_ticket.session_categories" sortorder="30" control="oneToManyConfigurator" fields="eventId" />
```

![Screenshot of the empty configurator form control](images/screenshots/configurator1.png)

Now we define the configurator form:

```xml
<!-- /forms/preside-objects/event_ticket_session_category/configurator.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<form>
	<tab id="default" >
		<fieldset>
			<field binding="event_ticket_session_category.event_session_category" sortorder="10" required="true" filterBy="eventId" filterByField="event_id" />
			<field binding="event_ticket_session_category.allowance"              sortorder="20" />

			<field binding="event_ticket_session_category.event_ticket"           sortorder="30" control="hidden" />
			<field name="eventId"                                                 sortorder="40" control="hidden" />
		</fieldset>
	</tab>
</form>
```

This form will be loaded by Ajax, and will display two fields: an object picker to let you choose the session category, and a field for the category allowance.

Note the two hidden fields. The `event_ticket` field is automatically populated with the `id` of the ticket record from which we came. __You will always need to include this field.__ The `eventId` field accepts the value we passed through from the calling form, and can then be used by the `event_session_category` object picker to filter the choices displayed.

![Screenshot of the configurator form](images/screenshots/configurator2.png)

Finally, we need to tell our configurator how to construct labels for the selected options. In this case, we want the name of the selected category, followed by the allowance specified (or "unlimited" if it is left blank).

To do this, we will use Preside's new label renderers.

```luceescript
// /handlers/renderers/labels/event_ticket_session_category.cfc

component {

	private array function _selectFields( event, rc, prc ) {
		return [
			  "allowance"
			, "event_session_category"
			, "event_session_category.label as __event_session_category_label"
		];
	}

	private string function _renderLabel( event, rc, prc ) {
		var allowance            = arguments.allowance                      ?: "";
		var sessionCategoryId    = arguments.event_session_category         ?: "";
		var sessionCategoryLabel = arguments.__event_session_category_label ?: renderLabel( "event_session_category", sessionCategoryId );
		var label                = "#sessionCategoryLabel#: ";

		if ( len( allowance ) ) {
			label &= allowance;
		} else {
			label &= "unlimited";
		}

		return label;
	}

}
```

This is covered in more detail in the [[labelrenderers|label renderers]] guide.

The `_selectFields()` method defines the fields required in order to render the label server-side (i.e. when a saved record is being displayed), and the `_renderLabel()` method takes thos fields and actually builds the label.

However, it now works slightly differently when using a one-to-many configurator. All the data from the configurator form is passed into `_renderLabel()` in the `arguments` scope. But the form only knows about the `id` of the selected session category, and not its name. So we need to add in an extra piece of logic which will get the label text from the `event_session_category` object if it's not present in the `arguments` scope.

![Screenshot of the configurator form control with rendered labels](images/screenshots/configurator3.png)

>>> Note that any selections you make via the One-to-many Configurator form control are only saved __when you save the parent record__ - in this case the `event_ticket` - even though it may look a bit like the QuickAdd functionality.
---
id: formcontrol-rolePicker
title: "Form control: Role picker"
---

The `rolePicker` control is a specialist control for picking CMS user roles. See [[cmspermissioning]] for an in-depth guide to CMS users, groups, permissioning and roles.

### Arguments

This control does not accept any custom arguments.

### Example

![Screenshot of role picker](images/screenshots/rolePicker.png)

---
id: formcontrol-autoSlug
title: "Form control: Auto Slug"
---

The `autoSlug` control is a control that will automatically create a "slug" version of the text entered in another field as you type.

### Arguments

<div class="table-responsive">
    <table class="table">
        <tbody>
            <tr>
                <th>basedOn (required)</th>
                <td>Field name that this auto slug field should create a slug from, e.g. "title"</td>
            </tr>
            <tr>
                <th>placeholder (optional)</th>
                <td>Placeholder text for the input</td>
            </tr>
        </tbody>
    </table>
</div> 

### Example

```xml
<field name="title" control="textinput"/>
<field name="slug" control="autoSlug" basedOn="title" />
```

![Screenshot of an auto slug control](images/screenshots/autoSlug.png)


---
id: formcontrol-pageTypePicker
title: "Form control: Page Type Picker"
---

The `pageTypePicker` control allows you to choose from all the available page types in a select list.
---
id: formcontrol-enumSelect
title: "Form control: Enum select"
---

The `enumRadioList` control allows users to pick from the values of an enum, showing titles and descriptions of each item with a radio box to select.

### Arguments

<div class="table-responsive">
    <table class="table">
        <tbody>
            <tr>
                <th>enum (required)</th>
                <td>Name of the enum to get values from</td>
            </tr>
        </tbody>
    </table>
</div>

### Example

```xml
<field name="type" control="enumRadioList" enum="eventType" />
```
---
id: formcontrol-datetimepicker
title: "Form control: Date and Time Picker"
---

The `dateTimePicker` control allows users to choose a date and time from a calendar popup with extra time picker.

### Arguments

<div class="table-responsive">
    <table class="table">
        <tbody>
            <tr>
                <th>minDate (optional)</th>
                <td>Minimum allowed date</td>
            </tr>
            <tr>
                <th>maxDate (optional)</th>
                <td>Maximum allowed date</td>
            </tr>
            <tr>
                <th>defaultDate (optional)</th>
                <td>Default date to choose when opening the picker for the first time. Defaults to the current day at midnight (00:00)*.<br>
                <strong>*As of 10.13.0</strong>, the time part is set using defaultTime.</td>
            </tr>
            <tr>
                <th>defaultTime (optional)</th>
                <td><strong>Added in 10.13.0:</strong> Default time to choose when opening the picker for the first time. Defaults to midnight (00:00).<br>
                Can either be a 24-hour time (e.g. "17:00"), or "now" to use the current time.</td>
            </tr>
            <tr>
                <th>relativeToField (optional)</th>
                <td>Related Date Picker field</td>
            </tr>
            <tr>
                <th>relativeOperator (optional)</th>
                <td>Operator to be used when comparing related Date Picker field. Valid Operators are: lt, lte, gt, gte</td>
            </tr>
        </tbody>
    </table>
</div>

### Example

```xml
<field name="start_date" control="datetimepicker" relativeToField="end_date" relativeOperator="lte"/>
<field name="end_date" control="datetimepicker" relativeToField="start_date" relativeOperator="gte"/>
```

![Screenshot of a date and time picker](images/screenshots/dateTimePicker.png)

---
id: formcontrol-notificationTopicPicker
title: "Form control: Notification topic picker"
---

The `notificationTopicPicker` is a special control for picking notification topics. Used in the notifications manager.

### Arguments

This control does not accept any arguments.

### Example

![Screenshot of notification topic picker](images/screenshots/notificationTopicPicker.png)
---
id: formcontrol-richeditor
title: "Form control: Rich editor"
---

The `richEditor` control gives the user a Preside rich editor instance that can be used to insert Preside Widgets, images from the asset manager, etc.

For an in-depth guide, see [[workingwiththericheditor]].

### Arguments

<div class="table-responsive">
    <table class="table">
        <tbody>
            <tr>
                <th>toolbar (optional)</th>
                <td>An optional toolbar definition for the editor (defaults to "full"). See [[workingwiththericheditor]] for an in-depth guide.</td>
            </tr>
            <tr>
                <th>customConfig (optional)</th>
                <td>An optional custom config location for the editor. See [[workingwiththericheditor]] for an in-depth guide.</td>
            </tr>
            <tr>
                <th>widgetCategories (optional)</th>
                <td>Optional comma separated list of categories of widget that are eligible for insertion into this content. See [[widgets]] for further details.</td>
            </tr>
        </tbody>
    </table>
</div>

### Example

```xml
<field name="body" control="richeditor" />
```

![Screenshot of Preside richeditor](images/screenshots/richeditor.png)


---
id: formcontrol-derivativePicker
title: "Form control: Derivative Picker"
---

The `derivativePicker` control allows users to select from a list of publicly available asset derivatives (see [[assetmanager]]). It is an extension of the [[formcontrol-select|select control]].

### Arguments

The control accepts no custom arguments, though all arguments that can be passed to [[formcontrol-select|select control]] can be used.

### Example

```xml
<field name="derivatives" control="derivativePicker" multiple="true" sortable="true" />
```---
id: formcontrol-passwordStrengthPicker
title: "Form control: Password strength picker"
---

The `passwordStrengthPicker` control is a specialist control for picking password strengh levels. This is currently used in the password policy manager.

### Arguments

This control does not accept any custom arguments.

### Example

![Screenshot of password strength picker](images/screenshots/passwordStrengthPicker.png)
---
id: formcontrol-pageLayoutPicker
title: "Form control: Page layout picker"
---

The `pageLayoutPicker` control is a special form control used when adding or editing site tree pages that allows you to choose between different layouts available for the page type that the page uses.

It is not a control that you are likely to want to use in another context.
---
id: formcontrol-siteTreePagePicker
title: "Form control: Site tree page picker"
---

The `siteTreePagePicker` control allows you to select pages from the site tree. It is a customized extension of the [[formcontrol-objectPicker|object picker control]].

### Arguments

<div class="table-responsive">
    <table class="table">
        <tbody>
            <tr>
                <th>multiple (optional)</th>
                <td>True or false (default). Whether or not multiple pages can be selected.</td>
            </tr>
            <tr>
                <th>sortable (optional)</th>
                <td>True or false (default). Whether or not multiple selected pages are sortable within the control's interface.</td>
            </tr>
            <tr>
                <th>childPage (optional)</th>
                <td>ID of the child page with which to restrict the list of selectable pages. If supplied, only pages that can be a _parent_ of the child page will be shown in the control.</td>
            </tr>
        </tbody>
    </table>
</div>

### Example

```xml
<field name="pages" control="sitetreePagePicker" multiple="true" sortable="true" />
```---
id: formcontrol-siteTemplatePicker
title: "Form control: Site template picker"
---

The `siteTemplatePicker` control allows you to select site templates from a select list. See [[workingwithmultiplesites]] for more information on site templates.

### Arguments

The control extends the [[formcontrol-select|select control]]. It does not accept any custom arguments of its own.

### Example

```xml
<field name="templates" control="siteTemplatePicker" multiple="true" /> 
```


---
id: formcontrol-oneToManySelect
title: "Form control: One-to-many select"
---

The `oneToManySelect` control is a variation of the [[formcontrol-objectpicker|Object picker]] that allows you to select all the related records that should "belong" to the current record (the record that you are in the process of creating / editing).

For example, you may have a user group relationship where a user can belong to zero or _one_ group. In the `group` object, you could define a `users` property with a `one-to-many` relationship and have it use the `oneToManySelect` form control. When creating or editing a group, you can then define directly which users belong to the group.

### Arguments

_This control has no custom arguments._

### Example

```luceescript
// /preside-objects/user.cfc
...
property name="group" relationship="many-to-one" relatedTo="group";
...
```

```luceescript
// /preside-objects/group.cfc
...
property name="users" relationship="one-to-many" relatedTo="user" relationshipKey="group";
...
```

```xml
<!-- /forms/preside-objects/group/admin.edit.xml -->
<!-- /forms/preside-objects/group/admin.add.xml -->
<!-- ... -->
<field binding="group.users" control="oneToManySelect" />
```
---
id: formcontrol-spinner
title: "Form control: Spinner"
---

The `spinner` control is a control used for numeric input. It provides a text area with up and down arrows for conveniently being able to adjust the numeric input.

### Arguments

<div class="table-responsive">
    <table class="table">
        <tbody>
            <tr>
                <th>minValue (optional)</th>
                <td>A minimum value accepted by the control (will trigger validation errors if attempting to submit lower values)</td>
            </tr>
            <tr>
                <th>maxValue (optional)</th>
                <td>A maximum value accepted by the control (will trigger validation errors if attempting to submit higher values)</td>
            </tr>
            <tr>
                <th>step (optional)</th>
                <td>Numeric value defining by how much the value should increase or decrease when the spinner control's up and down buttons are triggered. Default is 1.</td>
            </tr>
        </tbody>
    </table>
</div>

### Example

```xml
<field name="companySize" control="spinner" minvalue="0" maxvalue="200000" step="5000" />
```

---
id: formcontrol-manyToOneSelect
title: "Form control: Many to One Select"
---

The `manyToOneSelect` control is a special wrapper to the standard [[formcontrol-objectPicker|object picker control]], used by the system when creating setting automatically mapped form controls from preside object properties with `many-to-one` relationships.

If in doubt, use the [[formcontrol-objectPicker|object picker control]] when manually setting form controls in your form.
---
id: formcontrol-select
title: "Form control: Select"
---

The `select` control allows the user to select either a single or multiple items for an array of values and optional labels, offering a text search feature to quickly find items for selection.

### Arguments


<div class="table-responsive">
    <table class="table">
        <tbody>
            <tr>
                <th>values (required)</th>
                <td>Either an array or comma separated list of values for the select list</td>
            </tr>
            <tr>
                <th>labels (optional)</th>
                <td>Either a comma separated list or array of labels that correspond with the values for each item in the list (must be same length as the values list/array). If not supplied, the values will be used for the labels. Can also be i18n resource URIs</td>
            </tr>
            <tr>
                <th>multiple (optional)</th>
                <td>True or false (default). Whether or not multiple selection is enabled</td>
            </tr>
            <tr>
                <th>sortable (optional)</th>
                <td>True or false (default). Whether or not select items can be sorted (only relevant when multiple is true)</td>
            </tr>
            <tr>
                <th>addMissingValues (optional)</th>
                <td>True or false (default). If the control is being rendered with a pre-selected saved value, and the value is not already present in the provided values list/array - this option allows the saved value to be added to the list</td>
            </tr>
        </tbody>
    </table>
</div>

### Example

```xml
<field name="colours" control="select" values="red,blue,aquamarine" labels="colours:red,colours:blue,colours:aquamarine" multiple="true" />
```

### "Extending" the control

The `select` control is particularly useful for extending to make more specific controls that dynamically generate their values and labels. For example, the [[formcontrol-derivativePicker|Derivative picker control]]. This can be done easily by creating a form control that uses a handler based viewlet:

```luceescript
component {

	property name="assetManagerService"  inject="assetManagerService";

	public string function index( event, rc, prc, args={} ) {
		// Dynamically build args.labels and args.values
		var derivatives   = assetManagerService.listEditorDerivatives();

		args.labels       = [ translateResource( "derivatives:none.title" ) ];
		args.values       = [ "none" ];
		args.extraClasses = "derivative-select-option";

		if ( !derivatives.len() ) {
		    return "";
		}

		for( var derivative in derivatives ) {
		    args.values.append( derivative );
			args.labels.append( translateResource( uri="derivatives:#derivative#.title", defaultValue="derivatives:#derivative#.title" ) );
		}

		// send them to select control's view directly
		return renderView( view="formcontrols/select/index", args=args );
	}
}
```
---
id: formcontrol-enumSelect
title: "Form control: Enum select"
---

The `enumSelect` control is an extension of the [[formcontrol-select]] form control, automatically populating the select control with options from the supplied enum.

### Arguments

<div class="table-responsive">
    <table class="table">
        <tbody>
            <tr>
                <th>enum (required)</th>
                <td>Name of the enum to get values from</td>
            </tr>
        </tbody>
    </table>
</div>

### Example

```xml
<field name="type" control="enumSelect" enum="eventType" />
```
---
id: formcontrol-yesNoSwitch
title: "Form control: Yes/No Switch"
---

The `yesNoSwitch` control is a fancy looking checkbox used for saving boolean values.

>>>>>> Never set the `required` attribute to `true` for a field using the `yesNoSwitch` control. If required, users will only be able to set the option to `yes`.

### Arguments

This control does not accept any custom arguments.

### Example

```xml
<field name="active" control="yesNoSwitch" />
```---
id: formcontrol-dataManagerObjectPicker
title: "Form control: DataManager Object Picker"
---

The `dataManagerObjectPicker` control allows selection of _objects_ that appear in the data manager (not to be confused with the [[formcontrol-objectPicker|Object picker control]] that allows you to select records for a given data object). It is an extension of the [[formcontrol-select|select control]]. It accepts no custom arguments of its own.

### Example

```xml
<field name="objects" control="dataManagerObjectPicker" multiple="true" />
```

![Screenshot of an data manager object picker control](images/screenshots/dataManagerObjectPicker.png)
---
id: formcontrol-checkbox
title: "Form control: Checkbox"
---

The `checkbox` form control renders a _single_ checkbox with an optional custom label (different from the general field label).


### Arguments

<div class="table-responsive">
    <table class="table">
        <tbody>
            <tr>
                <th>checkboxLabel (optional)</th>
                <td>Label to be output to the right of the checkbox input</td>
            </tr>
        </tbody>
    </table>
</div> 

### Example

```xml
<field name="terms" control="checkbox" checkboxLabel="I have read and understand the terms and conditions..." />
```---
id: formcontrol-checkboxList
title: "Form control: Checkbox list"
---

The `checkboxList` control allows multiple choice selection of pre-defined set of items.

### Arguments

<div class="table-responsive">
    <table class="table">
        <tbody>
            <tr>
                <th>values (required)</th>
                <td>Either a comma separated list or array of values for the checkboxes</td>
            </tr>
            <tr>
                <th>labels (optional)</th>
                <td>Either a comma separated list or array of labels that correspond with the values for each checkbox (must be same length as the values list/array). If not supplied, the values will be used for the labels</td>
            </tr>
        </tbody>
    </table>
</div>

### Example

```xml
<field name="numbers" control="checkboxList" values="1,2,3" labels="One,Two,Three"/>
```---
id: formcontrol-websitePermissionsPicker
title: "Form control: Website Permissions Picker"
---

The `websitePermissionsPicker` control is a specialized control for choosing website permissions. It is used in the website user and website user benefit administrator (see [[websiteusersandpermissioning]] for more details on permissioning with website users).

### Arguments

This control does not accept any custom arguments.

### Example

```xml
<field name="permissions" control="websitePermissionsPicker" />
```

![Screenshot of website permissions picker](images/screenshots/websitePermissionsPicker.png)


---
id: formcontrol-oneToManyManager
title: "Form control: One-to-many manager"
---

The `oneToManyManager` form control is actually an link to an iframe modal that helps you manage related data to a record. This control is automatically used when you declare a `one-to-many` property in a preside object and include that property in a form.

### Arguments

This control is currently only used automatically for form fields that bind to `one-to-many` preside object properties. It does not accept any custom arguments.

### Example

```luceescript
// /preside-objects/consultation.cfc
...
property name="sections" relationship="one-to-many" relatedTo="consultation_section" relationshipKey="consultation";
...
```

```xml
<!-- /forms/preside-objects/consultation/admin.edit.xml -->
<!-- ... -->
<field binding="consultation.sections" />
```

![Screenshot of one to many manager link](images/screenshots/oneToManyManagerLink.png)
![Screenshot of one to many manager dialog](images/screenshots/oneToManyManagerDialog.png)---
id: formcontrol-assetStorageLocationPicker
title: "Form control: Asset Storage Location Picker"
---

The `assetStorageLocationPicker` control is a very specific form control for selecting asset storage locations (see [[assetmanager]]). It is a simple extension of the [[formcontrol-select|select control]]. It takes no custom arguments of its own.

### Example

```xml
<field name="storageLocation" control="assetStorageLocationPicker" />
```
---
id: formcontrol-simpleColourPicker
title: "Form control: Simple colour picker"
---

The `simpleColourPicker` control allows users to pick a colour from a pre-defined palette, and can return it as an RGB or hex value.

The [[api-simplecolourpickerservice]] exposes methods for creating and registering palettes, and other helper methods for working with colour values.


### Arguments

<div class="table-responsive">
    <table class="table">
        <tbody>
            <tr>
                <th>palette (optional)</th>
                <td>
                    Name of the pre-defined palette to use. Built-in palettes are "web64" (default), "web216", and "material". You can register additional palettes using the [[simplecolourpickerservice-registerpalette]] method. If the palette you specify is not found, the default palette will be used.
                </td>
            </tr>
            <tr>
                <th>colours (optional)</th>
                <td>
                    Alternatively, you can define a list of colours directly in the form XML file. This should be a pipe-separated list of RGB (e.g. <code>100,150,200</code>) or hex (e.g. <code>cc601a</code> or <code>fff</code>) values - or even a mixture of the two.
                </td>
            </tr>
            <tr>
                <th>rowLength (optional)</th>
                <td>
                    The maximum number of colours displayed on each row of the colour picker. Default is 16.
                </td>
            </tr>
            <tr>
                <th>colourFormat (optional)</th>
                <td>
                    "hex" (default) or "rgb". The format in which you would like the selected colour value to be returned.
                </td>
            </tr>
            <tr>
                <th>rawValue (optional)</th>
                <td>
                    True or false (default). Indicates whether to return the colour as a raw value (e.g. <code>ffcc00</code> or <code>0,150,255</code>) or as a valid CSS value (e.g. <code>#ffcc00</code> or <code>rgb(0,150,255)</code>). You might want to set this to true if, for example, you will be using the selected RGB value as the basis for an rgba() value.
                </td>
            </tr>
            <tr>
                <th>showInput (optional)</th>
                <td>
                    True or false (default). Indicates whether you want the selected colour to be displayed in an input field below the colour swatch, or just show the swatch.
                </td>
            </tr>
        </tbody>
    </table>
</div>

### Examples

```xml
<field name="colour" control="simpleColourPicker" palette="material" showInput="true" colourFormat="rgb" />
```

![Screenshot of a simple colour picker](images/screenshots/simpleColourPicker1.png)


```xml
<field name="colour" control="simpleColourPicker" colours="000|333|666|999|ccc|fff" rowLength="3" />
```

![Screenshot of a simple colour picker](images/screenshots/simpleColourPicker2.png)
---
id: formcontrol-timePicker
title: "Form control: Time picker"
---

The `timePicker` control allows users to choose a time value from a special time picking interface.

### Arguments

<div class="table-responsive">
    <table class="table">
        <tbody>
            <tr>
                <th>defaultTime (optional)</th>
                <td><strong>Added in 10.13.0:</strong> Default time to choose when opening the picker for the first time. Defaults to midnight (00:00).<br>Can either be a 24-hour time (e.g. "17:00"), or "now" to use the current time.</td>
            </tr>
        </tbody>
    </table>
</div>

### Example

```xml
<field name="start_time" control="timePicker" defaultTime="09:00" />
<field name="end_time"   control="timePicker" defaultTime="17:00" />
```

---
id: formcontrol-datePicker
title: "Form control: Date picker"
---

The `datePicker` control allows users to choose a date from a calendar popup.

### Arguments

<div class="table-responsive">
    <table class="table">
        <tbody>
            <tr>
                <th>minDate (optional)</th>
                <td>Minimum date allowed to be selected</td>
            </tr>
            <tr>
                <th>maxDate (optional)</th>
                <td>Maximum date allowed to be selected</td>
            </tr>
            <tr>
                <th>relativeToField (optional)</th>
                <td>Related Date Picker field</td>
            </tr>
            <tr>
                <th>relativeOperator (optional)</th>
                <td>Operator to be used when comparing related Date Picker field. Valid Operators are: lt, lte, gt, gte</td>
            </tr>
        </tbody>
    </table>
</div>

>>> [Work is in progress](https://presidecms.atlassian.net/browse/PRESIDECMS-398) to allow relative date restrictions.

### Example

```xml
<field name="start_date" control="datepicker" minDate="2016-01-01" />
```

### Example with related datepicker field options

```xml
<field name="start_date" control="datepicker" relativeToField="end_date" relativeOperator="lte"/>
<field name="end_date" control="datepicker" relativeToField="start_date" relativeOperator="gte"/>
```

![Screenshot of a date picker](images/screenshots/datePicker.png)
---
id: formcontrol-hidden
title: "Form control: Hidden"
---

The `hidden` form control outputs a hidden input field.

### Arguments

The control does not accept any arguments.

### Example

```xml
<field binding="product.id" control="hidden"/>
```
---
id: systemformcontrols
title: System form controls
---

System provided form controls for the [[presideforms]]:

* [[formcontrol-assetFolderPicker]]
* [[formcontrol-assetPicker]]
* [[formcontrol-assetStorageLocationPicker]]
* [[formcontrol-autoSlug]]
* [[formcontrol-captcha]]
* [[formcontrol-checkbox]]
* [[formcontrol-checkboxList]]
* [[formcontrol-dataManagerObjectPicker]]
* [[formcontrol-datePicker]]
* [[formcontrol-datetimepicker]]
* [[formcontrol-derivativePicker]]
* [[formcontrol-emailInput]]
* [[formcontrol-enumSelect]]
* [[formcontrol-enumRadioList]]
* [[formcontrol-fileTypePicker]]
* [[formcontrol-hidden]]
* [[formcontrol-imagedimensions]]
* [[formcontrol-linkPicker]]
* [[formcontrol-manyToManySelect]]
* [[formcontrol-manyToOneSelect]]
* [[formcontrol-notificationTopicPicker]]
* [[formcontrol-objectPicker]]
* [[formcontrol-oneToManyConfigurator]]
* [[formcontrol-oneToManyManager]]
* [[formcontrol-oneToManySelect]]
* [[formcontrol-pageLayoutPicker]]
* [[formcontrol-pageTypePicker]]
* [[formcontrol-password]]
* [[formcontrol-passwordStrengthPicker]]
* [[formcontrol-radio]]
* [[formcontrol-readonly]]
* [[formcontrol-richeditor]]
* [[formcontrol-rolePicker]]
* [[formcontrol-select]]
* [[formcontrol-simpleColourPicker]]
* [[formcontrol-siteTemplatePicker]]
* [[formcontrol-siteTreePagePicker]]
* [[formcontrol-spinner]]
* [[formcontrol-textarea]]
* [[formcontrol-textInput]]
* [[formcontrol-timePicker]]
* [[formcontrol-websitePermissionsPicker]]
* [[formcontrol-yesNoSwitch]]---
id: formcontrol-assetPicker
title: "Form control: Asset picker"
---

The `assetPicker` form control is a customized extension of the [[formcontrol-objectPicker|object picker]] that allows you to:

* search for, and choose assets from the asset manager
* browse and choose assets from the asset manager
* upload and select assets into the asset manager

### Arguments

In addition to the standard arguments for the [[formcontrol-objectPicker|object picker]], the control can take:

<div class="table-responsive">
    <table class="table">
        <tbody>
            <tr>
                <th>allowedTypes (optional)</th>
                <td>Comma separated list of asset types that are accepted. e.g. "image", "document", or "png,jpg", etc.</td>
            </tr>
            <tr>
                <th>maxFileSize (optional)</th>
                <td>Maximum size, in MB, for uploaded files</td>
            </tr>
        </tbody>
    </table>
</div> 

### Example

```xml
<field name="images" control="assetPicker" allowedTypes="image" maxFileSize="0.5" multiple="true" sortable="true" />
```

![Screenshot of an asset picker](images/screenshots/assetPicker.png)
---
id: formcontrol-linkPicker
title: "Form control: Link picker"
---

The `linkPicker` control allows you to select and create links from the system-wide links database. It extends the [[formcontrol-objectPicker|Object picker control]].

### Arguments

This control does not accept any custom arguments. However, arguments that can be passed to the [[formcontrol-objectPicker|Object picker control]] are valid.

### Example

```xml
<field name="links" control="linkPicker" multiple="true" sortable="true" />
```
---
id: formcontrol-filterpicker
title: "Form control: Filter picker"
---

The `filterPicker` control is an [[formcontrol-objectPicker| object picker]] with custom options and interface specific to rules engine filters.

### Arguments

You can use any arguments that can be used with the [[object picker]]. In addition, the control accepts the following attributes:

<div class="table-responsive">
    <table class="table">
        <tbody>
            <tr>
                <th>filterObject (required)</th>
                <td>The target object for the filter</td>
            </tr>
            <tr>
                <th>rulesEngineContextData (optional)</th>
                <td>Struct of data that will be passed to all filter field configuration forms in the quick add / edit filter builder. This allows you to limit choices on fields when creating dynamic filters within specific contexts. As this is a stuct, it can only be injected using `additionalArgs` argument to renderForm().</td>
            </tr>
            <tr>
                <th>preSavedFilters (optional)</th>
                <td>For use with the quick add/edit filter builders. A list of saved filters that will be used additionally filter the "filter count" shown in the filter builder.</td>
            </tr>
            <tr>
                <th>preRulesEngineFilters (optional)</th>
                <td>For use with the quick add/edit filter builders. A list of saved rules engine filter IDs that will be used additionally filter the "filter count" shown in the filter builder.</td>
            </tr>
        </tbody>
    </table>
</div> 

expects a single **required** option, `filterObject` indicating the object that selected / added filters should apply to.


### Example

```xml
<field name="optional_filters" control="filterPicker" filterObject="news" multiple="true" sortable="true"  />
```---
id: formcontrol-captcha
title: "Form control: Captcha"
---

The `captcha` form control renders a Google ReCaptcha (v2) control, and was introduced in *10.10.38*.

Note that the name of the Captcha field is irrelevant - this is just used internally to attach validation errors. Validation is done automatically, as part of the standard form validation.

If Captcha keys have not been set up for the site, then the control will simply not be displayed (and it will not try to validate it).

### Arguments

<div class="table-responsive">
    <table class="table">
        <tbody>
            <tr>
                <th>theme (optional)</th>
                <td>Available values are <code>light</code> (default) or <code>dark</code></td>
            </tr>
            <tr>
                <th>size (optional)</th>
                <td>Available values are <code>normal</code> (default) or <code>compact</code></td>
            </tr>
        </tbody>
    </table>
</div>

### Example

```xml
<field name="captcha" control="captcha" theme="dark" size="compact" label="Are you human?" />
```---
id: apacheexample
title: Apache2 Proxy example
---

The following is an example Apache2 Virtual Host definition that should work well proxying to a Lucee backend setup with the [[serversetupfoundation|Lucee setup guide]].

```apache
<VirtualHost *:80>
  ServerName www.mysite.com
  ServerAlias mysite.com
  RewriteEngine On
  
  RewriteCond %{SERVER_PORT} !^443$
  RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI} [R=301,NC,L]
  
  RewriteCond %{HTTPS} off
  RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI} [R=301,NC,L]
  
  RewriteCond %{HTTP:X-Forwarded-Proto} !https
  RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI} [R=301,NC,L]
</VirtualHost>

<VirtualHost *:443>
  ServerName www.mysite.com
  ServerAlias mysite.com
  
  DirectoryIndex index.cfm
  DocumentRoot /var/www/
  
  <Directory /var/www/>
    Options Indexes FollowSymLinks MultiViews
    AllowOverride All
    Order allow,deny
    Allow from all
  </Directory>
 
  SSLEngine On
  SSLCertificateFile "/ssl/mysite/mysite.com.crt"
  SSLCertificateChainFile "/ssl/mysite/mysite.com.ca-bundle"
  SSLCertificateKeyFile "/ssl/mysite/privkey.pem"

<IfModule mod_proxy.c>
    ProxyPreserveHost On
    ProxyPassMatch ^/(.*)(.*)?$ http://127.0.0.1:8888/$1$2
    ProxyPassMatch ^/(.*)(/.*)?$ http://127.0.0.1:8888/$1$2
    ProxyPassReverse / http://127.0.0.1:8888/

    ProxyTimeout 900
</IfModule>
</VirtualHost>
```---
id: serversetupfoundation
title: Lucee setup
---

This guide assumes you already have a webserver up and running using Lucee (e.g. using one of Lucee's installers). It will take you through the settings and additional installation requirements for working with Preside websites.

## Tuckey URL rewrite filter

We recommend using the Tucky URL rewrite filter for Preside's URL rewriting. The chief reasons for this are:

1. Enables us to setup CommandBox based local development with no extra setup
2. Enables us to easily ship Preside based applications that have their rewrites defined right in the application

You can, of course, use your web server of choice's own rewriting engine, but for now, we don't have any setup guides for doing so.

### Installing the filter

Installing the filter comes in two steps. Firstly, download the [urlrewritefilter-4.0.3.jar](http://search.maven.org/remotecontent?filepath=org/tuckey/urlrewritefilter/4.0.3/urlrewritefilter-4.0.3.jar) file and copy to `/{lucee-home}/lib/`; ensure that the user that Lucee runs with can access the file.

Next, you will need to edit your servlet's `web.xml` file. For a default Lucee install with Tomcat, this lives at `/{lucee-home}/tomcat/conf/web.xml`. You will need to add the following code _before_ the very first `<servlet>` definition:

```xml
<!-- ==================================================================== -->
<!-- URL ReWriting Filter                                                 -->
<!-- ==================================================================== -->
<filter>
    <filter-name>UrlRewriteFilter</filter-name>
    <filter-class>org.tuckey.web.filters.urlrewrite.UrlRewriteFilter</filter-class>

    <!--
       the confPath param below tells the filter to look
       for urlrewrite.xml in the webroot of each of your applications
    -->
    <init-param>
        <param-name>confPath</param-name>
        <param-value>/urlrewrite.xml</param-value>
    </init-param>

    <!--
       the confReloadCheckInterval param below means that changes
       to urlrewrite.xml will take effect almost immediately.
       Has minor performance implications, so you may wish to exclude it.
    -->
    <init-param>
        <param-name>confReloadCheckInterval</param-name>
        <param-value>1</param-value>
    </init-param>
</filter>

<!--
    Map the defined filter to all incoming URL patterns
-->
<filter-mapping>
    <filter-name>UrlRewriteFilter</filter-name>
    <url-pattern>/*</url-pattern>
    <dispatcher>REQUEST</dispatcher>
    <dispatcher>FORWARD</dispatcher>
</filter-mapping>
```

## Lucee settings

Preside requires the use of a couple of non-default settings in Lucee that cannot be defined in the Application's code.

### Null Support

>>> Coldbox and Preside will **not run with Full NULL support**. Ensure that Null support is set to **Partial Support (CFML Default)**.

### Preserve case for structs

Log in to the Lucee _Server_ admin and go to **Settings -> Language/Compiler**.
(Lucee 4.x) Choose the **"Keep original case"** option for the **Dot notation** setting and hit **update**.
(Lucee 5.x) Choose the **"Preserve case"** option for the **Key case** setting and hit **update**.

### Lucee Admin API password

If you wish to update Preside versions through the Preside Admin interface, and do not wish to supply an admin password, you must set the security to "open" for the API. In the Lucee _Server_ admin, go to **Security > Access > General Access**. Choose **"Open"** for both options and hit the **update** button.

## Per-application mapping and datasource

The final setup involves creating a mapping to the Preside source code and setting up of a Datasource for your application. This can be done through the Lucee _Web_ admin.

The mapping should have a logical path of */preside* and point to the physical directory in which you have Preside downloaded. Head over to [https://www.preside.org](https://www.preside.org) to grab the latest version.

The datasource should, by default, be named *"preside"* and should be setup as with any normal datasource. Prior to Preside 10.5.0, we only support MySQL/MariaDB. As of the upcoming Preside 10.5.0 release, we will additionally support PostgreSQL and Microsoft SQL Server.

## Conclusion and next steps

With all those settings in place, you should be able to deploy Preside applications to your environment and have them running.

As always, if you need more help than the docs can provide, please join our [community forums](https://community.preside.org/) where we'll be happy to help you out.
---
id: nginxexample
title: Nginx Proxy example
---

The following is an example NGiNX proxy server definition that should work well proxying to a Lucee backend setup with the [[serversetupfoundation|Lucee setup guide]].

```nginx
server {

    listen 80;
    server_name www.mysite.com;

    # Allow internal taskmanager requests
    # over plain HTTP. Prevents issues
    # with Lucee failing to make requests
    # due to SSL certificate compatibility
    location /taskmanager/runtasks/ {
        proxy_set_header X-Original-Url $request_uri;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $http_host;

        proxy_read_timeout 1200;
        proxy_pass http://127.0.0.1:8888$request_uri;
    }

    # all other locations, redirect to ensure https
    location / {
        return 301 https://$server_name$request_uri;
    }
}

# port 443 server (HTTPS)
server {
    listen 443 ssl http2;

    server_name www.mysite.com;

    ssl_certificate /path/to/publicssl.crt;
    ssl_certificate_key /path/to/privatesslkey.rsa;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers EECDH+CHACHA20:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;
    ssl_prefer_server_ciphers on;

    add_header Strict-Transport-Security "max-age=15552000";
    add_header X-Content-Type-Options "nosniff";
    add_header X-Download-Options "noopen";
    add_header X-Permitted-Cross-Domain-Policies "none";

    client_max_body_size 100M;

    # proxy by default to the Tomcat/Lucee
    # backend
    location / {
        proxy_set_header X-Original-Url $request_uri;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $http_host;

        if ( $uri ~ "\.(?:ico|css|js|gif|jpe?g|png)$" ) {
            expires max;
            add_header Pragma public;
            add_header Cache-Control "public, must-revalidate, proxy-revalidate";
        }

        proxy_read_timeout 1200;
        proxy_pass http://127.0.0.1:8888$request_uri;
    }

    # public uploads from asset manager
    # served with nginx directly
    location /uploads/assets/ {
        # where /var/www is the webroot of your Preside application
        root /var/www;
        expires max;
        add_header Pragma public;
        add_header Cache-Control "public, must-revalidate, proxy-revalidate";
    }

    # public css, js and css images
    # for your application served
    # with nginx directly
    location /assets/ {
        # where /var/www is the webroot of your Preside application
        root /var/www;
        expires max;
        add_header Pragma public;
        add_header Cache-Control "public, must-revalidate, proxy-revalidate";
    }
    
}
```
---
id: serverguides
title: Server setup guides
---

The guides here are for those who wish to setup Preside in various hosting environments:

[[serversetupfoundation]]

As always, if you need more help than the docs can provide, please join our [community forums](https://community.preside.org/) where we'll be happy to help you out.---
id: runningtests
title: Running the test suite
---

The test suite can be run in two ways:

1. From the command line, by running `/preside> ./test.sh`
2. Through a browser, by running `/preside> ./support/tests/startserver.sh` 

Both methods require that you have [CommandBox](https://www.ortussolutions.com/products/commandbox) installed and in your path.

## Test database

Both methods also require that you have an empty test database accessible to the server running the code. The easiest way to do that is to have a local MySQL database and user created with the following credentials:

```
Host     : localhost
Port     : 3306
DB Name  : preside_test
User     : root
Password : (empty)
```

An alternative database can be used by setting the following environment variables that should be made available to the running test suite:

```
PRESIDETEST_DB_HOST
PRESIDETEST_DB_PORT
PRESIDETEST_DB_NAME
PRESIDETEST_DB_USER
PRESIDETEST_DB_PASSWORD
```

## Be patient

On my well spec'd laptop, the full test suite takes around five minutes to complete. Expect for the suite to take a long time.

>>>>>> Use the Web browser based test suite runner to be able to pick and choose which tests to run, this will make a huge difference when focusing on a particular area of development.
---
id: submittingchanges
title: Submitting fixes, improvements and awesome new features
---

The primary mechanism for submitting changes to the codebase is via [GitHub Pull Requests](https://help.github.com/articles/proposing-changes-to-a-project-with-pull-requests/). The recommended practice for doing this is as follows:

1. Fork and clone the primary [Preside repository](https://github.com/pixl8/Preside-CMS) (see [[buildfromsource]] for further instructions)

2. For each new bug / feature or improvement you wish to make, **create a new branch** forked from the branch named "stable". If you are working against a ticket in [JIRA](https://presidecms.atlassian.net/), include the issue number in the branch name. For example:
```
/preside> git checkout -b PRESIDECMS-266_awesomenewfeature stable
```
3. Make your changes and commit to your local clone and push to your GitHub fork, remember to include the JIRA issue number in your commit messages.

4. When you're ready, visit your branch in GitHub and [make a Pull Request](https://help.github.com/articles/creating-a-pull-request/) from your new branch to the Preside stable branch.

After a pull request has been made, it will be reviewed and we may ask you to make ammendments. At this point, all you need to do is make those changes in your new feature branch and push them back to your fork in GitHub - the changes will automatically make it into the Pull Request.

When we're all happy with the request, we'll manually merge it into the primary repository ready for the upcoming release (see [[branchingmodel]]).---
id: branchingmodel
title: Our git branching model and release strategy
---

We use the [TwGit flow](https://github.com/Twenga/twgit) by [Twenga](http://twgit.twenga.com/) to manage our software releases. What this means is that the repository will always have a branch named `stable` and this will contain the very latest official release. Official releases will also be tagged using [Semantic Versioning](http://semver.org/).

Upcoming releases that we're working on will have their own release branch that will live until the release has been finalized and merged into `stable`. The naming convention for these branches is `release-x.x.x` where `x.x.x` is the proposed release version number.

Individual changes are all made in their own *feature* branches that are merged into the *release* branch when they're ready to be tested with the upcoming release. The naming convention for these branches is `feature-JIRA-XXX_shortdescription`, where `JIRA-XXX` is the JIRA issue number that is being worked on.

## Packaged builds

Whenever we push changes to the GitHub repository, we have [Travis CI](https://travis-ci.org/) run our test suite (the [test results](http://downloads.presidecms.com/#!/presidecms%2Ftestresults%2F) are posted to our downloads site). In addition, we also have Travis create a packaged zip file of the system when the branch being pushed is a *release* branch, or when we push a *tag*.

Builds of tagged releases make it to the ["stable" folder on our downloads site](https://downloads.preside.org/#!/stable%2F). Builds of upcoming release branches make it the the ["bleeding-edge" folder on our downloads site](https://downloads.preside.org/#!/bleeding-edge%2F).

## What this means for you

For the most part, you don't really have to worry about this branching model. If you're contributing code changes, [[submittingchanges|our guide to contributing changes]], should give you all you need to know.

That said, if you *are* pulling down the code from Git, and want to be on the latest version in development, be sure to checkout whatever *release* branch exists at the time. If you want the official releases, you can stick with the *stable* branch.---
id: buildfromsource
title: Building Preside locally
---

In order to run Preside from a local copy of the codebase, the system requires that external dependencies be pulled in to the expected locations in the project. Before continuing, you will need to make sure you have [CommandBox](https://www.ortussolutions.com/products/commandbox), [NodeJs](https://nodejs.org/en/) and [grunt-cli](https://www.npmjs.com/package/grunt-cli) installed and available in your path. Build steps:

1. [Fork](https://help.github.com/articles/fork-a-repo/) the [GitHub repository](https://github.com/pixl8/Preside-CMS)
2. [Make a local clone](https://help.github.com/articles/cloning-a-repository/) of your forked repository
3. Run the `box install save=false` command to have CommandBox pull in all of presides dependencies that are declared in its `box.json` file:
```
/preside> box install
```
4. CD into the `system/assets` directory and run `grunt` to compile static assets:
```
/preside/system/assets> npm install && grunt all
```


Once you have the repository cloned to your local machine and have pulled down the dependencies, create a `/preside` mapping in your application that points at your clone. You will then be able to develop in your fork and test the changes in your application. See [[submittingchanges]] for details on how best to contribute your changes back to the project.

## Keeping your fork up to date

When you fork our repository in GitHub, you essentially have a "cut off" repository that is all your own. GitHub have an excellent guide on [working with forks](https://help.github.com/articles/working-with-forks/) that includes information on syncing with an upstream repository, but here is our super quick guide:

```
# add the master repo as a git remote called 'upstream'
git remote add upstream // needed here ssh + https urls

# fetch the latest code from the upstream remote
git fetch upstream

# merge the upstream changes into your local branches
git checkout stable
git merge upstream/stable

# do this for as many branches that you want to 
# work with locally
git checkout release-10.2.4
git merge upstream/release-10.2.4

```

For a guide to the git branching model we use, see [[branchingmodel]].
---
id: contribguides
title: Contributor guides
---

This guide is for those who wish to maintain or contribute to Preside.

* [[buildfromsource]]
* [[submittingchanges]]
* [[runningtests]]
* [[branchingmodel]]

As always, if you need more help than the docs can provide, please join our [community forums](https://community.preside.org/) where we'll be happy to help you out.