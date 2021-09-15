---
id: formcontrol-enumSelect
title: "Form control: Enum select"
---

The `enumSelect` control is an extension of the [[formcontrol-select]] form control, automatically populating the select control with options from the supplied enum.

### Arguments

<div class="table-responsive">
    <table class="table">
        <tbody>
            <tr>
                <th>enum (required)</th>
                <td>Name of the enum to get values from</td>
            </tr>
        </tbody>
    </table>
</div>

### Example

```xml
<field name="type" control="enumSelect" enum="eventType" />
```
