---
id: enhancedrecordviews
title: Enhanced record views
---

## Introduction

As of **Preside 10.24.0**, the admin system provides an alternative system to the default view record screen. To get started with it, create a data manager handler for your entity that extends `preside.system.base.EnhancedDataManagerBase`.

### "Info-card" and tabs

The view record layout uses standard Preside datamanager "top right buttons" and crumbtrail customizations but adds a concept of an "info card" and "view tabs" for your record.

![image](images/screenshots/enhanced-datamanager-infocard.png)

_If you have the [Alternate Admin Theme extension](https://www.forgebox.io/view/preside-ext-alt-admin-theme) installed, you can also make use of an alternative UX which gives a sidebar menu in place of the tabs, and allows for a header card to be placed at the top of the sidebar._

_The Alternate Admin Theme is likely to become the default core admin theme in a future release of Preside._

### Customizing the "info card"

The info card layout is configured using three columns that are arrays of info card items. The default configuration is to have **created** and **modified** info in column three but you can customize these as you wish. The columns must be set in the psuedo-constructor of your CFC and look like this:

```luceescript
component extends="preside.system.base.EnhancedDataManagerBase" {

	variables.infoCol1 = variables.infoCol1 ?: [];
	variables.infoCol2 = variables.infoCol2 ?: [];
	variables.infoCol3 = variables.infoCol3 ?: [];

	// for example, add new items to whatever is already
	// existing in the columns
	ArrayAppend( variables.infoCol1, "entityStatus" );
	ArrayAppend( variables.infoCol2, "entityWebsite" );

// ....
```

For each item in an info column, you can implement a private viewlet handler in your CFC, `_infoCard{colname}()`. For example:

```luceescript
component extends="preside.system.base.EnhancedDataManagerBase" {

	variables.infoCol1 = variables.infoCol1 ?: [];
	variables.infoCol2 = variables.infoCol2 ?: [];
	variables.infoCol3 = variables.infoCol3 ?: [];

	ArrayAppend( variables.infoCol1, "entityStatus" );

	private string function _infoCardEntityStatus( event, rc, prc, args={} ) {
		var record = args.record ?: {}; // struct of the current record

		return '<i class="fa fa-fw fa-check green"></i>&nbsp; #( record.status ?: "" )#';
	}
```

However, you can also just use a field name for the item and the system will use the standard admin renderer for that item _if you do not supply a custom viewlet for the info card_.

#### Specifiying info card column sizes

You may also hard code an array of column sizes for your info card. These sizes should add up to a total of 12 to match the bootstrap grid system. Examples:

```luceescript
variables.infoCol1 = [ "status", "owner" ];
variables.infoCol2 = [ "description" ];
variables.infoCol3 = [];

// set column sizes
variables.infoColSizes = [ 3, 9, 0 ];
```

#### Rendered description

By setting `variables.infoDescription`, you can choose a property from the record, or a defined custom infoCard item, to be rendered above the infocard. Example:

```luceescript
variables.infoDescription = "teaser";
```

#### preRenderDataManagerObjectInfoCard interceptor

Before the info card is rendered, an interception event `preRenderDataManagerObjectInfoCard` is announced.

This receives the following in its `interceptData`:

* `objectName` - the name of the object
* `record` - the record data for the displayed record
* `tabs` - an array of tab names to display
* `currentTab` - the name of the currently selected tab

Manipulating this data would enable an extension to add its own tab to an object's default array of tabs, for example.

### Customizing tabs

Similar to the info card items, tabs must be configured in your object's psuedo-constructor. For example:

```luceescript
component extends="preside.system.base.EnhancedDataManagerBase" {
	variables.tabs = variables.tabs ?: [ "default" ]; // the default
	ArrayInsertAt( variables.tabs, 2, "directory" );
	ArrayAppend( variables.tabs, "orders" );
	ArrayAppend( variables.tabs, "bookings" );
	variables.maxTabCount = 5; // default is 6

```

For each tab, you must supply a corresponding viewlet (`_{tabid}Tab()`) in your handler to render the _content_ of the tab. For example:

```luceescript
component extends="preside.system.base.EnhancedDataManagerBase" {
	variables.tabs = variables.tabs ?: [ "default" ]; // the default
	ArrayAppend( variables.tabs, "bookings" );

	private string function _bookingsTab( event, rc, prc, args={} ) {
		return "your view rendering logic here";
	}

```

#### Tab title's and icons

Tab icons and titles can be specified by convention in your `/i18n/preside-objects/my_entity.properties` file with the convention:

```properties
viewtab.tabid.title=Title of tab
viewtab.tabid.iconClass=fa-list orange
```

If you wish to implement more complex logic for rendering your tab title, you can implement a `_{tabId}TabTitle()` handler action:


```luceescript
component extends="preside.system.base.EnhancedDataManagerBase" {
	variables.tabs = variables.tabs ?: [ "default" ]; // the default
	ArrayAppend( variables.tabs, "bookings" );

	private string function _bookingsTabTitle( event, rc, prc, args={} ) {
		var bookingsCount = bookingsService.getBookingsCount( args.recordId ?: "" );
		return translateResource( "preside-objects.my_entity:viewtab.bookings.title" ) & ' <span class="badge">#NumberFormat( bookingsCount )#</span>';
	}
	private string function _bookingsTab( event, rc, prc, args={} ) {
		return "your view rendering logic here";
	}

```

#### Tab content

To display DB record fields in name value pair within table, you can call the view `/admin/datamanager/_propertyNameValueData`, pass in the array list of field names as `fields` args from within the tab viewlet. E.g.

```luceescript
private string function _defaultTab( event, rc, prc, args={} ) {
	return renderView( view="/admin/datamanager/_propertyNameValueData", args={
		  objectName = args.objectName ?: ""
		, fields     = [ "description", "start_date", "..." ]
		, detail     = args.record
	} );
}
```

To manipulate the field data for similar display layout, use `extraRows` args. E.g.

```luceescript
private string function _defaultTab( event, rc, prc, args={} ) {
	var extraRows = [];

	if ( Len( args.record.amount_paid ) ) {
		ArrayAppend( extraRows, {
			  title = translateResource( "preside-objects.#args.objectName#:field.amount_paid.title" )
			, body  = renderLabel( "currency", args.record.paid_currency ) & args.record.amount_paid
		} );
	}

	return renderView( view="/admin/datamanager/_propertyNameValueData", args={
		  objectName = args.objectName ?: ""
		, extraRows  = extraRows
		, detail     = args.record
	} );
}
```

#### "Max" tabs

By specifying a `maxTabCount` setting, you limit the number of tabs that will show before tabs are treated as "additional". Additional tabs are grouped in a final tab using a dropdown menu.

For instance, if have 10 tabs and can easily fit 8 in before breaking on to two lines, then you may wish to set this value to 8:

```luceescript
variables.maxTabCount = 8; // default is 6
```

#### preRenderDataManagerObjectTabs interceptor

Before the tabs are rendered, an interception event `preRenderDataManagerObjectTabs` is announced.

This receives the following in its `interceptData`:

* `objectName` - the name of the object
* `record` - the record data for the displayed record
* `col1`, `col2`, `col3` - arrays of the items to be displayed in each column
* `infoDescription` - the rendered description to appear before the info card

Manipulating this data would enable an extension to add its own items to an object's info card, or add to or manipulate the recored description.

### Sidebar Navigation

If you have the [Alternate Admin Theme extension](https://www.forgebox.io/view/preside-ext-alt-admin-theme) installed, there is an alternative UX which gives a sidebar menu in place of the tabs.

This can be enabled for an object by setting:
```luceescript
variables.sidebarNavigation = true; // default is false (i.e. traditional tab layout)
```

#### Tab content

Tab content is defined the same as before. The only differences are that only the content of the active tab is rendered on any one page, and whether a tab/sidebar item is hidden is now based on the menu item generator, not on a tab having no content.

#### Tab titles

Custom tab title methods are not used in the sidebar. Instead, any logic contained previously in these should be refactored into the `_{tab}MenuItem()` method.

#### Menu items

Sidebar menu items are still governed by the `variables.tabs` array, and in the absence of any customisation the menu item will have a text label sourced from the `viewtab.tabid.title` i18n property, as before.

Note however that the title property **should not** now include a placeholder for adding badges, but should be the simple text title.

If you wish to implement more complex logic for rendering your tab title, you can implement a `_{tabId}MenuItem()` handler action.

The handler action will receive as its `args` the following:

* `objectName`
* `recordId`
* `tabId` - the tabId of the menu item
* `currentTab` - the tabId of the currently selected tab
* `subMenuItems` - an array of the items child items, which will have been built first

A menu item has the following base structure:

* `link` _string_ Target link of the menu item.
* `title` _string_ Label of the menu item, defaults to the `viewtab.tabid.title` i18n property
* `badge` _string_ Content of a badge to be shown after the menu title - could be text or numeric. Defaults to empty string (no badge)
* `badgeClass` _string_ One of "success", "warning", "danger" or "error", defining the colour of the badge. Defaults to empty string (blue info badge).
* `active` _boolean_ is this the currently selected tab?
* `display` _boolean_ whether this menu item should be displayed in the sidebar
* `open` _boolean_ whether a menu with children should be open on page load. Defaults to true if one of its children is the active page, otherwise false
* `submenuItems` _array_ an array of similarly structured menu items

The handler action should then return a struct of the items to be modified, which will be merged with the base item. For example:

```luceescript
private struct function _bookingsMenuItem( event, rc, prc, args={} ) {
	if ( !isFeatureEnabled( "bookings" ) ) {
		return { display=false }; // The menu item will not be displayed
	}

	// Return a record count as the badge content, which will be combined
	// with the default values that have been generated automatically
	var bookingsCount = bookingsService.getBookingsCount( args.recordId ?: "" );
	return {
		badge = bookingsCount
	};
}
```

#### Nested menu items

Nested menu structures can be defined in `variables.tabs` by including structs:

```luceescript
variables.tabs = [
	  "default"
	, "activity"
	, { id="paymentsmenu", children=[ "orders","invoices","payments" ] }
];
```

Child menu items and their parent items are customised just the same as any other menu. The only caveat is that the parent is simply a menu toggle to hide/reveal its children - it does not have a link action of its own.

Menus can be nested at multiple levels, so a child menu item could have its own children.


#### Sidebar header

If you are displaying sidebar navigation, you can also define a header panel to appear at the top of the sidebar, above the menu.

This might display, for example, a contact's name, photo and basic contact info, and will be shown on all tab pages for the object.

The header is defined by adding a `renderSidebarHeader()` method to your datamanager object, which should return a string value - the rendered sidebar header. An empty string will result in no header being displayed.

```luceescript
private string function renderSidebarHeader( event, rc, prc, args={} ) {
	// Do not display the record title at the top of the main content panel,
	// as we will be including it in this header
	prc.displayPageHeader  = false;

	// Add one or more classes to the containing <header> element
	// to make targeted styling easier
	prc.sidebarHeaderClass = "crm-sidebar-header";

	// render a list of tags to be passed through to the view
	args.renderedTags = renderContent(
		  renderer = "crmTagsList"
		, data     = ""
		, context  = [ "adminview", "admin" ]
		, args     = {
			  objectName = "crm_contact"
			, recordId   = args.record.id
			, maxRows    = 3
			, class      = "sidebar-header-tags"
		}
	);

	// return the rendered view
	return renderView( view="/admin/datamanager/crm_contact/_sidebarHeader", args=args );
}
```


### Permissioning

In addition to improving the view record screen, the base object gives you a standard implementation of the `checkPermission()` customization. Set `variables.permissionBase` in your pseudo constructor to automatically map the data manager operations:

* `read`
* `add`
* `edit`
* `delete`
* `clone`

i.e. if you set a base of `payments`, then permission check keys will look like `payments.read`, `payments.add` and so on.

If you do not set `variables.permissionBase`, the base will default to the object name. However, this default behaviour can be customised by setting up by adding a custom method `getPermissionBaseFromObjectName()` to `/handlers/admin/datamanager/GlobalCustomizations.cfc`, e.g.:

```luceescript
private string function getPermissionBaseFromObjectName( event, rc, prc, args={} ) {
	return ReReplaceNoCase( args.objectName, "^crm_", "" );
}
```

The above would remove `crm_` from the beginning of any object name to create the permission base; but you could have more complex logic in here if required.
