---
id: formcontrol-captcha
title: "Form control: Captcha"
---

The `captcha` form control renders a Google ReCaptcha (v2) control.

Note that the name of the Captcha field is irrelevant - this is just used internally to attach validation errors. Validation is done automatically, as part of the standard form validation.

If Captcha keys have not been set up for the site, then the control will simply not be displayed (and it will not try to validate it).

### Arguments

<div class="table-responsive">
    <table class="table">
        <tbody>
            <tr>
                <th>theme (optional)</th>
                <td>Available values are <code>light</code> (default) or <code>dark</code></td>
            </tr>
            <tr>
                <th>size (optional)</th>
                <td>Available values are <code>normal</code> (default) or <code>compact</code></td>
            </tr>
        </tbody>
    </table>
</div>

### Example

```xml
<field name="captcha" control="captcha" theme="dark" size="compact" label="Are you human?" />
```