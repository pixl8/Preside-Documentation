---
id: customizing-deletion-prompt-matches
title: "Customizing the delete record prompt and match text"
---

## Summary

As of **10.16.0**, you are able to configure objects to use a "match" text in the delete prompt. You can configure both application-wide default behaviour, and object-level overrides for the default.

![Screenshot of a delete record prompt](images/screenshots/deleteprompt.png)

## Configuring application defaults

### Enabling/disabling the match text

There are two **Config.cfc** settings that control whether or not match text must be input:

```luceescript
// default values supplied by Preside
settings.dataManager.defaults.typeToConfirmDelete      = false;
settings.dataManager.defaults.typeToConfirmBatchDelete = true;
```

So by _default_, we _will_ prompt to enter a matching text when _batch_ deleting records, but _not_ while deleting _single_ records. Update the settings above to change this behaviour.

### Customizing the global match text

Two i18n entries are used for the match text. To change them, supply your own application/extension overrides of the properties:

```properties
# /i18n/cms.properties
datamanager.delete.record.match=delete
datamanager.batch.delete.records.match=delete
```

## Per object customisation

### Enabling/disabling the match text

To have an object use a non-default behaviour, annotate the object cfc file with the `datamanagerTypeToConfirmDelete` and/or `datamanagerTypeToConfirmBatchDelete` flags:

```luceescript
/**
 * @datamanagerTypeToConfirmDelete      true
 * @datamanagerTypeToConfirmBatchDelete true
 *
 */
component {
	// ...
}

```

### Customizing per-object match text

You have two approaches available here, static i18n match text and dynamically generated text for single record deletes.

#### Static i18n

In your object's `.properties` file (i.e. `/i18n/preside-objects/my_object.propertes`), implement the property keys `delete.record.match` and/or `batch.delete.records.match`. i.e.

```properties
# ...

delete.record.match=CONFIRM
batch.delete.records.match=DO IT
```

#### Dynamic match text for single record deletes

To create dynamic match text per record, use the datamanager customisation: [[datamanager-customization-getdeletionconfirmationmatch|getDeletionConfirmationMatch]] (see guide for more details).




