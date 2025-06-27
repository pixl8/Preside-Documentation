---
id: cfflow-tokenproviders
title: "Workflow reference: CfFlow Token Providers"
---

## CfFlow Token Providers

The workflow extension registers several [CfFlow token providers](https://pixl8.github.io/cfflow/guides/extending/tokenproviders.html) (link to CfFlow documentation) with the CfFlow library that can be used throughout your CfFlow workflow definitions, i.e.

```yaml
condition:
  ref: string.EndsWith
  args:
    pattern: '@gmail.com'
    value: $preside.webuser.email_address # token here
```

This page gives details of all the token patterns made available by this extension.

## Token patterns

### General Preside Tokens

#### $coldbox.setting.*

Use the `$coldbox.setting.*` token pattern to make use of settings defined in your application's Config.cfc.

##### Example

```yaml
actions:
  post:
    ref: coldbox.Handler
    args:
      event: email.Send
      args:
        template: $coldbox.setting.events.notificationEmailTemplate
```

#### $preside.setting.*

Use the `$preside.setting.*` token pattern to make use of settings that are configured in the Preside admin -> System -> Settings screens.

##### Example

```yaml
actions:
  post:
    ref: coldbox.Handler
    args:
      event: email.Send
      args:
        template: $preside.setting.events.notificationEmailTemplate
```

#### $preside.webuser.*

Use the `$preside.webuser.*` token pattern to make use of fields from the `website_user` object that are present for the logged in user. For example:


##### Example

```yaml
actions:
  post:
    ref: coldbox.Handler
    args:
      event: email.verify
      args:
        email: $preside.webuser.email_address
```

### Webflow Tokens

These token patterns are to be used with the Webflow sytem.

#### $webflow.config.*

The `$webflow.config.*` pattern allows you to make use of webflow config variables within your webflow conditions.

##### Example

```yaml
steps:
- id: optionalstep
  condition:
    ref: bool.IsTrue
    args:
      value: $webflow.config.use_my_optional_step
```

#### $webflow.step.{stepid}.config.*

The `$webflow.step.{stepid}.config.*` pattern allows you to make use of webflow _step_ configuration variables within your webflow conditions.

##### Example

```yaml
steps:
- id: 2fa
  condition:
    ref: bool.IsTrue
    args:
      value: $webflow.step.login.config.use_2fa
```