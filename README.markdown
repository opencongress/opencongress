# OpenCongress - a Ruby on Rails application for displaying information about Congress

[Lighthouse Project Page](http://participatorypolitics.lighthouseapp.com/projects/35587-opencongress "link")

---

## Install Notes

### A. Dependencies

Start by installing all the packages you might need.

Ubuntu:

	sudo apt-get install postgresql postgresql-client postgresql-contrib libpq-dev ruby1.8 ruby1.8-dev 		rubygems libopenssl-ruby imagemagick libmagick9-dev gcj-4.4-jre

Mac OSX:

	sudo port install postgresql84 postgresql84-doc postgresql84-server ImageMagick


Then grab the gems you need:

	sudo gem install rails --version 2.3.2
	sudo gem install hpricot jammit json pg RedCloth ruby-openid simple-rss rmagick htmlentities

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
	
	development:
	  adapter: postgresql
	  database: opencongress_development
	  username: opencongress
	  password: (password from step B)
	  host: localhost

Now you can start the solr server and run the database migrations
	
	cd ..;rake solr:start
	rake db:migrate

### D. Data
   
Next, you will have to get the data from govtrack and fill in your database with the parse.

	mkdir -p data/govtrack/111
	rsync -az govtrack.us::govtrackdata/us/111/bills data/govtrack/111
	rsync -az govtrack.us::govtrackdata/us/111/repstats data/govtrack/111
	rsync -az govtrack.us::govtrackdata/us/111/bills.index.xml data/govtrack/111
	rsync -az govtrack.us::govtrackdata/us/111/committeeschedule.xml data/govtrack/111
	rsync -az govtrack.us::govtrackdata/us/111/rolls data/govtrack/111

Now, you will have to actually parse the data

	ruby bin/govtrack_parse_people.rb
	ruby bin/govtrack_parse_bills.rb
	ruby bin/govtrack_parse_committees.rb
	ruby bin/govtrack_parse_committee_schedules.rb
	ruby parse_individual_bills.rb

---

Copyright (c) 2005-2010 Participatory Politics Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
                     