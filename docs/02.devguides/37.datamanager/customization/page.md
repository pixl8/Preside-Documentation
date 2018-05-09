---
id: customizingdatamanager
title: Customizing Data Manager
---

## Introduction

As of Preside 10.9.0, [[datamanager]] comes with a customization system that allows you to customize many aspects of the Data Manager both globally and per object. In addition, you are able to use all the features of Data Manager for your object **without needing to list your object in the Data Manager homepage**. This means that you can create your own custom navigation to your object and not need to write any further code to create your CRUD admin interface - perfect for building custom admin interfaces with dedicated navigation.

## Customization system overview

Customizations are implemented as convention based ColdBox _handlers_. Customizations that should be applied globally belong in `/handlers/admin/datamanager/GlobalCustomizations.cfc`. Customizations that should be applied to a specific object go in `/handlers/admin/datamanager/objectname.cfc`. For example, if you wish to supply customizations for a `blog_author` object, you would create a handler file: `/handlers/admin/datamanager/blog_author.cfc`.

The Data Manager implements a large number of customizations. Each customization will be implemented in your handlers as a **private** handler action. The return type (if any) and arguments supplied to the action will depend on the specific customization.

For example, you may wish to do some extra processing after saving an `employee` record using the `postEditRecordAction` customization:

```luceescript
// /application/handlers/datamanager/employee.cfc

component {

	// as this is a regular coldbox handler
	// we can use wirebox to inject and access our service layer
	property name="notificationService" inject="notificationService";

	private void function postEditRecordAction( event, rc, prc, args={} ) {
		// the args struct values will vary depending on the customization point.
		// in this case, we get new and old data (as well as many other fields)
		var newData    = args.formData       ?: {};
		var oldData    = args.existingRecord ?: {};
		var employeeId = args.recordId       ?: {}

		// here, as an example, we use the notification service to
		// raise a "Date of birth change" notification when the DOB changes
		if ( newData.keyExists( "dob" ) && newData.dob != oldData.dob ) {
			notificationService.createNotification( topic="DOBChange", type="info", data={ employeeId=employeeId } )
		}

		// of course, we could do anything we like here. For instance,
		// we could redirect the user to a different screen than the
		// normal "post-edit" behaviour for Data Manager.
	}

}
```

## Building and customizing links

With the new 10.9.0 customization system comes a new method of building data manager links for objects. Use `event.buildAdminLink( objectName=objectName )` along with optional arguments, `operation` and `recordId` to build various links. For example, to link to the data manager listing page for an object, use the following:

```luceescript
event.buildAdminLink( objectName=objectName );
```

To link to the default view for a record, use:

```luceescript
event.buildAdminLink( objectName=objectName, recordId=recordId );
```

To link to a specific page or action URL for an object or record, add the `operation` argument, e.g.

```luceescript
event.buildAdminLink( objectName=objectName, operation="addRecord" );
event.buildAdminLink( objectName=objectName, operation="editRecord", recordId=recordId );
// etc.
```

The core, "out-of-box" operations are:

* `listing`
* `viewRecord`
* `addRecord`
* `addRecordAction`
* `editRecord`
* `editRecordAction`
* `deleteRecordAction`
* `translateRecord`
* `sortRecords`
* `managePerms`
* `ajaxListing`
* `multiRecordAction`
* `exportDataAction`
* `dataExportConfigModal`
* `recordHistory`
* `getNodesForTreeView`


>>>>>> You can pass extra query string parameters to any of these links with the `queryString` argument. For example:
>>>>>>
```
event.buildAdminLink(
	  objectName  = objectName
	, operation   = "addRecord"
	, queryString = "categoryId=#categoryId#"
);
```

### Custom link builders

There is a naming convention for providing a custom link builder for an operation: `build{operation}Link`. There are therefore Data Manager customizations named `buildListingLink`, `buildViewRecordLink`, and so on. For example, to provide a completely different link for a view record screen for your object, you could do:

```luceescript
// /application/handlers/admin/datamanager/blog_author.cfc

component {

	private string function buildViewRecordLink( event, rc, prc, args={} ) {
		var recordId = args.recordId    ?: "";
		var extraQs  = args.queryString ?: "";
		var qs       = "id=#recordId#";

		if ( extraQs.len() ) {
			qs &= "&#extraQs#";
		}

		// e.g. here we would have a coldbox handler /admin/BlogAuthors.cfc
		// with a public 'view' method for completely controlling the entire
		// view record request outside of Data Manager
		return event.buildAdminLink( linkto="blogauthors.view", querystring=qs );
	}
}
```

### Adding your own operations

