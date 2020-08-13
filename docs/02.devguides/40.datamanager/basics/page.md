---
id: datamanagerbasics
title: Data Manager Basics
---

## Introduction

This page will take you through the basic default set up and configuration of [[datamanager]] for a [[dataobjects|Preside data object]]. By the end of this guide, you should be comfortable creating a basic admin CRUD interface for an object within the main Data Manager user interface.

## Data Manager homepage

The Data Manager homepage in the Preside administrator displays all of the objects in the system **that have been configured to display within Data Manager**. Objects are organised into groups and are searchable (by object name). Clicking on an object will take you into that object's listing screen.


![Screenshot showing example of a Data Manager object listing screen](images/screenshots/datamanager-listing-screen.png)

### Get your object listed in the Data Manager homepage

In order for your object to appear in the Data Manager homepage, your `.cfc` file must be annotated with the `@datamanagerGroup` annotation. For example:

```luceescript
// /application/preside-objects/author.cfc

/**
 * @datamanagerGroup blog
 * @labelfield       name
 */
component {
	property name="name" type="string" dbtype="varchar" maxlength="200" required=true uniqueindexes="name";
}
```

That is all there is to it. You now how a full CRUD interface for your object. However, you probably want to make things a little more user friendly with regards to human readable and translatable labels; see below.

### Translatable and human readable labels

Each Preside Object should have a corresponding `.properties` file that will provide title, description, optional icon class and entries for each field in your object. The file must live at: `/i18n/preside-objects/myobject.properties`. For example:

```properties
# /application/i18n/preside-objects/author.properties
title=Authors
title.singular=Author
description=Authors of blog posts
iconclass=fa-user

field.name.title=Author Name
```

#### Translate title base on context

As 10.12, context had introduced to Preside Object title properties. Object listing view is using `listing` context, you able to have different field label in the listing table by adding `field.{field_name}.listing.title`. For example:

```properties
field.product_id.title=Product ID
field.product_id.listing.title=#
```

You also able to add help text for the listing table. For example:

```properties
field.product_id.listing.help=Product ID
```

![Screenshot showing example of a Data Manager object listing screen with overwrite label](images/screenshots/datamanager-listing-overwrite-label-example.png)

>>>>>> _See [[presideforms-i18n]] for more conventions for field names, placeholders, help, etc._

Each Data Manager **group** should also have a corresponding `.properties` file at `/i18n/preside-objects/groups/groupname.properties`. For our blog example:

```properties
# /application/i18n/preside-objects/groups/blog.properties
title=Blogs
description=Data related to blogs
iconclass=fa-comments
```

## Basic customizations for the listing grid

There are four basic customizations that can be achieved with simple annotations on your preside object `.cfc` file:

1. Change the fields that are displayed in the table
2. Change the _default_ sort order of records
3. Change the sortable fields in the table
4. Change the fields that are searchable

In addition, limiting the _operations_ that are allowed on an object will affect the actions that appear on each row (see **Limiting operations**, below).

To specify a non-default list of fields to display in the table, use the `@datamanagerGridFields` annotation.

To specify a default sort order for the table, use the `@datamanagerDefaultSortOrder` annotation.

To specify a non-default list of fields to sortable in the table, use the `@datamanagerSortableFields` annotation.

To specify a non-default list of fields that are _searchable_ in the table, use the `@datamanagerSearchFields` annotation.

For example:


```luceescript
// /application/preside-objects/author.cfc

/**
 * @labelfield                  name
 * @datamanagerGroup            blog
 * @datamanagerGridFields       name,post_count,datemodified
 * @datamanagerSortableFields   name,post_count
 * @datamanagerSearchFields     name,posts.title
 * @datamanagerDefaultSortOrder post_count desc
 */
component {
	property name="name" type="string" dbtype="varchar" maxlength="200" required=true uniqueindexes="name";
	property name="posts" relationship="one-to-many" relatedto="blog_post" relationshipkey="blog_author";
	property name="post_count" type="numeric" formula="Count( ${prefix}posts.id )";
}
```

## Customizing the listing grid header label

There is a `listing` context available when translate property name for listing grid header.

To specify a label for listing grid, add `field.{your_field}.listing.title=Listing label` in corresponding object i18n file.

