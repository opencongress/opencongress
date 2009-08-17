<?php
/*
Extension Name: Notify
Extension Url: mail@hutstein.de
Description: An extension, that enables users to subscribe to the complete forum, categories or specific discussions, to be notified about new posts
Version: 1.2.1
Author: Andreas Hutstein
Author Url: http://www.hutstein.de/

You should cut & paste these language definitions into your conf/your_language.php file
(replace "your_language" with your chosen language, of course):
*/
$Context->Dictionary['Notification'] = 'Notification';
$Context->Dictionary['SubscribeForum'] = 'Subscribe to forum';
$Context->Dictionary['UnsubscribeForum'] = 'Unsubscribe forum';
$Context->Dictionary['SubscribeCategory'] = 'Subscribe to category';
$Context->Dictionary['UnsubscribeCategory'] = 'Unsubscribe category';
$Context->Dictionary['SubscribeDiscussion'] = 'Subscribe to discussion';
$Context->Dictionary['UnsubscribeDiscussion'] = 'Unsubscribe discussion';
$Context->Dictionary['NotificationManagement'] = 'Notification Management';
$Context->Dictionary['NotificationOptions'] = 'Notification options';
$Context->Dictionary['NotificationOnOwnExplanation'] = 'Notify me, when comments are posted in my own discussions';
$Context->Dictionary['YourNotifications'] = 'Your Notifications';
$Context->Dictionary['NotificationForum'] = 'Notify me, when comments are posted in the complete forum';
$Context->Dictionary['DeleteAllNotifications']= 'If you want to delete all notifications, you can click on the following link';
$Context->Dictionary['AdminDeleteAllNotifications']= 'If you want to delete all notifications this user has created, click the following link';


// Check to see if this extension has been configured
if (!array_key_exists('NOTIFY_SETUP', $Configuration))
{
    $Errors = 0;
	// Create the Notify table if not exists
    $NotifyCreate = "CREATE TABLE IF NOT EXISTS `".$Context->Configuration['DATABASE_TABLE_PREFIX']."Notify` (
      `NotifyID` int(11) NOT NULL auto_increment,
      `UserID` int(11) NOT NULL,
      `Method` varchar(10) NOT NULL,
      `SelectID` int(11) NOT NULL,
      PRIMARY KEY  (`NotifyID`)
      );";
	if (!mysql_query($NotifyCreate, $Context->Database->Connection)) $Errors = 1;

    // Create the additional user preferences if necessary
	$result = mysql_query("SHOW columns FROM ".$Context->Configuration['DATABASE_TABLE_PREFIX']."User like 'SubscribeOwn'");
	if (mysql_num_rows($result) == 0)
    {
    	$NotifyCreate = "ALTER TABLE `".$Context->Configuration['DATABASE_TABLE_PREFIX']."User`
    	ADD `SubscribeOwn` TINYINT( 1 ) NOT NULL ,
    	ADD `Notified` TINYINT( 1 ) NOT NULL;";
    	if (!mysql_query($NotifyCreate, $Context->Database->Connection)) $Errors = 1;
	}

	if ($Errors == 0)
    {
	    // Mark this extension as enabled using a convenience method.
        AddConfigurationSetting($Context, 'NOTIFY_SETUP');
	}
}
if (!array_key_exists('NOTIFY_VERSION', $Configuration))
{
    AddConfigurationSetting($Context, 'NOTIFY_ALLOW_ALL', '1');
    AddConfigurationSetting($Context, 'NOTIFY_ALLOW_DISCUSSION', '1');
    AddConfigurationSetting($Context, 'NOTIFY_ALLOW_CATEGORY', '1');
    AddConfigurationSetting($Context, 'NOTIFY_VERSION', '1.0.0');
    if (!mysql_query("ALTER TABLE `".$Context->Configuration['DATABASE_TABLE_PREFIX']."Category` ADD `Subscribeable` INT( 1 ) NOT NULL ;",$Context->Database->Connection)) $Errors = 1;
}
if ($Context->Configuration['NOTIFY_VERSION'] < '1.2.0')
{
    AddConfigurationSetting($Context, 'NOTIFY_AUTO_ALL', '0');
    $cm = new ConfigurationManager($Context);
    $cm->GetSettingsFromFile($Configuration['APPLICATION_PATH'].'conf/settings.php');
    $cm->DefineSetting('NOTIFY_VERSION','1.2.0');
    $cm->SaveSettingsToFile($Configuration['APPLICATION_PATH'].'conf/settings.php');
}

