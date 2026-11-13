---
id: draftmanager
title: Draft Manager
---

## Introduction

The Draft Manager allows Data Manager records to exist in two states: live and draft.

It is intended for content that requires review, preview, or iteration before being published. Editors can work on drafts without affecting live content, making changes safer and more controlled.

Draft Manager is opt in and must be explicitly enabled.

## Enable draft manager for an object

Draft manager support is disabled by default for Data Manager objects.

To enable it, add the `draftManagerEnabled` annotation to the object definition.

```luceescript
/**
 * @draftManagerEnabled true
 */
component {
}
```

## Building and customizing previews

Draft Manager supports custom preview actions in the Draft Manager action menu.

To add one or more preview buttons, implement getDraftPreviewActionButtons() in your object specific Data Manager admin handler.

```luceescript
// /handlers/admin/datamanager/article.cfc
component extends="preside.system.base.AdminHandler" {

	private array function getDraftPreviewActionButtons( event, rc, prc, args={} ) {
		return [
			{
				  title     = "Preview"
				, link      = event.buildLink( linkTo="..." )
				, iconClass = "fa-globe"
				, btnClass  = "btn-default"
				, target    = "_blank"
			}
		]
	}

}
```