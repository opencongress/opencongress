<?php
// REPORT ALL ERRORS
error_reporting(E_ALL);
// DO NOT ALLOW PHP_SESS_ID TO BE PASSED IN THE QUERYSTRING
ini_set('session.use_only_cookies', 1);
// Track errors so explicit error messages can be reported should errors be encountered
ini_set('track_errors', 1);
// Define constant for magic_quotes
define('MAGIC_QUOTES_ON', get_magic_quotes_gpc());

// INCLUDE NECESSARY CLASSES & FUNCTIONS
include('../library/Framework/Framework.Functions.php');
include('../library/Framework/Framework.Class.Select.php');
include('../library/Framework/Framework.Class.SqlBuilder.php');
include('../library/Framework/Framework.Class.MessageCollector.php');
include('../library/Framework/Framework.Class.ErrorManager.php');
include('../library/Framework/Framework.Class.ConfigurationManager.php');

// Include database structure
include('../appg/database.php');

// Set up some configuration defaults to override
$Configuration['DATABASE_HOST'] = ''; 
$Configuration['DATABASE_NAME'] = ''; 
$Configuration['DATABASE_USER'] = ''; 
$Configuration['DATABASE_PASSWORD'] = '';
$Configuration['APPLICATION_PATH'] = '';
$Configuration['DATABASE_PATH'] = ''; 
$Configuration['LIBRARY_PATH'] = ''; 
$Configuration['EXTENSIONS_PATH'] = ''; 
$Configuration['LANGUAGES_PATH'] = '';
$Configuration['THEME_PATH'] = '';
$Configuration['BASE_URL'] = '';
$Configuration['DEFAULT_STYLE'] = ''; 
$Configuration['WEB_ROOT'] = '';
$Configuration['COOKIE_DOMAIN'] = ''; 
$Configuration['COOKIE_PATH'] = ''; 
$Configuration['SUPPORT_EMAIL'] = ''; 
$Configuration['SUPPORT_NAME'] = ''; 
$Configuration['FORWARD_VALIDATED_USER_URL'] = '';
$Configuration['CHARSET'] = 'utf-8';
$Configuration['DATABASE_TABLE_PREFIX'] = 'LUM_';
$Configuration['SETUP_COMPLETE'] = '0';
$Configuration['SETUP_TEST'] = '0';

$Configuration['APPLICATION_TITLE'] = '';
$Configuration['BANNER_TITLE'] = '';
$Configuration['APPLICATION_TITLE'] = '';
$Configuration['APPLICATION_TITLE'] = '';
$Configuration['DISCUSSIONS_PER_PAGE'] = '';
$Configuration['COMMENTS_PER_PAGE'] = '';
$Configuration['SEARCH_RESULTS_PER_PAGE'] = '';
$Configuration['ALLOW_NAME_CHANGE'] = '';
$Configuration['PUBLIC_BROWSING'] = '';
$Configuration['USE_CATEGORIES'] = '';
$Configuration['LOG_ALL_IPS'] = '';
$Configuration['PANEL_BOOKMARK_COUNT'] = '';
$Configuration['PANEL_PRIVATE_COUNT'] = '';
$Configuration['PANEL_HISTORY_COUNT'] = '';
$Configuration['PANEL_USERDISCUSSIONS_COUNT'] = '';
$Configuration['PANEL_SEARCH_COUNT'] = '';
$Configuration['MAX_COMMENT_LENGTH'] = '';
$Configuration['DISCUSSION_POST_THRESHOLD'] = '';
$Configuration['DISCUSSION_TIME_THRESHOLD'] = '';
$Configuration['DISCUSSION_THRESHOLD_PUNISHMENT'] = '';
$Configuration['COMMENT_POST_THRESHOLD'] = '';
$Configuration['COMMENT_TIME_THRESHOLD'] = '';
$Configuration['COMMENT_THRESHOLD_PUNISHMENT'] = '';
$Configuration['DEFAULT_ROLE'] = '';
$Configuration['ALLOW_IMMEDIATE_ACCESS'] = '';
$Configuration['APPROVAL_ROLE'] = '';

class FauxContext {
   var $WarningCollector;
   var $ErrorManager;
   var $SqlCollector;
	var $Configuration;
	var $Dictionary;
	var $DatabaseTables;
	var $DatabaseColumns;
	var $Session;
	function GetDefinition($Code) {
		if (array_key_exists($Code, $this->Dictionary)) {
			return $this->Dictionary[$Code];
		} else {
			return $Code;
		}
	}
}

class FauxSession {
	var $User = false;
}

// Retrieves an array of column names in the specified table
function GetColumns(&$Connection, $Table) {
	$Data = @mysql_query('show columns from '.$Table, $Connection);
	$FoundColumns = array();
	if (!$Data) {
		$Context->WarningCollector->Add("Failed to identify existing '.$Table.' columns. MySQL reported the following error: <code>".mysql_error($Connection)."</code>");
	} else {
		while ($Row = mysql_fetch_array($Data)) {
			$FoundColumns[] = $Row[0];
		}					
	}
	return $FoundColumns;
}
function ApplySetting(&$SettingsManager, $NewConfiguration, $Setting) {
	if (array_key_exists($Setting, $NewConfiguration)) {
		$SettingsManager->DefineSetting($Setting, $NewConfiguration[$Setting], 1);
	}
}

// Create warning & error handlers
$Context = new FauxContext();
$Context->Session = new FauxSession();
$Context->WarningCollector = new MessageCollector();
$Context->ErrorManager = new ErrorManager();
$Context->SqlCollector = new MessageCollector();
$Context->Configuration = $Configuration;
$Context->DatabaseTables = $DatabaseTables;
$Context->DatabaseColumns = $DatabaseColumns;
$Context->Dictionary = array();

// Dictionary Definitions
$Context->Dictionary['ErrReadFileSettings'] = 'An error occurred while attempting to read settings from the configuration file: ';
$Context->Dictionary['ErrOpenFile'] = 'The file could not be opened. Please make sure that PHP has write access to the //1 file.';
$Context->Dictionary['ErrWriteFile'] = 'The file could not be written.';

// Define application settings
$WorkingDirectory = str_replace('\\', '/', getcwd()).'/';
$RootDirectory = str_replace('setup/', '', $WorkingDirectory);
$WebRoot = dirname(ForceString(@$_SERVER['PHP_SELF'], ''));
$WebRoot = substr($WebRoot, 0, strlen($WebRoot) - 5); // strips the "setup" off the end of the path.
$BaseUrl = 'http://'.ForceString(@$_SERVER['HTTP_HOST'], '').$WebRoot;
$ThemeDirectory = $WebRoot . 'themes/';
$AllowNext = 0;
$NewConfiguration = array();

// Assign some default values to the postback parameters
$DBHost = '';
$DBName = '';
$DBUser = '';
$DBPass = '';
$SupportEmail = '';
$SupportName = '';
$ApplicationTitle = '';

