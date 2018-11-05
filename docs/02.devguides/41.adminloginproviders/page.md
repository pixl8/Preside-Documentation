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
```