---
id: formcontrol-objectPicker
title: "Form control: Object Picker"
---
The `objectPicker` control allows users to select one or multiple records from a given preside object. Configuration options also allow you to add new records and edit existing records from within the form control.
### Arguments
<div class="table-responsive">
    <table class="table">
        <tbody>
            <tr>
                <th>object (required)</th>
                <td>Name of the object whose records the user can select</td>
            </tr>
            <tr>
                <th>ajax (optional)</th>
                <td>True (default) or false. Whether or not to fetch records for the picker using Ajax.</td>
            </tr>
            <tr>
                <th>objectFilters (optional)</th>
                <td>String list of saved preside object filters. See [[dataobjects]]</td>
            </tr>
            <tr>
                <th>prefetchUrl (optional)</th>
                <td>When ajax is set to "true", you can additionally supply a specific URL for fetching records to pre-populate the drop down</td>
            </tr>
            <tr>
                <th>remoteUrl (optional)</th>
                <td>When ajax is set to "true", you can additionally supply a specific URL for fetching records to match typed searches</td>
            </tr>
            <tr>
                <th>useCache (optional)</th>
                <td>True (default) or false. Whether to use caching when selecting data for this form field and its respective ajax lookup and prefetch.</td>
            </tr>
            <tr>
                <th>orderBy (optional)</th>
                <td>Specify which column(s) to sort the select list on. Default is "label", which sorts alphabetically on the text displayed in the picker.</td>
            </tr>
            <tr>
                <th>placeholder (optional)</th>
                <td>Message to appear prompting the user to search for records</td>
            </tr>
            <tr>
                <th>multiple (optional)</th>
                <td>True of false (default). Whether or not to allow multiple record selection</td>
            </tr>
            <tr>
                <th>sortable (optional)</th>
                <td>True or false (default). Whether or not to allow multiple selected records to be sortable within the control.</td>
            </tr>
            <tr>
                <th>searchable (optional)</th>
                <td>True (default) or false. Whether or not the search feature of the control is enabled.</td>
            </tr>
            <tr>
                <th>resultTemplate (optional)</th>
                <td>A Mustache template for rendering items in the drop down list. The default is "{{text}}". This can be used in conjunction with a custom remote URL for providing a highly customized object picker.</td>
            </tr>
            <tr>
                <th>selectedTemplate (optional)</th>
                <td>A Mustache template for rendering selected items in the control. The default is "{{text}}". This can be used in conjunction with a custom remote URL for providing a highly customized object picker.</td>
            </tr>
            <tr>
                <th>quickAdd (optional)</th>
                <td>True of false (default). Whether or not the quick add record feature is enabled. If enabled, you should create a /forms/preside-objects/(objectname)/admin.quickadd.xml form that will be used in the quick add dialog.</td>
            </tr>
            <tr>
                <th>quickAddUrl (optional)</th>
                <td>If quickAdd is enabled, you can additionally set a custom URL for providing the quick add form.</td>
            </tr>
            <tr>
                <th>superQuickAdd (optional, 10.10.38 and above)</th>
                <td>True of false (default). Whether or not the <em>super</em> quick add record feature is enabled. The super quick add feature allows you to add records inline when the search text
                entered does not exactly match any existing records. <strong>Note: the target object must be enabled for data manager.</strong></td>
            </tr>
            <tr>
                <th>superQuickAddUrl (optional, 10.10.38 and above)</th>
                <td>If superQuickAdd is enabled, you can additionally set a custom URL for processing the super quick add request. The URL will receive a POST request with a <code>value</code> field and should return a json object with <code>text</code> (<em>label</em>) and <code>value</code> (<em>id</em>) fields.</td>
            </tr>
            <tr>
                <th>quickEdit (optional)</th>
                <td>True of false (default). Whether or not the quick edit record feature is enabled. If enabled, you should create a /forms/preside-objects/(objectname)/admin.quickadd.xml form that will be used in the quick edit dialog.</td>
            </tr>
            <tr>
                <th>quickEditUrl (optional)</th>
                <td>If quickEdit is enabled, you can additionally set a custom URL for providing the quick edit form.</td>
            </tr>
            <tr>
                <th>bypassTenants (optional)</th>
                <td>A comma separated list of tenants to <strong>ignore</strong> when populating the dropdown. See [[data-tenancy]].</td>
            </tr>
            <tr>
                <th>filterBy (optional)</th>
                <td>An optional comma separated list of fields to filter the selectable data on. These fields can be present in either the form, URL parameters, or in any data set using event.includeData().</td>
            </tr>
            <tr>
                <th>filterByField (optional)</th>
                <td>An optional comma separated list of database field names to correspond with the fields defined in the filterBy attribute. Only necessary when the database fieldnames differ from the field names used to get the values for the filter.</td>
            </tr>
            <tr>
                <th>disabledIfUnfiltered (optional)</th>
                <td>true or false and only to be used in conjunction with the filterBy attribute. If true and the filterBy field(s) are empty, the control will be disabled until the field(s) have value.</td>
            </tr>
        </tbody>
    </table>
</div>

### Example
```xml
<field name="categories" control="objectPicker" object="blog_category" multiple="true" sortable="true" quickAdd="true" quickEdit="true" />
```
### Example with caching disabled
```xml
<field name="categories" useCache="false" control="objectPicker" object="blog_category" multiple="true" sortable="true" quickAdd="true" quickEdit="true" />
```
![Screenshot of object picker](images/screenshots/objectPicker.png)
