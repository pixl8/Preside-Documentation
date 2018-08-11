---
id: healthchecks
title: External service health checks
---

## Introduction

As of **10.10.0**, Preside comes with an external service healthchecking system that allows your code to:

* Periodically check the up status of external services (e.g. every 30 seconds)
* Call `isUp( "myservice" )` or `isDown( "myservice" )` to check the result of the last status check, without calling the external service directly

## Turning the feature on/off

The `healthchecks` feature is used to control whether healthchecks are run within the preside application. This is turned **on** by default but turned **off** by default for local development servers. To turn on in your local dev environment, use the following in `Config.cfc`:

```luceescript
component extends="preside.system.config.Config" {

	// ...

	// override the "local" function to provide
	// local env settings.
	public void function local() {
		super.local();

		settings.features.healthchecks.enabled = true;
	}
}
```

## Registering a healthcheck

### In Config.cfc

First, you must register your healthcheck in your application or extension's `Config.cfc$configure()` method. The `settings.healthcheckServices` _struct_ is used to configure healtcheck services. The struct keys indicate the service ID, e.g. for an "ElasticSearch" healthcheck:

```luceescript
settings.healthcheckServices.ElasticSearch = {
	interval = CreateTimeSpan( 0, 0, 0, 10 ) // default is 30 seconds
};
```

Possible settings for your healthcheck services are:

* `interval`: must be a `timespan` default is `CreateTimeSpan( 0, 0, 0, 30 )`

### Create corresponding handler

For each configured service, there must be a corresponding handler with a `check()` method at: `/handlers/healtchcheck/serviceid.cfc`. For example, to create an `ElasticSearch` healthcheck, we'd create `/handlers/healthcheck/ElasticSearch.cfc`:

```luceescript
component {
	property name="elasticSearchService" inject="elasticSearchService";

	private boolean function check() {
		return elasticSearchService.ping();
	}
}
```

If the `check` action returns `true` the service is deemed to be up. Any other return value, or error thrown, will lead to the system marking the service as being down.

## Checking service health in your code

### Handlers and views

In your handlers and views, you can use the `isUp( serviceId )` and `isDown( serviceId )` helpers:

```luceescript
if ( isUp( "elasticsearch" ) ) {
	var results = elasticSearchService.search( ... );
} else {
	var results = searchFallBackService.search( ... );
}
```

### Services

Services can use the `$isUp( serviceId )` and `$isDown( serviceId )` methods from the [[api-presidesuperclass]]. See [[presidesuperclass]].

```luceescript
if ( $isDown( "elasticsearch" ) ) {
	var results = searchFallBackService.search( ... );
} else {
	var results = elasticSearchService.search( ... );
}
```

