---
id: datamanager-customization-isoperationallowed
title: "Data Manager customization: isOperationAllowed"
---

## Data Manager customization: isOperationAllowed

Similar to the [[datamanager-customization-checkpermission|checkPermission]] customization, the `isOperationAllowed` customization allows you to completely override the core Data Manager logic for determining whether the given operation is allowed for the object.

It is expected to return a `boolean` value and is given the following in the `args` struct:

* `objectName`: The name of the object
* `operation`: The operation to check. Core operations are: `add`, `arguments`, `delete`, `edit` and `read`

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private boolean function isOperationAllowed( event, rc, prc, args={} ) {
		var operation = args.operation ?: "";

		return operation != "delete";
	}

}
```

>>> For core operations, you are also able to achieve similar results by setting `@dataManagerAllowedOperations` on your preside object. See [[datamanagerbasics]] for documentation.



