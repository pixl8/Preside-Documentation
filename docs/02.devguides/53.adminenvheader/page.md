---
id: adminenvheader
title: Admin development environment banner header
---

## Overview

As of Preside 10.27, you are able to have the admin user interface display a banner showing the working environment (i.e. staging vs production).

## Configuring the banner

In Config.cfc, you are able to configure whether or not the banner shows + configure an icon, alert class + optionally configure a specific message to display:

```luceescript
settings.environmentMessage = "Some message to display"; // default is empty, using i18n approach as detailed below
settings.environmentBannerConfig = {
    icon     = "fa-code"
  , cssClass = "alert-info"
  , display  = true
};
```

Using this approach, you can use [Coldbox environments system](https://coldbox.ortusbooks.com/getting-started/configuration/coldbox.cfc/configuration-directives/environments) to provide different configuration for different environments. i.e. Have "local", and "staging" environment configurations by using corresponding methods in your Config.cfc:

```luceescript
function local() {
  super.local();

  settings.environmentBannerConfig = { display=false };
}

function staging() {
  settings.environmentBannerConfig = { display=true, icon="fa-code", cssClass="alert-warning" };
  // ...
}
```

## Using i18n for the message

If you leave `settings.environmentMessage` empty, then you can use i18n to specify the message. The key for the i18n resource will be: `cms:environment.#environment#.label`, where `environment` is the coldbox environment. So in `/i18n/cms.properties`, you could have:

```properties
environment.staging.label=This is the staging environment
environment.dev.label=This is the dev environment
```