CREATE TABLE `LUM_Category` (
  `CategoryID` int(2) NOT NULL auto_increment,
  `Name` varchar(100) NOT NULL default '',
  `Description` text NULL,
  `Priority` int(11) NOT NULL default '0',
  PRIMARY KEY  (`CategoryID`)
);

INSERT INTO `LUM_Category` VALUES (1,'General','General discussions go in here...',7);

CREATE TABLE `LUM_CategoryBlock` (
  `CategoryID` int(11) NOT NULL default '0',
  `UserID` int(11) NOT NULL default '0',
  `Blocked` enum('1','0') NOT NULL default '1',
  PRIMARY KEY  (`CategoryID`,`UserID`),
  KEY `cat_block_user` (`UserID`)
);

CREATE TABLE `LUM_CategoryRoleBlock` (
  `CategoryID` int(11) NOT NULL default '0',
  `RoleID` int(11) NOT NULL default '0',
  `Blocked` enum('1','0') NOT NULL default '0',
  KEY `cat_roleblock_cat` (`CategoryID`),
  KEY `cat_roleblock_role` (`RoleID`)
);

CREATE TABLE `LUM_Comment` (
  `CommentID` int(8) NOT NULL auto_increment,
  `DiscussionID` int(8) NOT NULL default '0',
  `AuthUserID` int(10) NOT NULL default '0',
  `DateCreated` datetime default NULL,
  `EditUserID` int(10) default NULL,
  `DateEdited` datetime default NULL,
  `WhisperUserID` int(11) default NULL,
  `Body` text,
  `FormatType` varchar(20) default NULL,
  `Deleted` enum('1','0') NOT NULL default '0',
  `DateDeleted` datetime default NULL,
  `DeleteUserID` int(10) NOT NULL default '0',
  `RemoteIp` varchar(100) default '',
  PRIMARY KEY  (`CommentID`,`DiscussionID`),
  KEY `comment_user` (`AuthUserID`),
  KEY `comment_whisper` (`WhisperUserID`),
  KEY `comment_discussion` (`DiscussionID`)
);

CREATE TABLE `LUM_Discussion` (
  `DiscussionID` int(8) NOT NULL auto_increment,
  `AuthUserID` int(10) NOT NULL default '0',
  `WhisperUserID` int(11) NOT NULL default '0',
  `FirstCommentID` int(11) NOT NULL default '0',
  `LastUserID` int(11) NOT NULL default '0',
  `Active` enum('1','0') NOT NULL default '1',
  `Closed` enum('1','0') NOT NULL default '0',
  `Sticky` enum('1','0') NOT NULL default '0',
  `Sink` enum('1','0') NOT NULL default '0',
  `Name` varchar(100) NOT NULL default '',
  `DateCreated` datetime NOT NULL default '0000-00-00 00:00:00',
  `DateLastActive` datetime NOT NULL default '0000-00-00 00:00:00',
  `CountComments` int(4) NOT NULL default '1',
  `CategoryID` int(11) default NULL,
  `WhisperToLastUserID` int(11) default NULL,
  `WhisperFromLastUserID` int(11) default NULL,
  `DateLastWhisper` datetime default NULL,
  `TotalWhisperCount` int(11) NOT NULL default '0',
  PRIMARY KEY  (`DiscussionID`),
  KEY `discussion_user` (`AuthUserID`),
  KEY `discussion_whisperuser` (`WhisperUserID`),
  KEY `discussion_first` (`FirstCommentID`),
  KEY `discussion_last` (`LastUserID`),
  KEY `discussion_category` (`CategoryID`),
  KEY `discussion_dateactive` (`DateLastActive`)
);

CREATE TABLE `LUM_DiscussionUserWhisperFrom` (
  `DiscussionID` int(11) NOT NULL default '0',
  `WhisperFromUserID` int(11) NOT NULL default '0',
  `LastUserID` int(11) NOT NULL default '0',
  `CountWhispers` int(11) NOT NULL default '0',
  `DateLastActive` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`DiscussionID`,`WhisperFromUserID`),
  KEY `discussion_user_whisper_lastuser` (`LastUserID`),
  KEY `discussion_user_whisper_lastactive` (`DateLastActive`)
);

