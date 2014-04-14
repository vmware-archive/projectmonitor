# Displaying Your Project's Status

Just open a browser on `/`. The page refreshes every 30 seconds with the latest
status fetched by the cron job or received via Webhook. That is,
refreshing the page doesn't cause the individual builds to be re-polled.

## Layout

The layout consists of a grid of tiles representing the projects.  The
number of projects that need to be displayed is determined automatically.

## Example

[![](http://f.cl.ly/items/2R2U392y1D2B033I0z3J/Screen%20Shot%202013-04-02%20at%208.27.44%20PM.png)](http://ci.pivotallabs.com)

## Tile colors

Tiles are green for green projects, red for red projects, and light gray if the
project's build server cannot be reached. If the build server is online but no
builds have been run then the tile will appear in yellow. A pulsating tile indicates
that a new build is currently in progress.

## Project Ticker Codes

Each tile shows the project's brief ticker code.  If not chosen explicitly,
this will be the first 4 letters of the project.

## Build Statuses

To the right of the ticker and name, each project lists the amount of time
since the last build, followed by the build status history.  The last 5-8 builds
are displayed from left to right, in reverse chronological order -- the most
recent build will be on the left and the least recent on the right.
Successful builds are marked with a filled in circle, and unsuccessful builds
are marked with an x.

## Tags

You can enter tags for a project (separated by commas) on the project edit page.  You can then have ProjectMonitor display
only projects that match a set of tags by going to /?tags=tag1,tag2

## Aggregate Projects

Striped tiles indicate the aggregate status of several projects.  Click on an
aggregate project to see the status of its component projects.

## Pivotal Tracker Integration

ProjectMonitor can display basic [Pivotal Tracker](http://pivotaltracker.com) information.  When
configured, the current velocity will be displayed, as well as a graph showing points completed for
the current iteration and the past 9 iterations.  To add this integration, you will need to add your
Pivotal Tracker project ID and a Pivotal Tracker API key in the admin section.

