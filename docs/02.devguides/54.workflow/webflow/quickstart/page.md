---
id: webflowquickstart
title: "Webflows: Quick start tutorial"
---

## Webflows Quick start tutorial

**NOTE:** The following tutorial assumes you have a running Preside application running Preside 10.30 or higher.

### 1. Define a webflow

Webflows are added to the "library" by convention. Copy and paste the file below into a file at `{webroot}/application/workflow/webflows/tutorial.yml` (all `yml` files under `/workflow/webflows/` directory will automatically be imported from extensions and your application):

```yaml
version: 1.0.0
webflow:
  id: webflowtutorial
  singleton: true
  steps:
  - id: introduction
  - id: aform
  - id: alternativeending
    finish: true
    condition:
      ref: bool.IsTruthy
      args:
        value: $aformfield
  - id: ending
```

Next, copy and paste the following into `{webroot}/application/i18n/webflow/webflowtutorial.properties` (convention is `/i18n/webflow/{webflowid}.properties`):

```properties
title=TUTORIAL: Webflow tutorial

step.introduction.label=Introduction
step.introduction.description=A step to allow you to introduce the flow to your users (this is just an example)

step.aform.label=Step with form
step.aform.description=A step with a form in it to show form processing

step.alternativeending.label=An alternative ending
step.alternativeending.description=A final step to show conditional step logic

step.ending.label=Default ending
step.ending.description=The default final page where the flow ends
```

That's it, the extension will register this webflow with the id `webflowtutorial`.

### 2. Configuring the webflow and steps

Reload your application, log in to the admin and visit the following URL (you may be able to find it via navigation): `/{adminpath}/datamanager/object/?id=webflow_configuration`.

From the table of webflows, you should see a `TUTORIAL: Webflow tutorial` entry. Click on it and you should see something like this:

![Figure 1: Webflow admin screen](images/screenshots/webflow-admin-screen.png)

#### i. Configure the webflow itself

Click on the green **Edit** button on the top right of the screen. You will be presented with a form with the following sections:

* **Internal title/description**: As it says, this is for internal use only. The title will be prepopulated from i18n.
* **Eligibility**: Here, editors can enter a message to show for users who do not meet any [[webflowschema-init|init conditions]] defined on the flow. We haven't defined any yet so its not relevant here.
* **Timeout**: Editors can configure idle timeouts for users within a flow. The default is currently 20 minutes. In addition, they can customize the message that shows to users who have timed out.

Make some changes and save the form. You should be taken back to the screen in **figure 1**, above.

#### ii. Configuring steps

Next, click into each step to edit it. What you see may depend on the step you enter:

* **Title and copy**: You'll see this for all steps. Editors can change the title, a short title (that can appear in a flow progress bar) and introductory text.
* **Navigation buttons**: Depending on the position of the step in the flow, you may be able edit the text that appears on the **Next** and **Back** buttons for flow navigation.

Make some changes and hit save.

### 3. Output and use the flow

Create a new view file at `{webroot}/application/views/webflowtutorial.cfm` with the following content:

```lucee
<cfoutput>
    <div class="container">
        #renderWebflow( "webflowtutorial" )#
    </div>
</cfoutput>
```

Reload your application and visit `/webflowtutorial/`. What you see will depend on your application layout, of course. But you should see the first step title and intro copy you entered + a next button.

Hit the next button and see how you can journey through the webflow steps until you get to the end.

Remove any query string params from the URL to get back to `/webflowtutorial/`, you'll notice that you can go through the flow again from the start. Play with going back after step 2 and clicking the "progress bar" link (might appear as a plain ordered list, depending on your site's pre-existing css).

### 4. Add a form

Copy and paste the following form file into `{webroot}/application/forms/webflow/webflowtutorial/aform.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form i18nBaseUri="webflow.webflowtutorial:step.aform.">
    <tab id="default">
        <fieldset id="default" sortorder="10">
            <field name="aformfield" control="select" values="true,false" labels="Yes,No" />
        </fieldset>
    </tab>
</form>
```

