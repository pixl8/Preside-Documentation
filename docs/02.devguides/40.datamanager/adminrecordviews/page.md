---
id: adminrecordviews
title: Admin record views
---

## Overview

As of **Preside 10.9.0**, the admin system comes with a framework for displaying single records through the data manager. An example might look like this:

![Screenshot showing example data view](images/screenshots/presidedataview.jpg)

This view is automatically available to any object that is managed in the data manager and will display fields and relationships of a record, grouped into configurable display boxes. The display groups, sort order and renderers for fields are all fully customizable. You are even able to use your own handler entirely for displaying a record.

## Customizing the view screen

### View groups and columns

One of the first features you might want to customize is the grouping of fields in the default view of a record for your object.

The standard groups are `default` and `system` and these will appear in your view with core Preside fields in the `system` "box" and everything else in the `default` "box". By default, the `default` group's title will be the name of the object, will have a sort order of `1`, and be positioned in the `left` column; the system group will have a sort order of `1` and be positioned in the `right` column:

![Screenshot showing example data view with standard groups](images/screenshots/adminviewStandardGroups.jpg)

#### Assign a property to a group

To assign a property to a particular view group, use the `adminViewGroup` attribute on the `property` definition, e.g.

```luceescript
// category.cfc
component {
	property name="label" adminViewGroup="system";
}
```

The above change to our object would lead to a grouping as below:

![Screenshot showing example data view with only a system group](images/screenshots/adminviewOnlySystemGroup.jpg)

#### Creating and customizing groups

A group is automatically registered as soon as it is referenced by the `adminViewGroup` attribute on a property. For instance, if we wanted to add a new `many-to-many` `posts` property on category and assign it to a group named 'posts', we could do so:


```luceescript
// category.cfc
component {
	property name="label" adminViewGroup="system";
	property name="posts" adminViewGroup="posts" relationship="many-to-many" relatedto="blog_post" relatedvia="blog_post_category";
}
```

![Screenshot showing example data view with a custom group](images/screenshots/adminviewCustomGroup.jpg)

We can then use convention to give the group a translatable name, icon, column and sort order. Add the following keys to the corresponding `.properties` file for you object:

```properties
viewgroup.{groupname}.title=A group title
viewgroup.{groupname}.iconClass=fa-icon
viewgroup.{groupname}.sortorder=2
viewgroup.{groupname}.column=right
```

For example, in our `category.properties` file:

```properties
# /application/i18n/preside-objects/category.properties

# ...

viewgroup.posts.title=Posts
viewgroup.posts.iconClass=fa-file-text-o
viewgroup.posts.column=left
viewgroup.posts.sortorder=1


viewgroup.system.title=Category
viewgroup.system.iconClass=fa-tag
viewgroup.system.column=right
viewgroup.system.sortorder=2
```

Leads to:

![Screenshot showing example data view with a custom group decorated with custom labelling](images/screenshots/adminviewCustomGroupWithLabels.jpg)

#### Omit field label for many-to-many fields

To omit a property's field label, use the `displayPropertyTitle` attribute on the `property` definition, e.g.

```luceescript
// category.cfc
component {
	...
	property name="posts" ... displayPropertyTitle=false;
}
```

![Screenshot showing example data view with property field title is hidden](images/screenshots/adminviewPropertyTitleHidden.png)

### Field renderers

Each field is rendered using a regular Preside content renderer with a context of `[ "adminview", "admin" ]` (if the renderer has a `adminview` context, use that, if not, use `admin`, if not, use `default`). In addition, the renderer viewlet is passed `objectName`, `propertyName`, and `recordId` in the `args` struct so that it can do things like render a datatable showing related records filtered by the current record.

For the most part, you should not need to customize the renderers here and a sensible default will be chosen.

#### Assigning a renderer

To assign a renderer to a property specifically for admin record views, use the `adminRenderer` attibute:

```luceescript
property name="label" adminrenderer="richeditor";
```

