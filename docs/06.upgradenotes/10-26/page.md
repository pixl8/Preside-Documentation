---
id: 10-26-upgrade-notes
title: Upgrade notes for 10.25 -> 10.26
---

## Summary

The 10.26.0 release introduces a a trio of enhancements, none of which require any technical changes on behalf of your application. However, the Email statistics feature warrants a note around data migration (see below).

If you haven't already, check out the release post and video describing the changes: [https://www.preside.org/resource/preside-10-26-released.html](https://www.preside.org/resource/preside-10-26-released.html).


## Data migration to enhanced email logging

There is an asynchonous data migration that will execute after upgrading to 10.26. This migration will loop through each email template in turn and generate the "summary tables" data from their raw logs. Should this process be interrupted by a redeployment or other application reload, it will pick up where it left off.

Email templates that have not yet completed migration, will continue to behave as they did before the change. Once migrated, you will see the new statistics views for the templates.

If your application has a LOT of email activity, you might expect this to take several hours (or more). The migration will log its progress to the console.

## Email bot detection

Email bot detection is disabled by default due to its experimental nature. You can enable it with:

```luceescript
settings.features.emailTrackingBotDetection.enabled = true;
```

