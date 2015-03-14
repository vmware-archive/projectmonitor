## Semaphore

When configuring [Semaphore](http://semaphoreapp.com), you should use the Branch History URL from the API section of your Project Settings page.

This ensures that no build statuses will be missed.

If you notice that there are build statuses missing in project monitor, ensure that you are NOT using the Branches URL from the API section (vs. the
recommended Branch History URL).  The Branches URL from the API section returns only the latest build status, instead of the history, so if builds occurred
between status fetches, they would be missed and not be reflected in project monitor.

