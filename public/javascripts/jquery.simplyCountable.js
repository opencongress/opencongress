/*
* jQuery Simply Countable plugin
* Provides a character counter for any text input or textarea
* 
* @version  0.2
* @homepage http://github.com/aaronrussell/jquery-simply-countable/
* @author   Aaron Russell (http://www.aaronrussell.co.uk)
*
* Copyright (c) 2009 Aaron Russell (aaron@gc4.co.uk)
* Dual licensed under the MIT (http://www.opensource.org/licenses/mit-license.php)
* and GPL (http://www.opensource.org/licenses/gpl-license.php) licenses.

* modified for OC [agp]
*/

(function($){

  $.fn.simplyCountable = function(options){
    
    options = $.extend({
      counter: '#counter',
      post: '#post',
      nopost: '<span id="post">Over Length Limit</span>',
      countType: 'characters',
      maxCount: 140,
      countDirection: 'down',
      safeClass: 'safe',
      overClass: 'over'
    }, options);
    
    
    var countable = this;
    var post = $(options.post)

    var countCheck = function(){
           
      if (options.countType === 'words'){
        var count = options.maxCount - countable.val().split(/[\s]+/).length;
        if (countable.val() === '') count += 1;
      }
      else var count = options.maxCount - countable.val().length;
      
      if (!$(options.counter).hasClass(options.safeClass) && !$(options.counter).hasClass(options.overClass)){
        if (count < 0) $(options.counter).addClass(options.overClass);
        else $(options.counter).addClass(options.safeClass);
      }
      else if (count < 0 && $(options.counter).hasClass(options.safeClass)){
        $(options.counter).removeClass(options.safeClass).addClass(options.overClass);
        $(options.post).replaceWith(options.nopost);
      }
      else if (count >= 0 && $(options.counter).hasClass(options.overClass)){
        $(options.counter).removeClass(options.overClass).addClass(options.safeClass);
        $(options.post).replaceWith(post);
      }
      
      if (options.countDirection === 'up'){
        count = count - (count*2) + options.maxCount;
      }
      
      $(options.counter).text(count);
    };
    countCheck();
    
    countable.keyup(countCheck);
    
  };

})(jQuery);