CREATE TABLE `LUM_DiscussionUserWhisperTo` (
  `DiscussionID` int(11) NOT NULL default '0',
  `WhisperToUserID` int(11) NOT NULL default '0',
  `LastUserID` int(11) NOT NULL default '0',
  `CountWhispers` int(11) NOT NULL default '0',
  `DateLastActive` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`DiscussionID`,`WhisperToUserID`),
  KEY `discussion_user_whisperto_lastuser` (`LastUserID`),
  KEY `discussion_user_whisperto_lastactive` (`DateLastActive`)
);

CREATE TABLE `LUM_IpHistory` (
  `IpHistoryID` int(11) NOT NULL auto_increment,
  `RemoteIp` varchar(30) NOT NULL default '',
  `UserID` int(11) NOT NULL default '0',
  `DateLogged` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`IpHistoryID`)
);

CREATE TABLE `LUM_Role` (
  `RoleID` int(2) NOT NULL auto_increment,
  `Name` varchar(100) NOT NULL default '',
  `Icon` varchar(155) NOT NULL default '',
  `Description` varchar(200) NOT NULL default '',
  `Active` enum('1','0') NOT NULL default '1',
  `PERMISSION_SIGN_IN` enum('1','0') NOT NULL default '0',
  `PERMISSION_HTML_ALLOWED` enum('0','1') NOT NULL default '0',
  `PERMISSION_RECEIVE_APPLICATION_NOTIFICATION` enum('1','0') NOT NULL default '0',
  `Permissions` text NULL,
  `Priority` int(11) NOT NULL default '0',
  `UnAuthenticated` enum('1','0') NOT NULL default '0',
  PRIMARY KEY  (`RoleID`)
);

