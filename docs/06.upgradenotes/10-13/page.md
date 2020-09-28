---
id: 10-13-upgrade-notes
title: Upgrade notes for 10.12 -> 10.13
---

## Form builder data model v2

The 10.13 release adds a new data model for form builder that offers a shared global library of questions and normalized data storage of answers. 

This feature must be enabled with `settings.features.formbuilder2.enabled=true` and will work out of the box once enabled.

However, if you have custom form builder item types, you may want to implement v2 features to ensure that they are stored optimally in the database and will work well with the new system. See:

* [renderV2ResponsesForDb()](//devguides/formbuilder/itemtypes.html#renderv2responsesfordb)
* [getQuestionDataType()](//devguides/formbuilder/itemtypes.html#getquestiondatatype)