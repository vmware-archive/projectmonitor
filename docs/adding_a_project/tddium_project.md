## TDDium / Solano CI

TDDium / Solano only supports connecting via polling, not Webhooks.

In order to get polling configured, you will need to: 

1. Log in to your Solano dashboard, go to Organizations using the drop down in the top right corner.
2. Click on organization settings for the appropriate organization. 
3. In the left-hand nav, click "CC Menu (XML Status)"

That should take you to a URL that looks like:

    https://ci.solanolabs.com/cc/SOME-TOKEN-HERE/cctray.xml

The value for "SOME-TOKEN-HERE" is the TDDium authentication token you'll need to paste into the ProjectMonitor settings.

If you access that link, the XML returned will look something like:

~~~
<Projects>
  <Project name="FooBar (master)" webUrl="https://ci.solanolabs.com:443/reports/1359512" lastBuildLabel="1359512" lastBuildTime="2015-03-24 17:19:48" lastBuildStatus="Unknown" activity="Sleeping"/>
</Projects>
~~~

The "TDDium Project Name" field in the ProjectManager settings will need to be set to the full value of the Project
name attribute, complete with the branch name in parentheses (in this case, "FooBar (master)").

The Base URL is the host name of the CI server. If you are using the Solano Labs server, the base URL is found is in the XML return. In this case it is https://ci.solanolabs.com:443