function CheckNotifySyntax($Context,$Method,$SelectID)
{
    switch ($Method)
    {
        case 'ALL':
        {
            if ($SelectID == 0)
                return true;
            else
                return false;
        }
        case 'CATEGORY':
        {
            if ($SelectID > 0)
            {
                $result = mysql_query("SELECT CategoryID FROM ".$Context->Configuration['DATABASE_TABLE_PREFIX']."Category WHERE CategoryID = '$SelectID'",$Context->Database->Connection);
                $row = mysql_fetch_row($result);
                if ($row[0] == $SelectID)
                    return true;
                else
                    return false;
            }
            else
                return false;
        }
        case 'DISCUSSION':
        {
            if ($SelectID > 0)
            {
                $result = mysql_query("SELECT DiscussionID FROM ".$Context->Configuration['DATABASE_TABLE_PREFIX']."Discussion WHERE DiscussionID = '$SelectID'",$Context->Database->Connection);
                $row = mysql_fetch_row($result);
                if ($row[0] == $SelectID)
                    return true;
                else
                    return false;
            }
            else
                return false;
        }
        default:
            return false;
    }
}

function ChangeNotify($Context,$Method,$SelectID,$Value)
{
    if ($Context->Configuration['NOTIFY_ALLOW_'.$Method] == 1 AND $Context->Configuration['NOTIFY_AUTO_ALL'] == 0)
    {
      if ($Value == 1)
      {
          if (CheckNotifySyntax($Context,$Method,$SelectID) AND CheckNotify($Context,$Method,$SelectID) == false)
             if (mysql_query("INSERT INTO `".$Context->Configuration['DATABASE_TABLE_PREFIX']."Notify` ( `NotifyID` , `UserID` , `Method` , `SelectID` ) VALUES (NULL , '".$Context->Session->UserID."', '".$Method."', '".$SelectID."')", $Context->Database->Connection))
                 return true;
      }
      else
      {
          if (CheckNotifySyntax($Context,$Method,$SelectID) AND CheckNotify($Context,$Method,$SelectID) == true)
              if (mysql_query("DELETE FROM `".$Context->Configuration['DATABASE_TABLE_PREFIX']."Notify` WHERE UserID = '".$Context->Session->UserID."' AND Method = '".$Method."' AND SelectID = '".$SelectID."'",$Context->Database->Connection))
                  return true;
      }
    }
    else
        return false;
}

function CheckNotify($Context,$Method,$SelectID)
{
	$result = mysql_query("SELECT NotifyID FROM `".$Context->Configuration['DATABASE_TABLE_PREFIX']."Notify` WHERE UserID = '".$Context->Session->UserID."' AND Method = '".$Method."' AND SelectID = '".$SelectID."'", $Context->Database->Connection);
	$row = mysql_fetch_row($result);
	if ($row[0] > 0)
        return true;
    else
        return false;
}

function SwitchOwnNotify($Context,$Switch,$UserID)
{
	 mysql_query("UPDATE `LUM_User` SET SubscribeOwn = $Switch WHERE UserID = $UserID",$Context->Database->Connection);
}

function CheckSubscribeOwn($Context)
{
	$result = mysql_query("SELECT SubscribeOwn FROM ".$Context->Configuration['DATABASE_TABLE_PREFIX']."User WHERE UserID = '".$Context->Session->UserID."'",$Context->Database->Connection);
	$row = mysql_fetch_row($result);
    return $row[0];
}

