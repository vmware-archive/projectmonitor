Description
===========

Pulse is a CI display aggregator. It displays the status of multiple Continuous Integration builds on a single web page.
The intent is that you display the page on a big screen monitor or TV so that the status of all your projects' builds
are highly visible/glanceable (a "Big Visible Chart"). Pulse currently only supports Cruise Control builds, but the plan
is to add support others (such as Integrity).

We use Pulse internally at Pivotal Labs to display the status of the builds for all our client projects. We also have an
instance of Pulse running at [ci.pivotallabs.com](http://ci.pivotallabs.com) that we use for displaying the status of the builds of various
open source projects - both of projects Pivotal Labs maintains (such as Refraction) and of non-Pivotal projects (such as
Rails).

## Installation

### Get the code

Pulse is a Rails application. To get the code, execute the following:

    git clone git://github.com/pivotal/pulse.git pivotal_pulse
    cd pivotal_pulse
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

Add a cron job for `RAILS_ENV=production rake pulse:fetch_statuses > fetch_statuses.log 2>&1` at whatever frequency you
like. This is what goes out and hits the individual Cruise Control builds. We find that if you do this too frequently it
can swamp the builds. On the other hand, you don't want Pulse displaying stale information. At Pivotal we set it up to
run every 3 minutes.

### Start the application

Execute:

    nohup RAILS_ENV=production script/server & > pulse.log 2> &1

## Configuration

Each build that you want Pulse to display is called a "project" in Pulse. You need to login to set up projects.

### Create a user

Pulse uses the [Restful Authentication plugin](http://github.com/technoweenie/restful-authentication) for user security.
Your first user must be created at the command line.

    RAILS_ENV=production script/console
    User.create!(:login => 'john', :name => 'John Doe', :email => 'jdoe@example.com', :password => 'password', :password_confirmation => 'password')

After that, you can login to Pulse and use the "New User" link to create new users.

### Log in

Open a browser on Pulse. Login by clicking on "Login" in the upper-right corner.

### Add projects

Click on "Projects" in the upper-right corner. Click on "New Project" and enter the details for a Cruise Control build
you want to display on Pulse. The only required fields are "Name" and "Cruise Control RSS URL". If your Cruise URL is
http://myhost.com:3333/projects/MyProject, then your RSS URL is probably http://myhost.com:3333/projects/MyProject.rss.

Optionally, if your Cruise Build is behind Basic Authentication or Digest Authentication, you can enter the credentials.

If you want to temporarily hide your build on Pulse, you can uncheck the "Enable" checkbox.

Pulse's main display page is at `/`. You can always get back there by clicking on the "Pivotal Labs" logo at the upper
left.

## Display

Just open a browser on `/`. The page will refresh every 30 seconds. When it refreshes, it shows whatever status was last
fetched by the cron job. That is, a refresh doesn't cause the individual Cruise Builds to be polled.

Pulse shows a big green check or a big red X to indicate a build's status. In addition, it shows the history of a
project's builds: the previous 9 are displayed underneath as green or red dots. The larger the dot, the more recent the
build.

Pulse looks good on an iPhone, by the way :)

## Notifications

Pulse can inform you of builds that have been red for more than 24 hours. Set up cron to daily execute
`RAILS_ENV=production rake pulse:red_over_one_day_notification > red_over_one_day_notification.log 2>&1`

