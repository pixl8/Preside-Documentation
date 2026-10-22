---
id: presideforms-permissioning
title: Restricting Preside form elements by permission key
---

## Restricting Preside form elements by permission key

As of Preside 10.8.0, the forms system allows you to restrict individual `field`, `fieldset` and `tab` elements by an _admin_ **permission key** (see [[cmspermissioning]] for full details of the admin permissioning system). Simply tag your element with a `permissionKey` attribute to indicate the permission key that controls access to the `field`/`fieldset`/`tab`.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form>
	<!-- only users with 'standard.editing' perms will see this tab -->
	<tab id="default" permissionKey="standard.editing">
		<fieldset id="default" sortorder="10">
			<field binding="myobject.title"       />

			<!-- only users with 'slug.edit' perms will see this field -->
			<field binding="myobject.slug" permissionkey="slugs.edit" />
		</fieldset>

		<!-- only users with 'advanced.editing' perms will see this fieldset -->
		<fieldset id="advanced" sortorder="10" permissionkey="advanced.editing">
			<field binding="myobject.title"       />
			<field binding="myobject.description" />
		</fieldset>
	</tab>
</form>
```

### Restricting an entire form

As of Preside **10.31.0**, the root `form` element also accepts a `permissionKey` attribute. This does not strip any elements from the form; instead it declares the permission key that governs access to the form as a whole, for admin areas that want to restrict a whole screen rather than individual fields.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form permissionKey="payments.settings.manage">
	<tab id="default">
		<fieldset id="default" sortorder="10">
			<field name="my_setting" />
		</fieldset>
	</tab>
</form>
```

Because form definitions are merged across core, extensions and your application (see [[presideforms-merging]]), the attribute can be declared by an extension and then overridden in your own copy of the form definition.

To check the declared key for the currently logged in admin user, use [[formsservice-usercanaccessform]]:

```luceescript
component {
	property name="formsService" inject="formsService";

	private boolean function _userCanEditSettings() {
		return formsService.userCanAccessForm( formName="system-config.my_category" );
	}
}
```

Forms that do not declare a `permissionKey` are considered accessible by default. Pass `allowedIfNoPermissionKey=false` to invert that, so that only forms explicitly declaring a key are considered accessible - this is how [[editablesystemsettings]] categories use the attribute.

The method also accepts `permissionContext` and `permissionContextKeys` arguments for context aware permissions, as described below.

### Context permissions

If you are building a custom admin area and you are rendering and validating forms with permissions that are _context aware_ (see [[cmspermissioning]]), you can supply the context and context keys to the various methods for interacting with forms to ensure that the correct permissions are applied. For example:

```lucee
#renderForm(
	  formName              = "my.form"
	, permissionContext     = "myContext"
	, permissionContextKeys = [ contextId ]
 // , ...
)#
```

```luceescript
var formData = event.getCollectionForForm(
	  formName              = "my.form"
	, permissionContext     = "myContext"
	, permissionContextKeys = [ contextId ]
);
var validationResult = validateForm(
	  formName              = "my.form"
	, formData              = formData
	, permissionContext     = "myContext"
	, permissionContextKeys = [ contextId ]
);
```

>>> If you are unsure what context permissions mean, then you probably don't need to worry about them for getting your form permissions to work. The default settings will work well for any situation where you have not created any custom logic for context aware permissioning.