## TeamCity

For TeamCity projects, find the buildTypeId (usually something like 'bt2') from the URL, which should look like one of the following:

    http://teamcity:8111/app/rest/builds?locator=running:all,buildType:
    http://teamcity:8111/viewType.html?buildTypeId=
    http://teamcity:8111/viewLog.html?buildId=1&tab=buildResultsDiv&buildTypeId=

You will also need a valid user account and password.

If you want TeamCity to connect via Webhooks, you'll need to install the
[TcWebHooks plugin](http://sourceforge.net/apps/trac/tcplugins/wiki/TcWebHooks) on
your TeamCity instance. When setting up the webhook in TeamCity, make sure the payload
format is set to "JSON" (it might show up as "JSON (beta)").

If you want to connect to TeamCity via polling, you will need to ensure that your TeamCity instance
is accessible by the machine running ProjectMonitor.

