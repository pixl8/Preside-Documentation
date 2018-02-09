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



