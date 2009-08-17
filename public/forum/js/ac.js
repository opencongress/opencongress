function AutoComplete (TextInputID, AllowMultipleChoices){
	/* ---- Public Variables ---- */
	this.TimeOut = -1; // Autocomplete Timeout in ms (-1: autocomplete never time out)
	this.MouseSupport = true; // Enable Mouse Support
	if (AllowMultipleChoices) {
		this.Delimiter = new Array(';',',');  // Delimiter for multiple autocomplete. Set it to empty array for single autocomplete
	} else {
		this.Delimiter = new Array('');  // Delimiter for multiple autocomplete. Set it to empty array for single autocomplete
	}
	
	this.StartCharacter = 1; // Show widget only after this number of characters is typed in.
	this.KeywordSourceUrl = "autocomplete.php?Search=";
	/* ---- Public Variables ---- */

	/* --- Styles --- */
	this.ResultContainerClass = 'AutoCompleteContainer';
	this.StandardRowClass = 'AutoCompleteRow';
	this.HoverRowClass = 'AutoCompleteHoverRow';
	/* --- Styles --- */
	  
	this.TableID = 'AutoCompleteTable';

	/* ---- Private Variables ---- */
	var _DelimWords = new Array();
	var _CDelimWord = 0;
	var _DelimChar = new Array();
	var _Display = false;
	var _Pos = 0;
	var _Total = 0;
	var _Curr = null;
	var _RangeU = 0;
	var _RangeD = 0;
	var _Bool = new Array();
	var _Pre = 0;
	var _ToId;
	var _ToMake = false;
	var _GetPre = "";
	var _MouseOnList = 1;
	var _KWCount = 0;
	var _CaretMove = false;
	this._Keywords = new Array();
	/* ---- Private Variables---- */
	
	var _Self = this;
	_Curr = null;
	_Curr = document.getElementById(TextInputID);
	
	if (_Curr) {
		addEvent(_Curr, "focus", SetupEvents);
		// turn existing autocomplete off
		_Curr.setAttribute("autocomplete", "off"); 
	}
	function SetupEvents(){
		addEvent(document,"keydown",CheckKey);
		addEvent(_Curr,"blur",ClearEvents);
		addEvent(document,"keypress",KeyPress);
	}

	function ClearEvents(evt){
		if (!evt) evt = event;
		removeEvent(document,"keydown",CheckKey);
		removeEvent(_Curr,"blur",ClearEvents);
		removeEvent(document,"keypress",KeyPress);
		RemoveAutocomplete();
	}
	function GenerateItems(Request){
		_Self._Keywords = Request.responseText.split(",");
		_KWCount = _Self._Keywords.length;
		if (_KWCount == 1 && _Self._Keywords[0] == '') {
			_KWCount = 0;
			_Self._Keywords = new Array();
		}		
		_Total = _KWCount;
		if (document.getElementById(_Self.TableID)) { _Display = false; document.body.removeChild(document.getElementById(_Self.TableID)); }
		if (document.getElementById(_Self.TableID+'_iefix')){ document.body.removeChild(document.getElementById(_Self.TableID+'_iefix')); }
		if (_KWCount == 0) {
			_MouseOnList = 0;
			RemoveAutocomplete();
			return;
		}
		a = document.createElement('table');
		a.className = _Self.ResultContainerClass;
		a.style.position='absolute';
		a.style.top = eval(curTop(_Curr) + _Curr.offsetHeight) + "px";
		a.style.left = curLeft(_Curr) + "px";
		a.id = _Self.TableID;
		a.cellPadding = '0';
		a.cellSpacing = '0';
		a.style.zIndex = '200';
		document.body.appendChild(a);
		
		var i;
		var first = true;
		var j = 1;
		if (_Self.MouseSupport){
			a.onmouseout = TableBlur;
			a.onmouseover = TableFocus;
		}
		var counter = 0;
		for (i = 0; i < _Self._Keywords.length; i++) {
			counter++;
			r = a.insertRow(-1);
			if (first && !_ToMake){
				r.className = _Self.HoverRowClass;
				first = false;
				_Pos = counter;
			}else if(_Pre == i){
				r.className = _Self.HoverRowClass;
				first = false;
				_Pos = counter;
			}else{
				r.className = _Self.StandardRowClass;
			}
			r.id = 'tat_tr'+(j);
			c = r.insertCell(-1);
			c.innerHTML = _Self._Keywords[i];
			c.id = 'tat_td'+(j);
			c.setAttribute('pos',j);
			if (_Self.MouseSupport){
				c.onmousedown = MouseClick;
				// c.onclick = MouseClick;
				c.onmouseover = TableHighlight;
			}
			j++;
		}
		_RangeU = 1;
		_RangeD = j-1;
		_Display = true;
		if (_Pos <= 0) _Pos = 1;

		// Fix ie display bugs
		// 2006-04-24: Normally I would NEVER do a useragent sniff, but Opera
		// seems to have the unique ability among new browsers to use this
		// insertAdjacentHTML method, but NOT allow iframes to have other elements
		// appear on top of them. So, I don't want opera to use this iframe code
		// since, after all, this is an IE fix.
		if (document.body.insertAdjacentHTML && navigator.userAgent.indexOf('Opera') == -1) {
			document.body.insertAdjacentHTML('beforeEnd', '<iframe '
				+'id="'+a.id+'_iefix" '
				+'style="position:absolute;'
					+'filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);'
					+'top:'+a.style.top+';'
					+'left:'+a.style.left+';'
					+'width:'+a.offsetWidth+'px;'
					+'height:'+a.offsetHeight+'px;'
					+'z-index:100;'
					+'border:0;'
				+'" '
				+'src="javascript:false;" '
				+'frameborder="0" '
				+'scrolling="no"></iframe>');
		}
	}
	function GoUp(){
		if (!_Display) return;
		if (_Pos == 1) return;
		document.getElementById('tat_tr'+_Pos).className = _Self.StandardRowClass;
		_Pos--;
		document.getElementById('tat_tr'+_Pos).className = _Self.HoverRowClass;
		if (_ToId) clearTimeout(_ToId);
		if (_Self.TimeOut > 0) _ToId = setTimeout(function(){_MouseOnList=0;RemoveAutocomplete();},_Self.TimeOut);
	}
	function GoDown(){
		if (!_Display) return;
		if (_Pos == _Total) return;
		document.getElementById('tat_tr'+_Pos).className = _Self.StandardRowClass;
		_Pos++;
		document.getElementById('tat_tr'+_Pos).className = _Self.HoverRowClass;
		if (_ToId) clearTimeout(_ToId);
		if (_Self.TimeOut > 0) _ToId = setTimeout(function(){_MouseOnList=0;RemoveAutocomplete();},_Self.TimeOut);
	}

	/* Mouse */
	function MouseClick(evt){
		if (!evt) evt = event;
		if (!_Display) return;
		_MouseOnList = 0;
		_Pos = this.getAttribute('pos');
		PressEnter();
	}
	function TableFocus(){
		_MouseOnList = 1;
	}
	function TableBlur(){
		_MouseOnList = 0;
		if (_ToId) clearTimeout(_ToId);
		if (_Self.TimeOut > 0) _ToId = setTimeout(function(){_MouseOnList = 0;RemoveAutocomplete();},_Self.TimeOut);
	}
	function TableHighlight(){
		_MouseOnList = 1;
		document.getElementById('tat_tr'+_Pos).className = _Self.StandardRowClass;
		_Pos = this.getAttribute('pos');
		document.getElementById('tat_tr'+_Pos).className = _Self.HoverRowClass;
		if (_ToId) clearTimeout(_ToId);
		if (_Self.TimeOut > 0) _ToId = setTimeout(function(){_MouseOnList = 0;RemoveAutocomplete();},_Self.TimeOut);
	}
	/* ---- */

	function InsertWord(a){
		if (_Self.Delimiter.length > 0){
			str = '';
			l=0;
			for (i=0;i<_DelimWords.length;i++){
				if (_CDelimWord == i){
					prespace = postspace = '';
					gotbreak = false;
					for (j=0;j<_DelimWords[i].length;++j){
						if (_DelimWords[i].charAt(j) != ' '){
							gotbreak = true;
							break;
						}
						prespace += ' ';
					}
					for (j=_DelimWords[i].length-1;j>=0;--j){
						if (_DelimWords[i].charAt(j) != ' ') break;
						postspace += ' ';
					}
					str += prespace;
					str += a;
					l = str.length;
					if (gotbreak) str += postspace;
				}else{
					str += _DelimWords[i];
				}
				if (i != _DelimWords.length - 1){
					str += _DelimChar[i];
				}
			}
			_Curr.value = str;
			setCaret(_Curr,l);
		}else{
			_Curr.value = a;
		}
		_MouseOnList = 0;
		RemoveAutocomplete();
	}
	function PressEnter(){
		if (!_Display) return;
		_Display = false;
		var word = _Self._Keywords[_Pos - 1];
		InsertWord(word);
		l = getCaretStart(_Curr);
		_Curr.focus();
	}
	function RemoveAutocomplete(){
		// if (_MouseOnList==0){
		_Display = 0;
		if (document.getElementById(_Self.TableID)){ document.body.removeChild(document.getElementById(_Self.TableID)); }
		if (document.getElementById(_Self.TableID+'_iefix')){ document.body.removeChild(document.getElementById(_Self.TableID+'_iefix')); }
		if (_ToId) clearTimeout(_ToId);
		// }
	}
	function KeyPress(e){
		if (_CaretMove && _Curr.id == getTargetElement(e).id) stopEvent(e);
		return !_CaretMove;
	}
	function CheckKey(evt){
		if (!evt) evt = event;
		// alert(_Curr.id+ " must equal "+getTargetElement(evt).id);
		if (_Curr.id != getTargetElement(evt).id) return;
		a = evt.keyCode;
		caret_pos_start = getCaretStart(_Curr);
		_CaretMove = 0;
		switch (a){
			case 38:
				GoUp();
				_CaretMove = 1;
				return false;
				break;
			case 40:
				GoDown();
				_CaretMove = 1;
				return false;
				break;
			case 13: case 9:
				if (_Display){
					_CaretMove = 1;
					PressEnter();
					return false;
				}else{
					return true;
				}
				break;
			default:
				setTimeout(function(){GetItems(a)},1000);
				break;
		}
	}

	function GetItems(kc){
		if (kc == 38 || kc == 40 || kc == 13 || kc == 9) return;
		var i;
		if (_Display){ 
			var word = 0;
			var c = 0;
			for (var i=0;i<=_Self._Keywords.length;i++){
				if (_Bool[i]) c++;
				if (c == _Pos){
					word = i;
					break;
				}
			}
			_Pre = word;
		} else { _Pre = -1 };
		
		if (_Curr.value == ''){
			_MouseOnList = 0;
			RemoveAutocomplete();
			return;
		}
		if (_Self.Delimiter.length > 0){
			caret_pos_start = getCaretStart(_Curr);
			caret_pos_end = getCaretEnd(_Curr);
			
			delim_split = '';
			for (i=0;i<_Self.Delimiter.length;i++){
				delim_split += _Self.Delimiter[i];
			}
			if (delim_split == '') delim_split = '##void##';
			delim_split = delim_split.addslashes();
			delim_split_rx = new RegExp("("+delim_split+")");
			c = 0;
			_DelimWords = new Array();
			_DelimWords[0] = '';
			for (i=0,j=_Curr.value.length;i<_Curr.value.length;i++,j--){
				if (_Curr.value.substr(i,j).search(delim_split_rx) == 0){
					ma = _Curr.value.substr(i,j).match(delim_split_rx);
					_DelimChar[c] = ma[1];
					c++;
					_DelimWords[c] = '';
				}else{
					_DelimWords[c] += _Curr.value.charAt(i);
				}
			}

			var l = 0;
			_CDelimWord = -1;
			for (i=0;i<_DelimWords.length;i++){
				if (caret_pos_end >= l && caret_pos_end <= l + _DelimWords[i].length){
					_CDelimWord = i;
				}
				l+=_DelimWords[i].length + 1;
			}
			var ot = _DelimWords[_CDelimWord].trim(); 
			var t = _DelimWords[_CDelimWord].addslashes().trim();
		}else{
			var ot = _Curr.value;
			var t = _Curr.value.addslashes();
		}
		if (ot.length == 0){
			_MouseOnList = 0;
			RemoveAutocomplete();
		}
		if (ot.length < _Self.StartCharacter) return this;
		
		// Get the values from database
		var dm = new DataManager();
		dm.RequestCompleteEvent = GenerateItems;
		dm.RequestFailedEvent = HandleFailure;
		dm.LoadData(_Self.KeywordSourceUrl+escape(t));
	}

	function HandleFailure(Request) {
		HideResults();
	}
	
	function HideResults() {
		_MouseOnList = 0;
		RemoveAutocomplete();
	}
}
/* Event Functions */

