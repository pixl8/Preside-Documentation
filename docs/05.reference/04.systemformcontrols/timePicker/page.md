---
id: formcontrol-timePicker
title: "Form control: Time picker"
---

The `timePicker` control allows users to choose a time value from a special time picking interface.

### Arguments

<div class="table-responsive">
    <table class="table">
        <tbody>
            <tr>
                <th>defaultTime (optional)</th>
                <td><strong>Added in 10.13.0:</strong> Default time to choose when opening the picker for the first time. Defaults to midnight (00:00).<br>Can either be a 24-hour time (e.g. "17:00"), or "now" to use the current time.</td>
            </tr>
        </tbody>
    </table>
</div>

### Example

```xml
<field name="start_time" control="timePicker" defaultTime="09:00" />
<field name="end_time"   control="timePicker" defaultTime="17:00" />
```

