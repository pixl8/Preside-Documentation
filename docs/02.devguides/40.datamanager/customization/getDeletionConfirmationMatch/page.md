---
id: datamanager-customization-getdeletionconfirmationmatch
title: "Data Manager customization: getDeletionConfirmationMatch"
---

## Data Manager customization: getDeletionConfirmationMatch

As of **Preside 10.16.0**, the `getDeletionConfirmationMatch` customization allows you to supply dynamic runtime confirmation match text for the delete prompt. For example, you may want to ask users to type in the name record they are deleting to confirm deletion.

![Screenshot of a delete record prompt](images/screenshots/deleteprompt.png)

## Arguments

The method receives `args.record` - a struct containing details of the record that the user may delete.

## Example

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	property name="blogService" inject="blogService";

	private void function getDeletionConfirmationMatch( event, rc, prc, args={} ) {
		return args.record.label ?: "delete";
	}
}

```

See also: [[customizing-deletion-prompt-matches]]



