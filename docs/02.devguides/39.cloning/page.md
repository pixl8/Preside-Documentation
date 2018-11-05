---
id: cloning
title: Record cloning
---

## Introduction

In Preside 10.10.0, we introduced APIs and foundations for Preside object record cloning as well as concrete implementations in the Data Manager, Email Centre and Site tree. This guide provides information on getting the most out of the cloning system and how to configure your objects.

## Making my object cloneable, or not

By default, the system attempts to calculate whether or not an object is cloneable by seeing if it has any cloneable properties (see below). If you want to explicitly define whether or not your object is cloneable, however, you can do so with the `@cloneable` annotation on the component. For example:

```luceescript
/**
 * @cloneable false
 *
 */
component {
	// ...
}
```

## Making properties cloneable, or not

You can explicitly mark a property as being "cloneable" by using the `cloneable` annotation on the property, setting to either `true` or `false`:

```property name="my_prop" cloneable=true // ...```

By default, however, the system uses the following rules to decide whether or not your property will be cloneable.

### Rules for properties that can never be cloned

* The property is either the `id`, `datemodified` or `datecreated` field
* The property is a formula field (these will *never* be cloneable)

### Rules for properties that are not cloneable by default

* The property is part of a unique index
* The property is a `one-to-many` relationship

### Rules for properties that are cloneable by default

All properties that do not match the criteria, above, are cloneable by default.

## Supplying alternative logic for cloning

You can use the `@cloneHandler` annotation on your Preside object component to specify a private Coldbox handler action that will be run to clone a record. This handler will be passed the following arguments:

* `objectName` Name of object whose record is to be cloned
* `recordId` ID of record to be cloned
* `data` Additional data that should be included in the new record

## Other customizations

See the "Cloning" customizations in the [[customizingdatamanager]] page.

## Using the API directly

See [[api-presideobjectcloningservice]].


