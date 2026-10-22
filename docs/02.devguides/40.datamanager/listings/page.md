---
id: datamanagerlistings
title: Data Manager listings
---

## Introduction

Preside listings have been rebuilt around **DataTables 3**. The old search box and filter strip are replaced by a single **everything bar**. Users can show, hide and reorder columns, filter from column headings, and save named **views** (filters plus columns).

This page is the developer guide for that change: what broke, what is on by default, and what you should tweak per object or per embedded table.

The annotation and `objectDataTable()` reference still lives in [[datamanagerbasics]] and [[customizingdatamanager]]. Customization points are listed at the end.

## What changed (react to this)

Check these first when upgrading an application or extension:

1. **Custom DataTables JavaScript** still using `fnServerParams`, `sAjaxSource`, `aoColumns` or `$table.dataTable({ ... })` with Hungarian options. Core listings go through a compatibility adapter, but new tables should use DataTables 3 options (`ajax`, `columns`, `serverSide`, …). Prefer `PresideDatatables.hungarianAjax()` if you still POST the old `sEcho` / `iDisplayStart` payload.
2. **Search UI**. There is no standalone `.data-table-search` / `dataTables_filter` on core listings. Search is the everything bar. If you injected extra buttons next to the old search input, move them to [[datamanager-customization-geteverythingbaractions|getEverythingBarActions]] or the listing top-right buttons.
3. **Default columns in the picker**. Objects that omit `@datamanagerColumnPickerFields` now use **`auto`**, not “grid fields only”. Users will see more columns than before unless you tighten the pool (see [Available columns](#available-columns)).
4. **No columns are locked** unless you set `@datamanagerLockedGridFields`. The label column is not fixed by default; users can hide it.
5. **Saved views** are on for non-compact listings that have a column picker. Turn them off per object or per table if that does not make sense (see [Saved views](#saved-views)).
6. **Listing footers** that return a **string** still work (one cell). If users can hide columns, prefer a **mapped** footer keyed by field name so totals stay under the right column (see [Footers](#footers)).
7. **Compact / related-record tables** (`compact=true`, including view-record related listings) keep the old, simpler table: no column picker, no heading filters, no saved views.

## Available columns

`@datamanagerGridFields` is still the **default visible** set (what a user sees before they change anything). The **picker pool** is a larger list: grid fields, hidden grid fields, then `@datamanagerColumnPickerFields` (or the application default).

### Object annotations

```luceescript
/**
 * @datamanagerEnabled              true
 * @datamanagerGridFields           label,status,category,datecreated
 * @datamanagerHiddenGridFields     notes
 * @datamanagerColumnPickerFields   auto,!internal_notes
 * @datamanagerLockedGridFields
 * @datamanagerAllowSavedViews      true
 */
component {
	property name="status"         type="string"  dbtype="varchar" maxlength=20;
	property name="notes"          type="string"  dbtype="varchar" maxlength=200;
	property name="internal_notes" type="string"  dbtype="text"    excludeDataExport=true;
}
```

* `@datamanagerGridFields` — default columns on the table.
* `@datamanagerHiddenGridFields` — in the picker, off until the user turns them on.
* `@datamanagerColumnPickerFields` — extra pool. Accepts `auto`, `*` wildcards and `!` exclusions (`auto,!internal_notes`, `*,!sensitive_*`).
* `@datamanagerLockedGridFields` — always visible, always first, cannot be hidden or reordered. **Empty by default.**

Grid fields, hidden grid fields and search fields stay in the pool even when `auto` would skip them.

### What `auto` includes

`auto` is the default when the object has no `@datamanagerColumnPickerFields` and you have not changed `settings.dataManager.defaults.columnPickerFields`. It **skips**:

* The ID field (`id` or the object's `getIdField()`)
* Properties whose name starts with `_`
* Unbounded text (`text`, `longtext`, …) and binary / blob `dbtype`s, and `type="text"` / `type="binary"`
* `excludeDataExport=true` and `autofilter=false` (unless you opt the property back in)
* `one-to-many`, `many-to-many` and `select-data-view` relationships
* Secret, encrypted, password and `renderer=none` / `adminRenderer=none` fields

Many-to-one relationships and formula fields **are** included in `auto` (formula fields still do not get a heading filter).

### Property flags

```luceescript
property name="notes"         type="string" dbtype="longtext" datamanagerUserColumn=true;
property name="internal_code" type="string" dbtype="varchar"  datamanagerUserColumn=false;
```

* `datamanagerUserColumn=true` — put the field in the picker even when `auto` would skip it.
* `datamanagerUserColumn=false` — keep it out of the picker even if a wildcard would include it.

### Application default

```luceescript
// /application/config/Config.cfc
settings.dataManager.defaults.columnPickerFields = "auto"; // core default
settings.dataManager.defaults.columnPickerFields = "";     // picker = grid + hidden grid fields only
settings.dataManager.defaults.columnPickerFields = "*";    // every listable field
```

Per-object `@datamanagerColumnPickerFields` always wins.

### Replacing the pool in a handler

```luceescript
// /application/handlers/admin/datamanager/blog_post.cfc
component {

	private array function getAvailableListingColumns( event, rc, prc, args={} ) {
		return [ "title", "status", "published", "datemodified" ];
	}

	private array function getDefaultListingColumns( event, rc, prc, args={} ) {
		return [ "title", "status", "published" ];
	}

}
```

* `getAvailableListingColumns` — replace the picker pool. Explicit `gridFields` / `hiddenGridFields` passed into that table are still merged in.
* `getDefaultListingColumns` — replace the default **visible** columns (`args.defaultFields` is the annotated grid field list).

## Saved views

A view is a named snapshot of **filters + columns**. It does not store free-text search, sort order or page length.

**Default on** when the table has a column picker and is not compact. **Default off** for compact tables.

```luceescript
/**
 * @datamanagerAllowSavedViews false
 */
```

Or for one embedded table only:

```luceescript
objectDataTable( objectName="blog_post", args={
	  allowSavedViews = false
} );
```

Passing `allowSavedViews=true` on a compact table has no effect.

### Permissions

Anyone who can use the listing can save a **personal** view. Sharing globally or with a group needs CMS permission `datamanager.sharelistingviews` (included in `datamanager.*`).

### Behaviour to know about

* Named views **lock** the filters they own until the user chooses **Edit view**. Extra search and extra everything-bar filters can still be added on top.
* Columns can be shown, hidden or reordered on a locked view; those column changes are **not** written to the view unless the user is editing it.
* The implicit **Default** view is annotated grid fields and no saved filters.

## Listing context

Column layout and the last selected view are stored per user, listing and **context**.

If you list the same object in more than one place with different meaning (subscriptions for a product, corporate vs individual, …), set a labelled context on that table. The save form then asks whether the view applies to **this context** or **all listings of the object**.

```luceescript
// /application/handlers/admin/datamanager/crm_subscription.cfc
component {

	private string function listingViewlet( event, rc, prc, args={} ) {
		args.listingContextKey   = prc.recordId ?: "all";
		args.listingContextLabel = prc.recordLabel ?: "";

		return renderViewlet( event="admin.datamanager._objectListingViewlet", args=args );
	}

}
```

* `listingContextKey` — stable machine id (max 100 characters; longer keys are hashed).
* `listingContextLabel` — shown in the save form. If it contains `:`, it is treated as an i18n URI.

If you omit the key, Preside derives context from the listing ajax URL query string (cache-busters stripped). Extra parameters from [[datamanager-customization-getadditionalquerystringforbuildajaxlistinglink|getAdditionalQueryStringForBuildAjaxListingLink]] are included, so two listings that already differ by query string get separate prefs without extra work.

`listingPreferenceKey` only separates **named views** when the same object appears twice on one screen. It does not replace listing context.

## Column heading filters

Heading filters follow the picker pool and also need `allowFilter` (rules engine listing filters). They are off for compact tables.

They are **not** created for formula fields, `autofilter=false`, many-to-many, one-to-many, or `renderer=none`. Many-to-one columns get an object picker plus a saved-filter picker for the related object. Enums get the enum options.

## Footers

[[datamanager-customization-renderfooterforgridlisting|renderFooterForGridListing]] still accepts a **string** (shown in the first footer cell). That layout does not track hidden or reordered columns.

When the column picker is on, return a **struct** (or array of row structs) keyed by field name. Core places each cell under the matching visible column and drops cells whose column is hidden.

```luceescript
private any function renderFooterForGridListing( event, rc, prc, args={} ) {
	return {
		  labelField = "label"
		, label      = "Totals"
		, cells      = {
			  status   = NumberFormat( args.records.recordCount )
			, amount   = { html=NumberFormat( 1234.5, "9,999.99" ), className="text-right" }
		  }
	};
}
```

* `label` / `labelField` — put the label in that column when it is visible; otherwise the first data column.
* `cells.{field}` — string HTML, or `{ html, className }`.
* Multiple rows: `{ rows=[ { label, cells, labelField }, ... ] }` or a raw array of those structs.

`args` still includes `records` and `getRecordsArgs` (current search and filters).

## Everything bar extras

To add an action that uses the typed query (for example “Ask AI” that returns a rules-engine expression), implement [[datamanager-customization-geteverythingbaractions|getEverythingBarActions]]. Extra chips stay removable on a locked view; when the user saves a view, extra expressions are folded into that view’s `advancedFilter`.

Do not write extra filters into `[name=filter]` from your ajax handler.

## Embedded tables

```luceescript
objectDataTable( objectName="blog_post", args={
	  compact              = false
	, allowColumnPicker    = true
	, allowColumnFilter    = true
	, allowSavedViews      = true
	, listingPreferenceKey = "blog_post_editorial"
	, listingContextKey    = "corporate"
	, listingContextLabel  = "crm.subscription:listing.context.corporate"
	, hiddenGridFields     = [ "notes" ]
} );
```

| Arg | Default | Notes |
| --- | --- | --- |
| `compact` | `false` on main listings; `true` on related-record tables | Forces picker, heading filters and views **off** |
| `allowColumnPicker` | on unless compact | Show / hide / reorder |
| `allowColumnFilter` | on unless compact | Also requires `allowFilter` |
| `allowSavedViews` | follows picker unless `@datamanagerAllowSavedViews` is set | Compact always off |
| `listingContextKey` / `listingContextLabel` | derived from ajax query string | Labelled identity for prefs and views |
| `listingPreferenceKey` | object name | Isolates named views on the same screen |

Override `listingViewlet` and pass the same `args` through to `admin.datamanager._objectListingViewlet` if you only need to set context or flags, rather than replacing the whole listing.

## Custom DataTables (extensions)

Admin `$().dataTable({ bServerSide, sAjaxSource, fnServerParams, ... })` is mapped to DataTables 3 automatically. New code should call `.DataTable()` with camelCase options.

If you still talk to a Preside ajax listing that expects Hungarian POST fields:

```javascript
ajax : PresideDatatables.hungarianAjax( datasourceUrl, function( params, dtRequest ) {
	params.sSearch = $( ".my-search" ).val();
} )
```

Do **not** use DataTables 1.x `fnServerParams` on a table that is already using `ajax` / `PresideDatatables.hungarianAjax` — that combination throws at runtime.

## Related documentation

* [[datamanagerbasics]] — object annotations
* [[customizingdatamanager]] — `objectDataTable()` args and customization index
* [[datamanager-customization-listingviewlet|listingViewlet]]
* [[datamanager-customization-renderfooterforgridlisting|renderFooterForGridListing]]
* [[datamanager-customization-geteverythingbaractions|getEverythingBarActions]]
* [[datamanager-customization-getadditionalquerystringforbuildajaxlistinglink|getAdditionalQueryStringForBuildAjaxListingLink]]
* [[datamanager-customization-prefetchrecordsforgridlisting|preFetchRecordsForGridListing]]
