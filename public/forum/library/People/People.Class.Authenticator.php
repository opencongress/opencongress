<?php
/*
* Copyright 2003 Mark O'Sullivan
* This file is part of People: The Lussumo User Management System.
* Lussumo's Software Library is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
* Lussumo's Software Library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
* You should have received a copy of the GNU General Public License along with Vanilla; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
* The latest source code is available at www.lussumo.com
* Contact Mark O'Sullivan at mark [at] lussumo [dot] com
* 
* Description: Default interface for user authentication. This class may be
* replaced with another using the "AUTHENTICATION_MODULE" configuration setting.
* Applications utilizing this file: Vanilla;
*/
class Authenticator {
   var $Context;
   // Returning '0' indicates that the username and password combination weren't found.
   // Returning '-1' indicates that the user does not have permission to sign in.
   // Returning '-2' indicates that a fatal error has occurred while querying the database.
   function Authenticate($Username, $Password, $PersistentSession) {
      // Validate the username and password that have been set
      $Username = FormatStringForDatabaseInput($Username);
      $Password = FormatStringForDatabaseInput($Password);
      $UserID = 0;
		
      // Retrieve matching username/password values
      $s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
      $s->SetMainTable('User', 'u');
      $s->AddJoin('Role', 'r', 'RoleID', 'u', 'RoleID', 'left join');
      $s->AddSelect(array('UserID','VerificationKey'), 'u');
      $s->AddSelect('PERMISSION_SIGN_IN', 'r');
      $s->AddWhere('u', 'Name', '', $Username, '=');
      $s->AddWhere('u', 'Password', '', $Password, '=', 'and', 'md5', 1, 1);
      $s->AddWhere('u', 'Password', '', $Password, '=', 'or');
      $s->EndWhereGroup();

      $UserResult = $this->Context->Database->Select($s,
         'Authenticator',
         'Authenticate',
         'An error occurred while attempting to validate your credentials');
              
      if (!$UserResult) {
         $UserID = -2;
      } elseif ($this->Context->Database->RowCount($UserResult) > 0) {
         $CanSignIn = 0;
         $VerificationKey = '';
         while ($rows = $this->Context->Database->GetRow($UserResult)) {
            $VerificationKey = ForceString($rows['VerificationKey'], '');
            if ($VerificationKey == '') $VerificationKey = DefineVerificationKey();
            $UserID = ForceInt($rows['UserID'], 0);
            $CanSignIn = ForceBool($rows['PERMISSION_SIGN_IN'], 0);
         }
         if (!$CanSignIn) {
            $UserID = -1;
         } else {
            // Update the user's information
            $this->UpdateLastVisit($UserID, $VerificationKey);

            // Assign the session value
            $this->AssignSessionUserID($UserID);

            // Set the 'remember me' cookies
            if ($PersistentSession) $this->SetCookieCredentials($UserID, $VerificationKey);
         }
      }
      return $UserID;
   }
   
   function Authenticator(&$Context) {
      $this->Context = &$Context;
   }
   
   function DeAuthenticate() {
      if (session_id()) session_destroy();

      // Destroy the cookies as well
      setcookie($this->Context->Configuration['COOKIE_USER_KEY'],
         ' ',
         time()-3600,
         $this->Context->Configuration['COOKIE_PATH'],
         $this->Context->Configuration['COOKIE_DOMAIN']);
      unset($_COOKIE[$this->Context->Configuration['COOKIE_USER_KEY']]);
      setcookie($this->Context->Configuration['COOKIE_VERIFICATION_KEY'],
         ' ',
         time()-3600,
         $this->Context->Configuration['COOKIE_PATH'],
         $this->Context->Configuration['COOKIE_DOMAIN']);
      unset($_COOKIE[$this->Context->Configuration['COOKIE_VERIFICATION_KEY']]);
      return true;      
   }
   