// Add an event to the obj given
// event_name refers to the event trigger, without the "on", like click or mouseover
// func_name refers to the function callback when event is triggered
function addEvent(obj,event_name,func_name){
	if (obj.attachEvent){
		obj.attachEvent("on"+event_name, func_name);
	}else if(obj.addEventListener){
		obj.addEventListener(event_name,func_name,true);
	}else{
		obj["on"+event_name] = func_name;
	}
}

// Removes an event from the object
function removeEvent(obj,event_name,func_name){
	if (obj.detachEvent){
		obj.detachEvent("on"+event_name,func_name);
	}else if(obj.removeEventListener){
		obj.removeEventListener(event_name,func_name,true);
	}else{
		obj["on"+event_name] = null;
	}
}

// Stop an event from bubbling up the event DOM
function stopEvent(evt){
	evt || window.event;
	if (evt.stopPropagation){
		evt.stopPropagation();
		evt.preventDefault();
	}else if(typeof evt.cancelBubble != "undefined"){
		evt.cancelBubble = true;
		evt.returnValue = false;
	}
	return false;
}

// Get the obj that starts the event
function getElement(evt){
	if (window.event){
		return window.event.srcElement;
	}else{
		return evt.currentTarget;
	}
}
// Get the obj that triggers off the event
function getTargetElement(evt){
	if (window.event){
		return window.event.srcElement;
	}else{
		return evt.target;
	}
}
// For IE only, stops the obj from being selected
function stopSelect(obj){
	if (typeof obj.onselectstart != 'undefined'){
		addEvent(obj,"selectstart",function(){ return false;});
	}
}

