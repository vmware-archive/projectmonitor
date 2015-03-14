## TDDium

TDDium only supports connecting via polling, not Webhooks.

In order to get polling configured, you will need to log in to your TDDium dashboard, go to Organizations using the drop down in the top right corner.
Then click on organization settings for the appropriate organization. Then click on "Chat Notifications"; CCmenu is at the bottom of the page.
That should take you to a URL that looks like:

    https://api.tddium.com/cc/SOME-TOKEN-HERE/cctray.xml

The value for "SOME-TOKEN-HERE" is the TDDium authentication token you'll need to paste into the ProjectMonitor settings.
The XML returned by that link will look something like:

    <Projects>
       <Project name="foobar (master)" webUrl="https://api.tddium.com/1/reports/151751" lastBuildLabel="151751"
       lastBuildTime="2013-01-08 18:20:05" lastBuildStatus="Failure" activity="Building"/>
    </Projects>

The "TDDium Project Name" field in the ProjectManager settings will need to be set to the full value of the Project
name attribute, complete with the branch name in parentheses (in this case, "foobar (master)").

