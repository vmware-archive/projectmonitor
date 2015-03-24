## TeamCity Rest

For TeamCity REST projects, find the buildTypeId. You can find this by

1. Selecting the Project from TeamCity
2. Selecting the build associated with that project
3. Looking at the URL for that build. ```www.domain.com/viewType.html?buildTypeId=YourProject_BuildTypeId```

In the example above, the build type id is the last argument in the URL

You will also need a valid user account and password.

If you want TeamCity to connect via Webhooks, you'll need to install the
[TcWebHooks plugin](http://sourceforge.net/apps/trac/tcplugins/wiki/TcWebHooks) on
your TeamCity instance. When setting up the webhook in TeamCity, make sure the payload
format is set to "JSON" (it might show up as "JSON (beta)").

If you want to connect to TeamCity via polling, you will need to ensure that your TeamCity instance
is accessible by the machine running ProjectMonitor.