// Include the old settings file if it is present (it just contains constants)
if (file_exists($RootDirectory.'conf/old_settings.php')) {
   include($RootDirectory.'conf/old_settings.php');
   
   // Now re-assign the default configuration settings to the ones defined as constants in the old version
   if (defined('dbHOST')) {
		$NewConfiguration['DATABASE_HOST'] = dbHOST;
		$DBHost = dbHOST;
	}
   if (defined('dbNAME')) {
		$NewConfiguration['DATABASE_NAME'] = dbNAME;
		$DBName = dbNAME;
	}
   if (defined('dbUSER')) {
		$NewConfiguration['DATABASE_USER'] = dbUSER;
		$DBUser = dbUSER;
	}
   if (defined('dbPASSWORD')) {
		$NewConfiguration['DATABASE_PASSWORD'] = dbPASSWORD;
		$DBPass = dbPASSWORD;
	}   
   if (defined('agAPPLICATION_TITLE')) {
		$NewConfiguration['APPLICATION_TITLE'] = agAPPLICATION_TITLE;
		$ApplicationTitle = agAPPLICATION_TITLE;
	}
   if (defined('agBANNER_TITLE')) $NewConfiguration['BANNER_TITLE'] = agBANNER_TITLE;
   if (defined('agDISCUSSIONS_PER_PAGE')) $NewConfiguration['DISCUSSIONS_PER_PAGE'] = agDISCUSSIONS_PER_PAGE;
   if (defined('agCOMMENTS_PER_PAGE')) $NewConfiguration['COMMENTS_PER_PAGE'] = agCOMMENTS_PER_PAGE;
   if (defined('agSEARCH_RESULTS_PER_PAGE')) $NewConfiguration['SEARCH_RESULTS_PER_PAGE'] = agSEARCH_RESULTS_PER_PAGE;
   if (defined('agSUPPORT_EMAIL')) {
		$NewConfiguration['SUPPORT_EMAIL'] = agSUPPORT_EMAIL;
		$SupportEmail = agSUPPORT_EMAIL;
	}
   if (defined('agSUPPORT_NAME')) {
		$NewConfiguration['SUPPORT_NAME'] = agSUPPORT_NAME;
		$SupportName = agSUPPORT_NAME;
	}
   if (defined('agALLOW_NAME_CHANGE')) $NewConfiguration['ALLOW_NAME_CHANGE'] = agALLOW_NAME_CHANGE;
   if (defined('agPUBLIC_BROWSING')) $NewConfiguration['PUBLIC_BROWSING'] = agPUBLIC_BROWSING;
   if (defined('agUSE_CATEGORIES')) $NewConfiguration['USE_CATEGORIES'] = agUSE_CATEGORIES;
   if (defined('agLOG_ALL_IPS')) $NewConfiguration['LOG_ALL_IPS'] = agLOG_ALL_IPS;
   if (defined('agPANEL_BOOKMARK_COUNT')) $NewConfiguration['PANEL_BOOKMARK_COUNT'] = agPANEL_BOOKMARK_COUNT;
   if (defined('agPANEL_PRIVATE_COUNT')) $NewConfiguration['PANEL_PRIVATE_COUNT'] = agPANEL_PRIVATE_COUNT;
   if (defined('agPANEL_HISTORY_COUNT')) $NewConfiguration['PANEL_HISTORY_COUNT'] = agPANEL_HISTORY_COUNT;
   if (defined('agPANEL_USERDISCUSSIONS_COUNT')) $NewConfiguration['PANEL_USERDISCUSSIONS_COUNT'] = agPANEL_USERDISCUSSIONS_COUNT;
   if (defined('agPANEL_SEARCH_COUNT')) $NewConfiguration['PANEL_SEARCH_COUNT'] = agPANEL_SEARCH_COUNT;
   if (defined('agMAX_COMMENT_LENGTH')) $NewConfiguration['MAX_COMMENT_LENGTH'] = agMAX_COMMENT_LENGTH;
   if (defined('agDISCUSSION_POST_THRESHOLD')) $NewConfiguration['DISCUSSION_POST_THRESHOLD'] = agDISCUSSION_POST_THRESHOLD;
   if (defined('agDISCUSSION_TIME_THRESHOLD')) $NewConfiguration['DISCUSSION_TIME_THRESHOLD'] = agDISCUSSION_TIME_THRESHOLD;
   if (defined('agDISCUSSION_THRESHOLD_PUNISHMENT')) $NewConfiguration['DISCUSSION_THRESHOLD_PUNISHMENT'] = agDISCUSSION_THRESHOLD_PUNISHMENT;
   if (defined('agCOMMENT_POST_THRESHOLD')) $NewConfiguration['COMMENT_POST_THRESHOLD'] = agCOMMENT_POST_THRESHOLD;
   if (defined('agCOMMENT_TIME_THRESHOLD')) $NewConfiguration['COMMENT_TIME_THRESHOLD'] = agCOMMENT_TIME_THRESHOLD;
   if (defined('agCOMMENT_THRESHOLD_PUNISHMENT')) $NewConfiguration['COMMENT_THRESHOLD_PUNISHMENT'] = agCOMMENT_THRESHOLD_PUNISHMENT;
   if (defined('agDEFAULT_ROLE')) $NewConfiguration['DEFAULT_ROLE'] = agDEFAULT_ROLE;
   if (defined('agALLOW_IMMEDIATE_ACCESS')) $NewConfiguration['ALLOW_IMMEDIATE_ACCESS'] = agALLOW_IMMEDIATE_ACCESS;
   if (defined('agAPPROVAL_ROLE')) $NewConfiguration['APPROVAL_ROLE'] = agAPPROVAL_ROLE;   
}

// Retrieve all postback parameters
$CurrentStep = ForceIncomingInt("Step", 0);
$PostBackAction = ForceIncomingString('PostBackAction', '');
$DBHost = ForceIncomingString('DBHost', $DBHost);
$DBName = ForceIncomingString('DBName', $DBName);
$DBUser = ForceIncomingString('DBUser', $DBUser);
$DBPass = ForceIncomingString('DBPass', $DBPass);
$SupportEmail = ForceIncomingString('SupportEmail', $SupportEmail);
$SupportName = ForceIncomingString('SupportName', $SupportName);
$ApplicationTitle = ForceIncomingString('ApplicationTitle', $ApplicationTitle);
$CookieDomain = ForceIncomingString('CookieDomain', '');
$CookiePath = ForceIncomingString('CookiePath', '');

function CreateFile($File, $Contents, &$Context) {
	if (!file_exists($File)) {
		$Handle = @fopen($File, 'wb');
		if (!$Handle) {
			$Error = $php_errormsg;
			if ($Error != '') $Error = 'The system reported the following message:<code>'.$Error.'</code>';
			$Context->WarningCollector->Add("Failed to create the '".$File."' configuration file. ".$Error);
		} else {
			if (fwrite($Handle, $Contents) === FALSE) {
				$Context->WarningCollector->Add("Failed to write to the '".$File."' file. Make sure that PHP has write access to the file.");
			}
			fclose($Handle);
		}
	}
}

