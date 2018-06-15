---
id: datamanager-customization-listingmultiactions
title: "Data Manager customization: listingMultiActions"
---

## Data Manager customization: listingMultiActions

The `listingMultiActions` customization allows you to completely override the buttons that appear when a user selects multiple rows in a regular listing table. It should return a string containing the rendered buttons.

Note: the buttons that appear here rely on some javascript to turn into something useful for the subsequent request. Each button should be of type `submit` and have a unique `name` that will be sent to the next request as the value of `rc.multiAction`. Customize in conjunction with the [[datamanager-customization-multirecordaction|multiRecordAction]] customization that can process the result.

See also: [[datamanager-customization-getlistingmultiactions|getListingMultiActions]] and 
[[datamanager-customization-getextralistingmultiactions|getExtraListingMultiActions]].


For example:


```luceescript
// /application/handlers/admin/datamanager/GlobalDefaults.cfc
component {

	private string function listingMultiActions( event, rc, prc, args={} ) {
		return renderView( view="/admin/datamanager/_myCustomMultiActions", args=args );
	}

}
```

```lucee
<!--- /application/views/admin/datamanager/_myCustomMultiActions.cfm --->

<cfoutput>
	<button class="btn btn-danger confirmation-prompt" type="submit" name="delete" disabled="disabled" data-global-key="d" title="Archive the selected entities">
			<i class="fa fa-trash-o bigger-110"></i>
			Archive selected entities
		</button>
</cfoutput>
```