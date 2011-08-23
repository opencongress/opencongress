#!/bin/sh

# this url needs a key to actually execute.  not checking in, but will run on dev.
/usr/local/bin/curl -sS 'http://www.opencongress.org/contact_congress_letters/get_replies' | /bin/awk '{ print strftime("\n%Y-%m-%d %H:%M:%S ::"), $0; }'