INSERT INTO `LUM_Role`
(`Name`, `Active`, `PERMISSION_SIGN_IN`, `PERMISSION_HTML_ALLOWED`, `PERMISSION_RECEIVE_APPLICATION_NOTIFICATION`, `Permissions`, `Priority`, `UnAuthenticated`)
VALUES ('Unauthenticated','1','1','1','1','a:32:{s:23:\"PERMISSION_ADD_COMMENTS\";N;s:27:\"PERMISSION_START_DISCUSSION\";N;s:28:\"PERMISSION_STICK_DISCUSSIONS\";N;s:27:\"PERMISSION_HIDE_DISCUSSIONS\";N;s:28:\"PERMISSION_CLOSE_DISCUSSIONS\";N;s:27:\"PERMISSION_EDIT_DISCUSSIONS\";N;s:34:\"PERMISSION_VIEW_HIDDEN_DISCUSSIONS\";N;s:24:\"PERMISSION_EDIT_COMMENTS\";N;s:24:\"PERMISSION_HIDE_COMMENTS\";N;s:31:\"PERMISSION_VIEW_HIDDEN_COMMENTS\";N;s:44:\"PERMISSION_ADD_COMMENTS_TO_CLOSED_DISCUSSION\";N;s:25:\"PERMISSION_ADD_CATEGORIES\";N;s:26:\"PERMISSION_EDIT_CATEGORIES\";N;s:28:\"PERMISSION_REMOVE_CATEGORIES\";N;s:26:\"PERMISSION_SORT_CATEGORIES\";N;s:28:\"PERMISSION_VIEW_ALL_WHISPERS\";N;s:29:\"PERMISSION_APPROVE_APPLICANTS\";N;s:27:\"PERMISSION_CHANGE_USER_ROLE\";N;s:21:\"PERMISSION_EDIT_USERS\";N;s:31:\"PERMISSION_IP_ADDRESSES_VISIBLE\";N;s:30:\"PERMISSION_MANAGE_REGISTRATION\";N;s:21:\"PERMISSION_SORT_ROLES\";N;s:20:\"PERMISSION_ADD_ROLES\";N;s:21:\"PERMISSION_EDIT_ROLES\";N;s:23:\"PERMISSION_REMOVE_ROLES\";N;s:28:\"PERMISSION_CHECK_FOR_UPDATES\";N;s:38:\"PERMISSION_CHANGE_APPLICATION_SETTINGS\";N;s:28:\"PERMISSION_MANAGE_EXTENSIONS\";N;s:26:\"PERMISSION_MANAGE_LANGUAGE\";N;s:24:\"PERMISSION_MANAGE_STYLES\";N;s:27:\"PERMISSION_ALLOW_DEBUG_INFO\";N;s:27:\"PERMISSION_DATABASE_CLEANUP\";N;}',0,'1'),
('Banned','1','0','0','0','a:32:{s:23:\"PERMISSION_ADD_COMMENTS\";N;s:27:\"PERMISSION_START_DISCUSSION\";N;s:28:\"PERMISSION_STICK_DISCUSSIONS\";N;s:27:\"PERMISSION_HIDE_DISCUSSIONS\";N;s:28:\"PERMISSION_CLOSE_DISCUSSIONS\";N;s:27:\"PERMISSION_EDIT_DISCUSSIONS\";N;s:34:\"PERMISSION_VIEW_HIDDEN_DISCUSSIONS\";N;s:24:\"PERMISSION_EDIT_COMMENTS\";N;s:24:\"PERMISSION_HIDE_COMMENTS\";N;s:31:\"PERMISSION_VIEW_HIDDEN_COMMENTS\";N;s:44:\"PERMISSION_ADD_COMMENTS_TO_CLOSED_DISCUSSION\";N;s:25:\"PERMISSION_ADD_CATEGORIES\";N;s:26:\"PERMISSION_EDIT_CATEGORIES\";N;s:28:\"PERMISSION_REMOVE_CATEGORIES\";N;s:26:\"PERMISSION_SORT_CATEGORIES\";N;s:28:\"PERMISSION_VIEW_ALL_WHISPERS\";N;s:29:\"PERMISSION_APPROVE_APPLICANTS\";N;s:27:\"PERMISSION_CHANGE_USER_ROLE\";N;s:21:\"PERMISSION_EDIT_USERS\";N;s:31:\"PERMISSION_IP_ADDRESSES_VISIBLE\";N;s:30:\"PERMISSION_MANAGE_REGISTRATION\";N;s:21:\"PERMISSION_SORT_ROLES\";N;s:20:\"PERMISSION_ADD_ROLES\";N;s:21:\"PERMISSION_EDIT_ROLES\";N;s:23:\"PERMISSION_REMOVE_ROLES\";N;s:28:\"PERMISSION_CHECK_FOR_UPDATES\";N;s:38:\"PERMISSION_CHANGE_APPLICATION_SETTINGS\";N;s:28:\"PERMISSION_MANAGE_EXTENSIONS\";N;s:26:\"PERMISSION_MANAGE_LANGUAGE\";N;s:24:\"PERMISSION_MANAGE_STYLES\";N;s:27:\"PERMISSION_ALLOW_DEBUG_INFO\";N;s:27:\"PERMISSION_DATABASE_CLEANUP\";N;}',1,'0'),
('Member','1','1','1','0','a:33:{s:23:\"PERMISSION_ADD_COMMENTS\";i:1;s:27:\"PERMISSION_START_DISCUSSION\";i:1;s:27:\"PERMISSION_SINK_DISCUSSIONS\";i:1;s:28:\"PERMISSION_STICK_DISCUSSIONS\";N;s:27:\"PERMISSION_HIDE_DISCUSSIONS\";N;s:28:\"PERMISSION_CLOSE_DISCUSSIONS\";N;s:27:\"PERMISSION_EDIT_DISCUSSIONS\";N;s:34:\"PERMISSION_VIEW_HIDDEN_DISCUSSIONS\";N;s:24:\"PERMISSION_EDIT_COMMENTS\";N;s:24:\"PERMISSION_HIDE_COMMENTS\";N;s:31:\"PERMISSION_VIEW_HIDDEN_COMMENTS\";N;s:44:\"PERMISSION_ADD_COMMENTS_TO_CLOSED_DISCUSSION\";N;s:25:\"PERMISSION_ADD_CATEGORIES\";N;s:26:\"PERMISSION_EDIT_CATEGORIES\";N;s:28:\"PERMISSION_REMOVE_CATEGORIES\";N;s:26:\"PERMISSION_SORT_CATEGORIES\";N;s:28:\"PERMISSION_VIEW_ALL_WHISPERS\";N;s:29:\"PERMISSION_APPROVE_APPLICANTS\";N;s:27:\"PERMISSION_CHANGE_USER_ROLE\";N;s:21:\"PERMISSION_EDIT_USERS\";N;s:31:\"PERMISSION_IP_ADDRESSES_VISIBLE\";N;s:30:\"PERMISSION_MANAGE_REGISTRATION\";N;s:21:\"PERMISSION_SORT_ROLES\";N;s:20:\"PERMISSION_ADD_ROLES\";N;s:21:\"PERMISSION_EDIT_ROLES\";N;s:23:\"PERMISSION_REMOVE_ROLES\";N;s:28:\"PERMISSION_CHECK_FOR_UPDATES\";N;s:38:\"PERMISSION_CHANGE_APPLICATION_SETTINGS\";N;s:28:\"PERMISSION_MANAGE_EXTENSIONS\";N;s:26:\"PERMISSION_MANAGE_LANGUAGE\";N;s:24:\"PERMISSION_MANAGE_STYLES\";N;s:27:\"PERMISSION_ALLOW_DEBUG_INFO\";N;s:27:\"PERMISSION_DATABASE_CLEANUP\";N;}',2,'0'),
('Administrator','1','1','1','1','a:34:{s:23:\"PERMISSION_ADD_COMMENTS\";i:1;s:27:\"PERMISSION_START_DISCUSSION\";i:1;s:27:\"PERMISSION_SINK_DISCUSSIONS\";i:1;s:28:\"PERMISSION_STICK_DISCUSSIONS\";i:1;s:27:\"PERMISSION_HIDE_DISCUSSIONS\";i:1;s:28:\"PERMISSION_CLOSE_DISCUSSIONS\";i:1;s:27:\"PERMISSION_EDIT_DISCUSSIONS\";i:1;s:34:\"PERMISSION_VIEW_HIDDEN_DISCUSSIONS\";i:1;s:24:\"PERMISSION_EDIT_COMMENTS\";i:1;s:24:\"PERMISSION_HIDE_COMMENTS\";i:1;s:31:\"PERMISSION_VIEW_HIDDEN_COMMENTS\";i:1;s:44:\"PERMISSION_ADD_COMMENTS_TO_CLOSED_DISCUSSION\";i:1;s:25:\"PERMISSION_ADD_CATEGORIES\";i:1;s:26:\"PERMISSION_EDIT_CATEGORIES\";i:1;s:28:\"PERMISSION_REMOVE_CATEGORIES\";i:1;s:26:\"PERMISSION_SORT_CATEGORIES\";i:1;s:28:\"PERMISSION_VIEW_ALL_WHISPERS\";i:1;s:29:\"PERMISSION_APPROVE_APPLICANTS\";i:1;s:27:\"PERMISSION_CHANGE_USER_ROLE\";i:1;s:21:\"PERMISSION_EDIT_USERS\";i:1;s:31:\"PERMISSION_IP_ADDRESSES_VISIBLE\";i:1;s:30:\"PERMISSION_MANAGE_REGISTRATION\";i:1;s:21:\"PERMISSION_SORT_ROLES\";i:1;s:20:\"PERMISSION_ADD_ROLES\";i:1;s:21:\"PERMISSION_EDIT_ROLES\";i:1;s:23:\"PERMISSION_REMOVE_ROLES\";i:1;s:28:\"PERMISSION_CHECK_FOR_UPDATES\";i:1;s:38:\"PERMISSION_CHANGE_APPLICATION_SETTINGS\";i:1;s:28:\"PERMISSION_MANAGE_EXTENSIONS\";i:1;s:26:\"PERMISSION_MANAGE_LANGUAGE\";i:1;s:24:\"PERMISSION_MANAGE_THEMES\";i:1;s:24:\"PERMISSION_MANAGE_STYLES\";i:1;s:27:\"PERMISSION_ALLOW_DEBUG_INFO\";i:1;s:27:\"PERMISSION_DATABASE_CLEANUP\";i:1;}',4,'0');

