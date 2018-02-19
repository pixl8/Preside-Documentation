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