If you are extending Data Manager to add extra pages for a particular object (for example), you can create new operations by following the same link building convention above. For example, say we wanted to build a "preview" link for an article, we can use the following:

```luceescript
// /handlers/admin/datamanager/article.cfc
component extends="preside.system.base.AdminHandler" {

// Public events for extra admin pages and actions
	public void function preview() {
		event.initializeDatamanagerPage(
			  objectName = "article"
			, recordId   = rc.id ?: ""
		);

		event.addAdminBreadCrumb(
			  title = translateResource( "preside-objects.article:preview.breadcrumb.title" )
			, linke = ""
		);

		prc.pageTitle = translateResource( "preside-objects.article:preview.page.title" );
		prc.pageSubTitle = translateResource( "preside-objects.article:preview.page.subtitle" );
	}

// customizations
	private string function buildPreviewLink( event, rc, prc, args={} ) {
		var qs = "id=#( args.recordId ?: "" )#";

		if ( Len( Trim( args.queryString ?: "" ) ) ) {
			qs &= "&#args.queryString#";
		}

		return event.buildAdminLink( linkto="datamanager.article.preview", querystring=qs );
	}



}
```

Linking to the "preview" operation can then be done with:

```luceescript
event.buildAdminLink( objectName="article", operation="preview", id=recordId );
```

>>> Notice that the handler extends `preside.system.base.AdminHandler`. This base handler supplies a preAction that sets the admin layout and checks for logged in users. You should do this when supplying additional public handler actions in your customization.

#### event.initializeDatamanagerPage()

Notice the handy `event.initializeDatamanagerPage()` in the example, above. This method will setup standard breadcrumbs for your page as well as setting up common variables that are available to other data manager pages such as:

* `prc.recordId`: id of the current record being viewed
* `prc.record`: current record being viewed
* `prc.recordLabel`: rendered label field for the current record
* `prc.objectName`: current object name
* `prc.objectTitle`: translated title of the current object
* `prc.objectTitlePlural`: translated _plural_ title of the current object

The method expects either one, or two arguments: `objectName`, the name of the object, and `recordId`, the ID of the current record (if applicable).


## Customization reference

There are currently more than 60 customization points in the Data Manager and this number is set to grow. We have grouped them into categories below for your reference:

### Record listing table / grid

* [[datamanager-customization-listingviewlet|listingViewlet]]
* [[datamanager-customization-prerenderlisting|preRenderListing]]
* [[datamanager-customization-postrenderlisting|postRenderListing]]
* [[datamanager-customization-gettoprightbuttonsforobject|getTopRightButtonsForObject]]
* [[datamanager-customization-extratoprightbuttonsforobject|extraTopRightButtonsForObject]]
* [[datamanager-customization-prefetchrecordsforgridlisting|preFetchRecordsForGridListing]]
* [[datamanager-customization-getadditionalquerystringforbuildajaxlistinglink|getAdditionalQueryStringForBuildAjaxListingLink]]
* [[datamanager-customization-postfetchrecordsforgridlisting|postFetchRecordsForGridListing]]
* [[datamanager-customization-decoraterecordsforgridlisting|decorateRecordsForGridListing]]
* [[datamanager-customization-getactionsforgridlisting|getActionsForGridListing]]
* [[datamanager-customization-getrecordactionsforgridlisting|getRecordActionsForGridListing]]
* [[datamanager-customization-extrarecordactionsforgridlisting|extraRecordActionsForGridListing]]
* [[datamanager-customization-listingmultiactions|listingMultiActions]]
* [[datamanager-customization-getlistingmultiactions|getListingMultiActions]]
* [[datamanager-customization-getextralistingmultiactions|getExtraListingMultiActions]]
* [[datamanager-customization-multirecordaction|multiRecordAction]]


### Adding records

* [[datamanager-customization-addrecordform|addRecordForm]]
* [[datamanager-customization-getaddrecordformname|getAddRecordFormName]]
* [[datamanager-customization-prerenderaddrecordform|preRenderAddRecordForm]]
* [[datamanager-customization-postrenderaddrecordform|postRenderAddRecordForm]]
* [[datamanager-customization-addrecordactionbuttons|addRecordActionButtons]]
* [[datamanager-customization-getaddrecordactionbuttons|getAddRecordActionButtons]]
* [[datamanager-customization-getextraaddrecordactionbuttons|getExtraAddRecordActionButtons]]
* [[datamanager-customization-gettoprightbuttonsforaddrecord|getTopRightButtonsForAddRecord]]
* [[datamanager-customization-extratoprightbuttonsforaddrecord|extraTopRightButtonsForAddRecord]]
* [[datamanager-customization-addrecordaction|addRecordAction]]
* [[datamanager-customization-preaddrecordaction|preAddRecordAction]]
* [[datamanager-customization-postaddrecordaction|postAddRecordAction]]