// Step 1. Check for correct PHP, MySQL, and permissions
if ($PostBackAction == "Permissions") {
   
   // Make sure we are running at least PHP 4.1.0
   if (intval(str_replace('.', '', phpversion())) < 410) $Context->WarningCollector->Add("It appears as though you are running PHP version ".phpversion().". Vanilla requires at least version 4.1.0 of PHP. You will need to upgrade your version of PHP before you can continue.");
   // Make sure MySQL is available
   if (!function_exists('mysql_connect')) $Context->WarningCollector->Add("It appears as though you do not have MySQL enabled for PHP. You will need a working copy of MySQL and PHP's MySQL extensions enabled in order to run Vanilla.");   
   // Make sure the conf folder is readable
   if (!is_readable('../conf/')) $Context->WarningCollector->Add("Vanilla needs to have read permission enabled on the conf folder.");
   // Make sure the conf folder is writeable
   if (!is_writable('../conf/')) $Context->WarningCollector->Add("Vanilla needs to have write permission enabled on the conf folder.");
   
   // Make sure other folders are readable
   if (!is_readable('../extensions/')) $Context->WarningCollector->Add("Vanilla needs to have read permission enabled on the extensions folder.");
   if (!is_readable('../languages/')) $Context->WarningCollector->Add("Vanilla needs to have read permission enabled on the languages folder.");
   if (!is_readable('../themes/')) $Context->WarningCollector->Add("Vanilla needs to have read permission enabled on the themes folder.");
   if (!is_readable('../setup/')) $Context->WarningCollector->Add("Vanilla needs to have read permission enabled on the setup folder.");
	
	// Make sure the files don't exist already (ie. the site is already up and running);
   if (file_exists('../conf/settings.php')) $Context->WarningCollector->Add("Vanilla seems to have been upgraded already. You will need to remove the conf/settings.php and conf/database.php files to run the upgrade utility again.");
	
   if ($Context->WarningCollector->Count() == 0) {
      $Contents = '<?php
// Database Configuration Settings
?>';
      CreateFile($RootDirectory.'conf/database.php', $Contents, $Context);
      $Contents = "<?php
// Make sure this file was not accessed directly and prevent register_globals configuration array attack
if (!defined('IN_VANILLA')) exit();		
// Enabled Extensions
?>";
      CreateFile($RootDirectory.'conf/extensions.php', $Contents, $Context);
      $Contents = "<?php
// Custom Language Definitions
?>";
      CreateFile($RootDirectory.'conf/language.php', $Contents, $Context);
      $Contents = '<?php
// Application Settings
?>';
      CreateFile($RootDirectory.'conf/settings.php', $Contents, $Context);
   }

   // Save a test configuration option to the conf/settings.php file (This is inconsequential and is only done to make sure we have read access).
   if ($Context->WarningCollector->Count() == 0) {
      $SettingsFile = $RootDirectory . 'conf/settings.php';
      $SettingsManager = new ConfigurationManager($Context);
      $SettingsManager->DefineSetting('SETUP_TEST', '1', 1);
      if (!$SettingsManager->SaveSettingsToFile($SettingsFile)) {
         $Context->WarningCollector->Clear();
         $Context->WarningCollector->Add("For some reason we couldn't save your general settings to the '".$SettingsFile."' file.");
      }
   }
      
   if ($Context->WarningCollector->Count() == 0) {
		// Redirect to the next step (this is done so that refreshes don't cause steps to be redone)
      header('location: '.$WebRoot.'setup/upgrader.php?Step=2&PostBackAction=None');
		die();
	}
} elseif ($PostBackAction == "Database") {
	$CurrentStep = 2;
   // Test the database params provided by the user
   $Connection = @mysql_connect($DBHost, $DBUser, $DBPass);
   if (!$Connection) {
		$Response = '';
		if ($php_errormsg != '') $Response = ' The database responded with the following message: '.$php_errormsg;
      $Context->WarningCollector->Add("We couldn't connect to the server you provided (".$DBHost.").".$Response);
   } elseif (!mysql_select_db($DBName, $Connection)) {
      $Context->WarningCollector->Add("We connected to the server, but we couldn't access the \"".$DBName."\" database. Are you sure it exists and that the specified user has access to it?");
   }
   
   // If the database connection worked...
   if ($Context->WarningCollector->Count() == 0 && $Connection) {
					
      // Make sure all of the required tables are there for upgrading
      $TableData = @mysql_query('show tables', $Connection);
      if (!$TableData) {
         $Context->WarningCollector->Add("We had some problems identifying the tables already in your database: ". mysql_error($Connection));
      } else {
         $TableMatches = array();
			$TableToCompare = '';
			$MissingTables = '';
         while ($Row = mysql_fetch_array($TableData)) {
				$TableToCompare = $Row[0];
				$TableToCompare = str_replace('lum_', '', strtolower($TableToCompare));
				// Make sure that the required tables exist
				while (list($TableKey, $TableName) = each($DatabaseTables)) {
					if (strtolower($TableKey) == $TableToCompare) {
						// Make sure to update the DatabaseTables array with the actual table names (case-corrected for buggy windows machines)
						$DatabaseTables[$TableKey] = $Row[0];
						$TableMatches[$TableToCompare] = $Row[0];
					}
				}
				reset($DatabaseTables);
         }
         if (count($TableMatches) != count($DatabaseTables)) {
				$MissingTables = '';
				while (list($TableKey, $TableName) = each($DatabaseTables)) {
					$Found = 0;
					while (list ($MatchKey, $MatchName) = each ($TableMatches)) {
						if (strtolower($TableName) != $MatchKey) $Found = 1;
					}
					if (!$Found) {
						if ($MissingTables != '') $MissingTables .= ', ';
						$MissingTables .= $TableName;
					}
				}
            $Context->WarningCollector->Add("It appears as though your Vanilla installation is missing some tables: <code>".$MissingTables."</code>");
         } else {
				// 1. Upgrade Role Table (The hard part first)
            
				// Check for current columns in the table
            $RoleData = @mysql_query('show columns from '.$DatabaseTables['Role'], $Connection);
				$RoleColumns = GetColumns($Connection, $DatabaseTables['Role']);
				
            // 1a. Rename columns
				if ($Context->WarningCollector->Count() == 0) {
					if (in_array('CanLogin', $RoleColumns) && !in_array('PERMISSION_SIGN_IN', $RoleColumns)) {
						$AlterSQL = "alter table ".$DatabaseTables['Role']." change CanLogin PERMISSION_SIGN_IN enum('1','0') not null default '0'";
						if (!@mysql_query($AlterSQL, $Connection)) $Context->WarningCollector->Add("An error occurred renaming LUM_Role.CanLogin to LUM_Role.PERMISSION_SIGN_IN. MySQL reported the following error: <code>".mysql_error($Connection).'</code>');
					}
				}
				
				if ($Context->WarningCollector->Count() == 0) {
					if (in_array('CanPostHTML', $RoleColumns) && !in_array('PERMISSION_HTML_ALLOWED', $RoleColumns)) {
						$AlterSQL = "alter table ".$DatabaseTables['Role']." change CanPostHTML PERMISSION_HTML_ALLOWED enum('1','0') not null default '0'";
						if (!@mysql_query($AlterSQL, $Connection)) $Context->WarningCollector->Add("An error occurred renaming LUM_Role.CanPostHTML to LUM_Role.PERMISSION_HTML_ALLOWED. MySQL reported the following error: <code>".mysql_error($Connection).'</code>');
					}
				}
				
				// 1b. Add new columns
				if ($Context->WarningCollector->Count() == 0) {
					if (!in_array('PERMISSION_RECEIVE_APPLICATION_NOTIFICATION', $RoleColumns)) {
						$AlterSQL = "alter table ".$DatabaseTables['Role']." add PERMISSION_RECEIVE_APPLICATION_NOTIFICATION enum('1','0') not null default '0'";
						if (!@mysql_query($AlterSQL, $Connection)) $Context->WarningCollector->Add("An error occurred while adding LUM_Role.PERMISSION_RECEIVE_APPLICATION_NOTIFICATION. MySQL reported the following error: <code>".mysql_error($Connection).'</code>');
					}
				}
				
				if ($Context->WarningCollector->Count() == 0) {
					if (!in_array('Permissions', $RoleColumns)) {
						$AlterSQL = "alter table ".$DatabaseTables['Role']." add Permissions text";
						if (!@mysql_query($AlterSQL, $Connection)) $Context->WarningCollector->Add("An error occurred while adding LUM_Role.Permissions. MySQL reported the following error: <code>".mysql_error($Connection).'</code>');
					}
				}
				if ($Context->WarningCollector->Count() == 0) {
					if (!in_array('Priority', $RoleColumns)) {
						$AlterSQL = "alter table ".$DatabaseTables['Role']." add Priority int not null default '0'";
						if (!@mysql_query($AlterSQL, $Connection)) $Context->WarningCollector->Add("An error occurred while adding LUM_Role.Priority. MySQL reported the following error: <code>".mysql_error($Connection).'</code>');
					}
				}
				if ($Context->WarningCollector->Count() == 0) {
					if (!in_array('UnAuthenticated', $RoleColumns)) {
						$AlterSQL = "alter table ".$DatabaseTables['Role']." add UnAuthenticated enum('1','0') not null default '0'";
						if (!@mysql_query($AlterSQL, $Connection)) $Context->WarningCollector->Add("An error occurred while adding LUM_Role.UnAuthenticated. MySQL reported the following error: <code>".mysql_error($Connection).'</code>');
					}
				}
				
				// 1c. Retrieve current permissions, serialize, and resave as long as the MasterAdmin column was present
            if (in_array('MasterAdmin', $RoleColumns)) {
					// Get an updated version of the columns in the database (Because some were changed above)
               $RoleColumns = GetColumns($Connection, $DatabaseTables['Role']);
					$SelectSQL = "select ".implode(',', $RoleColumns)." from ".$DatabaseTables['Role'];
					$RoleData = @mysql_query($SelectSQL, $Connection);
					if (!$RoleData) {
						$Context->WarningCollector->Add("An error occurred while retrieving existing role data. MySQL reported the following error: <code>".mysql_error($Connection)."</code>");
					} else {
						$Permissions = array();
						while ($Row = mysql_fetch_array($RoleData)) {
							$RoleID = ForceInt($Row['RoleID'], 0);
							$Permissions['PERMISSION_ADD_COMMENTS'] = ForceBool(@$Row['CanPostComment'], 0);
							$Permissions['PERMISSION_START_DISCUSSION'] = ForceBool(@$Row['CanPostDiscussion'], 0);
							// Discussion Moderator Permissions
							$Permissions['PERMISSION_SINK_DISCUSSIONS'] = ForceBool(@$Row['AdminCategories'], 0);
							$Permissions['PERMISSION_STICK_DISCUSSIONS'] = ForceBool(@$Row['AdminCategories'], 0);
							$Permissions['PERMISSION_HIDE_DISCUSSIONS'] = ForceBool(@$Row['AdminCategories'], 0);
							$Permissions['PERMISSION_CLOSE_DISCUSSIONS'] = ForceBool(@$Row['AdminCategories'], 0);
							$Permissions['PERMISSION_EDIT_DISCUSSIONS'] = ForceBool(@$Row['AdminCategories'], 0);
							$Permissions['PERMISSION_VIEW_HIDDEN_DISCUSSIONS'] = ForceBool(@$Row['ShowAllWhispers'], 0);
							$Permissions['PERMISSION_EDIT_COMMENTS'] = ForceBool(@$Row['AdminCategories'], 0);
							$Permissions['PERMISSION_HIDE_COMMENTS'] = ForceBool(@$Row['AdminCategories'], 0);
							$Permissions['PERMISSION_VIEW_HIDDEN_COMMENTS'] = ForceBool(@$Row['ShowAllWhispers'], 0);
							$Permissions['PERMISSION_ADD_COMMENTS_TO_CLOSED_DISCUSSION'] = ForceBool(@$Row['AdminCategories'], 0);
							$Permissions['PERMISSION_ADD_CATEGORIES'] = ForceBool(@$Row['AdminCategories'], 0);
							$Permissions['PERMISSION_EDIT_CATEGORIES'] = ForceBool(@$Row['AdminCategories'], 0);
							$Permissions['PERMISSION_REMOVE_CATEGORIES'] = ForceBool(@$Row['AdminCategories'], 0);
							$Permissions['PERMISSION_SORT_CATEGORIES'] = ForceBool(@$Row['AdminCategories'], 0);
							$Permissions['PERMISSION_VIEW_ALL_WHISPERS'] = ForceBool(@$Row['AdminCategories'], 0);
							// User Moderator Permissions
							$Permissions['PERMISSION_APPROVE_APPLICANTS'] = ForceBool(@$Row['AdminUsers'], 0);
							$Permissions['PERMISSION_RECEIVE_APPLICATION_NOTIFICATION'] = ForceBool(@$Row['AdminUsers'], 0);
							$Permissions['PERMISSION_CHANGE_USER_ROLE'] = ForceBool(@$Row['AdminUsers'], 0);
							$Permissions['PERMISSION_EDIT_USERS'] = ForceBool(@$Row['AdminUsers'], 0);
							$Permissions['PERMISSION_IP_ADDRESSES_VISIBLE'] = ForceBool(@$Row['CanViewIps'], 0);
							$Permissions['PERMISSION_MANAGE_REGISTRATION'] = ForceBool(@$Row['AdminUsers'], 0);
							$Permissions['PERMISSION_SORT_ROLES'] = ForceBool(@$Row['AdminUsers'], 0);
							$Permissions['PERMISSION_ADD_ROLES'] = ForceBool(@$Row['AdminUsers'], 0);
							$Permissions['PERMISSION_EDIT_ROLES'] = ForceBool(@$Row['AdminUsers'], 0);
							$Permissions['PERMISSION_REMOVE_ROLES'] = ForceBool(@$Row['AdminUsers'], 0);
							// Administrative Permissions
							$Permissions['PERMISSION_CHECK_FOR_UPDATES'] = ForceBool(@$Row['MasterAdmin'], 0);
							$Permissions['PERMISSION_CHANGE_APPLICATION_SETTINGS'] = ForceBool(@$Row['MasterAdmin'], 0);
							$Permissions['PERMISSION_MANAGE_EXTENSIONS'] = ForceBool(@$Row['MasterAdmin'], 0);
							$Permissions['PERMISSION_MANAGE_LANGUAGE'] = ForceBool(@$Row['MasterAdmin'], 0);
							$Permissions['PERMISSION_MANAGE_THEMES'] = ForceBool(@$Row['MasterAdmin'], 0);
							$Permissions['PERMISSION_MANAGE_STYLES'] = ForceBool(@$Row['MasterAdmin'], 0);
							$Permissions['PERMISSION_ALLOW_DEBUG_INFO'] = ForceBool(@$Row['MasterAdmin'], 0);
							
							
							$UpdateSQL = "update ".$DatabaseTables['Role']." set Permissions = '".SerializeArray($Permissions)."' where RoleID = ".$RoleID;
							if (!@mysql_query($UpdateSQL, $Connection)) {
								$Context->WarningCollector->Add("An error occurred while updating LUM_Role data. MySQL reported the following error: <code>".mysql_error($Connection).'</code>');
								break;
							}
							// Clear out the permissions array
							$Permissions = array();
						}
					}
				}
            
				// 1d. Remove old permission columns
            if ($Context->WarningCollector->Count() == 0) {
					// Silently drop these columns. If any errors occur, it doesn't
               // really slow anything down to leave them behind. It's just clutter.
               if (in_array('CanPostDiscussion', $RoleColumns)) {
						$AlterSQL = "alter table ".$DatabaseTables['Role']." drop column CanPostDiscussion";
						@mysql_query($AlterSQL, $Connection);
					}
               if (in_array('CanPostComment', $RoleColumns)) {
						$AlterSQL = "alter table ".$DatabaseTables['Role']." drop column CanPostComment";
						@mysql_query($AlterSQL, $Connection);
					}
               if (in_array('AdminUsers', $RoleColumns)) {
						$AlterSQL = "alter table ".$DatabaseTables['Role']." drop column AdminUsers";
						@mysql_query($AlterSQL, $Connection);
					}
               if (in_array('AdminCategories', $RoleColumns)) {
						$AlterSQL = "alter table ".$DatabaseTables['Role']." drop column AdminCategories";
						@mysql_query($AlterSQL, $Connection);
					}
               if (in_array('ShowAllWhispers', $RoleColumns)) {
						$AlterSQL = "alter table ".$DatabaseTables['Role']." drop column ShowAllWhispers";
						@mysql_query($AlterSQL, $Connection);
					}
               if (in_array('MasterAdmin', $RoleColumns)) {
						$AlterSQL = "alter table ".$DatabaseTables['Role']." drop column MasterAdmin";
						@mysql_query($AlterSQL, $Connection);
					}
               if (in_array('CanViewIps', $RoleColumns)) {
						$AlterSQL = "alter table ".$DatabaseTables['Role']." drop column CanViewIps";
						@mysql_query($AlterSQL, $Connection);
					}
				}
				
				// 1e. Make sure that there is an unauthenticated role.
            if ($Context->WarningCollector->Count() == 0) {
					$SelectSQL = "select RoleID from ".$DatabaseTables['Role']." where UnAuthenticated = '1'";
					$RoleData = @mysql_query($SelectSQL, $Connection);
					if (!$RoleData) {
						$Context->WarningCollector->Add("An error occurred while querying for an unauthenticated role. MySQL returned the following error message: <code>".mysql_error($Context)."</code>");
					} else {
						if (mysql_num_rows($RoleData) == 0) {
							// Insert a new unauthenticated role
                     $InsertSQL = "insert into ".$DatabaseTables['Role']."
(`Name`, `Active`, `PERMISSION_SIGN_IN`, `PERMISSION_HTML_ALLOWED`, `PERMISSION_RECEIVE_APPLICATION_NOTIFICATION`, `Permissions`, `Priority`, `UnAuthenticated`)
VALUES ('Unauthenticated','1','1','1','1','a:32:{s:23:\"PERMISSION_ADD_COMMENTS\";N;s:27:\"PERMISSION_START_DISCUSSION\";N;s:28:\"PERMISSION_STICK_DISCUSSIONS\";N;s:27:\"PERMISSION_HIDE_DISCUSSIONS\";N;s:28:\"PERMISSION_CLOSE_DISCUSSIONS\";N;s:27:\"PERMISSION_EDIT_DISCUSSIONS\";N;s:34:\"PERMISSION_VIEW_HIDDEN_DISCUSSIONS\";N;s:24:\"PERMISSION_EDIT_COMMENTS\";N;s:24:\"PERMISSION_HIDE_COMMENTS\";N;s:31:\"PERMISSION_VIEW_HIDDEN_COMMENTS\";N;s:44:\"PERMISSION_ADD_COMMENTS_TO_CLOSED_DISCUSSION\";N;s:25:\"PERMISSION_ADD_CATEGORIES\";N;s:26:\"PERMISSION_EDIT_CATEGORIES\";N;s:28:\"PERMISSION_REMOVE_CATEGORIES\";N;s:26:\"PERMISSION_SORT_CATEGORIES\";N;s:28:\"PERMISSION_VIEW_ALL_WHISPERS\";N;s:29:\"PERMISSION_APPROVE_APPLICANTS\";N;s:27:\"PERMISSION_CHANGE_USER_ROLE\";N;s:21:\"PERMISSION_EDIT_USERS\";N;s:31:\"PERMISSION_IP_ADDRESSES_VISIBLE\";N;s:30:\"PERMISSION_MANAGE_REGISTRATION\";N;s:21:\"PERMISSION_SORT_ROLES\";N;s:20:\"PERMISSION_ADD_ROLES\";N;s:21:\"PERMISSION_EDIT_ROLES\";N;s:23:\"PERMISSION_REMOVE_ROLES\";N;s:28:\"PERMISSION_CHECK_FOR_UPDATES\";N;s:38:\"PERMISSION_CHANGE_APPLICATION_SETTINGS\";N;s:28:\"PERMISSION_MANAGE_EXTENSIONS\";N;s:26:\"PERMISSION_MANAGE_LANGUAGE\";N;s:24:\"PERMISSION_MANAGE_STYLES\";N;s:27:\"PERMISSION_ALLOW_DEBUG_INFO\";N;s:27:\"PERMISSION_DATABASE_CLEANUP\";N;}',0,'1')";
							if (!@mysql_query($InsertSQL, $Connection)) {
								$Context->WarningCollector->Add("An error occurred while inserting a new unauthenticated role. MySQL returned the following error message: <code>".mysql_error($Context)."</code>");
							}
						}
					}
				}
				
				if ($Context->WarningCollector->Count() == 0) {
					// Retrieve Category Columns
               $CategoryColumns = GetColumns($Connection, $DatabaseTables['Category']);
					$DiscussionColumns = GetColumns($Connection, $DatabaseTables['Discussion']);
					$UserColumns = GetColumns($Connection, $DatabaseTables['User']);
					
					// Make remaining table alterations
               if (in_array('Order', $CategoryColumns) && !in_array('Priority', $CategoryColumns)) {
						$AlterSQL = "alter table ".$DatabaseTables['Category']." change `Order` Priority int not null default '0'";
						if (!@mysql_query($AlterSQL, $Connection)) $Context->WarningCollector->Add("An error occurred renaming LUM_Category.Order to LUM_Category.Priority. MySQL reported the following error: <code>".mysql_error($Connection).'</code>');
					}

					if ($Context->WarningCollector->Count() == 0) {
						if (in_array('Settings', $UserColumns) && !in_array('Preferences', $UserColumns)) {
							$AlterSQL = "alter table ".$DatabaseTables['User']." change Settings Preferences text";
							if (!@mysql_query($AlterSQL, $Connection)) $Context->WarningCollector->Add("An error occurred renaming LUM_User.Settings to LUM_User.Preferences. MySQL reported the following error: <code>".mysql_error($Connection).'</code>');
						}
					}
					if ($Context->WarningCollector->Count() == 0) {
						if (!in_array('Sink', $DiscussionColumns)) {
							$AlterSQL = "alter table ".$DatabaseTables['Discussion']." add Sink enum('1','0') not null default '0'";
							if (!@mysql_query($AlterSQL, $Connection)) $Context->WarningCollector->Add("An error occurred adding LUM_Discussion.Sink. MySQL reported the following error: <code>".mysql_error($Connection).'</code>');
						}
					}
					if (in_array('ToolsOn', $UserColumns)) {
						$AlterSQL = "alter table ".$DatabaseTables['User']." drop column ToolsOn";
						@mysql_query($AlterSQL, $Connection);
					}
					if (in_array('UseQuickKeys', $UserColumns)) {
						$AlterSQL = "alter table ".$DatabaseTables['User']." drop column UseQuickKeys";
						@mysql_query($AlterSQL, $Connection);
					}
				}
         }      
      }
      // Close the database connection
      @mysql_close($Connection);
   }
   
   // If the database was upgraded successfully, save all parameters to the conf/database.php file
   if ($Context->WarningCollector->Count() == 0) {
      // Save database settings
      $DBFile = $RootDirectory . 'conf/database.php';
      $DBManager = new ConfigurationManager($Context);
		$DBManager->GetSettingsFromFile($DBFile);
		// Only make these changes if the settings haven't been defined already
      if ($DBManager->GetSetting('DATABASE_HOST') == '') {
			$DBManager->DefineSetting("DATABASE_HOST", $DBHost, 1);
			$DBManager->DefineSetting("DATABASE_NAME", $DBName, 1);
			$DBManager->DefineSetting("DATABASE_USER", $DBUser, 1);
			$DBManager->DefineSetting("DATABASE_PASSWORD", $DBPass, 1);
			$DBManager->SaveSettingsToFile($DBFile);
		
			// Save the general settings as well (now that we know this person is authenticated to
	      // a degree - knowing the database access params).
			$SettingsFile = $RootDirectory . 'conf/settings.php';
			$SettingsManager = new ConfigurationManager($Context);
			$SettingsManager->DefineSetting('APPLICATION_PATH', $RootDirectory, 1);
			$SettingsManager->DefineSetting('DATABASE_PATH', $RootDirectory . 'conf/database.php', 1);
			$SettingsManager->DefineSetting('LIBRARY_PATH', $RootDirectory . 'library/', 1);
			$SettingsManager->DefineSetting('EXTENSIONS_PATH', $RootDirectory . 'extensions/', 1);
			$SettingsManager->DefineSetting('LANGUAGES_PATH', $RootDirectory . 'languages/', 1);
			$SettingsManager->DefineSetting('THEME_PATH', $RootDirectory . 'themes/vanilla/', 1);
			$SettingsManager->DefineSetting("DEFAULT_STYLE", $ThemeDirectory.'vanilla/styles/default/', 1);
			$SettingsManager->DefineSetting("WEB_ROOT", $WebRoot, 1);
			$SettingsManager->DefineSetting("BASE_URL", $BaseUrl, 1);
			$SettingsManager->DefineSetting("FORWARD_VALIDATED_USER_URL", $BaseUrl, 1);
			$SettingsManager->SaveSettingsToFile($SettingsFile);
		} else {
			$Context->WarningCollector->Add("Vanilla seems to have been upgraded already. You will need to remove the conf/settings.php and conf/database.php files to run the upgrade utility again.");
		}
   }
   if ($Context->WarningCollector->Count() == 0) {
		// Redirect to the next step (this is done so that refreshes don't cause steps to be redone)
      header('location: '.$WebRoot.'setup/upgrader.php?Step=3&PostBackAction=None');
		die();
   }
} elseif ($PostBackAction == "User") {
	$CurrentStep = 3;	
   // Validate user inputs
   if (strip_tags($ApplicationTitle) != $ApplicationTitle) $Context->WarningCollector->Add("You can't have any html in your forum name.");
   if ($SupportName == "") $Context->WarningCollector->Add("You must provide a support contact name.");
   if (!eregi("(.+)@(.+)\.(.+)", $SupportEmail)) $Context->WarningCollector->Add("The email address you entered doesn't appear to be valid.");
   if ($ApplicationTitle == "") $Context->WarningCollector->Add("You must provide an application title.");
	
   $SettingsFile = $RootDirectory . 'conf/settings.php';
   $SettingsManager = new ConfigurationManager($Context);
	$SettingsManager->GetSettingsFromFile($SettingsFile);
	if ($SettingsManager->GetSetting('SETUP_COMPLETE') != '1') {
		// Include the db settings defined in the previous step
		include($RootDirectory.'conf/database.php');
		
		// Open the database connection
		$Connection = false;
		if ($Context->WarningCollector->Count() == 0) {
			$DBHost = $Configuration['DATABASE_HOST'];
			$DBName = $Configuration['DATABASE_NAME'];
			$DBUser = $Configuration['DATABASE_USER'];
			$DBPass = $Configuration['DATABASE_PASSWORD'];
			$Connection = @mysql_connect($DBHost, $DBUser, $DBPass);
			if (!$Connection) {
				$Context->WarningCollector->Add("We couldn't connect to the server you provided (".$DBHost."). Are you sure you entered the right server, username and password?");
			} elseif (!mysql_select_db($DBName, $Connection)) {
				$Context->WarningCollector->Add("We connected to the server, but we couldn't access the \"".$DBName."\" database. Are you sure it exists and that the specified user has access to it?");
			}
		}
		
		// Insert the new Style and assign to all users
		if ($Context->WarningCollector->Count() == 0 && $Connection) {
			// Truncate all old styles (They can't work with the new Vanilla)
         $LowerCaseTableNames = 0;
			if (!@mysql_query('truncate table LUM_Style', $Connection)) {
				// Try doing it with a lowercase table name before erroring out
            if (!@mysql_query('truncate table lum_style', $Connection)) {
					$Context->WarningCollector->Add('Failed to clean out LUM_Style table. MySQL reported the following error: <code>'.mysql_error($Connection).'</code>');
				} else {
					$LowerCaseTableNames = 1;
				}
			}
			if ($Context->WarningCollector->Count() == 0) {
				// Insert the new style
				if (!@mysql_query("insert into ".($LowerCaseTableNames ? "lum_style" : "LUM_Style")." (Name, Url) values ('Vanilla', '".$ThemeDirectory."vanilla/styles/default/')", $Connection)) {
					$Context->WarningCollector->Add("Failed to insert new default Vanilla style into LUM_Style table. MySQL reported the following error: <code>".mysql_error($Connection)."</code>");
				} else {
					// Assign the new style to everyone
					if (!@mysql_query("update ".($LowerCaseTableNames ? "lum_user" : "LUM_User")." set StyleID = 1", $Connection)) {
						$Context->WarningCollector->Add("Failed to assign new style to all users. MySQL reported the following error: <code>".mysql_error($Connection)."</code>");
					}
				}
			}
		}
		
		// Close the database connection
		@mysql_close($Connection);
		
		// Save the application constants
		if ($Context->WarningCollector->Count() == 0) {
			$SettingsManager->DefineSetting("SUPPORT_EMAIL", $SupportEmail, 1);
			$SettingsManager->DefineSetting("SUPPORT_NAME", $SupportName, 1);
			$SettingsManager->DefineSetting("APPLICATION_TITLE", $ApplicationTitle, 1);
			$SettingsManager->DefineSetting("COOKIE_DOMAIN", $CookieDomain, 1);
			$SettingsManager->DefineSetting("COOKIE_PATH", $CookiePath, 1);
			if (array_key_exists('BANNER_TITLE', $NewConfiguration)) {
				$SettingsManager->DefineSetting("BANNER_TITLE", $NewConfiguration['BANNER_TITLE'], 1);
			} else {
				$SettingsManager->DefineSetting("BANNER_TITLE", $ApplicationTitle, 1);
			}
			
			// Apply old settings if they were provided
			ApplySetting($SettingsManager, $NewConfiguration, 'DISCUSSIONS_PER_PAGE');
			ApplySetting($SettingsManager, $NewConfiguration, 'COMMENTS_PER_PAGE');
			ApplySetting($SettingsManager, $NewConfiguration, 'SEARCH_RESULTS_PER_PAGE');
			ApplySetting($SettingsManager, $NewConfiguration, 'ALLOW_NAME_CHANGE');
			ApplySetting($SettingsManager, $NewConfiguration, 'PUBLIC_BROWSING');
			ApplySetting($SettingsManager, $NewConfiguration, 'USE_CATEGORIES');
			ApplySetting($SettingsManager, $NewConfiguration, 'LOG_ALL_IPS');
			ApplySetting($SettingsManager, $NewConfiguration, 'PANEL_BOOKMARK_COUNT');
			ApplySetting($SettingsManager, $NewConfiguration, 'PANEL_PRIVATE_COUNT');
			ApplySetting($SettingsManager, $NewConfiguration, 'PANEL_HISTORY_COUNT');
			ApplySetting($SettingsManager, $NewConfiguration, 'PANEL_USERDISCUSSIONS_COUNT');
			ApplySetting($SettingsManager, $NewConfiguration, 'PANEL_SEARCH_COUNT');
			ApplySetting($SettingsManager, $NewConfiguration, 'MAX_COMMENT_LENGTH');
			ApplySetting($SettingsManager, $NewConfiguration, 'DISCUSSION_POST_THRESHOLD');
			ApplySetting($SettingsManager, $NewConfiguration, 'DISCUSSION_TIME_THRESHOLD');
			ApplySetting($SettingsManager, $NewConfiguration, 'DISCUSSION_THRESHOLD_PUNISHMENT');
			ApplySetting($SettingsManager, $NewConfiguration, 'COMMENT_POST_THRESHOLD');
			ApplySetting($SettingsManager, $NewConfiguration, 'COMMENT_TIME_THRESHOLD');
			ApplySetting($SettingsManager, $NewConfiguration, 'COMMENT_THRESHOLD_PUNISHMENT');
			ApplySetting($SettingsManager, $NewConfiguration, 'DEFAULT_ROLE');
			ApplySetting($SettingsManager, $NewConfiguration, 'ALLOW_IMMEDIATE_ACCESS');
			ApplySetting($SettingsManager, $NewConfiguration, 'APPROVAL_ROLE');
			$SettingsManager->DefineSetting("SETUP_COMPLETE", '1', 1);
			$SettingsManager->SaveSettingsToFile($SettingsFile);
		}
	} else {
		$Context->WarningCollector->Add("Vanilla seems to have been upgraded already. You will need to remove the conf/settings.php and conf/database.php files to run the upgrade utility again.");
	}
   
   if ($Context->WarningCollector->Count() == 0) {
		// Redirect to the next step (this is done so that refreshes don't cause steps to be redone)
      header('location: '.$WebRoot.'setup/upgrader.php?Step=4&PostBackAction=None');
		die();
	}
} 

