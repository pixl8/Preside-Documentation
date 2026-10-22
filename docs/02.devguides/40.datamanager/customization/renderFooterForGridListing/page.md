---
id: datamanager-customization-renderfooterforgridlisting
title: "Data Manager customization: renderFooterForGridListing"
---

## Data Manager customization: renderFooterForGridListing

>>> This feature was introduced in 10.11.0

The `renderFooterForGridListing` customization allows you to render footer content at the bottom of a dynamic data grid in the Data Manager. This may be to show a sum of certain fields based on the search and filters used, or just show a static message.

You may return:

* a **string** — shown in the first footer cell (legacy layout; does not follow hidden or reordered columns)
* a **struct** (or array of row structs) — cells keyed by field name, placed under the matching visible column. Prefer this when the listing has a column picker. See [[datamanagerlistings]].

* `objectName`: The name of the object
* `records`: The paginated records that have been selected to show
* `getRecordsArgs`: Arguments that were passed to [[datamanagerservice-getrecordsforgridlisting]], including filters

For example:


```luceescript
// /application/handlers/admin/datamanager/pipeline.cfc
component {

    property name="pipelineService" inject="pipelineService";

    private string function renderFooterForGridListing( event, rc, prc, args={} ) {
        var pr = pipelineService.getPipelineTotalReport(
              filter       = args.getRecordsArgs.filter       ?: {}
            , extraFilters = args.getRecordsArgs.extraFilters ?: []
            , searchQuery  = args.getRecordsArgs.searchQuery  ?: ""
            , gridFields   = args.getRecordsArgs.gridFields   ?: []
            , searchFields = args.getRecordsArgs.searchFields ?: []
        );

        return translateResource(
              uri  = "pipeline_table:listing.table.footer"
            , data = [ NumberFormat( pr.total ), NumberFormat( pr.adjusted ), pr.currencySymbol ]
        );
    }

}
```

When the listing has a column picker, return cells keyed by field so they stay under the matching column:

```luceescript
private any function renderFooterForGridListing( event, rc, prc, args={} ) {
	return {
		  labelField = "label"
		, label      = "Totals"
		, cells      = {
			  amount = NumberFormat( 1234.5, "9,999.99" )
		  }
	};
}
```