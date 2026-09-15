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

## Column picker and per-column filters

Non-compact listing tables include a column picker (show, hide and reorder columns) and per-column heading filters. Both are on by default for the main Data Manager listing; they are off when the table is rendered with `compact=true` (for example, related-record tables on a view record screen).

The columns a user can pick from start as `@datamanagerGridFields` plus `@datamanagerHiddenGridFields`. Hidden grid fields are available in the picker but are not shown until the user turns them on.

Use `@datamanagerLockedGridFields` for columns that must stay visible and at the front of the table (they cannot be hidden or reordered). If you omit it, no columns are locked.

```luceescript
// /application/preside-objects/author.cfc

/**
 * @datamanagerGroup             blog
 * @datamanagerGridFields        name,post_count,datemodified
 * @datamanagerHiddenGridFields  email_address,website
 * @datamanagerLockedGridFields  name
 */
component {
	property name="name"          type="string" dbtype="varchar" maxlength="200" required=true uniqueindexes="name";
	property name="email_address" type="string" dbtype="varchar" maxlength="255";
	property name="website"       type="string" dbtype="varchar" maxlength="255";
	property name="post_count"    type="numeric" formula="Count( ${prefix}posts.id )";
}
```

To widen or narrow the picker pool without listing every field, use `@datamanagerColumnPickerFields`. The list accepts:

* `auto` — include a sensible default set of columns: skip the object's ID field; skip `text` / `longtext` (and other unbounded text or binary) fields; skip `excludeDataExport=true` and `autofilter=false` unless the property sets `datamanagerUserColumn=true`; skip `one-to-many`, `many-to-many` and `select-data-view` relationships; skip secret, encrypted, password and `renderer=none` fields
* `*` wildcards
* `!` exclusions, for example `auto,!internal_notes` or `*,!internal_notes`

Grid fields, hidden grid fields and search fields stay in the pool even when `auto` would otherwise skip them. Individual properties can opt in or out with `datamanagerUserColumn=true` / `datamanagerUserColumn=false`.

When an object omits `@datamanagerColumnPickerFields`, Preside uses the application default `settings.dataManager.defaults.columnPickerFields`, which is **`auto`**. Set it to an empty string to limit the picker to grid and hidden grid fields, or `*` if every listable field should be available:

```luceescript
// /application/config/Config.cfc
settings.dataManager.defaults.columnPickerFields = "*";
```

Per-object annotations still win over that global default.

Per-column heading filters follow the same field pool and also require rules-engine listing filters to be enabled for the table (`allowFilter`). Properties with `autofilter=false`, formula fields, many-to-many and one-to-many relationships do not get a column filter. Many-to-one columns use an object picker for related records and a saved-filter picker for filters of that related object.

A user's chosen column layout, and the view they last had selected, are stored per user, listing and **listing context**. By default that context is the table's ajax datasource query string (cache-buster parameters removed). Pass `listingContextKey` / `listingContextLabel` when two listings of the same object should be labelled and stored separately — for example corporate vs individual subscriptions, or subscriptions for a specific product. See [[customizingdatamanager]] for the listing `args` that turn the picker and filters on or off for a specific table.

## Saved listing views

A saved listing view is a named snapshot of the listing's **filters and columns**. It does not store free-text search, sort order, or page length. The implicit **Default** view is the object's annotated grid fields with no saved filters applied.

Saved views follow the column picker. If you omit `@datamanagerAllowSavedViews`, views are **on** when the table can edit columns (`allowColumnPicker`, which is true unless the listing is compact) and **off** otherwise. Set the annotation to `true` or `false` to override that default:

```luceescript
// /application/preside-objects/author.cfc

/**
 * @datamanagerGroup           blog
 * @datamanagerGridFields      name,post_count,datemodified
 * @datamanagerAllowSavedViews false
 */
component {
	property name="name" type="string" dbtype="varchar" maxlength="200" required=true uniqueindexes="name";
	property name="post_count" type="numeric" formula="Count( ${prefix}posts.id )";
}
```

Compact listings never show saved views, even when the annotation is `true`.

Users can save **personal** views without any extra permission. Sharing a view as global or with a user group requires the CMS permission `datamanager.sharelistingviews`. Roles that already have `datamanager.*` pick this up automatically.

When the table has a developer-supplied `listingContextLabel`, the save form also asks whether the view should apply to **all listings of this object** or **this context only**. Without a labelled context, that control is hidden and the view is stored against the derived datasource query string.

Named views lock the filters they own until the user chooses **Edit view**. Visible columns can still be shown, hidden or reordered at any time; those column changes are not saved onto the view unless it is being edited. Extra search and extra filters can still be added on top without changing the saved view.

To enable or disable views for a single embedded table (rather than the object's main listing), pass `allowSavedViews` to `objectDataTable()` / `_objectDataTable` — see [[customizingdatamanager]].

## Having record viewed in a modal popup

>>> As of **10.26.67** and **10.27.34**

You are able to specify that clicking the eye icon (view record) link in a grid listing results in a modal/popover view of the record rather than showing in a new page. This is great for records that have little value in navigating to view and where it makes sense to remain focused on the grid listing.

To enable this behaviour for your object, use the annotation `@datamanagerModalView true`. e.g.

```luceescript
// /application/preside-objects/log_detail.cfc

/**
 * @datamanagerEnabled           true
 * @datamanagerAllowedOperations view
 * @datamanagerModalView         true
 */
component {
	// ... etc.
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
