---
id: datamanager-customization-geteverythingbaractions
title: "Data Manager customization: getEverythingBarActions"
---

## Data Manager customization: getEverythingBarActions

The `getEverythingBarActions` customization registers extra actions on the listing everything bar. Use it when typed text should do something other than record search — for example, send the query to an endpoint that returns a [[rulesengine|rules engine]] expression.

The method must return an **array** of action definitions. Core is unaware of any particular integration; it only renders the actions, POSTs to an optional endpoint, and ANDs the returned expression into listing ajax as an extra filter (not as `sSearch`).

Arguments in `args`:

* `listingKey`: listing preference key for this table
* `allowFilter`: whether rules-engine listing filters are enabled
* `allowSearch`: whether record search is enabled

Each action:

* `id` (required)
* `icon`: Font Awesome icon name, default `magic`
* `labelUri` / `label`: `{1}` is replaced with the typed query
* `requireQuery`: default `true` (hide the action when the input is empty, like search)
* `endpoint`: optional admin URL for the generic ajax path
* `chipIcon`: optional icon for the resulting extra-filter chip

Register globally with `admin.datamanager.GlobalCustomizations`, or per object with `admin.datamanager.{object}`. An interceptor can also append via `postRunCustomization`.

```luceescript
// /application/handlers/admin/datamanager/GlobalCustomizations.cfc
component {

	private array function getEverythingBarActions( event, rc, prc, args={} ) {
		if ( !args.allowFilter ) {
			return [];
		}

		return [{
			  id           = "askFilter"
			, icon         = "magic"
			, labelUri     = "myextension:listing.askFilter"
			, requireQuery = true
			, endpoint     = event.buildAdminLink( linkTo="myextension.listingAskFilter" )
		}];
	}

}
```

The generic ajax path POSTs `{ object, listingKey, query }` and expects JSON `{ ok, label, expression }`. `expression` must be rules-engine JSON in the same shape as the advanced filter builder. On success, core shows a removable extra-filter chip and ANDs it into `sFilterExpression` after the view/advanced filter and before column heading filters. Extra chips stay removable on a locked named view.

Do not write extra filters into `[name=filter]` from the ajax path. When the user saves a listing view, extra expressions are folded into that view's `advancedFilter` snapshot.

For richer UX (loading copy, a confirm step), skip `endpoint` and register a JS runner instead:

```javascript
$( document ).on( "preside.listing.everythingBar", function( e, bar ) {
	PresideEverythingBar.actions.askFilter = function( item ) {
		// async work, then:
		bar.addExtraFilter( {
			  id         : item.id
			, label      : "Generated filter"
			, icon       : item.chipIcon || "magic"
			, expression : [ /* rules-engine JSON */ ]
		} );
		bar.close();
		bar.onChange();
	};
} );
```

Helpers on the bar instance: `addExtraFilter()`, `removeExtraFilter()`, `clearExtraFilters()`, `getExtraFilters()`, `getQuery()`, `close()`.
