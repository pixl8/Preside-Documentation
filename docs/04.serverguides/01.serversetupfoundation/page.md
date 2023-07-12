---
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