/*    Caret Functions     */

// Get the end position of the caret in the object. Note that the obj needs to be in focus first
function getCaretEnd(obj){
	if(typeof obj.selectionEnd != "undefined"){
		return obj.selectionEnd;
	}else if(document.selection&&document.selection.createRange){
		var M=document.selection.createRange();
		try{
			var Lp = M.duplicate();
			Lp.moveToElementText(obj);
		}catch(e){
			var Lp=obj.createTextRange();
		}
		Lp.setEndPoint("EndToEnd",M);
		var rb=Lp.text.length;
		if(rb>obj.value.length){
			return -1;
		}
		return rb;
	}
}
// Get the start position of the caret in the object
function getCaretStart(obj){
	if(typeof obj.selectionStart != "undefined"){
		return obj.selectionStart;
	}else if(document.selection&&document.selection.createRange){
		var M=document.selection.createRange();
		try{
			var Lp = M.duplicate();
			Lp.moveToElementText(obj);
		}catch(e){
			var Lp=obj.createTextRange();
		}
		Lp.setEndPoint("EndToStart",M);
		var rb=Lp.text.length;
		if(rb>obj.value.length){
			return -1;
		}
		return rb;
	}
}
// sets the caret position to l in the object
function setCaret(obj,l){
	obj.focus();
	if (obj.setSelectionRange){
		obj.setSelectionRange(l,l);
	}else if(obj.createTextRange){
		m = obj.createTextRange();		
		m.moveStart('character',l);
		m.collapse();
		m.select();
	}
}
// sets the caret selection from s to e in the object
function setSelection(obj,s,e){
	obj.focus();
	if (obj.setSelectionRange){
		obj.setSelectionRange(s,e);
	}else if(obj.createTextRange){
		m = obj.createTextRange();		
		m.moveStart('character',s);
		m.moveEnd('character',e);
		m.select();
	}
}

/*    Escape function   */
String.prototype.addslashes = function(){
	return this.replace(/(["\\\.\|\[\]\^\*\+\?\$\(\)])/g, '\\$1');
}
String.prototype.trim = function () {
    return this.replace(/^\s*(\S*(\s+\S+)*)\s*$/, "$1");
};
/* --- Escape --- */

/* Offset position from top of the screen */
function curTop(obj){
	toreturn = 0;
	while(obj){
		toreturn += obj.offsetTop;
		obj = obj.offsetParent;
	}
	return toreturn;
}
function curLeft(obj){
	toreturn = 0;
	while(obj){
		toreturn += obj.offsetLeft;
		obj = obj.offsetParent;
	}
	return toreturn;
}
/* ------ End of Offset function ------- */

/* Types Function */

// is a given input a number?
function isNumber(a) {
    return typeof a == 'number' && isFinite(a);
}

/* Object Functions */

function replaceHTML(obj,text){
	while(el = obj.childNodes[0]){
		obj.removeChild(el);
	};
	obj.appendChild(document.createTextNode(text));
}