> Tip: Notice how this is a convention: `/forms/webflow/{webflowid}/{stepid}.xml`.

Let's also add some i18n to our `/i18n/webflow/webflowtutorial.properties` file:

```properties
# ...

step.aform.field.aformfield.title=Do you like alternative endings?
```

Reload the application and run through the flow. You should notice that on step 2, you get a form field. Choosing different options should mean that you finish on one of two alternative end steps.

### 5. Add a step display viewlet

Being able to supply a convention based form for a step is really useful. But sometimes you will need more power and flexibility. Here, we will add a viewlet into the `aform` step.

Copy and paste the following file into `{webroot}/application/handlers/webflow/WebflowTutorial.cfc`:

```luceescript
component {

    private string function aform( event, rc, prc, args={}, wfInstance ) {
        return renderView( view="/webflow/webflowTutorial/aform", args=args );
    }

}
```

Then, paste the following in to a view file at `{webroot}/application/views/webflow/webflowtutorial/aform.cfm`:

```lucee
<cfoutput>
    #( args.renderedForm ?: "" )#

    <div class="form-field">
        <label>
            Tutorial input:
            <input name="custom_input" placeholder="type 'tutorial' here to continue">
        </label>
    </div>
</cfoutput>
```

Reload your application and journey through the flow again. You should notice that you have an extra input in our `aform` step. Of course, you can do much more here. Custom javascript, etc. Now let's add some processing to make the `type "tutorial" here to continue` actually work.

### 6. Add a step submission handler

We can add logic to the handling of a form step submission. In this case we'll use it to add some custom validation for our new text input. Edit your `{webroot}/application/handlers/webflow/WebflowTutorial.cfc` file to add the `aformAction` handler:

```luceescript
component {

    private string function aform( event, rc, prc, args={}, wfInstance ) {
        return renderView( view="/webflow/webflowTutorial/aform", args=args );
    }

    private void function aformAction( event, rc, prc, args={}, wfInstance, persistData, validationResult ) {
        var customInputValue = ( rc.custom_input ?: "" );
        if ( customInputValue != "tutorial" ) {
            validationResult.setGeneralMessage( "Please type in 'tutorial' in the box below to continue" );
        }

        // note: any validation errors set will result in the journey being
        // halted and the user being returned to the step they just submitted.
        // You can also achieve this by return 'false' from this method

		// The persistData argument is a struct combining all the data from the
		// form submission (with defaults and preprocessed fields), combined with
		// any other data received in the rc scope. You can modify this, and the
		// resulting persistData will be persisted to the state on success, or
		// passed back to the calling page on validation failure.
    }

}
```

Reload the application and journey through the flow, testing that you can only complete the flow by entering 'tutorial' in the custom input box.

### 7. Add custom step configuration for editors

Let's make the 'password' editable by administrators. We'll also make the label of the form field from our main form editable. Again, we'll use convention to achieve this. Create a new form xml file at: `{webroot}/application/forms/webflow/webflowtutorial/aform.config.xml` (convention is `/forms/webflow/{webflowid}/{stepid}.config.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form i18nBaseUri="webflow.webflowtutorial:step.aform.config.">
    <tab id="config" sortorder="20">
        <fieldset id="config" sortorder="10">
            <field name="custom_input_password" control="textinput" sortorder="10" />
        </fieldset>
    </tab>
    <tab id="forms" sortorder="30">
        <fieldset id="formfields" sortorder="40">
            <!-- notice the convention here, you can make
                form field labels, placeholders, etc.
                editorial by supplying config field names
                with the convention below
            -->
            <field name="form.field.aformfield.label" control="textinput"  sortorder="10" />
        </fieldset>
    </tab>
</form>
```

**Note:** this form will be merged with the Preside's [[form-webflowconfigurationstepbaseeditform|step configuration form]]

Add some i18n to `/i18n/webflow/webflowtutorial.properties`:

```properties
# ...

