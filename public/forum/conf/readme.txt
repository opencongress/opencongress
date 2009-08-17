
About Vanilla Configuration
===========================

All customizations to Vanilla configuration settings should be done in this
conf (short for "Configuration") folder. After you run the Vanilla installer,
this conf folder should contain four files:

1. database.php

   The database.php file contains any Vanilla configuration settings specific to
   your database. For example, your database host name, database name, database
   login and database password. It can also contain custom database array
   structure definitions (don't worry if you don't know what those are).
   
   If you want your installation to be extra secure, you can move your
   database.php file to a non-web-accessable directory and change the path to
   the file in your conf/settings.php file with the DATABASE_PATH configuration
   variable.
   
2. extensions.php

   This file contains all enabled extensions in your Vanilla installation. The
   file is completely erased and rebuilt when extensions are added to or removed
   from your Vanilla installation. If you enable an extension that has bugs
   which prevent the extension management from working, you can edit this file
   and remove the offending extension.
   
3. language.php

   This file is not edited by Vanilla in any way. It's purpose is to allow you 
   to re-define language definitions made in 
   /languages/yourlanguage/definitions.php. You should NEVER edit the files in
   your /languages folder. You should always copy the definition you want to
   change into this file and edit it here.
   
4. settings.php

   This is the main settings file where most of your custom configuration
   settings should go. Vanilla will use this file when making settings changes
   through various forms in the application, and you can feel free to manually
   make changes in here as well.