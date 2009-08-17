Q. Where are the template files for this theme?

A. This is the default theme folder for Vanilla. It relies on all of
   the standard template files found within the root themes folder.
   
Q. I want to make my own style for the default vanilla theme. What should I do?

A. Navigate to the styles folder within this directory. Copy the "default"
   folder and rename it to your new style's name. Then edit the css and image
   files within that.
   
Q. How can I apply my new style to Vanilla?

A. First, set it as the default style folder in your conf/settings file with
   the following line:
   
   $Configuration['DEFAULT_STYLE'] = './themes/vanilla/styles/your_new_style/';
   
   That line will make it so that non-signed-in users see your new style. Now
   you need to make signed-in users see your style. Add your style to the
   database with the following MySQL query:
   
   insert into LUM_Style
   (AuthUserID, Name, Url)
   values (1, 'Your style name', './themes/vanilla/styles/your_new_style/');
   
   Now you need to assign everyone in your database to see that style. First
   find out what StyleID MySQL assigned to your style:
   
   select StyleID from LUM_Style
   where Url = './themes/vanilla/styles/your_new_style/';
   
   Once you know what the StyleID is, update the user table with the following
   MySQL query:
   
   update LUM_User set StyleID = `your new StyleID`
   
Q. Can't I just alter the default Vanilla style instead?

A. You can, but when upgrades to Vanilla come out, they will most likely include
   new stylesheets, and we will be advising you to overwrite all old Vanilla
   files.
   
Q. I want to change a template file in the root folder. How should I do it?

A. If you only want to make a minor change, you should copy the template file
   you want to alter into this directory. Then change it as much as you want.
   DO NOT ALTER THE ROOT FOLDER'S TEMPLATE FILES DIRECTLY. THEY WILL BE
   OVERWRITTEN AS UPGRADES ARE MADE TO VANILLA.
   
   If, however, you want to make a multitude of changes, we suggest that you
   create a whole new theme and possibly even share it with the community.
   
Q. How do I create a new theme?

A. Begin by copying the "vanilla" folder within the root "/themes" folder and
   pasting it with your new theme name. Once this is complete, you have a
   skeleton of the folder structure, images, and css required for a theme.
   
   Next take any templates you wish to alter and copy them from the root themes
   folder into your new theme folder. Then alter them as needed. We strongly
   advise that you ONLY copy the template files that you need to alter. This
   will make upgrading easier later on since you will easily see which of your
   templates may need updating in order to work with newer versions of Vanilla.
   
   Finally, change the css and image files as necessary to work with your new
   templates.
   
Q. How do I apply my new theme?

A. Add the following line to your conf/settings.php file:

   $Configuration['THEME_PATH'] = '/path/to/vanilla/themes/your_theme_name/';

Q. I don't get it. How does Vanilla know which template file to include?

A. Once you've configured your THEME_PATH, Vanilla will always look in that
   folder for a template file *first*. If Vanilla can't find your custom
   template file, it will include the base template file in the root themes
   folder.
   
Q. What are each of these template files for? I can't figure out which one to
   change.
   
A. We've done our best to give each of the template files descriptive names.
   Here are some pointers which may help you out in finding your way around:
   
      * Any templates beginning with "account_" are used on the account tab.
      
      * Any templates beginning with "people_" are used on the sign in, sign
        out, register, and password retrieval screens.
        
      * Any templates beginning with "search_" are used on the search tab.
      
      * Any templates beginning with "settings_" are used on the settings tab.
      
      * Any templates ending with "_nopostback" are input forms.
      
      * Any templates ending with "_validpostback" are the results of
        successfully submitting the related "_nopostback" form.
        
      * "head.php" is used on every screen and contains everything up to and
        including the "body" tag.
        
      * "menu.php" is used to write the containing structure of Vanilla AND
         the Vanilla tab menu.
        
      * "foot.php" can be considered the closing of everything that was opened
        in "menu.php".
        
      * "page_end.php" is where the body is closed.
      
Q. My question wasn't answered here. Where can I go for help?

A. http://lussumo.com/community