### Viewing records

>>> The customizations below allow you to override or decorate the core record rendering system in Data Manager. In addition to these, you should also familiarize yourself with [[adminrecordviews]] as the core view record screen can also be customized using annotations within your Preside Objects.

* [[datamanager-customization-renderrecord|renderRecord]]
* [[datamanager-customization-prerenderrecord|preRenderRecord]]
* [[datamanager-customization-postrenderrecord|postRenderRecord]]
* [[datamanager-customization-prerenderrecordleftcol|preRenderRecordLeftCol]]
* [[datamanager-customization-postrenderrecordleftcol|postRenderRecordLeftCol]]
* [[datamanager-customization-prerenderrecordrightcol|preRenderRecordRightCol]]
* [[datamanager-customization-postrenderrecordrightcol|postRenderRecordRightCol]]
* [[datamanager-customization-gettoprightbuttonsforviewrecord|getTopRightButtonsForViewRecord]]
* [[datamanager-customization-extratoprightbuttonsforviewrecord|extraTopRightButtonsForViewRecord]]

### Editing records

* [[datamanager-customization-editrecordform|editRecordForm]]
* [[datamanager-customization-geteditrecordformname|getEditRecordFormName]]
* [[datamanager-customization-prerendereditrecordform|preRenderEditRecordForm]]
* [[datamanager-customization-postrendereditrecordform|postRenderEditRecordForm]]
* [[datamanager-customization-editrecordactionbuttons|editRecordActionButtons]]
* [[datamanager-customization-geteditrecordactionbuttons|getEditRecordActionButtons]]
* [[datamanager-customization-getextraeditrecordactionbuttons|getExtraEditRecordActionButtons]]
* [[datamanager-customization-gettoprightbuttonsforeditrecord|getTopRightButtonsForEditRecord]]
* [[datamanager-customization-extratoprightbuttonsforeditrecord|extraTopRightButtonsForEditRecord]]
* [[datamanager-customization-editrecordaction|editRecordAction]]
* [[datamanager-customization-preeditrecordaction|preEditRecordAction]]
* [[datamanager-customization-posteditrecordaction|postEditRecordAction]]

### Deleting records

* [[datamanager-customization-deleterecordaction|deleteRecordAction]]
* [[datamanager-customization-predeleterecordaction|preDeleteRecordAction]]
* [[datamanager-customization-postdeleterecordaction|postDeleteRecordAction]]

### Building links

* [[datamanager-customization-buildlistinglink|buildListingLink]]
* [[datamanager-customization-buildviewrecordlink|buildViewRecordLink]]
* [[datamanager-customization-buildaddrecordlink|buildAddRecordLink]]
* [[datamanager-customization-buildaddrecordactionlink|buildAddRecordActionLink]]
* [[datamanager-customization-buildeditrecordlink|buildEditRecordLink]]
* [[datamanager-customization-buildeditrecordactionlink|buildEditRecordActionLink]]
* [[datamanager-customization-builddeleterecordactionlink|buildDeleteRecordActionLink]]
* [[datamanager-customization-buildtranslaterecordlink|buildTranslateRecordLink]]
* [[datamanager-customization-buildsortrecordslink|buildSortRecordsLink]]
* [[datamanager-customization-buildmanagepermslink|buildManagePermsLink]]
* [[datamanager-customization-buildajaxlistinglink|buildAjaxListingLink]]
* [[datamanager-customization-buildmultirecordactionlink|buildMultiRecordActionLink]]
* [[datamanager-customization-buildexportdataactionlink|buildExportDataActionLink]]
* [[datamanager-customization-builddataexportconfigmodallink|buildDataExportConfigModalLink]]
* [[datamanager-customization-buildrecordhistorylink|buildRecordHistoryLink]]
* [[datamanager-customization-buildgetnodesfortreeviewlink|buildGetNodesForTreeViewLink]]

### Permissioning

* [[datamanager-customization-checkpermission|checkPermission]]
* [[datamanager-customization-isoperationallowed|isOperationAllowed]]

### General

* [[datamanager-customization-prelayoutrender|preLayoutRender]]
* [[datamanager-customization-toprightbuttons|topRightButtons]]
* [[datamanager-customization-extratoprightbuttons|extraTopRightButtons]]
* [[datamanager-customization-rootbreadcrumb|rootBreadcrumb]]
* [[datamanager-customization-objectbreadcrumb|objectBreadcrumb]]
* [[datamanager-customization-recordbreadcrumb|recordBreadcrumb]]
* [[datamanager-customization-versionnavigator|versionNavigator]]


