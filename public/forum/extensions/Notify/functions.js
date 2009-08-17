/*
    Type=CATEGORY,DISCUSSION,ALL;
    ElementID=x (DiscussionID,CategoryID,0)
    Value=1/0 (1=set, 0=unset)
                                  */
function SetNotify(Type,ElementID,Value,Elem,Class,NewText)
{
    var Vanilla = new PathFinder();
    var ajax = new Ajax.Request(Vanilla.webRoot = Vanilla.getRootPath('script', 'src', 'js/global.js')+'extensions/Notify/ajax.php',    {
        parameters:'PostBackAction=ChangeNotify&Type='+Type+'&ElementID='+ElementID+'&Value='+Value,
        onSuccess: function(r)
        {
            Element.removeClassName(Elem,Class);
            if (NewText != '') Elem.innerHTML = NewText;
            $(Elem).innerHTML = NewText;
         }
    });
    return true;
}

function NotifyCat(CategoryID)
{
    Element.addClassName('NotifyCatCont_'+CategoryID,'PreferenceProgress');
    if ($('NotifyCat_'+CategoryID).checked == true) Value = 1;
    else Value = 0;
    SetNotify('CATEGORY',CategoryID,Value,'NotifyCatCont_'+CategoryID,'PreferenceProgress','');
}
function NotifyDiscussion(DiscussionID)
{
    Element.addClassName('NotifyDiscussionCont_'+DiscussionID,'PreferenceProgress');
    if ($('NotifyDiscussion_'+DiscussionID).checked == true) Value = 1;
    else Value = 0;
    SetNotify('DISCUSSION',DiscussionID,Value,'NotifyDiscussionCont_'+DiscussionID,'PreferenceProgress','');
}
function PNotifyAll(SetText,UnSetText)
{
    Element.addClassName('SetNotifyAll','Progress');
    if ($('SetNotifyAll').innerHTML == SetText)
    {
        Value = 1;
        NewText = UnSetText;
    }
    else
    {
        Value = 0;
        NewText = SetText;
    }
    SetNotify('ALL',0,Value,'SetNotifyAll','Progress',NewText);
}
function PNotifyCategory(CategoryID,SetText,UnSetText)
{
    Element.addClassName('SetNotifyCategory_'+CategoryID,'Progress');
    if ($('SetNotifyCategory_'+CategoryID).innerHTML == SetText)
    {
        Value = 1;
        NewText = UnSetText;
    }
    else
    {
        Value = 0;
        NewText = SetText;
    }
    SetNotify('CATEGORY',CategoryID,Value,'SetNotifyCategory_'+CategoryID,'Progress',NewText);
}
function PNotifyDiscussion(DiscussionID,SetText,UnSetText)
{
    Element.addClassName('SetNotifyDiscussion_'+DiscussionID,'Progress');
    if ($('SetNotifyDiscussion_'+DiscussionID).innerHTML == SetText)
    {
        Value = 1;
        NewText = UnSetText;
    }
    else
    {
        Value = 0;
        NewText = SetText;
    }
    SetNotify('DISCUSSION',DiscussionID,Value,'SetNotifyDiscussion_'+DiscussionID,'Progress',NewText);
}

function NotifyAll()
{
    Element.addClassName('NotifyAllCont','PreferenceProgress');
    if ($('NotifyAllField').checked == true) Value = 1;
    else Value = 0;
    SetNotify('ALL',0,Value,'NotifyAllCont','PreferenceProgress','');
}

function NotifyOwn()
{
    Element.addClassName('NotifyOwnCont','PreferenceProgress');
    if ($('NotifyOwnField').checked == true) Value = 1;
    else Value = 0;
    SetNotify('OWN',0,Value,'NotifyOwnCont','PreferenceProgress','');
}