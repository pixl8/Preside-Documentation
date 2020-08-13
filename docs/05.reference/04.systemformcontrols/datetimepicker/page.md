---
id: formcontrol-datetimepicker
title: "Form control: Date and Time Picker"
---

The `dateTimePicker` control allows users to choose a date and time from a calendar popup with extra time picker.

### Arguments

<div class="table-responsive">
    <table class="table">
        <tbody>
            <tr>
                <th>minDate (optional)</th>
                <td>Minimum allowed date</td>
            </tr>
            <tr>
                <th>maxDate (optional)</th>
                <td>Maximum allowed date</td>
            </tr>
            <tr>
                <th>defaultDate (optional)</th>
                <td>Default date to choose when opening the picker for the first time. Defaults to the current day at midnight (00:00)*.<br>
                <strong>*As of 10.13.0</strong>, the time part is set using defaultTime.</td>
            </tr>
            <tr>
                <th>defaultTime (optional)</th>
                <td><strong>Added in 10.13.0:</strong> Default time to choose when opening the picker for the first time. Defaults to midnight (00:00).<br>
                Can either be a 24-hour time (e.g. "17:00"), or "now" to use the current time.</td>
            </tr>
            <tr>
                <th>relativeToField (optional)</th>
                <td>Related Date Picker field</td>
            </tr>
            <tr>
                <th>relativeOperator (optional)</th>
                <td>Operator to be used when comparing related Date Picker field. Valid Operators are: lt, lte, gt, gte</td>
            </tr>
        </tbody>
    </table>
</div>

### Example

```xml
<field name="start_date" control="datetimepicker" relativeToField="end_date" relativeOperator="lte"/>
<field name="end_date" control="datetimepicker" relativeToField="start_date" relativeOperator="gte"/>
```

![Screenshot of a date and time picker](images/screenshots/dateTimePicker.png)

