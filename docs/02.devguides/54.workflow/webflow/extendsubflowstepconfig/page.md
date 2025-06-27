---
id: webflowextendsubflowstepconfig
title: "Webflows How-To: Extend subflow step configuration"
---

## How-To: Extend subflow step configuration

The subflow step configuration form will be shared across any webflow that implements the subflow; you can extend the subflow step configuration in the individual webflow's settings.

To define the configuration form: `forms > webflow > {your subflow id} > {subflow step id}.config.xml`

Example:
```
<?xml version="1.0" encoding="UTF-8"?>
<form i18nBaseUri="webflow.subflow.pixl8crmLoginRegister:">
	<tab id="default">
		<fieldset id="buttons">
			<field name="register_button_label" deleted="true" />
		</fieldset>
		<fieldset id="registration" deleted="true" />
	</tab>
	<tab id="config">
		<fieldset id="config">
			<field name="enable_registration" deleted="true" />
		</fieldset>
	</tab>
</form>
```