if ($Context->Session->UserID > 0 && isset($Panel) && $Context->Configuration['NOTIFY_AUTO_ALL'] == 0)
{
    $Panel->AddList($Context->GetDefinition('Notification'), 100);

    if ($Context->Configuration['NOTIFY_ALLOW_ALL'] == 1 && in_array($Context->SelfUrl, array('comments.php','index.php','categories.php')))
    {
		if (CheckNotify($Context,'ALL',0))
            $Panel->AddListItem($Context->GetDefinition('Notification'),$Context->GetDefinition('UnsubscribeForum'),"./","","id=\"SetNotifyAll\" onclick=\"PNotifyAll('".$Context->GetDefinition('SubscribeForum')."', '".$Context->GetDefinition('UnsubscribeForum')."'); return false;\"");
		else
            $Panel->AddListItem($Context->GetDefinition('Notification'),$Context->GetDefinition('SubscribeForum'),"./","","id=\"SetNotifyAll\" onclick=\"PNotifyAll('".$Context->GetDefinition('SubscribeForum')."', '".$Context->GetDefinition('UnsubscribeForum')."'); return false;\"");
	}

    $DiscussionID = ForceIncomingInt("DiscussionID", "0");
    if ($DiscussionID > 0)
    {
      $result = mysql_query("SELECT CategoryID FROM ".$Context->Configuration['DATABASE_TABLE_PREFIX']."Discussion WHERE DiscussionID = '$DiscussionID'",$Context->Database->Connection);
      $row = mysql_fetch_row($result);
      $CategoryID = $row[0];
    }
    else
        $CategoryID = ForceIncomingInt('CategoryID',0);
	if ($Context->Configuration['NOTIFY_ALLOW_CATEGORY'] == 1 && in_array($Context->SelfUrl, array('index.php','comments.php')) AND ($CategoryID > 0))
    {
    	if (CheckNotify($Context,'CATEGORY',$CategoryID) == true)
            $Panel->AddListItem($Context->GetDefinition('Notification'),$Context->GetDefinition('UnsubscribeCategory'),"./","","id=\"SetNotifyCategory_".$CategoryID."\" onclick=\"PNotifyCategory(".$CategoryID.",'".$Context->GetDefinition('SubscribeCategory')."', '".$Context->GetDefinition('UnsubscribeCategory')."'); return false;\"");
        else
            $Panel->AddListItem($Context->GetDefinition('Notification'),$Context->GetDefinition('SubscribeCategory'),"./","","id=\"SetNotifyCategory_".$CategoryID."\" onclick=\"PNotifyCategory(".$CategoryID.",'".$Context->GetDefinition('SubscribeCategory')."', '".$Context->GetDefinition('UnsubscribeCategory')."'); return false;\"");
	}

	if ($Context->Configuration['NOTIFY_ALLOW_DISCUSSION'] == 1 && in_array($Context->SelfUrl, array('comments.php')) AND $DiscussionID > 0)
    {
		if (CheckNotify($Context,'DISCUSSION',$DiscussionID) == true)
			$Panel->AddListItem($Context->GetDefinition('Notification'),$Context->GetDefinition('UnsubscribeDiscussion'),"./","","id=\"SetNotifyDiscussion_".$DiscussionID."\" onclick=\"PNotifyDiscussion(".$DiscussionID.",'".$Context->GetDefinition('SubscribeDiscussion')."', '".$Context->GetDefinition('UnsubscribeDiscussion')."'); return false;\"");
        else
    		$Panel->AddListItem($Context->GetDefinition('Notification'),$Context->GetDefinition('SubscribeDiscussion'),"./","","id=\"SetNotifyDiscussion_".$DiscussionID."\" onclick=\"PNotifyDiscussion(".$DiscussionID.",'".$Context->GetDefinition('SubscribeDiscussion')."', '".$Context->GetDefinition('UnsubscribeDiscussion')."'); return false;\"");
	}
}
function NotifyDiscussion($DiscussionForm)
{
	$DiscussionID = @$DiscussionForm->DelegateParameters['ResultDiscussion']->DiscussionID;
	if ($DiscussionID > 0)
    {
		#Detect if Whispered
		$result = mysql_query("SELECT WhisperUserID FROM ".$DiscussionForm->Context->Configuration['DATABASE_TABLE_PREFIX']."Discussion WHERE DiscussionID = '$DiscussionID'");
		$row = mysql_fetch_row($result);
		if ($row[0] > 0)
            $Whispered = 1;
		else
            $Whispered = 0;
		$WhisperUserID = $row[0];
        if (CheckSubscribeOwn($DiscussionForm->Context))
            ChangeNotify($DiscussionForm->Context,'DISCUSSION',$DiscussionID,1);
	}
	else
    {
		$DiscussionID = @$DiscussionForm->DelegateParameters['ResultComment']->DiscussionID;
		#Detect if Whispered
         $mTitle = @$DiscussionForm->DelegateParameters['ResultComment']->Title;
		$CommentID = @$DiscussionForm->DelegateParameters['ResultComment']->CommentID;
		$result = mysql_query("SELECT WhisperUserID FROM ".$DiscussionForm->Context->Configuration['DATABASE_TABLE_PREFIX']."Discussion WHERE DiscussionID = '$DiscussionID'");
		$row = mysql_fetch_row($result);
		if ($row[0] > 0)
            $Whispered = 1;
        else
            $Whispered = 0;
		$WhisperUserID = $row[0];
		if ($Whispered == 0)
		{
			$result = mysql_query("SELECT WhisperUserID FROM ".$DiscussionForm->Context->Configuration['DATABASE_TABLE_PREFIX']."Comment WHERE CommentID = '$CommentID'");
			$row = mysql_fetch_row($result);
			if ($row[0] > 0)
                $Whispered = 1;
			else
                $Whispered = 0;
			$WhisperUserID = $row[0];
		}
	}

	if ($DiscussionID > 0)
    {

       	$Notifieusers = array();
		$SelfUser = $DiscussionForm->Context->Session->UserID;
        if ($DiscussionForm->Context->Configuration['NOTIFY_AUTO_ALL'] == 0)
        {
      	#Add all users who have subscribed to all, aren't already notified except the posting user
          if ($DiscussionForm->Context->Configuration['NOTIFY_ALLOW_ALL'] == 1)
          {
      		$result = mysql_query("SELECT A.UserID,Email,FirstName, LastName FROM ".$DiscussionForm->Context->Configuration['DATABASE_TABLE_PREFIX']."Notify AS A, ".$DiscussionForm->Context->Configuration['DATABASE_TABLE_PREFIX']."User AS B WHERE A.Method = 'ALL' AND A.UserID <> '$SelfUser' AND A.UserID = B.UserID AND B.Notified = 0",$DiscussionForm->Context->Database->Connection);
      		while ($row = mysql_fetch_row($result))
      			if (($Whispered == 1 AND $WhisperUserID == $row[0]) OR ($Whispered == 0))
                      array_push($Notifieusers,array($row[0],$row[1],$row[2],$row[3]));
          }

  		#Add all users who have subscribed to this category , aren't already notified except the posting user
          if ($DiscussionForm->Context->Configuration['NOTIFY_ALLOW_CATEGORY'] == 1)
          {

  		$result = mysql_query("SELECT CategoryID FROM ".$DiscussionForm->Context->Configuration['DATABASE_TABLE_PREFIX']."Discussion WHERE DiscussionID = '$DiscussionID'",$DiscussionForm->Context->Database->Connection);
  		$row = mysql_fetch_row($result);
  		$result2 = mysql_query("SELECT A.UserID,Email,FirstName, LastName FROM ".$DiscussionForm->Context->Configuration['DATABASE_TABLE_PREFIX']."Notify AS A, ".$DiscussionForm->Context->Configuration['DATABASE_TABLE_PREFIX']."User AS B WHERE A.Method = 'CATEGORY' AND A.SelectID = '$row[0]' AND A.UserID <> '$SelfUser'  AND A.UserID = B.UserID AND B.Notified = 0",$DiscussionForm->Context->Database->Connection);
  		while ($row2 = mysql_fetch_row($result2))
  			if (($Whispered == 1 AND $WhisperUserID == $row[0]) OR ($Whispered == 0))
                  array_push($Notifieusers,array($row2[0],$row2[1],$row2[2],$row2[3]));
          }
  		#Add all users who have subscribed to this discussion , aren't already notified except the posting user
          if ($DiscussionForm->Context->Configuration['NOTIFY_ALLOW_DISCUSSION'] == 1)
          {

  		$result2 = mysql_query("SELECT A.UserID,Email,FirstName, LastName FROM ".$DiscussionForm->Context->Configuration['DATABASE_TABLE_PREFIX']."Notify AS A, ".$DiscussionForm->Context->Configuration['DATABASE_TABLE_PREFIX']."User AS B WHERE A.Method = 'DISCUSSION' AND A.SelectID = '$DiscussionID' AND A.UserID <> '$SelfUser' AND A.UserID = B.UserID AND B.Notified = 0",$DiscussionForm->Context->Database->Connection);
  		while ($row2 = mysql_fetch_row($result2))
      		if (($Whispered == 1 AND $WhisperUserID = $row[0]) OR ($Whispered == 0))
                  array_push($Notifieusers,array($row2[0],$row2[1],$row2[2],$row2[3]));
          }
          }
        else
        {
           #Add all users
            $result = mysql_query("SELECT UserID,Email,FirstName, LastName FROM ".$DiscussionForm->Context->Configuration['DATABASE_TABLE_PREFIX']."User WHERE UserID <> '$SelfUser' AND Notified = 0",$DiscussionForm->Context->Database->Connection);
      		while ($row = mysql_fetch_row($result))
      			if (($Whispered == 1 AND $WhisperUserID == $row[0]) OR ($Whispered == 0))
                      array_push($Notifieusers,array($row[0],$row[1],$row[2],$row[3]));

        }
		#Remove double inserted users
        array_unique($Notifieusers);
        #Send an email for each user:
        $mailsent = array();
		$e = $DiscussionForm->Context->ObjectFactory->NewContextObject($DiscussionForm->Context, 'Email');
		$e->HtmlOn = 0;
		foreach($Notifieusers as $val)
        {
            $mName = '';
            if ($val[2] != '')
                $mName = ' '.$val[2];
			if ($val[1] != "" AND !in_array($val[1],$mailsent))
            {
				if ($val[2] != "" AND $val[3] != "") $NotifyName = '';
				else $NotifyName = $val[2].' '.$val[3];
				$e->Clear();
				$e->AddFrom($DiscussionForm->Context->Configuration['SUPPORT_EMAIL'], $DiscussionForm->Context->Configuration['SUPPORT_NAME']);
				$e->AddRecipient($val[1], $NotifyName);
				$e->Subject = $DiscussionForm->Context->Configuration['APPLICATION_TITLE'].' '.$DiscussionForm->Context->GetDefinition('Notification');
				$EmailBody = @file_get_contents($DiscussionForm->Context->Configuration['EXTENSIONS_PATH'].'Notify/email_notify.txt');
				$e->Body = str_replace(
                array("{name}","{forum_name}","{title}","{comment}","{user}","{topic_url}","{support_name}"),
                array($mName,$DiscussionForm->Context->Configuration['APPLICATION_TITLE'],$mTitle,$mComment,$mUser,ConcatenatePath($DiscussionForm->Context->Configuration['BASE_URL'].'comments.php?DiscussionID='.$DiscussionID,''),$DiscussionForm->Context->Configuration['SUPPORT_NAME'])
                ,$EmailBody);
				$e->Send();
                array_push($mailsent,$val[1]);
				mysql_query("UPDATE ".$DiscussionForm->Context->Configuration['DATABASE_TABLE_PREFIX']."User SET Notified = 1 WHERE UserID = '$val[0]'");
			}
		}
      }
}

