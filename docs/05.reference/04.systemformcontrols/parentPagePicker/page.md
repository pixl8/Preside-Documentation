---
id: formcontrol-parentPagePicker
title: "Form control: Site tree page picker"
---

The `parentPagePicker` is a utility form control that is an extension of the [[formcontrol-siteTreePagePicker|site tree page picker control]].

In addition to the regular site tree page picker, this control will set the `childPage` option for you based on the value of `rc.id`. i.e. use this form control in an "edit page" screen where the page ID is in the url so that users can only pick valid parent pages for the current page.

### Arguments

See [[formcontrol-siteTreePagePicker]].

### Example

```xml
<field name="parent_page" control="parentPagePicker" />
```