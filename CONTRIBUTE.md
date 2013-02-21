# Contribute.md
This is the CONTRIBUTE.md for our project. Great to have you here. Have a look at our README.md if you're unfamiliar with Project Monitor.

## Resources
Product Manager: [Graham Siener](mailto:gsiener@pivotallabs.com)  
The google group for Project Monitor is [projectmonitor_pivotallabs](http://groups.google.com/group/projectmonitor_pivotallabs).  
The public Tracker project for ProjectMonitor is [here](http://www.pivotaltracker.com/projects/2872).

## A high level introduction to Project Monitor
There are two distinct layers to Project Monitor:

1. the front end which polls the back end for updates and
2. the back end which polls CI builds and receives webhook updates.

The front end is written in Backbone/CoffeeScript. Individual Backbone models are responsible for polling the database. Backbone views update when the model is updated.
The back end receives updates through a REST/json interface, or it uses delayed_job to poll CI instances.

## Gotchas (when things do not appear to be working as expected, try these...)
* If you're testing anything with CoffeeScript, you probably want to run `guard` so that the files are re-compiled each time.
* Are the workers running? Have you checked the worker log in log/delayed_job.log?
* You can run `rake projectmonitor:fetch_statuses` to force update the builds.

## Bug triage
If you encounter any bugs, feel free to file an issue in Github or contact our Product Manager: [Graham Siener](mailto:gsiener@pivotallabs.com).

## A final word
Please consider this a living document. When you've finished your work please take a minute to think of the developers who will follow in your footsteps. Is there anything missing from this document that you'd wished you'd known before you started coding?
