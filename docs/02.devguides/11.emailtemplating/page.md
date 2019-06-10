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
