---
id: healthchecks
title: External service health checks
---

## Introduction

As of **10.10.0**, Preside comes with an external service healthchecking system that allows your code to:

* Periodically check the up status of external services (every 30 seconds)
* Call `isUp( "myservice" )` or `isDown( "myservice" )` to check the result of the last status check, without going to the external service

## Registering a healthcheck

To register a healthcheck for a service, you must implement a handler with a `check()` method at: `/handlers/healtchcheck/servicename.cfc`. For example, to create an `ElasticSearch` healthcheck, we'd create `/handlers/healthcheck/ElasticSearch.cfc`:

```luceescript
component {
	property name="elasticSearchService" inject="elasticSearchService";

	private boolean function check() {
		return elasticSearchService.ping();
	}
}
```

If the `check` action returns `true` the service is deemed to be up. Any other return value, or an error thrown will lead to the system marking the service as being down.

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

