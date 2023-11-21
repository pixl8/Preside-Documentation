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
```