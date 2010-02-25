<div class="hideme">
<h2> OpenCongress - a Ruby on Rails application for displaying information about Congress</h2>

<h4><a href="http://participatorypolitics.lighthouseapp.com/projects/35587-opencongress">Lighthouse Project Page</a></h4>
<h4><a href="http://www.opencongress.org/about/code">OpenCongress for Developers</a></h4>
<hr />

</div>
## Getting started with our code

### A. Dependencies

Start by installing all the packages required by OpenCongress.

so for Ubuntu:

	sudo apt-get install postgresql postgresql-client postgresql-contrib libpq-dev ruby1.8 ruby1.8-dev rubygems libopenssl-ruby imagemagick libmagick9-dev gcj-4.4-jre

---

or Mac OS X, start by installing [MacPorts](http://www.macports.org/), then run:

	sudo port install postgresql84 postgresql84-doc postgresql84-server ImageMagick md5sha1sum

Follow the instructions from the port install for initializing your database

---


Then grab the gems you need:

<pre>
<code>sudo gem install rails --version 2.3.2<br/>
sudo gem install bluecloth hpricot htree jammit json pg RedCloth ruby-openid simple-rss rmagick htmlentities oauth</code>
</pre>

__Note for OS X:__ *You may need to specify additional compile options for the pg gem. Make sure pg_config is in PATH and run* `sudo env ARCHFLAGS="-arch x86_64" gem install pg`

### B. DB setup

Switch to the postgres user and setup a db user following prompts for password and superuser.

	sudo su postgres
	createuser opencongress -P

Create your database
	
	createdb opencongress_development -O opencongress

Import the tsearch2 backwards compatibility lib from wherever your postgres contribs got installed.
	
	psql opencongress_development < /your/install/share/postgresql/contrib/8.4/tsearch2.sql

`exit` postgres user

### C. App Setup

Copy over example yml files in /config

	cd config; for file in `ls *example*`; do cp $file `expr "$file" : '\([^-\.]*\)'`.yml; done

Edit database.yml:
	
<pre><code>development:<br/>
adapter: postgresql<br/>
database: opencongress_development<br/>
username: opencongress<br/>
password: (password from step B)<br/>
host: localhost<br/>
</code></pre>

Now you can start the solr server and run the database migrations
	
	cd ..;rake solr:start
	rake db:migrate

### D. Data
   
create some dirs for data

Make sure all your data paths are set and exist in your environment file then run `rake update:all` to fetch and parse all available data sources. This process will take a very long time. Take a look at /lib/tasks/daily.rake for all the rake tasks if you want to run them individually.

Now just a `script/server` and you should be running
 
<div class="hideme"> 

<hr />

<p>Copyright (c) 2005-2010 Participatory Politics Foundation</p>

<p>This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.
</p>
<p>This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
</p>
<p>You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
</p>
</div>
