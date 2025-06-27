---
id: webflowsubflowconfig
title: "Webflows How-To: Define subflow configuration"
---

## How-To: Define subflow configuration

The subflow configuration form will be shared across any webflow that implements the subflow; you can personalize the config in the individual webflow's settings.

To define the configuration form: `forms > webflow > subflow > {your subflow id} > config.xml`

Example:
```
<?xml version="1.0" encoding="UTF-8"?>
<form i18nBaseUri="webflow.subflow.pixl8crmLoginRegister:">
	<tab id="default">
		<fieldset id="loginRegisterSetting" sortorder="15">
			<field name="alt_layout" control="enumSelect" enum="loginLayoutOptions" sortorder="10" />
		</fieldset>
	</tab>
</form>
```