step.aform.config.tab.config.title=Configuration
step.aform.config.tab.config.iconclass=fa-cogs grey
step.aform.config.tab.forms.title=Form fields
step.aform.config.tab.forms.iconclass=fa-check-square orange

step.aform.config.field.custom_input_password.title=Step password
step.aform.config.field.custom_input_password.placeholder=e.g. 'tutorial' (default)

step.aform.config.field.form.field.aformfield.label.title=Alternative endings label
step.aform.config.field.form.field.aformfield.label.placeholder=e.g. Do you like alternative endings?
```

Reload the application and edit the step through the admin interface. You should see something like:

![Figure 2: Custom configuration 1](images/screenshots/webflow-admin-configure-step-screen-1.png)

![Figure 3: Custom configuration 2](images/screenshots/webflow-admin-configure-step-screen-2.png)

Put in custom configuration for both new config options and test the flow. You'll notice that the form field label has changed, but the actual 'password' for getting past the step has not.

#### i. Add code to handle custom config

Edit the view at `{webroot}/application/views/webflow/webflowtutorial/aform.cfm`:

```lucee
<cfset pw  = args.password     ?: "tutorial" />
<cfset frm = args.renderedForm ?: ""         />
<cfoutput>
    #frm#

    <div class="form-field">
        <label>
            Tutorial input:
            <input name="custom_input" placeholder="type '#pw#' here to continue">
        </label>
    </div>
</cfoutput>
```

Edit the handler at `{webroot}/application/handlers/webflow/WebflowTutorial.cfc`:

```luceescript
component {

    private string function aform( event, rc, prc, args={}, wfInstance ) {
        args.password = args.stepConfig.custom_input_password ?: "";
        if ( !Len( Trim( args.password ) ) ) {
            args.password = "tutorial";
        }
        return renderView( view="/webflow/webflowTutorial/aform", args=args );
    }

    private void function aformAction( event, rc, prc, args={}, wfInstance, validationResult, stepConfig ) {
        var customInputValue = ( rc.custom_input ?: "" );
        var password = stepConfig.custom_input_password ?: "";
        if ( !Len( Trim( password ) ) ) {
            password = "tutorial";
        }

        if ( customInputValue != password ) {
            validationResult.setGeneralMessage( "Please type in '#password#' in the box below to continue" );
        }
    }

}
```

### 8. Perform actions before and after steps

The flow we have defined is pretty useless. You can go from start to finish, but nothing actually happens. We will edit our webflow yml file to add some actions. In `{webroot}/application/workflow/webflows/tutorial.yml`:


```yaml
version: 1.0.0
webflow:
  id: webflowtutorial
  singleton: true
  steps:
  - id: introduction

  # add a post action that only fires when 'password' matches
  - id: aform
    postactions:
    - direction: forward # this is default, and not required, options are 'forward', 'back' and 'both'
      handler:
        event: webflow.webflowtutorial.postFormAction
      condition:
        ref: string.IsEqual
        args:
          value: $custom_input
          pattern: $webflow.step.aform.config.custom_input_password

  # add a pre action, that will fire before transitioning to this final step
  - id: alternativeending
    finish: true
    condition:
      ref: bool.IsTruthy
      args:
        value: $aformfield
    preactions:
    - direction: forward  # this is default, and not required, options are 'forward', 'back' and 'both'
      handler:
        event: webflow.webflowtutorial.alternativeEndingAction

  - id: ending
```

Now, edit your `WebflowTutorial.cfc` _handler_, adding the actions we just defined:

```luceescript
component {

    // ...

    private void function postFormAction( event, rc, prc, wfInstance ) {
        log file="webflowtutorial" text="I just performed postFormAction";
    }

    private void function alternativeEndingAction( event, rc, prc, wfInstance ) {
        log file="webflowtutorial" text="I just performed alternativeEndingAction";
    }

    // ...
}
```

Reload your application and proceed through the flow. Check your logs to confirm the actions were performed.

### 9. Conclusion

That's it! You have successfully completed the Webflows quick start tutorial. Hopefully you now have a good grounding in understanding of **what they are** and **how to develop and maintain** them.