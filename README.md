Description
===========

CiMonitor is a CI display aggregator. It displays the status of multiple Continuous Integration builds on a single web page.
The intent is that you display the page on a big screen monitor or TV so that the status of all your projects' builds
are highly visible/glanceable (a "Big Visible Chart"). CiMonitor currently supports Cruise Control and Hudson builds, but the plan
is to add support others (such as Integrity).

We use CiMonitor internally at Pivotal Labs to display the status of the builds for all our client projects. We also have an
instance of CiMonitor running at [ci.pivotallabs.com](http://ci.pivotallabs.com) that we use for displaying the status of the builds of various
open source projects - both of projects Pivotal Labs maintains (such as Refraction) and of non-Pivotal projects (such as
Rails).

## Installation

### Get the code

CiMonitor is a Rails application. To get the code, execute the following:

    git clone git://github.com/pivotal/cimonitor.git pivotal_cimonitor
    cd pivotal_cimonitor
    git submodule init
    git submodule update

### Install gem dependencies

If you don't have geminstaller installed, then execute:

    sudo gem install geminstaller

Then execute:

    sudo geminstaller

### Set up the database

You'll need a database (MySQL works). Create it with whatever name you want. Copy `config/database.yml.example` to
`database.yml` and edit the production environment configuration so it's right for your database. Then execute:

    RAILS_ENV=production rake db:migrate

### Set up the site keys

Copy `config/site_keys.rb.example` to `config/site_keys.rb` and change `REST_AUTH_SITE_KEY` to something secret.

### Set up cron

Add a cron job for `RAILS_ENV=production rake cimonitor:fetch_statuses > fetch_statuses.log 2>&1` at whatever frequency you
like. This is what goes out and hits the individual builds. We find that if you do this too frequently it
can swamp the builds. On the other hand, you don't want CiMonitor displaying stale information. At Pivotal we set it up to
run every 3 minutes.

### Start the application

Execute:

    nohup RAILS_ENV=production script/server & > cimonitor.log 2> &1

## Configuration

Each build that you want CiMonitor to display is called a "project" in CiMonitor. You need to login to set up projects.

### Create a user

CiMonitor uses the [Restful Authentication plugin](http://github.com/technoweenie/restful-authentication) for user security.
Your first user must be created at the command line.

    RAILS_ENV=production script/console
    User.create!(:login => 'john', :name => 'John Doe', :email => 'jdoe@example.com', :password => 'password', :password_confirmation => 'password')

After that, you can login to CiMonitor and use the "New User" link to create new users.

### Log in

Open a browser on CiMonitor. Login by clicking on "Login" in the upper-right corner.

### Add projects

Click on "Projects" in the upper-right corner. Click on "New Project" and enter the details for a build
you want to display on CiMonitor. The "Name", "Project Type", and "Feed URL" are required. If your Feed URL is
http://myhost.com:3333/projects/MyProject, then your RSS URL is probably http://myhost.com:3333/projects/MyProject.rss.

Optionally, if your Build system is behind Basic Authentication or Digest Authentication, you can enter the credentials.

If you want to temporarily hide your build on CiMonitor, you can uncheck the "Enable" checkbox.

CiMonitor's main display page is at `/`. You can always get back there by clicking on the "Pivotal Labs" logo at the upper
left.

## Display

Just open a browser on `/`. The page will refresh every 30 seconds. When it refreshes, it shows whatever status was last
fetched by the cron job. That is, a refresh doesn't cause the individual Builds to be polled.

CiMonitor shows a big green check or a big red X to indicate a build's status. In addition, it shows the history of a
project's builds: the previous 9 are displayed underneath as green or red dots. The larger the dot, the more recent the
build.

CiMonitor looks good on an iPhone, by the way :)

## Notifications

CiMonitor can inform you of builds that have been red for more than 24 hours. Set up cron to daily execute
`RAILS_ENV=production rake cimonitor:red_over_one_day_notification > red_over_one_day_notification.log 2>&1`

## Tags

You can enter tags for a project (separated by commas) on the project edit page.  You can then have CiMonitor display
only projects that match a set of tags by going to /?tags=tag1,tag2

## CI

CI for CiMonitor is [here](http://ci.pivotallabs.com:3333/builds/CiMonitor), and it's aggregated at [ci.pivotallabs.com](http://ci.pivotallabs.com)
(that's an instance of CiMonitor, of course).

## Pivotal Tracker

The public Tracker project for CiMonitor is [here](http://www.pivotaltracker.com/projects/2872).