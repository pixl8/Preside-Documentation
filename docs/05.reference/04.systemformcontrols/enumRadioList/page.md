---
id: formcontrol-enumSelect
title: "Form control: Enum select"
---

The `enumRadioList` control allows users to pick from the values of an enum, showing titles and descriptions of each item with a radio box to select.

### Arguments

<div class="table-responsive">
    <table class="table">
        <tbody>
            <tr>
                <th>enum (required)</th>
                <td>Name of the enum to get values from. Any enum from [[enums]], whether declared in configuration or registered at startup.</td>
            </tr>
        </tbody>
    </table>
</div>

### Example

```xml
<field name="type" control="enumRadioList" enum="eventType" />
```