## Creating your own customizations

You may wish to utilize the customization system in your extensions to allow implementations to easily override additional data manager features that you may provide. To do so, you can inject the [[api-datamanagercustomizationservice]] into your handler or service and make use of the methods:

* [[datamanagercustomizationservice-runCustomization]]
* [[datamanagercustomizationservice-objectHasCustomization]]

For example:


```luceescript
if ( datamanagerCustomizationService.objectHasCustomization( objectName, "printPreview" ) ) {
	printPreview = datamanagerCustomizationService.runCustomization(
		  objectName = objectName
		, action     = "printPreview"
		, args       = args
	);
} else {
	printPreview = renderView( view=defaultView, args=args );
}
```

Or:

```luceescript
printPreview = datamanagerCustomizationService.runCustomization(
	  objectName     = objectName
	, action         = "printPreview"
	, defaultHandler = "myhandler.printPreview"
	, args           = args
);
```

## Custom navigation to your objects

One of the most powerful changes in 10.9.0 is the ability to have objects use the Data Manager system _without needing to be listed in the Data Manager homepage_. This means that you could have a main navigation link directly to your object(s), for example. In short, you can build highly custom admin interfaces much quicker and with much less code.

### Remove from Data Manager homepage

To allow an object to use Data Manager without appearing in the Data Manager homepage listing, use the `@datamanagerEnabled true` annotation and **not** the `@datamanagerGroup` annotation. For example:

```luceescript
// /application/preside-objects/blog.cfc
/**
 * @datamanagerEnabled true
 *
 */
component {
    // ...
}
```

### Example: Add to the admin left-hand menu

>>>>>> See [[adminlefthandmenu]] for a full guide to customizing the left-hand menu/navigation.

In your application or extension's `Config.cfc` file, modify the `settings.adminSideBarItems` to add a new entry for your object. For example:

```luceescript
settings.adminSideBarItems.append( "blog" );
```

Then, create a corresponding view at `/views/admin/layout/sidebar/blog.cfm`. For _example_:

```luceescript
// /views/admin/layout/sidebar/blog.cfm
hasPermission = hasCmsPermission(
	  permissionKey = "read"
	, context       = "datamanager"
	, contextKeys   = [ "blog" ]
);
if ( hasPermission ) {
    Echo( renderView(
          view = "/admin/layout/sidebar/_menuItem"
        , args = {
              active  = ReFindNoCase( "^admin\.datamanager", event.getCurrentEvent() ) && ( prc.objectName ?: "" ) == "blog"
            , link    = event.buildAdminLink( objectName="blog" )
            , gotoKey = "b"
            , icon    = "fa-comments"
            , title   = translateResource( 'preside-objects.blog:menu.title' )
          }
    ) );
}

```

### Modify the breadcrumb

By default, your object will get breadcrumbs that start with a link to the Data Manager homepage. Use the breadcrumb customizations to modify this:

* [[datamanager-customization-rootbreadcrumb|rootBreadcrumb]]
* [[datamanager-customization-objectbreadcrumb|objectBreadcrumb]]
* [[datamanager-customization-recordbreadcrumb|recordBreadcrumb]]

For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

	private void function rootBreadcrumb() {
		// Deliberately do nothing so as to remove the root
		// 'Data manager' breadcrumb just for the 'blog' object.

		// We could, instead, call event.addAdminBreadCrumb( title=title, link=link )
		// to provide an alternative root breadcrumb
	}

}
```

## Modify core default page titles and other layout changes

A really useful customization is the [[datamanager-customization-prelayoutrender|preLayoutRender]] customization. This fires before the full admin page layout is rendered and allows you to make adjustments after all the handler logic has run. For example:

```luceescript
// /application/handlers/admin/datamanager/blog.cfc

component {

    private void function preLayoutRender( event, rc, prc, args={} ) {
        prc.pageTitle = translateResource(
              uri          = "preside-objects.blog:#args.action#.page.title"
            , defaultValue = prc.pageTitle ?: ""
        );
        prc.pageSubTitle = translateResource(
              uri          = "preside-objects.blog:#args.action#.page.subtitle"
            , defaultValue = prc.pageSubTitle ?: ""
        );
        prc.pageIcon = "fa-comments";
    }

    private void function preLayoutRenderForEditRecord( event, rc, prc, args={} ) {
        prc.pageTitle = translateResource(
              uri  = "preside-objects.blog:editRecord.page.title"
            , data = [ prc.recordLabel ?: "" ]
        );

        // modify the title of the last breadcrumb
        var breadCrumbs = event.getAdminBreadCrumbs();
        breadCrumbs[ breadCrumbs.len() ].title = prc.pageTitle;
    }
}
```