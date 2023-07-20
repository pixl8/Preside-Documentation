---
id: data-tenancy
title: Configuring data tenancy
---

## Overview

Data tenancy allows you to divide your data up into logical segments, or tenants. A classic example of this might be an application that serves different customers. The application is shared between all the customers, but each customer gets their own users and their own data and cannot see the data of the other customers.

Preside has always come with a concept of "site tenancy", but as of 10.8.0, it also provides a simple framework for defining your own custom tenancies.

## Example

Let's take a real-life scenario where an application maintains articles for on-line and print media. The application serves multiple customers and each article should belong to a single customer (we'll add some complexity to this later).

Article editors should be able to switch customer in the admin interface and automatically have their data filtered for that customer. Article editors require permissions to be able to work on particular customers' articles.

### Configuration

In our example, we have a single object for tenancy, `customer.cfc`. We are going to assume that the permissions model and data for customers is already setup and that we have a preside object for customer that looks something like this:

```luceescript
/**
 * @labelfield name
 */
component {
	property name="name";
	// ... other properties
}
```

To configure this object for tenancy, you would need to add the following to your application's `/application/config/Config.cfc`:

```luceescript
settings.tenancy.customer = {
	  object       = "customer"
	, defaultFk    = "customer"
};
```

This tells the framework that 'customer' can be used to create tenancy in other data objects. To configure an object to use this tenancy, we add `@tenant customer` to its definition. In our example, we want articles to have customer tenancy, so our `article.cfc` would look like this:

```luceescript
/**
 * @tenant     customer
 * @labelfield title
 */
component {
	//... 	
}
```

*That's it*. Our data model is now set. The framework will automatically inject the relevant foreign keys into the `article.cfc` object and ensure any indexes and unique indexes also include the `customer` foreign key.

Whenever data is selected from the `article` object, the framework will automatically filter it by the currently set `customer`. Whenever data is inserted into the `article` object store, the `customer` field will be automatically set to the currently active `customer`.

### Setting the active tenant per-request

In order for the framework to be able to auto-filter and maintain tenancy, you need to tell it what the current active tenant is per request. To do so, you can implement a handler action, `tenancy.{configuredtenant}.getId`. This handler should return the ID of the currently active tenant record. This handler action is called very early in the request lifecycle to ensure the active tenants get set before they need to be used.

In our example, our tenancy object is `customer`, so our convention based hander would live at `/handlers/tenancy/customer.cfc` and could look like this:


```luceescript
component {

	property name="customerService" inject="customerService";

	private string function getId( event, rc, prc ) {
		return customerService.getCurrentlyActiveCustomerId();
	}
}
```

>>>>> The logic that calculates the current tenant is entirely up to you. You may base it on the first part of the current domain, e.g. `customer.mysite.com`, or it may be based on a custom control in the admin interface that allows the user to switch between different tenants. **The tenancy framework does not provide any of this logic.**

If you do not wish to follow the convention based handler, you can configure a different one in your `settings.tenancy` config in `Config.cfc` using the `getIdHandler` property:

```luceescript
settings.tenancy.customer = {
	  object       = "cust"
	, defaultFk    = "cust_id"
	, getIdHandler = "customers.getActiveCustomerId"
};
```

### Setting default value for tenant

If the tenancy filter value might potentially be empty, you may want to set a default value; this can be implemented via a handler action, `tenancy.{configuredtenant}.getDefaultValue`. This handler should return the desired default value to filter any tenanted query.

In our example, our tenancy object is `customer`, so our convention based handler would live at `/handlers/tenancy/customer.cfc` and could look like this:

```luceescript
component {

	property name="customerService" inject="customerService";

	private string function getDefaultValue( event, rc, prc ) {
		return customerService.getDefaultCustomerId();
	}
}
```

## More complex filter scenarios

You may find that the tenancy is less straight forward than a record belonging to a single tenant. You may have a situation where you have one _main_ tenant, and then many optional tenants.

In our customer article's example, an article can belong to a single customer but also be available to other partner customers. Our `article.cfc` may look like this:

```luceescript
/**
 * @tenant     customer
 * @labelfield title
 */
component {
	// ...

	property name="partner_customers" relationship="many-to-many" relatedto="customer" relatedvia="article_partner_customer";

	// ...
}
```

If our active customer tenant is "Acme LTD", we only want to see articles whose main customer is "Acme LTD" **OR** whose partner customers contain "Acme LTD".

To implement this logic, you need to create a `getFilter()` handler action in your tenancy handler. This method will take four arguments (as well as the standard Coldbox handler arguments):

* `objectName` - the name of the object being filtered (in our example, `article`)
* `fk` - the name of the foreign key property that is the main tenancy indicator (in our example, `customer`)
* `tenantId` - the currently active tenant ID
* `defaultFilter` - the filter that is used by default, return this if you do not require any custom filtering for the given object (you may have multiple objects that use tenancy and some with different filtering requirements)

An example:

```luceescript
component {

	property name="presideObjectService" inject="presideObjectService";
	property name="customerService" inject="customerService";

	private string function getId( event, rc, prc ) {
		return customerService.getCurrentlyActiveCustomerId();
	}

	private struct function getFilter( objectName, fk, tenantId, defaultFilter ) {
		if ( arguments.objectName == "article" ) {
			var filter       = "#objectName#.#fk# = :customer_id or _extra.id is not null";
			var filterParams = { customer_id = { type="cf_sql_varchar", value=tenantId } };
			var subquery     = presideObjectService.selectData(
				  objectName          = "article_partner_customer"
				, getSqlAndParamsOnly = true
				, distinct            = true
				, selectFields        = [ "article as id" ]
				, filter              = "customer = :customer_id"
				, filterParams        = filterParams
			);

			return { filter=filter, filterParams=filterParams, extraJoins=[ {
				  type           = "left"
				, subQuery       = subQuery.sql
				, subQueryAlias  = "_extra"
				, subQueryColumn = "id"
				, joinToTable    = arguments.objectName
				, joinToColumn   = "id"
			} ] };
		}

		return defaultFilter;
	}
}
```

If you do not wish to follow the convention based handler, you can configure a different one in your `settings.tenancy` config in `Config.cfc` using the `getFilterHandler` property:

```luceescript
settings.tenancy.customer = {
	  object           = "cust"
	, defaultFk        = "cust_id"
	, getFilterHandler = "customers.getTenancyFilter"
};
```

## Bypassing tenancy

You may wish to bypass tenancy altogether in some scenarios. To do so, you can pass the `bypassTenants` arguments to [[presideobjectservice-selectdata]]:

```luceescript
presideObjectService.selectData(
	  // ...
	, bypassTenants = [ "customer" ]
);
```

This will ensure that any tenancy filters are **not** applied for the given tenants. You are also able to specify these bypasses on an object picker in forms:


```xml
<field binding="article.related_articles" bypassTenants="customer" /> 
```

## Overriding the per-request tenant

If you need to select data from a tenant that is not the currently active tenant for the request, you can use the `tenantIds` argument to specify the IDs for specific tenants. For example:


```luceescript
// ...
var alternativeCustomerAccounts = accounts.selectData(
	  selectFields = [ "id", "account_name" ]
	, tenantIds    = { customer=alternativeCustomerId }
);
// ...
```

The value of this argument must be a struct whose keys are the names of the tenant and whose values are the ID to use for the tenant. See [[presideobjectservice-selectdata]] for documentation.
