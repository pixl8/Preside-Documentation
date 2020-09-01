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
