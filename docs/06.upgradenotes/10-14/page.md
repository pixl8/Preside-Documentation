---
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