$Context->AddToDelegate('DiscussionForm','PostSaveDiscussion','NotifyDiscussion');
$Context->AddToDelegate('DiscussionForm','PostSaveComment','NotifyDiscussion');

class NotificationControl extends PostBackControl
{
	var $Context;

	function NotificationControl($Context)
    {
		$this->ValidActions = array("Notification");
		$this->Constructor($Context);
		$this->Context = $Context;
	}

    function Render()
    {
		if ($this->IsPostBack)
        {
            $u = $this->Context->Session->UserID;
//            if ($this->Context->Session->User->Permission("PERMISSION_EDIT_USERS"))
//            $u = ForceIncomingInt('u',$this->Context->Session->UserID);
			echo '<div id="Form" class="Account Preferences Notifications">
			<form  method="post" action="">
			<fieldset>
			<legend>'.$this->Context->GetDefinition("NotificationManagement").'</legend>

			<p class="Description">'.$this->Context->GetDefinition('ForumFunctionalityNotes').'</p>
			<h2>'.$this->Context->GetDefinition("NotificationOptions").'</h2>
			<ul><li>';
            $Active = ' ';
			if (CheckSubscribeOwn($this->Context) == 1)
            $Active = 'checked="checked" ';
                echo '<p><span id="NotifyOwnCont"><label for="NotifyOwnField">
                <input type="checkbox" value="1" id="NotifyOwnField" '.$Active.' onclick="NotifyOwn();" /> '.$this->Context->GetDefinition("NotificationOnOwnExplanation").'</label></span></p></li>';
			echo '</li></ul>
			<legend>'.$this->Context->GetDefinition("YourNotifications").'</legend>';
            if ($this->Context->Configuration['NOTIFY_ALLOW_ALL'] == 1)
               {
        echo '
			<h2>Forum</h2>
            <ul>';
            $Active = ' ';
            if (CheckNotify($this->Context,'ALL',0,$u)== true) $Active = 'checked="checked" ';
            echo '<li><p><span id="NotifyAllCont"><label for="NotifyAll">
            <input type="checkbox" value="1" id="NotifyAllField" '.$Active.' onclick="NotifyAll();" /> '.$this->Context->GetDefinition("NotificationForum").'</label></span></p></li>';
			echo '</ul>';
            }
                    if ($this->Context->Configuration['NOTIFY_ALLOW_CATEGORY'] == 1)
        {

           $CategoryManager = $this->Context->ObjectFactory->NewContextObject($this->Context, 'CategoryManager');
           $CategoryData = $CategoryManager->GetCategories(0, 1);
           if ($CategoryData)
           {
                echo '<h2>Categories</h2>
                <p>Notify me on new comments in the following categories</p>
                  <ul> ';
                $cat = $this->Context->ObjectFactory->NewObject($this->Context, 'Category');
                while ($Row = $this->Context->Database->GetRow($CategoryData))
                {
                    $cat->Clear();
                    $cat->GetPropertiesFromDataSet($Row);
                    $Active = '';
                    if (CheckNotify($this->Context,'CATEGORY',$cat->CategoryID,$u)== true) $Active = 'checked="checked" ';
                    echo '<li><p><span id="NotifyCatCont_'.$cat->CategoryID.'"><label for="NotifyCat_'.$cat->CategoryID.'"><input type="checkbox" name="NotifyCat_'.$cat->CategoryID.'" value="1" id="NotifyCat_'.$cat->CategoryID.'" '.$Active.' onclick="NotifyCat('.$cat->CategoryID.');" /> '.$cat->Name.'</label></span></p></li>';
                }
            echo '</ul>';
            }
            }
                    if ($this->Context->Configuration['NOTIFY_ALLOW_DISCUSSION'] == 1)
        {

           $res = mysql_query("SELECT B.DiscussionID,B.Name FROM ".$this->Context->Configuration['DATABASE_TABLE_PREFIX']."Notify A INNER JOIN ".$this->Context->Configuration['DATABASE_TABLE_PREFIX']."Discussion B ON (A.SelectID = B.DiscussionID) WHERE A.UserID = '".$u."' AND A.Method = 'DISCUSSION' ORDER BY B.DateLastActive",$this->Context->Database->Connection);
           if (mysql_num_rows($res) > 0)
           {
                echo '<h2>Discussions</h2>
                <p>Notify me on new comments in the following discussions. Only selected discussions are listed here. To submit to a discussion use the link provided on the discussions tab</p>
                  <ul> ';
               while ($row = mysql_fetch_array($res))
                {
                    $Active = '';
                   if (CheckNotify($this->Context,'DISCUSSION',$row[0])) $Active = 'checked="checked" ';
                echo '<li><p><span id="NotifyDiscussionCont_'.$row[0].'"><label for="NotifyDiscussion_'.$row[0].'"><input type="checkbox" name="NotifyDiscussion_'.$row[0].'" value="1" id="NotifyDiscussion_'.$row[0].'" '.$Active.' onclick="NotifyDiscussion('.$row[0].');" /> '.$row[1].'</label></span></p></li>';
                }
            echo '</ul>';
            }
            }
            echo '
			</fieldset></form></div>';
		}
	}
}