CREATE TABLE `LUM_Style` (
  `StyleID` int(3) NOT NULL auto_increment,
  `AuthUserID` int(11) NOT NULL default '0',
  `Name` varchar(50) NOT NULL default '',
  `Url` varchar(255) NOT NULL default '',
  `PreviewImage` varchar(20) NOT NULL default '',
  PRIMARY KEY  (`StyleID`)
);

CREATE TABLE `LUM_User` (
  `UserID` int(10) NOT NULL auto_increment,
  `RoleID` int(2) NOT NULL default '0',
  `StyleID` int(3) NOT NULL default '1',
  `CustomStyle` varchar(255) default NULL,
  `FirstName` varchar(50) NOT NULL default '',
  `LastName` varchar(50) NOT NULL default '',
  `Name` varchar(20) NOT NULL default '',
  `Password` varchar(32) default NULL,
  `VerificationKey` varchar(50) NOT NULL default '',
  `EmailVerificationKey` varchar(50) default NULL,
  `Email` varchar(200) NOT NULL default '',
  `UtilizeEmail` enum('1','0') NOT NULL default '0',
  `ShowName` enum('1','0') NOT NULL default '1',
  `Icon` varchar(255) default NULL,
  `Picture` varchar(255) default NULL,
  `Attributes` text NULL,
  `CountVisit` int(8) NOT NULL default '0',
  `CountDiscussions` int(8) NOT NULL default '0',
  `CountComments` int(8) NOT NULL default '0',
  `DateFirstVisit` datetime NOT NULL default '0000-00-00 00:00:00',
  `DateLastActive` datetime NOT NULL default '0000-00-00 00:00:00',
  `RemoteIp` varchar(100) NOT NULL default '',
  `LastDiscussionPost` datetime default NULL,
  `DiscussionSpamCheck` int(11) NOT NULL default '0',
  `LastCommentPost` datetime default NULL,
  `CommentSpamCheck` int(11) NOT NULL default '0',
  `UserBlocksCategories` enum('1','0') NOT NULL default '0',
  `DefaultFormatType` varchar(20) default NULL,
  `Discovery` text,
  `Preferences` text,
  `SendNewApplicantNotifications` enum('1','0') NOT NULL default '0',
  PRIMARY KEY  (`UserID`),
  KEY `user_role` (`RoleID`),
  KEY `user_style` (`StyleID`),
  KEY `user_name` (`Name`)
);