If you do not specify an `adminRenderer` but you _do_ specify a general renderer with the `renderer` attribute, the `renderer` value will be used:

```luceescript
property name="label" renderer="richeditor";
property name="something" renderer="richeditor" adminRenderer="none";
```

>>> A renderer value of `none` will mean that the property will not be displayed at all.

#### Creating a custom renderer

Content renderers are viewlets that live at `renderers.content.{renderername}.{context}`. To create a specific admin record view renderer named `myrenderer`, you could create a handler CFC with the following:

```luceescript
// /handlers/renderers/content/MyRenderer.cfc
component {

	private string function adminView( event, rc, prc, args={} ) {
		var value         = args.data         ?: "";
		var objectName    = args.objectName   ?: "";
		var propertyName  = args.propertyName ?: "";
		var recordId      = args.recordId     ?: "";

		return _doSomethingToValue( value, ... );
	}
}
```

Alternatively, the renderer could be just a view at `/views/renderers/content/myRenderer/adminView.cfm`:

```lucee
<cfparam name="args.data"         default="" />
<cfparam name="args.objectName"   default="" />
<cfparam name="args.propertyName" default="" />
<cfparam name="args.recordId"     default="" />

<!--- obviously do more than this... --->
<cfoutput>#args.data#</cfoutput>
```

### Property sort orders

The order of properties within an admin view defaults to the order of definition of the properties within the `.cfc` file. However, you can influence the sort order by adding a `sortOrder` attribute (which will also be the default sort order for the field in form layouts):

```luceescript
property name="title" sortorder=20;
property name="blog" sortorder=10;
// etc.
```

### Richeditor preview layout

The `richeditor` content renderer uses a special iFrame to display the rendered content in a full HTML layout. The purpose of this is to allow you to load front-end CSS and show the content as it would appear in the front end site.

The default preview layout provided by Preside will load the CSS defined to be used within your ckeditor instances with the `settings.ckeditor.defaults.stylesheets` setting. To change this, define your own layout in your application folder at `/application/layouts/richeditorPreview.cfm`. Use the following core layout as a starting point to customize:

```lucee
<cfscript>
	stylesheets = getSetting( name="ckeditor.defaults.stylesheets", defaultValue=[] );
	if ( IsArray( stylesheets ) ) {
		for( var stylesheet in stylesheets ) {
			event.include( stylesheet );
		}
	}

	css         = event.renderIncludes( "css" );
	js          = event.renderIncludes( "js" );
	content     = args.content ?: "";
</cfscript>

<cfoutput><!DOCTYPE html>
<html lang="en" class="richeditor-preview presidecms">
	<head>
		<meta charset="utf-8" />
		<meta name="robots" content="NOINDEX,NOFOLLOW" />
		<meta name="description" content="" />
		<meta name="viewport" content="width=device-width, initial-scale=1.0" />

		#css#
	</head>

	<body>
		#content#
		#js#
	</body>
</html></cfoutput>
```

### Other ways to customize the view

As of **Preside 10.24.0**, the admin system provides an alternative system to the default view record screen, detailed in [[enhancedrecordviews]].

In [[customizingdatamanager]], there are full details of how you can customize the Data Manager either globally, or per object. The following customizations relate to the view screen and allow you to either completely override the rendering of the view screen, or add HTML to various areas:

* [[datamanager-customization-renderrecord|renderRecord]]
* [[datamanager-customization-prerenderrecord|preRenderRecord]]
* [[datamanager-customization-prerenderrecordleftcol|preRenderRecordLeftCol]]
* [[datamanager-customization-prerenderrecordrightcol|preRenderRecordRightCol]]
* [[datamanager-customization-postrenderrecordleftcol|postRenderRecordLeftCol]]
* [[datamanager-customization-postrenderrecordrightcol|postRenderRecordRightCol]]
* [[datamanager-customization-postrenderrecord|postRenderRecord]]