Optional tooltip can be added to listing grid header field, add `field.{your_field}.listing.help=Listing label help` in corresponding object i18n file.

## Customizing the add / edit record forms

The Data Manager uses convention-based form names to build add and edit forms for your object. Prior to 10.9.0, these were:

* Add form: `/forms/preside-objects/objectname/admin.add.xml`
* Edit form: `/forms/preside-objects/objectname/admin.edit.xml`

As of Preside 10.9.0, you are also able to create a _single form_ that will be used as both **add** _and_ **edit**:

* Default form: `/forms/preside-objects/objectname.xml`

If you do not supply any form `.xml` definitions at all, the system will build a default form based on the `.cfc` definition. In many cases, particularly for simple objects, this will suffice.

Any **Preside object forms** that are defined beneath `/forms/preside-objects` will have a default i18n base URI of `preside-objects.objectname:`. This means that you can define all your convention based form field, tab and fieldset labels for your forms in your preside object's `.properties` file. See See [[presideforms-i18n]] for more information on form labeling conventions.

>>> See [[presideforms]] for full documentation on Preside's forms system.

## Versioning & Drafts

By default, preside objects are versioned (this can be turned off per object by adding the `@versioned false` annotation on the `.cfc` file. All versioned objects will automatically get a versioning user interface within Data Manager. In addition, you can turn on _drafts_ capability for your versioned objects by adding the `@datamanagerAllowDrafts` annotation to your object, for example:

```luceescript
// /application/preside-objects/author.cfc

/**
 * @labelfield                  name
 * @datamanagerGroup            blog
 * @datamanagerGridFields       name,post_count,datemodified
 * @datamanagerSearchFields     name,posts.title
 * @datamanagerDefaultSortOrder post_count desc
 * @datamanagerAllowDrafts      true
 */
component {
	property name="name" type="string" dbtype="varchar" maxlength="200" required=true uniqueindexes="name";
	property name="posts" relationship="one-to-many" relatedto="blog_post" relationshipkey="blog_author";
	property name="post_count" type="numeric" formula="Count( ${prefix}posts.id )";
}
```

## Limiting operations

The system defines eight core "operations" that can be "performed" on any given object record:

1. `read`: view an individual record in the view record screen
2. `add`: add new records
3. `edit`: edit records
4. `batchedit`: batch edit records (as of 10.12.0)
5. `delete`: delete a record
6. `batchdelete`: batch delete records (as of 10.12.0)
7. `clone`: clones a record (as of 10.10.0)
8. `viewversions`: view version history for a record

All operations are enabled by default. To limit the operations that are allowed for an object, use either the `@datamanagerAllowedOperations` or `@datamanagerDisallowedOperations`annotations, supplying a comma separated list without spaces of the operations that are allowed/disallowed. For example, we could disable deleting and the view screen for our blog authors with:

```luceescript
// /application/preside-objects/author.cfc

/**
 * @labelfield                      name
 * @datamanagerGroup                blog
 * @datamanagerDisallowedOperations delete,read
 */
component {
	property name="name" type="string" dbtype="varchar" maxlength="200" required=true uniqueindexes="name";
}
```

## Allowing records to be translated

The Data Manager comes with a basic user interface to allow translation of records. See [[multilingualcontent]] for how configure this feature and enable this per object.

## Displaying records in a tree view

>>> This feature is available since version 10.9.0

For hierarchical data, you can choose to show the listing screen as a tree by using the following attributes on your object:

* `@datamanagerTreeView`: True / false - whether or not to use tree view
* `@datamanagerTreeParentProperty`: The self referencing foreign key property that creates the hierarchical relationship
* `@datamanagerTreeSortOrder`: What field(s) to sort on when displaying the children of a node

For example:

```luceescript
// /application/preside-objects/article.cfc

/**
 * @labelfield                    title
 * @datamanagerTreeView           true
 * @datamanagerTreeParentProperty parent_article
 * @datamanagerTreeSortOrder      title
 *
 */
component {
	property name="parent_article" relationship="many-to-one" relatedto="article";

	property name="title" type="string" dbtype="varchar" maxlength=100 required=true;
	property name="body"  type="string" dbtype="text";
}
```