   function GetIdentity() {
      if (!session_id()) {
			session_set_cookie_params(0, $this->Context->Configuration['COOKIE_PATH'], $this->Context->Configuration['COOKIE_DOMAIN']);
			session_start();
		}
		
      $UserID = ForceInt(@$_SESSION[$this->Context->Configuration['SESSION_USER_IDENTIFIER']], 0);
      if ($UserID == 0) {
         // UserID wasn't found in the session, so attempt to retrieve it from the cookies
         // Retrieve cookie values         
         $CookieUserID = ForceIncomingCookieString($this->Context->Configuration['COOKIE_USER_KEY'], '');
         $VerificationKey = ForceIncomingCookieString($this->Context->Configuration['COOKIE_VERIFICATION_KEY'], '');
         
         if ($CookieUserID != '' && $VerificationKey != '') {
            
            // Compare against db values
            $s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
            $s->SetMainTable('User', 'u');
            $s->AddJoin('Role', 'r', 'RoleID', 'u', 'RoleID', 'inner join');
            $s->AddSelect('UserID', 'u');
            $s->AddWhere('u', 'UserID', '', FormatStringForDatabaseInput($CookieUserID), '=');
            $s->AddWhere('u', 'VerificationKey', '', FormatStringForDatabaseInput($VerificationKey), '=');

            $Result = $this->Context->Database->Select($s,
               'Authenticator',
               'GetIdentity',
               'An error occurred while attempting to validate your remember me credentials');

            if ($Result) {
               while ($rows = $this->Context->Database->GetRow($Result)) {
                  $UserID = ForceInt($rows['UserID'], 0);
               }
               if ($UserID > 0) {
                  // 1. Update the user's information
                  $this->UpdateLastVisit($UserID);
                  
                  // 2. Log the user's IP address
                  $this->LogIp($UserID);
               }
            }
         }
      }
		
      // If it has now been found, set up the session.
      $this->AssignSessionUserID($UserID);
      return $UserID;
   }
	
   // All methods below this point are specific to this authenticator and
   // should not be treated as interface methods. The only required interface
   // properties and methods appear above.
   
   function AssignSessionUserID($UserID) {
      if ($UserID > 0) {
         @$_SESSION[$this->Context->Configuration['SESSION_USER_IDENTIFIER']] = $UserID;
      }
   }
	
   function LogIp($UserID) {
      if ($this->Context->Configuration['LOG_ALL_IPS']) {
         $s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
         $s->SetMainTable('IpHistory', 'i');
         $s->AddFieldNameValue('UserID', $UserID);
         $s->AddFieldNameValue('RemoteIp', GetRemoteIp(1));
         $s->AddFieldNameValue('DateLogged', MysqlDateTime());

         $this->Context->Database->Insert($s,
            'Authenticator',
            'LogIp',
            'An error occurred while logging your IP address.',
            false); // fail silently
      }
   }
	
   function SetCookieCredentials($CookieUserID, $VerificationKey) {
      // Note: 2592000 is 60*60*24*30 or 30 days
      setcookie($this->Context->Configuration['COOKIE_USER_KEY'],
         $CookieUserID,
         time()+2592000,
         $this->Context->Configuration['COOKIE_PATH'],
         $this->Context->Configuration['COOKIE_DOMAIN']);
      setcookie($this->Context->Configuration['COOKIE_VERIFICATION_KEY'],
         $VerificationKey,
         time()+2592000,
         $this->Context->Configuration['COOKIE_PATH'],
         $this->Context->Configuration['COOKIE_DOMAIN']);
   }
	
   function UpdateLastVisit($UserID, $VerificationKey = '') {
      $s = $this->Context->ObjectFactory->NewContextObject($this->Context, 'SqlBuilder');
      $s->SetMainTable('User', 'u');
      $s->AddFieldNameValue('DateLastActive', MysqlDateTime());
      if ($VerificationKey != '') $s->AddFieldNameValue('VerificationKey', $VerificationKey);
      $s->AddFieldNameValue('CountVisit', 'CountVisit + 1', 0);
      $s->AddWhere('u', 'UserID', '', $UserID, '=');

      $this->Context->Database->Update($s,
         'Authenticator',
         'UpdateLastVisit',
         'An error occurred while updating your profile.',
         false); // fail silently
   }
}
?>