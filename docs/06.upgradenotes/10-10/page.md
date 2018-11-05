---
id: 10-10-upgrade-notes
title: Upgrade notes for 10.9 -> 10.10
---

## Coldbox upgrade

The 10.10 release upgrades Coldbox from 4 to 5.2, so please the [Coldbox upgrade notes](https://coldbox.ortusbooks.com/intro/introduction/whats-new-with-5.0.0) for any issues that might affect your application. That said, we have not come across issues with the applications that we have upgraded so far.

## Email center logging

There has been a minor change to email center logging that requires a data migration. Your first reload of your application may therefor take some time, especially if you have a large number of records in your `psys_email_template_send_log` table.

## Multi threaded email sending

There has been a change to the way we queue and send mass emails in the email center. There is no longer a task in the Preside task manager and you are now able to configure how many background threads will be dedicated to sending out emails from the queue (the default is 1). To configure more threads, use the following in your Config.cfc file:

```luceescript
settings.email.queueConcurrency = 8; // or whatever
```
