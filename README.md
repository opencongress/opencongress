<div class="hideme">
<h2> OpenCongress - a Ruby on Rails application for displaying information about Congress</h2>

<h4><a href="http://participatorypolitics.lighthouseapp.com/projects/35587-opencongress">Lighthouse Project Page</a></h4>
<h4><a href="http://www.opencongress.org/about/code">OpenCongress for Developers</a></h4>
<hr />

</div>
## Getting started with our code

### A. Dependencies

Start by installing all the packages required by OpenCongress.

For Ubuntu:

	sudo apt-get install postgresql postgresql-client postgresql-contrib libpq-dev ruby1.8 ruby1.8-dev rubygems libopenssl-ruby imagemagick libmagick9-dev gcj-4.4-jre

---

or Mac OS X, start by installing [MacPorts](http://www.macports.org/), then run:

	sudo port install postgresql84 postgresql84-doc postgresql84-server ImageMagick md5sha1sum wget

Follow the instructions from the port install for initializing your database

---


Then grab the gems you need:

<pre>
<code>
[sudo] gem install bundler
bundle install
</code>
</pre>

__Note for OS X:__ *You may need to specify additional compile options for the pg gem. Make sure pg_config is in PATH and run* `sudo env ARCHFLAGS="-arch x86_64" gem install pg`

### B. Database setup

Create a postgresql install, based on the database.yml file:
rake db:init

Import the tsearch2 backwards compatibility lib from wherever your postgres contribs got installed.
	
	psql opencongress_development < /your/install/share/postgresql/contrib/8.4/tsearch2.sql

`exit` postgres user

### C. App Setup

Now you can start the solr server and run the database migrations
	
	cd ..;rake solr:start
	rake db:structure:load
	rake db:seed

### D. Data
   
create some dirs for data

Make sure all your data paths are set and exist in your environment file then run `rake update:all` to fetch and parse all available data sources. This process will take a very long time. Take a look at /lib/tasks/daily.rake for all the rake tasks if you want to run them individually.

Now just a `script/server` and you should be running
 
<div class="hideme"> 

<hr />

<p>Copyright (c) 2005-2010 Participatory Politics Foundation</p>

<p>OpenCongress is licensed, as a whole, under AGPLv3. Components added prior to
OpenCongress version 3 (July 27, 2011) were and are licensed under GPLv3. All components added for or after
OpenCongress version 3 are licensed AGPLv3. When you contribute a patch to OpenCongress, it will be licensed under AGPLv3. See LICENSE-AGPLv3 file for details.
</div>