if (in_array($Context->SelfUrl, array('account.php')))
{
	if (!@$UserManager) unset($UserManager);
	$UserManager = $Context->ObjectFactory->NewContextObject($Context, "UserManager");
	$AccountUserID = ForceIncomingInt("u", $Context->Session->UserID);
	if (!@$AccountUser) $AccountUser = $UserManager->GetUserById($AccountUserID);
	if ($Context->Session->User)
	{
		if (($AccountUser->UserID == $Context->Session->UserID OR $Context->Session->User->Permission("PERMISSION_EDIT_USERS")) AND $Context->Configuration['NOTIFY_AUTO_ALL'] == 0)
        {
			$Panel->AddListItem($Context->GetDefinition('AccountOptions'), $Context->GetDefinition('Notification'), GetUrl($Configuration, $Context->SelfUrl, "", "", "", "", "u=".ForceIncomingInt('u',$Context->Session->UserID)."&amp;PostBackAction=Notification"), "", "", 92);
			$Page->AddRenderControl($Context->ObjectFactory->NewContextObject($Context, "NotificationControl"), $Configuration["CONTROL_POSITION_BODY_ITEM"]);
		}
	}
	$Head->AddStyleSheet('extensions/Notify/style.css');
}
if (in_array($Context->SelfUrl, array('comments.php','index.php','account.php','categories.php'))) {
    $Head->AddScript('js/prototype.js');
    $Head->AddScript('js/scriptaculous.js');
    $Head->AddScript('extensions/Notify/functions.js');
}
if ($Context->Session->UserID > 0)
    mysql_query("UPDATE ".$Context->Configuration['DATABASE_TABLE_PREFIX']."User SET Notified = 0 WHERE UserID = '".$Context->Session->UserID."'");

?>