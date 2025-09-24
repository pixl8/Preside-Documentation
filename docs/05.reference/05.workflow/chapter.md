---
id: cfflowreference
title: Reference documentation for Preside's CfFlow workflow implementations
---

## Workflow reference

### CfFlow Extensions and implementations

[CfFlow](https://pixl8.github.io/cfflow) is an abstract framework. Preside provides concrete classes and implementations to bring the engine to life within the framework. The following references pages detail the baseline extensions and implementations that are used by webflow and datamanager workflows and might be used by your own cfflow extensions within Preside:

* [[cfflow-conditions]]
* [[cfflow-functions]]
* [[cfflow-scheduler]]
* [[cfflow-storage]]
* [[cfflow-tokenproviders]]
* [[cfflow-workflowclass]]

### Webflow Schemas

[CfFlow](https://pixl8.github.io/cfflow) itself has JSON schemas for defining CfFlow worklows. In addition, Preside adds its Webflows schema. This allows developers to define Preside Webflows in a relatively slim yml/json schema compared with the full CfFlow Schema. The pages below detail these schemas.

* [[webflowschema-condition]]
* [[webflowschema-handler]]
* [[webflowschema-init]]
* [[webflowschema-prepostaction]]
* [[webflowschema-instrefconfig]]
* [[webflowschema-step]]
* [[webflowschema-webflow]]
* [[webflowschema-webflowsubflow]]

### Datamanager Workflow Schemas

As with webflow, preside adds its own Data manager workflow schema that simplifies the cfflow schema to remain focused on datamanager workflows and the problems that it solves. This allows developers to define data manager workflows in a relatively slim yml/json schema compared with the full CfFlow Schema. The pages below detail these schemas.

* [[datamanagerworkflowschema-action]]
* [[datamanagerworkflowschema-condition]]
* [[datamanagerworkflowschema-conditionalresult]]
* [[datamanagerworkflowschema-handler]]
* [[datamanagerworkflowschema-initialaction]]
* [[datamanagerworkflowschema-join]]
* [[datamanagerworkflowschema-permission]]
* [[datamanagerworkflowschema-result]]
* [[datamanagerworkflowschema-step]]
* [[datamanagerworkflowschema-workflow]]