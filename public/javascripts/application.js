// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function openRollCallOverlay(div_id)
{
  $j('#'+div_id).jqmShow();
}
function replace(new_id, old_id)
{
    $(old_id).hide();
    $(new_id).show();
}

function change_vis(el)
{
    if (Element.visible(el))
        Element.hide(el)
    else
        Element.show(el)
}

function change_vis_text(el1, el2, show_text, hide_text)
{
    if (Element.visible(el1))
        Element.update(el2, show_text)
    else
        Element.update(el2, hide_text)
    new Effect.toggle(el1, 'blind', { duration: 1.0 })
}

function show_search_options()
{
  Effect.BlindDown(document.getElementById('search_options'))
}

function show_learn_more()
{
  Effect.Appear(document.getElementById('learn_more'));
  $("learn-more-link").innerHTML = '<a href="/about/congress" class="arrow">Learn more</a></div>';
}

function dropdown_open(name)
{
  Effect.BlindDown(name)
}

function dropdown_close(name)
{
  Effect.BlindUp(name)
}

function toggle(div_name)
{
  Element.toggle('show_' + div_name)
  Element.toggle('hide_' + div_name)
  Effect.toggle(div_name, 'blind', { duration: 1.0 })
}
function duplicateSubscribeEmail()
{
  document.subscribeform.elements["emailconfirm"].value = document.subscribeform.elements["email"].value;
  
  return true;
}
function imagepop(url)
{
  var ipops=window.open(url,"","width=720, height=555")
}

function changePage(newLocId)
{
  newLoc = document.getElementById(newLocId)
  nextPage = newLoc.options[newLoc.selectedIndex].value
		
  if (nextPage != "")
  {
    document.location.href = nextPage
  }
}