// Write the page
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en-ca">
   <head>
      <title>Vanilla 1.1.2 Upgrader</title>
		<link rel="stylesheet" type="text/css" href="./style.css" />
   </head>
   <body>
      <h1>
         <span><strong>Vanilla 1.1.2</strong> Upgrader</span>
      </h1>
		<div class="Container">
			<div class="Content">
			<?php
			if ($CurrentStep < 2 || $CurrentStep > 4) {
				echo  '<h2>Vanilla Upgrade Wizard (Step 1 of 3)</h2>
				
				<p><strong>Only use this upgrader if you are upgrading from Vanilla 0.9.2.x</strong></p>';
				
				if ($Context->WarningCollector->Count() > 0) {
					echo "<div class=\"Warnings\">
						<strong>We came across some problems while checking your permissions...</strong>
						".$Context->WarningCollector->GetMessages()."
					</div>";
				}
				echo "<p>Navigate the filesystem of your server to the Vanilla folder. If you have your old appg/settings.php file from your previous installation of Vanilla, rename it <strong>old_settings.php</strong> and upload it to the /conf folder of your new Vanilla installation.</p>
				
				<p>Vanilla will need read AND write access to the <strong>conf</strong> folder.</p>
				
				<p>There are many ways to set these permissions. One way is to execute the following from the root Vanilla folder:</p>
				
				<code>chmod 777 ./conf</code>
				
				<p>You will also need to grant read access to the extensions, languages, setup, and themes folders. Typically these permissions are granted by default, but if not you can achieve them with the following commands:</p>
                                
                                <code>chmod --recursive 755 ./extensions
                                <br />chmod --recursive 755 ./languages
                                <br />chmod --recursive 755 ./setup
                                <br />chmod --recursive 755 ./themes</code>
				
				<form id=\"frmPermissions\" method=\"post\" action=\"upgrader.php\">
				<input type=\"hidden\" name=\"PostBackAction\" value=\"Permissions\" />
				<div class=\"Button\"><input type=\"submit\" value=\"Click here to check your permissions and proceed to the next step\" /></div>
				</form>";
			} elseif ($CurrentStep == 2) {
					echo "<h2>Vanilla Upgrade Wizard (Step 2 of 3)</h2>";
					if ($Context->WarningCollector->Count() > 0) {
						echo "<div class=\"Warnings\">
							<strong>We came across some problems while upgrading Vanilla...</strong>
							".$Context->WarningCollector->GetMessages()."
						</div>";
					}
					echo "<p>Below you can provide the connection parameters for the mysql server where your existing Vanilla database is set up so it can be upgraded. If you haven't done it yet, <strong>back up your existing Vanilla database before continuing</strong>.</p>
					<fieldset>
						<form id=\"frmDatabase\" method=\"post\" action=\"upgrader.php\">
						<input type=\"hidden\" name=\"PostBackAction\" value=\"Database\" />
							<ul>
								<li>
									<label for=\"tDBHost\">MySQL Server</label>
									<input type=\"text\" id=\"tDBHost\" name=\"DBHost\" value=\"".FormatStringForDisplay($DBHost, 1)."\" />
								</li>
								<li>
									<label for=\"tDBName\">MySQL Database Name</label>
									<input type=\"text\" id=\"tDBName\" name=\"DBName\" value=\"".FormatStringForDisplay($DBName, 1)."\" />
								</li>
								<li>
									<label for=\"tDBUser\">MySQL User</label>
									<input type=\"text\" id=\"tDBUser\" name=\"DBUser\" value=\"".FormatStringForDisplay($DBUser, 1)."\" />
								</li>
								<li>
									<label for=\"tDBPass\">MySQL Password</label>
									<input type=\"password\" id=\"tDBPass\" name=\"DBPass\" value=\"".FormatStringForDisplay($DBPass, 1)."\" />
								</li>
							</ul>
							<div class=\"Button\"><input type=\"submit\" value=\"Click here to create Vanilla's database and proceed to the next step\" /></div>
						</form>
					</fieldset>";
				} elseif ($CurrentStep == 3) {
					if ($PostBackAction != "User") {
						$CookieDomain = ForceString(@$_SERVER['HTTP_HOST'], "");
						$CookiePath = $WebRoot;
					}
					echo "<h2>Vanilla Upgrade Wizard (Step 3 of 3)</h2>";
					if ($Context->WarningCollector->Count() > 0) {
						echo "<div class=\"Warnings\">
							<strong>We came across some problems while setting up Vanilla...</strong>
							".$Context->WarningCollector->GetMessages()."
						</div>";
					}
					echo "<p>Now we've got to set up the support contact information for your forum. This is what people will see when emails go out from the system for things like password retrieval and role changes.</p>
						<fieldset>"
						.'<form name="frmUser" method="post" action="upgrader.php">
						<input type="hidden" name="PostBackAction" value="User" />					
						<ul>
							<li>
								<label for="tSupportName">Support Contact Name</label>
								<input id="tSupportName" type="text" name="SupportName" value="'.FormatStringForDisplay($SupportName, 1).'" />
							</li>
							<li>
								<label for="tSupportEmail">Support Email Address</label>
								<input id="tSupportEmail" type="text" name="SupportEmail" value="'.FormatStringForDisplay($SupportEmail, 1).'" />
							</li>
						</ul>
						<p>What do you want to call your forum?</p>
						<ul>
							<li>
								<label for="tApplicationTitle">Forum Name</label>
								<input id="tApplicationTitle" type="text" name="ApplicationTitle" value="'.FormatStringForDisplay($ApplicationTitle, 1).'" />
							</li>
						</ul>'
						."<p>The cookie domain is where you want cookies assigned to for Vanilla. Typically the cookie domain will be something like www.yourdomain.com. Cookies can be further defined to a particular path on your website using the \"Cookie Path\" setting. (TIP: If you want your Vanilla cookies to apply to all subdomains of your domain, use \".yourdomain.com\" as the cookie domain).</p>"
						.'<ul>
							<li>
								<label for="tCookieDomain">Cookie Domain</label>
								<input id="tCookieDomain" type="text" name="CookieDomain" value="'.FormatStringForDisplay($CookieDomain, 1).'" />
							</li>
							<li>
								<label for="tCookiePath">Cookie Path</label>
								<input id="tCookiePath" type="text" name="CookiePath" value="'.FormatStringForDisplay($CookiePath, 1).'" />
							</li>
						</ul>
						<div class="Button"><input type="submit" value="Click here to complete the setup process!" /></div>
						</form>
					</fieldset>';
				} else {
					echo "<h2>Vanilla Upgrade Wizard (Complete)</h2>
					<p><strong>That's it! Vanilla has been upgraded.</strong></p>
					<p>Things in Vanilla 1 are quite different to what you're used to. The best new feature is, without a doubt, the new extension engine. You should definitely head over to the <a href=\"http://lussumo.com/addons/\" target=\"Lussumo\">Vanilla Add-on directory</a> right away to find all of your favourite old extensions, plus a bunch of new ones.</p>
					<p>Of course you will also want to go make sure your application was upgraded properly. Here are a few things you should take a look at:</p>
					<ul>
						<li>Public &amp; Private browsing on the Registration Management Form</li>
						<li>On public forums, make sure that the unauthenticated role has access to all public discussion categories</li>
					</ul>
					
					<p>If you find that there was some unforseen problem with the upgrade procedure, visit <a href=\"http://lussumo.com/community/\" target=\"Lussumo\">Lussumo Community Forum</a> for help.</p>
					<div class=\"Button\"><a href=\"../people.php\">Go sign in and have some fun!</a></div>";
				}
				?>
			</div>
		</div>
   </body>
</html>