---
id: enabling-asset-queue
title: Enabling the asset processing queue
---

## Introduction

In **10.11.0**, we introduced a feature to queue the processing of asset derivatives using a simple database queue. The feature is disabled by default. You are able to enable the queue and also configure the background threads that subscribe to the queue.

## Enabling the feature

There are two key features that you can enable, `assetQueue` and `assetQueueHeartBeat`. The `assetQueue` feature controls whether or not asset derivative generation will be pushed to the queue, rather than processed inline. The `assetQueueHeartBeat` feature enables the background thread that will actually process derivative creation. For example, in your Config.cfc:

```luceescript
settings.features.assetQueue.enabled = true;
settings.features.assetQueueHeartBeat.enabled = true; // will not be enabled if assetQueue feature is disabled
```

### Configuring the queue subscriber

You can configure the behaviour of the asset queue "heartbeat" by setting the `settings.assetmanager.queue` struct:

```
settings.assetmanager.queue = {
	  concurrency = 8   // number of threads that will concurrenctly run and process the queue (default: 1)
	, batchSize   = 100 // number of assets to be processed by a thread before pausing for ~2 seconds (default: 100)
};
```


## Multi server environment example

The following example gives an outline of how you could configure a two server setup where one server will be responsible for serving web pages, and the second server will be responsible for processing images. In `Config.cfc`:


```luceescript
component extends="preside.system.config.Config" {

    public void function configure() {
        super.configure();

        // ...
        settings.features.assetQueue.enabled = true;

        environments.prodweb = "mysite.com";
		environments.prodbackend = "backend.mysite.com";

    }

    public void function prodweb() {
    	settings.features.assetQueueHeartBeat.enabled = false;
    }
    
    public void function prodbackend() {
    	settings.features.assetQueueHeartBeat.enabled = true;
    	settings.features.assetmanager.queue.concurrency = 8;
    }

}
```

>>> The above example uses ColdBox environments to achieve the configuration, but other approaches could be used. For example, you could inject environment variables into your application (see [[environment-variables]]).
