---
id: datamanagerbasics
title: Data Manager Basics
---

## Introduction

This page will take you through the basic default set up and configuration of [[datamanager]] for a [[dataobjects|Preside data object]]. By the end of this guide, you should be comfortable creating a basic admin CRUD interface for an object within the main Data Manager user interface.

## Data Manager homepage

The Data Manager homepage in the Preside administrator displays all of the objects in the system **that have been configured to display within Data Manager**. Objects are organised into groups and are searchable (by object name). Clicking on an object will take you into that object's listing screen:


![Screenshot showing example of a Data Manager object listing screen](images/screenshots/datamanager-listing-screen.png)

### Get your object listed in the Data Manager homepage

In order for your object to appear in the Data Manager homepage, your `.cfc` file must be annotated with the `@datamanagerGroup` annotation. For example:

```luceescript
// /application/preside-objects/author.cfc

/**
 * @datamanagerGroup blog
 * @labelfield       name
 */
component {
	property name="name" type="string" dbtype="varchar" maxlength="200" required=true uniqueindexes="name";
}
```

That's all their is to it, you now how a full CRUD interface for your object. However, you probably want to make things a little prettier, see how you can supply, labels below.

### Translatable and human readable labels

Each Preside Object should have a corresponding `.properties` file that will provide title, description, optional icon class and entries for each field in your object. The file must live at: `/i18n/preside-objects/myobject.properties`. For example:

```properties
# /application/i18n/preside-objects/author.properties
title=Authors
title.singular=Author
description=Authors of blog posts
iconclass=fa-user

field.name.title=Author Name
```

>>>>>> _See [[presideforms-i18n]] for more conventions for field names, placeholders, help, etc._

Each Data Manager **group** should also have a corresponding `.properties` file at `/i18n/preside-objects/groups/groupname.properties`. For our blog example:

```properties
# /application/i18n/preside-objects/groups/blog.properties
title=Blogs
description=Data related to blogs
iconclass=fa-comments
```

## Customizing the listing grid

TODO

## Customizing the add / edit record forms

TODO

## Versioning & Drafts

TODO

## Limiting operations

TODO