CREATE TABLE `LUM_UserBookmark` (
  `UserID` int(10) NOT NULL default '0',
  `DiscussionID` int(8) NOT NULL default '0',
  PRIMARY KEY  (`UserID`,`DiscussionID`)
);

CREATE TABLE `LUM_UserDiscussionWatch` (
  `UserID` int(10) NOT NULL default '0',
  `DiscussionID` int(8) NOT NULL default '0',
  `CountComments` int(11) NOT NULL default '0',
  `LastViewed` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`UserID`,`DiscussionID`)
);

CREATE TABLE `LUM_UserRoleHistory` (
  `UserID` int(10) NOT NULL default '0',
  `RoleID` int(2) NOT NULL default '0',
  `Date` datetime NOT NULL default '0000-00-00 00:00:00',
  `AdminUserID` int(10) NOT NULL default '0',
  `Notes` varchar(200) default NULL,
  `RemoteIp` varchar(100) default NULL,
  KEY `UserID` (`UserID`)
);

INSERT INTO `LUM_User`
(`RoleID`, `StyleID`, `FirstName`, `LastName`, `Name`, `Password`, `Email`, `UtilizeEmail`, `ShowName`, `CountVisit`, CountDiscussions`, `CountComments`, `DateFirstVisit`, `DateLastActive`,`SendNewApplicantNotifications`)
values (4,1,'Administrative','User','Admin','Admin','admin@forum.com','1','1',0,0,0,'1975-09-16 08:39:00','2006-04-25 17:38:44','1');