NotebookForm = {
	toggleForm: function(field){	
		div_name  = 'add-' + field;		
		form_name = 'add-' + field + '-form';
		
		div = $(div_name);
		showIt = !div.visible();
		
		NotebookForm.hideAllForms();
		// show the current one if it's a show request
		if(showIt){
			new Effect.BlindDown(div_name,{duration: 0.3});			
		}
	},

	hideAllForms: function(){
		$('jqmWindow').hide();
	},
	
	hideAllFormsOld: function(){
		// hide all of them
		$$('div.notebook-form-div').each(Element.hide);		
		$$('form.notebook-form').each(function(el) {
		    Form.reset(el.id);		
		});
		if($('notebook-items').childNodes.length > 1){
			$('no-items').hide();
		}else{
			$('no-items').show();
		}
	},

//value="(http://[^&]*\.com/v/[^&]*)

	setTitleFromEmbed: function(embedField){
		var result = "";
		var embed = $F(embedField);
		var regexp = /value=\"(http:\/\/[^&]*\.com\/v\/[^&]*)/ ;
		var matches = embed.match(regexp);
		if(matches.size() > 0){
			match = matches[1];
			
			titleField = Form.getInputs(embedField.form,'text','notebook_video[title]')[0];
			urlField = Form.getInputs(embedField.form,'hidden','notebook_video[url]')[0];
			
			titleField.disable();		
			titleField.value = 'Finding title...';
		
			url = '';
			//find youtube url
			if(match.search("www.youtube.com")){
				var regexp = /value="http:\/\/[^&]*\.com\/v\/([^&]*)/ ;
				var matches = embed.match(regexp);
				if(matches.size() > 0){
					url = "http://youtube.com/watch?v=" + matches[1];
					urlField.value = url;											
				}
			
			}
		
			if(url == ''){
				return false;
			}

			//$('finding-title-status').show();
			ajax = new Ajax.Request('/scrape_tools/get_url_title', {
				parameters: {
					url: url
				}
			,
			onSuccess:function(response){
				result = response.responseText;
				titleField.value = result;
				titleField.enable();
			} 
			});
			return true;
		}else{
			alert('you must specify a valid embed');
			return false
		}		
	},

	setTitleFromUrl: function(urlField){
		var result = "";
		var url = $F(urlField);
		var regexp = /(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/ ;
		if(regexp.test(url)){
			titleElement = Form.getInputs(urlField.form,'text','notebook_link[title]')[0];
			titleElement.disable();		
			titleElement.value = 'Finding title...';
			//$('finding-title-status').show();
			ajax = new Ajax.Request('/scrape_tools/get_url_title', {
				parameters: {
					url: url
				}
			,
			onSuccess:function(response){
				result = response.responseText;
	//			$('finding-title-status').hide();
				titleElement.value = result;
				titleElement.enable();
			} 
			});
			return true;
		}else{
			alert('you must specify a valid url');
			return false
		}
	}
}

Ajax.Responders.register({
  onCreate: function(request) {
    // don't show the throbber if it's a search autocomplete request
    if ($('search-field') && $('search-field').value.length >= 3)
      return;

    var match = /pn_ajax/.test(request.url)
    if (match == true)
      return;
      
    if ($('loading') && Ajax.activeRequestCount>0)
      Effect.Appear('loading',{duration:0.5,queue:'front'});
  },
  onComplete: function() {
    // don't show the throbber if it's a search autocomplete request
    if ($('search-field') && $('search-field').value.length >= 3)
      return;
    
    if ($('loading') && Ajax.activeRequestCount==0)
      Effect.Fade('loading',{duration:0.5,queue:'end'});
       }
});  

function ToggleNotebookForm(field){
	
//	form_name = 'add-' + field + '-form';
  //	Effect.toggle(form_name, 'slide', { duration: 1.0 })
}

NotebookForm = {
	toggleForm: function(field){	
		div_name  = 'add-' + field;		
		form_name = 'add-' + field + '-form';
		
		div = $(div_name);
		showIt = !div.visible();
		
		NotebookForm.hideAllForms();
		// show the current one if it's a show request
		if(showIt){
			new Effect.BlindDown(div_name,{duration: 0.3});			
		}
	},

	hideAllForms: function(){
		$j('#add-link').jqmHide();
		$j('#add-video').jqmHide();
		$j('#add-note').jqmHide();
		$j('#add-file').jqmHide();
	},
	
	hideAllFormsOld: function(){
		// hide all of them
		$$('div.notebook-form-div').each(Element.hide);		
		$$('form.notebook-form').each(function(el) {
		    Form.reset(el.id);		
		});
		if($('notebook-items').childNodes.length > 1){
			$('no-items').hide();
		}else{
			$('no-items').show();
		}
	},

//value="(http://[^&]*\.com/v/[^&]*)

	setTitleFromEmbed: function(embedField){
		var result = "";
		var embed = $F(embedField);
		var regexp = /value=\"(http:\/\/[^&]*\.com\/v\/[^&]*)/ ;
		var matches = embed.match(regexp);
		if(matches.size() > 0){
			match = matches[1];
			
			titleField = Form.getInputs(embedField.form,'text','notebook_video[title]')[0];
			urlField = Form.getInputs(embedField.form,'hidden','notebook_video[url]')[0];
			
			titleField.disable();		
			titleField.value = 'Finding title...';
		
			url = '';
			//find youtube url
			if(match.search("www.youtube.com")){
				var regexp = /value="http:\/\/[^&]*\.com\/v\/([^&]*)/ ;
				var matches = embed.match(regexp);
				if(matches.size() > 0){
					url = "http://youtube.com/watch?v=" + matches[1];
					urlField.value = url;											
				}
			
			}
		
			if(url == ''){
				return false;
			}

			//$('finding-title-status').show();
			ajax = new Ajax.Request('/scrape_tools/get_url_title', {
				parameters: {
					url: url
				}
			,
			onSuccess:function(response){
				result = response.responseText;
				titleField.value = result;
				titleField.enable();
			} 
			});
			return true;
		}else{
			alert('Please specify a valid embed');
			return false
		}		
	},

	setTitleFromUrl: function(urlField){
		var result = "";
		var url = $F(urlField);
		var regexp = /(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/ ;
		if(regexp.test(url)){
			titleElement = Form.getInputs(urlField.form,'text','notebook_link[title]')[0];
			titleElement.disable();		
			titleElement.value = 'Finding title...';
			//$('finding-title-status').show();
			ajax = new Ajax.Request('/scrape_tools/get_url_title', {
				parameters: {
					url: url
				}
			,
			onSuccess:function(response){
				result = response.responseText;
	//			$('finding-title-status').hide();
				titleElement.value = result;
				titleElement.enable();
			} 
			});
			return true;
		}else{
			alert('Please specify a valid url. For example: http://www.sunlightfoundation.com');
			return false
		}
	}
}

Effect.ScrollToEnd = function(element) {
	var telem = $(element)
	var left = parseInt(telem.getStyle('left'));
        var pwidth = parseInt(telem.getStyle('width'));
	var end = 500;
	if (left >= -500) {
		return new Effect.Move(element, { x: 0, y: 0, mode: 'absolute' });
	} else {
	    return new Effect.Move(element, { x: +end, y: 0, mode: 'relative' });
    }
}

Effect.ScrollToBeg = function(element) {
	var telem = $(element)
	var left = parseInt(telem.getStyle('left'));
        var pwidth = parseInt(telem.getStyle('width'));
        var stopper = pwidth - 983;
	var end = 500;
	if (left <= ((stopper - end)* -1)) {
		return new Effect.Move(element, { x: (stopper * -1), y: 0, mode: 'absolute' });
	} else {
	    return new Effect.Move(element, { x: -end, y: 0, mode: 'relative' });
    }
}

BillText = {
	mouseOverSection: function(nid){
		menu_div  = 'bill_text_section_menu_' + nid;		
    //setStyleById('bill_text_section_' + nid, 'background', '#F0F0F0');
    
    Element.show(menu_div)
  },
  
  mouseOutSection: function(nid){	
		menu_div  = 'bill_text_section_menu_' + nid;		
    //setStyleById('bill_text_section_' + nid, 'background', '#fff');

    Element.hide(menu_div)
  },
  
  showTextChanges: function(){
    $('bill_text_show_changes_link').hide();
    $('bill_text_hide_changes_link').show();

    $$('.bill_text_changed-from').each(Element.show);
    $$('.bill_text_removed').each(Element.show);
    
    setStyleByClass('span','bill_text_changed-to','color','#00CD66');
    setStyleByClass('span','bill_text_inserted','color','#00CD66');
    
    Effect.BlindDown('bill_text_changes_key');
  },

  hideTextChanges: function(){
    $$('.bill_text_changed-from').each(Element.hide);
    $$('.bill_text_removed').each(Element.hide);

    $('bill_text_show_changes_link').show();
    $('bill_text_hide_changes_link').hide();
    
    setStyleByClass('span','bill_text_changed-to','color','#000');
    setStyleByClass('span','bill_text_inserted','color','#000');
    
    Effect.BlindUp('bill_text_changes_key');
  },
  
  showComments: function(version, nid) {
    Element.show('bill_text_comments_' + nid);
    
    Element.hide('show_comments_link_' + nid);
    Element.show('close_comments_link_' + nid);
    
    new Ajax.Updater('bill_text_comments_' + nid, "/comments/bill_text_comments?version=" + version + "&nid=" + nid);
    
    Element.addClassName('bill_text_section_' + nid, 'selected');
  },
  
  closeComments: function(version, nid) {
    //Element.hide('bill_text_comments_' + nid);
    Effect.BlindUp('bill_text_comments_' + nid);
    
    Element.show('show_comments_link_' + nid);
    Element.hide('close_comments_link_' + nid);
    
    Element.removeClassName('bill_text_section_' + nid, 'selected');
  },
  
  highlightNode: function(nid) {
    setStyleById('bill_text_section_' + nid, 'background', '#D9D9F3');
    Effect.ScrollTo('bill_text_section_' + nid, {offset: -50});
  },

  setCommentsForNode: function(version, nid, num) {
    $('bill_text_section_' + nid).insert({top: "<div class='bill_text_section_num_comments'><span><a href='#' onClick=\"BillText.showComments(" + version + ", '" + nid + "'); return false;\">" + num + "</a></span></div>"});
  }
}
