# Contributing

This is the CONTRIBUTING.md for our project. Great to have you here. Have a look at our README.md if you're unfamiliar with Project Monitor.

## Resources

Product Manager: [Mike McCormick](mailto:mmccormick@pivotal.io)  
The google group for Project Monitor is [projectmonitor_pivotallabs](http://groups.google.com/group/projectmonitor_pivotallabs).  
The public Tracker project for ProjectMonitor is [here](http://www.pivotaltracker.com/projects/2872).

## A high level introduction to Project Monitor

There are two distinct layers to Project Monitor:

1. the front end which polls the back end for updates and
2. the back end which polls CI builds and receives webhook updates.

The front end is written in Backbone/CoffeeScript. Individual Backbone models are responsible for polling the database. Backbone views update when the model is updated.
The back end receives updates through a REST/json interface, or it uses delayed_job to poll CI instances.

## Development

The public Tracker project for ProjectMonitor is [here](http://www.pivotaltracker.com/projects/2872).

### Running tests

To run tests, run:

    rake setup
    rake spec

### Javascript tests

To run Jasmine tests, run this once when setting up the project or if you haven't consistently been running guard:

    rake jasmine:compile_coffeescript

To keep your jasmine tests current, run:

    guard

Install phantomjs if needed:

    brew install phantomjs

Then, to run Jasmine tests from the command line, run:

    RAILS_ENV=test bundle exec rake spec:javascript

To run Jasmine tests from the browser, with a rails server running, visit [http://localhost:3000/specs](http://localhost:3000/specs)

See the [jasmine-rails](https://github.com/searls/jasmine-rails) documentation for more details.

### Set up Vagrant

[Vagrant](http://www.vagrantup.com/) automatically sets up virtual machines to run 
Jenkins. First install VirtualBox. Then run the following commands to set it up.

    vagrant up

Useful commands

    vagrant ssh
    vagrant halt
    vagrant provision
    vagrant destroy #If you just halt, it will not rebuild everything from scratch

Once the VM has started, services will be available at `192.168.33.10`.

### Development server

To run a local development server and worker, run:

    foreman start

## Deploying to Github

Project Monitor has been moved under the "Pivotal" organization. In order to have push privileges to the repo, you will need to request that your GitHub account is added as a collaborator.

## Gotchas (when things do not appear to be working as expected, try these...)

* If you're testing anything with CoffeeScript, you probably want to run `guard` so that the files are re-compiled each time.
* Are the workers running? Have you checked the worker log in log/delayed_job.log?
* You can run `rake projectmonitor:fetch_statuses` to force update the builds.

## Bug triage

If you encounter any bugs, feel free to file an issue in Github or contact our Product Manager: [Graham Siener](mailto:gsiener@pivotallabs.com).

## CI

CI for ProjectMonitor is [here](http://travis-ci.org/pivotal/projectmonitor), and it's aggregated at [ci.pivotallabs.com](http://ci.pivotallabs.com)
(that's an instance of ProjectMonitor, of course).


## A final word

Please consider this a living document. When you've finished your work please take a minute to think of the developers who will follow in your footsteps. Is there anything missing from this document that you'd wished you'd known before you started coding?
