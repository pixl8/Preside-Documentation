---
id: selectDataViews
title: SelectData views
---

## Overview

**SelectData Views** are synonymous with SQL Views but for the [[dataobjects|Preside Data Objects system]]. In a nutshell, a SelectData view is a saved set of arguments that can be sent to the [[presideobjectservice-selectdata]] method.

**SelectData Views** were introduced in Preside **10.11.0**.

## Defining a view

**SelectData Views** are defined by implementing a convention based Coldbox handler action: `selectDataViews.{viewName}`. The handler must return a `struct` of arguments to be sent to `selectData()`. For example, the following handler CFC defines two simple views, `activeBlogPosts` and `inactiveBlogPosts`:

```luceescript
// /handlers/SelectDataViews.cfc
component {

    private struct function activeBlogPosts( event, rc, prc ) {
        return {
              objectName   = "blog_post"
            , filter       = { active = true }
            , selectFields = [ "id", "title", "category" ]
        };
    }

    private struct function inactiveBlogPosts( event, rc, prc ) {
        return {
              objectName = "blog_post"
            , filter     = { active = false }
        };
    }

}
```

## Using views

### Direct queries

You can directly query a view with the [[presideobjectservice-selectview]] method. For instance:

```luceescript
var activeBlogPosts = presideObjectService.selectView( "activeBlogPosts" );
```

### Relationship properties

You can also reference views from preside object properties using `relationship="select-data-view" relatedTo="nameOfview"`. The following Preside Object definition is for a `blog_category` object. It has a `one-to-many` relationship with the `blog_post` object and we can now create a relationship to the two views we defined above.

Furthermore, these relationships can be used in things like formula fields that can be used in data exports and data manager tables:


```luceescript
/**
 * @datamanagerGroup Blogs
 * @datamanagerGridFields label,active_post_count,inactive_post_count
 *
 */
component {
    property name="active_posts"   relationship="select-data-view" relatedto="activeBlogPosts"   relationshipKey="category";
    property name="inactive_posts" relationship="select-data-view" relatedto="inactiveBlogPosts" relationshipKey="category";

    property name="active_post_count"   formula="count( ${prefix}active_posts.id )"   type="numeric";
    property name="inactive_post_count" formula="count( ${prefix}inactive_posts.id )" type="numeric";
}
```

