/*
 ### jQuery Star Rating Plugin v2.63 - 2009-03-13 ###
 * Home: http://www.fyneworks.com/jquery/star-rating/
 * Code: http://code.google.com/p/jquery-star-rating-plugin/
 *
	* Dual licensed under the MIT and GPL licenses:
 *   http://www.opensource.org/licenses/mit-license.php
 *   http://www.gnu.org/licenses/gpl.html
 ###
*//*
	Based on http://www.phpletter.com/Demo/Jquery-Star-Rating-Plugin/
 Original comments:
	This is hacked version of star rating created by <a href="http://php.scripts.psu.edu/rja171/widgets/rating.php">Ritesh Agrawal</a>
	It transforms a set of radio type input elements to star rating type and remain the radio element name and value,
	so could be integrated with your form. It acts as a normal radio button.
	modified by : Logan Cai (cailongqun[at]yahoo.com.cn)
*/

/*# AVOID COLLISIONS #*/
;if(window.jQuery) (function($){
/*# AVOID COLLISIONS #*/
	
	// IE6 Background Image Fix
	if ($.browser.msie) try { document.execCommand("BackgroundImageCache", false, true)} catch(e) { }
	// Thanks to http://www.visualjquery.com/rating/rating_redux.html
	
	// default settings
	$.rating = {
		cancel: 'Cancel Rating',   // advisory title for the 'cancel' link
		cancelValue: '',           // value to submit when user click the 'cancel' link
		split: 0,                  // split the star into how many parts?
		
		// Width of star image in case the plugin can't work it out. This can happen if
		// the jQuery.dimensions plugin is not available OR the image is hidden at installation
		starWidth: 16,
		
		//NB.: These don't need to be defined (can be undefined/null) so let's save some code!
		//half:     false,         // just a shortcut to settings.split = 2
		//required: false,         // disables the 'cancel' button so user can only select one of the specified values
		//readOnly: false,         // disable rating plugin interaction/ values cannot be changed
		//focus:    function(){},  // executed when stars are focused
		//blur:     function(){},  // executed when stars are focused
		//callback: function(){},  // executed when a star is clicked
		
		// required properties:
		group: {},// holds details of a group of elements which form a star rating widget
		calls: 0,// differentiates groups of the same name to be created on separate plugin calls
		event: {// plugin event handlers
			fill: function(gid, el, settings, state){ // fill to the current mouse position.
				//if(window.console) console.log(['fill', $(el), $(el).prevAll('.star_group_'+gid), arguments]);
				this.drain(gid);
				$(el).prevAll('.star_group_'+gid).andSelf().addClass('star_'+(state || 'hover'));
				// focus handler, as requested by focusdigital.co.uk
				var lnk = $(el).children('a'); val = lnk.text();
				if(settings.focus) settings.focus.apply($.rating.group[gid].valueElem[0], [val, lnk[0]]);
			},
			drain: function(gid, el, settings) { // drain all the stars.
				//if(window.console) console.log(['drain', $(el), $(el).prevAll('.star_group_'+gid), arguments]);
				$.rating.group[gid].valueElem.siblings('.star_group_'+gid).removeClass('star_on').removeClass('star_hover');
			},
			reset: function(gid, el, settings){ // Reset the stars to the default index.
				if(!$($.rating.group[gid].current).is('.cancel'))
					$($.rating.group[gid].current).prevAll('.star_group_'+gid).andSelf().addClass('star_on');
				// blur handler, as requested by focusdigital.co.uk
				var lnk = $(el).children('a'); val = lnk.text();
				if(settings.blur) settings.blur.apply($.rating.group[gid].valueElem[0], [val, lnk[0]]);
			},
			click: function(gid, el, settings){ // Selected a star or cancelled
				$.rating.group[gid].current = el;
				var lnk = $(el).children('a'); val = lnk.text();
				// Set value
				$.rating.group[gid].valueElem.val(val);
				// Update display
				$.rating.event.drain(gid, el, settings);
				$.rating.event.reset(gid, el, settings);
				// click callback, as requested here: http://plugins.jquery.com/node/1655
				if(settings.callback) settings.callback.apply($.rating.group[gid].valueElem[0], [val, lnk[0]]);
			}      
		}// plugin events
	};
	
	$.fn.rating = function(instanceSettings){
		if(this.length==0) return this; // quick fail
		
		instanceSettings = $.extend(
			{}/* new object */,
			$.rating/* global settings */,
			instanceSettings || {} /* just-in-time settings */
		);
		
		// increment plugin calls
		$.rating.calls++;
		
		// loop through each matched element
		this.each(function(i){
			
			var settings = $.extend(
				{}/* new object */,
				instanceSettings || {} /* current call settings */,
				($.metadata? $(this).metadata(): ($.meta?$(this).data():null)) || {} /* metadata settings */
			);
			////if(window.console) console.log([this.name, settings.half, settings.split], '#');
			
			// Generate internal control ID
			// - ignore square brackets in element names
			var eid = (this.name || 'unnamed-rating').replace(/\[|\]+/g, "_");
			
			// differentiate groups of the same name on separate plugin calls
			// SEE: http://code.google.com/p/jquery-star-rating-plugin/issues/detail?id=5
			var gid = $.rating.calls +'_'+ eid;
			
			// Grouping
			if(!$.rating.group[gid]) $.rating.group[gid] = {count: 0};
			i = $.rating.group[gid].count; $.rating.group[gid].count++;
			
			// Accept readOnly setting from 'disabled' property
			$.rating.group[gid].readOnly = $.rating.group[gid].readOnly || settings.readOnly || $(this).attr('disabled');
			
			// Things to do with the first element...
			if(i == 0){
				// Create value element (disabled if readOnly)
				$.rating.group[gid].valueElem = $('<input type="hidden" name="' + eid + '" value=""' + (settings.readOnly ? ' disabled="disabled"' : '') + '/>');
				// Insert value element into form
				$(this).before($.rating.group[gid].valueElem);
				
				if($.rating.group[gid].readOnly || settings.required){
					// DO NOT display 'cancel' button
				}
				else{
					// Display 'cancel' button
					$(this).before(
						$('<div class="cancel"><a title="' + settings.cancel + '">' + settings.cancelValue + '</a></div>')
						.mouseover(function(){ $.rating.event.drain(gid, this, settings); $(this).addClass('star_on'); })
						.mouseout(function(){ $.rating.event.reset(gid, this, settings); $(this).removeClass('star_on'); })
						.click(function(){ $.rating.event.click(gid, this, settings); })
					);
				}
			}; // if (i == 0) (first element)
			
			// insert rating option right after preview element
			eStar = $('<div class="star"><a title="' + (this.title || this.value) + '">' + this.value + '</a></div>');
			$(this).after(eStar);
			
			// Half-stars?
			if(settings.half) settings.split = 2;
			
			// Prepare division settings
			if(typeof settings.split=='number' && settings.split>0){
				var stw = ($.fn.width ? $(eStar).width() : 0) || settings.starWidth;
				var spi = (i % settings.split), spw = Math.floor(stw/settings.split);
				$(eStar)
				// restrict star's width and hide overflow (already in CSS)
				.width(spw)
				// move the star left by using a negative margin
				// this is work-around to IE's stupid box model (position:relative doesn't work)
				.find('a').css({ 'margin-left':'-'+ (spi*spw) +'px' })
			};
			
			// Remember group name so controls within the same container don't get mixed up
			$(eStar).addClass('star_group_'+gid);
			
			// readOnly?
			if($.rating.group[gid].readOnly)//{ //save a byte!
				// Mark star as readOnly so user can customize display
				$(eStar).addClass('star_readonly');
			//}  //save a byte!
			else//{ //save a byte!
				$(eStar)
				// Enable hover css effects
				.addClass('star_live')
				// Attach mouse events
				.mouseover(function(){ $.rating.event.drain(gid, this, settings); $.rating.event.fill(gid, this, settings, 'hover'); })
				.mouseout(function(){ $.rating.event.drain(gid, this, settings); $.rating.event.reset(gid, this, settings); })
				.click(function(){ $.rating.event.click(gid, this, settings); });
			//}; //save a byte!
			
			////if(window.console) console.log(['###', gid, this.checked, $.rating.group[gid].initial]);
			if(this.checked) $.rating.group[gid].current = eStar;
			
			// remove this checkbox - values will be stored in a hidden field
			$(this).remove();
			
			// reset display if last element
			if(i + 1 == this.length) $.rating.event.reset(gid, this, settings);
		
		}); // each element
			
		// initialize groups...
		for(gid in $.rating.group)//{ not needed, save a byte!
			(function(c, v, gid){ if(!c) return;
				$.rating.event.fill(gid, c, instanceSettings || {}, 'on');
				$(v).val($(c).children('a').text());
			})
			($.rating.group[gid].current, $.rating.group[gid].valueElem, gid);
		//}; not needed, save a byte!
		
		return this; // don't break the chain...
	};
	
	
	
	/*
		### Default implementation ###
		The plugin will attach itself to file inputs
		with the class 'multi' when the page loads
	*/
	$(function(){ $('input[type=radio].star').rating(); });
	
	
	
/*# AVOID COLLISIONS #*/
})(jQuery);
/*# AVOID COLLISIONS #*/
