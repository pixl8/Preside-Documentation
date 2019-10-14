---
id: workingwiththericheditor
title: Working with the richeditor
---

## Overview

Preside uses [CKEditor](http://ckeditor.com/) for its richeditor.

Beyond the standard install, Preside provides custom plugins to interact with the CMS such as inserting images and documents from the Asset Manager, linking to pages in the site tree, etc. It also allows you to customize and configure the editor from your CFML code.

## Configuration

Default settings and toolbar sets can be configured in your site's `Config.cfc`. For example:

```luceescript
public void function configure() {
    super.configure();

    // ...

    settings.ckeditor = {};

    // default settings
    settings.ckeditor.defaults = {
          stylesheets           = [ "/css/admin/specific/richeditor/" ] // array of stylesheets to be included in editor body
        , configFile            = "/ckeditorExtensions/config.js"       // path is relative to the compiled assets folder
        , width                 = "auto"                                // default width of the editor, in pixels if numeric
        , minHeight             = 0                                     // minimum height of the editor, in pixels if numeric
        , maxHeight             = 300                                   // maximum autogrow height of the editor, in pixels if numeric
        , toolbar               = "full"                                // default toolbar set, see below
        , autoParagraph         = false                                 // should single-line content be wrapped in a <p> element
        , extraAllowedContent   = "img dl dt dd"                        // additional elements allowed in the editor (will not be stripped from source)
        , pasteFromWordDisallow = [                                     // elements to be stripped when pasting from Word
              "span"  // Strip all span elements
            , "*(*)"  // Strip all classes
            , "*{*}"  // Strip all inline-styles
          ]
    };

    // toolbar sets, see further documentation below
    settings.ckeditor.toolbars = {};
    settings.ckeditor.toolbars.full = 'Maximize,-,Source,-,Preview'
                                   & '|Cut,Copy,Paste,PasteText,PasteFromWord,-,Undo,Redo'
                                   & '|Find,Replace,-,SelectAll,-,Scayt'
                                   & '|Widgets,ImagePicker,AttachmentPicker,Table,HorizontalRule,SpecialChar,Iframe'
                                   & '|Link,Unlink,Anchor'
                                   & '|Bold,Italic,Underline,Strike,Subscript,Superscript,-,RemoveFormat'
                                   & '|NumberedList,BulletedList,-,Outdent,Indent,-,Blockquote,CreateDiv,-,JustifyLeft,JustifyCenter,JustifyRight,JustifyBlock,-,BidiLtr,BidiRtl,Language'
                                   & '|Styles,Format,Font,FontSize'
                                   & '|TextColor,BGColor';

    settings.ckeditor.toolbars.boldItalicOnly = 'Bold,Italic';
}
```

### Configuring toolbars

Preside uses a light-weight syntax for defining sets of toolbars that translates to the full CKEditor toolbar definition. The following two definitions are equivalent:

**CKEditor config.js**

```js
CKEDITOR.editorConfig = function( config ) {
    config.toolbar = "mytoolbar";

    config.toolbar_mytoolbar = [
        [
            [ 'Source', '-', 'NewPage', 'Preview', '-', 'Templates' ],                     // Defines toolbar group, '-' indicates a vertical divider within the group
            [ 'Cut', 'Copy', 'Paste', 'PasteText', 'PasteFromWord', '-', 'Undo', 'Redo' ], // Defines another toolbar group
            '/',                                                                           // Line break - next group will be placed in new line.
            [ 'Bold', 'Italic' ]                                                           // Defines another toolbar group
        ]
    ];
};
```

**Config.cfc equivalent**

```luceescript
public void function configure() {
    super.configure();

    // ...

    settings.ckeditor.defaults = {
        , toolbar = "mytoolbar"
    };

    // in the Preside version of the toolbar configuration, toolbar groups
    // are simply comma separated lists of buttons and dividers. Toolbar groups
    // are then delimited by the pipe ('|') symbol.
    settings.ckeditor.toolbars.mytoolbar = 'Source,-,NewPage,Preview,-,Templates'
                                        & '|Cut,Copy,Paste,PasteText,PasteFromWord,-,Undo,Redo'
                                        & '|/'
                                        & '|Bold,Italic';

    // the above toolbar string all on one line: 'Source,-,NewPage,Preview,-,Templates|Cut,Copy,Paste,PasteText,PasteFromWord,-,Undo,Redo|/|Bold,Italic'
}
```

#### Specifying non-default toolbars for form fields

You can define multiple toolbars in your configuration and then specify which toolbar to use for individual form fields (if you do not define a toolbar, the default will be used). An example, using a Preside form definition:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form>
    <tab>
        <fieldset>
            <field name="description" control="richeditor" toolbar="boldItalicOnly" label="widgets.mywidget:description.label"  />
        </fieldset>
    </tab>
</form>
```

You can also define toolbars inline:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form>
    <tab>
        <fieldset>
            <field name="description" control="richeditor" toolbar="Bold,Italic,Underline|Cut,Copy,Paste,PasteText,PasteFromWord,-,Undo,Redo" label="widgets.mywidget:description.label"  />
        </fieldset>
    </tab>
</form>
```

### Configuring stylesheets

The stylesheets configuration effects how content within the editor is displayed during editing. You will likely want to include your site's core styles so that the WYSIWYG experience is as close to the final product as possible.

Default stylesheets are configured as an array of stylesheet includes (see Config.cfc example above). Each item in the array will be expanded as a [Sticker](https://github.com/pixl8/sticker) include resource. For example:

```luceescript
settings.ckeditor.defaults.stylesheets = [ "/specific/richeditor/", "/core/", "bootstrap-css" ];
```

#### Specifying non-default stylesheets for form fields

You can define specific stylesheets for individual form controls by supplying a comma separated list:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form>
    <tab>
        <fieldset>
            <field name="description" control="richeditor" stylesheets="/specific/myCustomEditorStyles/,/core/" label="widgets.mywidget:description.label" />
        </fieldset>
    </tab>
</form>
```

### Configuring a custom CKEditor config file

For the most flexible configuration tweaking, you can define your own CKEditor `config.js` file:

```js
settings.ckeditor.defaults.configFile = "/path/to/my/custom/config/file.js"; // relative to your root assets folder
```

You can also define this inline:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form>
    <tab>
        <fieldset>
            <field name="description" control="richeditor" customConfig="/path/to/my/custom/config/file.js" label="widgets.mywidget:description.label" />
        </fieldset>
    </tab>
</form>
```

>>> The default configuration file can be found at `/preside/system/assets/ckeditorExtensions/config.js`


## Where the code lives (for maintainers and contributers)

We manage a custom build of the editor, including all the core plugins that we require, through our [own repository on GitHub](https://github.com/pixl8/Preside-Editor). In addition, any Preside specific extensions to the editor are developed and maintained in the [core repository](https://github.com/pixl8/Preside-CMS), they can be found at: `/system/assets/ckeditorExtensions`.

Finally, we have our own custom javascript object for building instances of the editor. It can be found at `/system/assets/js/admin/core/preside.richeditor.js`.

## Customizing the link picker

The richeditor link picker can be customized (as of 10.11.0). Key concepts:

* Link types
* Link Picker categories

### Link types

Link types are visible in the link picker as a list on the left hand side of the dialog. Examples are 'Site tree page', 'URL', etc.

As of 10.11.0, you are able to create your own link types. To do so, you will require the following:

#### 1. Properties file entry

An entry in `/i18n/cms.properties` matching the pattern: `ckeditor.linkpicker.type.{yourtype}`. This will be the title of your link type.

#### 2. Customize the core richeditor link form

Supply your own [[form-richeditorlinkform|/forms/richeditor/link.xml]] file that will **add a fieldset with the id of your link type to the 'basic' tab.**. For example:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<form>
    <tab id="basic">
        <fieldset id="yourtype" sortorder="100">
            <field name="article" control="objectpicker" object="article" />
        </fieldset>
    </tab>
</form>
```

#### 3. Create handler for rendering link + default link title

Create a handler at, `/handlers/admin/linkpicker/yourtype.cfc`. It needs to implement _two_ methods. One to render the HREF of the link, the other to render default link text. Each handler method will receive the filled in link form data as its `args` struct. For example:

```luceescript
component {

    private string function getHref( event, rc, prc, args={} ) {
        return event.buildLink( articleid=args.article ?: "" );
    }

    private string function getDefaultLinkText( event, rc, prc, args={} ) {
        return renderLabel( "article", args.article ?: "" );
    }
}
```

#### Link Picker categories

Link picker categories can be applied to a richeditor instance to customize the link types that appear in the link picker. For example, you may have a richeditor for a wiki page that requires only a custom "Wiki" link type, and not the others.

Link picker categories are defined as a struct at `settings.ckeditor.linkPicker`. Each key is the id of a category and is defined as a struct with a single `types` key, an array of Link types.

The default Preside config defines a default category:

```luceescript
settings.ckeditor.linkPicker.default = {
    types = [ "sitetreelink", "url", "email", "asset", "anchor" ]
}
```

You can customize this by appending to the list of types (or removing items from it). You can also then define your own categories:

```
settings.ckeditor.linkPicker.wiki = { types=[ "wikipage" ] };
```

Finally, an instance of a richeditor can be assigned a link picker category with the `linkPickerCategory` attribute:

```<field name="content" control="richeditor" linkPickerCategory="wiki" />```