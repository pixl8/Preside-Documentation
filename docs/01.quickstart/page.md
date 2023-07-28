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

