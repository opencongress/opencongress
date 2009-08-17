<?php
/*
* Copyright 2003 Mark O'Sullivan
* This file is part of Vanilla.
* Vanilla is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
* Vanilla is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
* You should have received a copy of the GNU General Public License along with Vanilla; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
* The latest source code for Vanilla is available at www.lussumo.com
* Contact Mark O'Sullivan at mark [at] lussumo [dot] com
*
* Description: English language dictionary
*
* 
* !!!!!DO NOT ALTER THIS FILE!!!!!
* If you need to make changes to these definitions, add the new definitions to
* your conf/language.php file. Definitions made there will override these.
*/

// Define the xml:lang attribute for the html tag
$Context->Dictionary['XMLLang'] = 'en-ca';

// Define all dictionary codes in English
$Context->Dictionary['NoDiscussionsNotSignedIn'] = 'You cannot take part in the discussions because you are not signed in.';
$Context->Dictionary['SelectDiscussionCategory'] = 'Select the category for this discussion';
$Context->Dictionary['WhisperYourCommentsTo'] = 'Whisper your comments to <small>(optional)</small>';
$Context->Dictionary['And'] = 'and';
$Context->Dictionary['Or'] = 'or';
$Context->Dictionary['ClickHereToContinueToDiscussions'] = 'Click here to continue to the discussions';
$Context->Dictionary['ClickHereToContinueToCategories'] = 'Click here to continue to the categories';
$Context->Dictionary['ReviewNewApplicants'] = 'Review new membership applicants';
$Context->Dictionary['New'] = 'new';
$Context->Dictionary['NewCaps'] = 'New';
$Context->Dictionary['Username'] = 'Username';
$Context->Dictionary['Password'] = 'Password';
$Context->Dictionary['RememberMe'] = 'Remember me';
$Context->Dictionary['ForgotYourPassword'] = 'Forgot your password?';
$Context->Dictionary['Proceed'] = 'Proceed';
$Context->Dictionary['ErrorTitle'] = 'Some problems were encountered';
$Context->Dictionary['RealName'] = 'Real Name';
$Context->Dictionary['Email'] = 'Email';
$Context->Dictionary['Style'] = 'Style';
$Context->Dictionary['AccountCreated'] = 'Account Created';
$Context->Dictionary['LastActive'] = 'Last Active';
$Context->Dictionary['VisitCount'] = 'Visit Count';
$Context->Dictionary['DiscussionsStarted'] = 'Discussions Started';
$Context->Dictionary['CommentsAdded'] = 'Comments Added';
$Context->Dictionary['LastKnownIp'] = 'Last Known Ip';
$Context->Dictionary['PermissionError'] = 'You do not have permission to perform the requested action.';
$Context->Dictionary['ChangePersonalInfo'] = 'Personal Information';
$Context->Dictionary['DefineYourAccountProfile'] = 'Define your account profile';
$Context->Dictionary['YourUsername'] = 'Your username';
$Context->Dictionary['YourUsernameNotes'] = 'Your username will appear next to your discussions and comments.';
$Context->Dictionary['YourFirstNameNotes'] = 'This should be your "real" first name. This will only be visible from the account page.';
$Context->Dictionary['YourLastNameNotes'] = 'This should be your "real" last name. This will only be visible from the account page.';
$Context->Dictionary['YourEmailAddressNotes'] = 'You must provide a valid email address so that you can retrieve your password should you lose it (the password retrieval form works over email).';
$Context->Dictionary['CheckForVisibleEmail'] = 'Check here to make your email address visible to other members';
$Context->Dictionary['AccountPictureNotes'] = 'You can enter any valid URL to an image here, such as: <strong>http://www.mywebsite.com/myaccountpicture.jpg</strong>
	<br />Your account picture will appear on your account page. Your account picture will be automatically centered and cropped to 280 pixels wide by 200 pixels high.';
$Context->Dictionary['IconNotes'] = 'You can enter any valid URL to an image here, such as: <strong>http://www.mywebsite.com/myicon.jpg</strong>
	<br />Your icon will appear next to your name in discussion comments and on your account page. Your icon will be automatically centered and cropped to 32 pixels wide by 32 pixels high.';
$Context->Dictionary['AddCustomInformation'] = 'Add custom information';
$Context->Dictionary['AddCustomInformationNotes'] = 'Using the following inputs, you can add custom information to your account profile as label &amp; value combinations (ie. <i>"Birthday"</i> and <i>"September 16th"</i>, or <i>"Favourite Band"</i> and <i>"The Velvet Underground"</i>). Values prefixed with a protocol like http://, mailto:, ftp://, aim:, etc will be automatically hyperlinked. You can add as many of these label/value combinations as you like.';
$Context->Dictionary['Label'] = 'Label';
$Context->Dictionary['Value'] = 'Value';
$Context->Dictionary['AddLabelValuePair'] = 'Add another label/value pair';
$Context->Dictionary['Save'] = 'Save';
$Context->Dictionary['Cancel'] = 'Cancel and go back';
$Context->Dictionary['YourOldPasswordNotes'] = 'The password you currently use to sign in to this discussion forum.';
$Context->Dictionary['YourNewPasswordNotes'] = 'Do not use birth-dates, bank-card pin numbers, telephone numbers, or anything that can be easily guessed. <strong>And PLEASE do not use the same password here as you do on other web-sites.</strong>';
$Context->Dictionary['Required'] = '(required)';
$Context->Dictionary['YourNewPasswordAgain'] = 'New password again';
$Context->Dictionary['YourNewPasswordAgainNotes'] = 'Re-enter your new password to be sure that you have not made any mistakes.';
$Context->Dictionary['ForumFunctionality'] = 'Forum Preferences';
$Context->Dictionary['ForumFunctionalityNotes'] = 'Changes made on this form take place immediately. You do not need to click a submit button.';
$Context->Dictionary['ControlPanel'] = 'Control panel';
$Context->Dictionary['CommentsForm'] = 'Comments form';
$Context->Dictionary['ShowFormatTypeSelector'] = 'Show the comment format type selector when adding comments';
$Context->Dictionary['NewUsers'] = 'New Users';
$Context->Dictionary['NewApplicantNotifications'] = 'Receive email notifications when new users apply for membership';
$Context->Dictionary['AssignToRole'] = 'Choose a New Role';
$Context->Dictionary['AssignToRoleNotes'] = 'The role change will take place immediately. If the user is switched to a role that does not have sign-in access, they will be signed out upon their next page-load.';
$Context->Dictionary['RoleChangeInfo'] = 'Role change notes';
$Context->Dictionary['RoleChangeInfoNotes'] = 'Please provide some notes regarding this role change. These notes will be visible to all users in the role-history for this user.';
$Context->Dictionary['AboutMembership'] = '<h2>About membership</h2>
	<p>This membership <strong>application</strong> form does not grant immediate access to the site. All membership applications are reviewed by an administrator before acceptance. You are <strong>not</strong> guaranteed access to the application by filling out this form.</p>
	<p>Please do not enter invalid or incorrect information in this form or you will most likely not be granted access to the site.</p>
	<p>All information entered in this form will be kept strictly confidential.</p>';
$Context->Dictionary['BackToSignInForm'] = 'Back to sign-in form';
$Context->Dictionary['MembershipApplicationForm'] = 'Membership Application Form';
$Context->Dictionary['AllFieldsRequired'] = '**All fields are required';
$Context->Dictionary['IHaveReadAndAgreeTo'] = 'I have read and agree to the //1';
$Context->Dictionary['TermsOfService'] = 'Terms of Service';
$Context->Dictionary['CommentHiddenOnXByY'] = 'Deleted //1 by //2';
$Context->Dictionary['ToYou'] = ' to you';
$Context->Dictionary['ToYourself'] = ' to yourself';
$Context->Dictionary['ToX'] = ' to //1';
$Context->Dictionary['Edited'] = 'edited';
$Context->Dictionary['edit'] = 'edit';
$Context->Dictionary['Edit'] = 'Edit';
$Context->Dictionary['Show'] = 'show';
$Context->Dictionary['Hide'] = 'delete';
$Context->Dictionary['WhisperBack'] = 'Whisper back';
$Context->Dictionary['AddYourComments'] = 'Add your comments';
$Context->Dictionary['TopOfPage'] = 'Top of Page';
$Context->Dictionary['BackToDiscussions'] = 'Back to Discussions';
$Context->Dictionary['SignOutSuccessful'] = 'You have been signed out successfully';
$Context->Dictionary['SignInAgain'] = 'Click here to sign in again';
$Context->Dictionary['RequestProcessed'] = 'Your request has been processed';
$Context->Dictionary['MessageSentToXContainingPasswordInstructions'] = 'A message has been sent to your <strong>//1</strong> email address containing password reset instructions.';
$Context->Dictionary['AboutYourPassword'] = 'About your password';
$Context->Dictionary['AboutYourPasswordRequestNotes'] = '<strong>This form will not change your password.</strong> By filling out this form you will be sent instructions via email on how to reset your password.';
$Context->Dictionary['PasswordResetRequestForm'] = 'Password reset request form';
$Context->Dictionary['PasswordResetRequestFormNotes'] = 'Enter your username to request that your password be reset.';
$Context->Dictionary['SendRequest'] = 'Send Request';
$Context->Dictionary['PasswordReset'] = 'Your password has been reset successfully';
$Context->Dictionary['SignInNow'] = 'Click here to sign in now';
$Context->Dictionary['AboutYourPasswordNotes'] = 'When choosing a new password, do not use birth-dates, bank-card pin numbers, telephone numbers, or anything that can be easily guessed. <strong>And PLEASE do not use the same password here as you do on other web-sites</strong>.';
$Context->Dictionary['PasswordResetForm'] = 'Password reset form';
$Context->Dictionary['ChooseANewPassword'] = 'Choose a new password and enter it below.';
$Context->Dictionary['NewPassword'] = 'New password';
$Context->Dictionary['ConfirmPassword'] = 'Again';
$Context->Dictionary['AllCategories'] = 'All categories';
$Context->Dictionary['DateLastActive'] = 'Date last active';
$Context->Dictionary['Topics'] = 'Topics';
$Context->Dictionary['Comments'] = 'Comments';
$Context->Dictionary['Users'] = 'Users';
$Context->Dictionary['AllRoles'] = 'All roles';
$Context->Dictionary['Advanced'] = 'Advanced';
$Context->Dictionary['ChooseSearchType'] = 'Search:';
$Context->Dictionary['DiscussionTopicSearch'] = 'Discussion topic search';
$Context->Dictionary['FindDiscussionsContaining'] = 'Find discussion topics containing';
$Context->Dictionary['InTheCategory'] = 'in the category';
$Context->Dictionary['WhereTheAuthorWas'] = 'where the author was';
$Context->Dictionary['Search'] = 'Search';
$Context->Dictionary['DiscussionCommentSearch'] = 'Discussion comment search';
$Context->Dictionary['FindCommentsContaining'] = 'Find comments containing';
$Context->Dictionary['UserAccountSearch'] = 'User account search';
$Context->Dictionary['FindUserAccountsContaining'] = 'Find user accounts containing';
$Context->Dictionary['InTheRole'] = 'in the role';
$Context->Dictionary['SortResultsBy'] = 'sort results by';
$Context->Dictionary['NoResultsFound'] = 'No results found';
$Context->Dictionary['DiscussionsCreated'] = 'Discussions Created';
$Context->Dictionary['AdministrativeOptions'] = 'Options';
$Context->Dictionary['ApplicationSettings'] = 'Application Settings';
$Context->Dictionary['ManageExtensions'] = 'Extensions';
$Context->Dictionary['RoleManagement'] = 'Roles &amp; Permissions';
$Context->Dictionary['CategoryManagement'] = 'Categories';
$Context->Dictionary['MembershipApplicants'] = 'Membership Applicants';
$Context->Dictionary['GlobalApplicationSettings'] = 'Application Settings';
$Context->Dictionary['GlobalApplicationSettingsNotes'] = 'BE CAREFUL with the changes you make on this page. Erroneous information entered here could cause your forum to crash and may require you manually altering settings files to repair the problem.';
$Context->Dictionary['AboutSettings'] = 'About Settings';
$Context->Dictionary['AboutSettingsNotes'] = "<p class=\"Description\">Using this section you can manipulate all configurable settings for your Vanilla installation. Summarized below are the standard menu items and their functions. Depending on your permissions, you may or may not see all of the menu items listed:</p>
	<dl><dt>Application Settings</dt>
	<dd>This is the main configuration screen for Vanilla. It allows you to change the banner text, manipulate spam controls, define cookie settings, and change basic forum options like whispers, categories, etc.</dd>
	<dt>Updates &amp; Reminders</dt>
	<dd>Configure how often you should be reminded to check for updates. Ping back to Lussumo for the latest updates for Vanilla.</dd>
	<dt>Roles &amp; Permissions</dt>
	<dd>Add, edit, and organize roles and permissions.</dd>
	<dt>Registration Settings</dt>
	<dd>Define how new members are handled: which role they are assigned to, do they require administrative approval, etc.</dd>
	<dt>Categories</dt>
	<dd>Add, edit, and organize categories.</dd>
	<dt>Extensions</dt>
	<dd>Extensions add extra functionality into Vanilla. Use this menu option to enable extensions and find new extensions from Lussumo.</dd>
	<dt>Themes &amp; Styles</dt>
	<dd>Change the theme (xhtml templates) that Vanilla is built on, change the default style (css &amp; images), and apply it to all users in the system.</dd>
	<dt>Languages</dt>
	<dd>Switch the language dictionary that Vanilla uses.</dd>
	<dt>Membership Applicants</dt>
	<dd>Vanilla does not have a \"member list\" like many other popular web forums. Instead we use our search to find and manage members. If approval is required for membership, this link will run a search that filters down to new (unapproved) members.</dd>
	<dt>Other options</dt>
	<dd>Depending on both your role's permissions and which extensions you have enabled, there may be more options in the menu(s) in this section. Welcome to the magic of Vanilla's extensions!</dd>
</dl>";
$Context->Dictionary['HiddenInformation'] = 'Deleted information';
$Context->Dictionary['DisplayHiddenDiscussions'] = 'Display deleted discussions';
$Context->Dictionary['DisplayHiddenComments'] = 'Display deleted comments';
$Context->Dictionary['Choose'] = 'Choose...';
$Context->Dictionary['GetCategoryToEdit'] = '1. Select the category you would like to edit';
$Context->Dictionary['Categories'] = 'Categories';
$Context->Dictionary['ModifyCategoryDefinition'] = '2. Modify the category definition';
$Context->Dictionary['DefineNewCategory'] = 'Define the new category';
$Context->Dictionary['CategoryName'] = 'Category name';
$Context->Dictionary['CategoryNameNotes'] = 'The category name will be visible in on the discussion index and on the discussion page. Html is not allowed.';
$Context->Dictionary['CategoryDescription'] = 'Category description';
$Context->Dictionary['CategoryDescriptionNotes'] = 'The value entered here will be visible from the category page. Html is not allowed.';
$Context->Dictionary['RolesInCategory'] = 'Roles allowed to take part in this category';
$Context->Dictionary['SelectCategoryToRemove'] = '1. Select the category you would like to remove';
$Context->Dictionary['SelectReplacementCategory'] = '2. Select a replacement category';
$Context->Dictionary['ReplacementCategory'] = 'Replacement category';
$Context->Dictionary['ReplacementCategoryNotes'] = 'When you remove a category from the system, discussions which have been placed in that category are orphaned. The replacement category will be assigned to all discussions that are currently assigned to the category you are removing.';
$Context->Dictionary['Remove'] = 'Remove';
$Context->Dictionary['CreateNewCategory'] = 'Create a new category';
$Context->Dictionary['CategoryRemoved'] = 'The category has been removed.';
$Context->Dictionary['CategorySaved'] = 'Your changes were saved successfully.';
$Context->Dictionary['NewCategorySaved'] = 'The category was created successfully.';
$Context->Dictionary['SelectRoleToEdit'] = '1. Select the role you would like to edit';
$Context->Dictionary['Roles'] = 'Roles';
$Context->Dictionary['ModifyRoleDefinition'] = '2. Modify the role definition';
$Context->Dictionary['DefineNewRole'] = 'Define the new role';
$Context->Dictionary['RoleName'] = 'Role name';
$Context->Dictionary['RoleNameNotes'] = "The role name will be visible on the user's account page next to his/her name. Html is not allowed.";
$Context->Dictionary['RoleIcon'] = 'Role icon';
$Context->Dictionary['RoleIconNotes'] = "You can enter any valid URL to an image here, such as: <strong>http://www.mywebsite.com/myicon.jpg</strong>
	<br />The role icon will replace the user's icon on all comments and the account page. If you do not supply a value for this field, the user-defined icon will remain (if one exists).";
$Context->Dictionary['RoleTagline'] = 'Role tagline';
$Context->Dictionary['RoleTaglineNotes'] = "The role tagline will appear on the user's account page underneath his/her name. If you do not supply a value for this field, the tagline will simply not appear on the user's account page.";
$Context->Dictionary['RoleAbilities'] = 'Role abilities';
$Context->Dictionary['RoleAbilitiesNotes'] = 'Check any abilities you wish users in this role to have.';
$Context->Dictionary['RoleRemoved'] = 'The role has been removed.';
$Context->Dictionary['RoleSaved'] = 'Your changes were saved successfully.';
$Context->Dictionary['NewRoleSaved'] = 'The role was created successfully.';
$Context->Dictionary['StartANewDiscussion'] = 'Start a new discussion';
$Context->Dictionary['SelectRoleToRemove'] = '1. Select the role you would like to remove';
$Context->Dictionary['SelectReplacementRole'] = '2. Select a replacement role';
$Context->Dictionary['ReplacementRole'] = 'Replacement role';
$Context->Dictionary['ReplacementRoleNotes'] = 'When you remove a role from the system, users who currently have that role will not have role abilities. The replacement role will be assigned to all users who are currently assigned to the role you are removing.';
$Context->Dictionary['CreateANewRole'] = 'Create a new role';
$Context->Dictionary['Extensions'] = 'Extensions';
$Context->Dictionary['YouAreSignedIn'] = 'You are signed in';
$Context->Dictionary['BottomOfPage'] = 'Bottom of Page';
$Context->Dictionary['NotSignedIn'] = 'Not signed in';
$Context->Dictionary['SignIn'] = 'Sign In';
$Context->Dictionary['Discussions'] = 'Discussions';
$Context->Dictionary['Settings'] = 'Settings';
$Context->Dictionary['Account'] = 'Account';
$Context->Dictionary['AllDiscussions'] = 'All Discussions';
$Context->Dictionary['Category'] = 'Category';
$Context->Dictionary['StartedBy'] = 'Started by';
$Context->Dictionary['LastCommentBy'] = 'Last comment by';
$Context->Dictionary['PageDetailsMessage'] = '//1 to //2';
$Context->Dictionary['PageDetailsMessageFull'] = '//1 to //2 of //3';
$Context->Dictionary['SearchResultsMessage'] = 'Results //1 to //2 for //3';
$Context->Dictionary['NoSearchResultsMessage'] = 'No results could be found';
$Context->Dictionary['Previous'] = 'Previous';
$Context->Dictionary['Next'] = 'Next';
$Context->Dictionary['WrittenBy'] = 'Written by';
$Context->Dictionary['Added'] = 'Added';
$Context->Dictionary['MyAccount'] = 'My Account';
$Context->Dictionary['ApplyForMembership'] = 'Apply for membership';
$Context->Dictionary['SignOut'] = 'Sign Out';
$Context->Dictionary['ResetYourPassword'] = 'Reset your password';
$Context->Dictionary['AdministrativeSettings'] = 'Administrative Settings';
$Context->Dictionary['TermsOfServiceBody'] = "<h1>Terms of Service</h1>
<h2>Please carefully review the following rules, policies, and disclaimers.</h2>

<p>Considering the real-time nature of this community, it is impossible for us to review messages or confirm the validity of information posted.
We do not actively monitor the contents of and are not responsible for any content posted.
We do not vouch for or warrant the accuracy, completeness or usefulness of any message, and are not responsible for the contents of any data posted by members. 
The messages express the views of the author of the message, not necessarily the views of this community or any entity associated with this community.
Any user who feels that a posted message is objectionable is encouraged to contact us immediately by email.
We have the ability to remove objectionable messages and we will make every effort to do so, within a reasonable time frame, if we determine that removal is necessary.
This is a manual process, however, so please realize that we may not be able to remove or edit particular messages immediately.</p>

<p>You agree, through your use of this service, that you will not use this community to post any material which is knowingly false and/or defamatory, inaccurate, abusive, vulgar, hateful, harassing, obscene, profane, sexually oriented, threatening, invasive of a person's privacy, or otherwise violative of any law.
You agree not to post any copyrighted material unless the copyright is owned by you.</p>

<p>Although this community does not and cannot review the messages posted and is not responsible for the content of any of these messages, we at this community reserve the right to delete any message for any or no reason at all.
You remain solely responsible for the content of your messages, and you agree to indemnify and hold harmless this community, Lussumo (the makers of the discussion software), and their agents with respect to any claim based upon transmission of your message(s).</p>

<p>We at this community also reserve the right to reveal your identity (or whatever information we know about you) in the event of a complaint or legal action arising from any message posted by you.
We log all internet protocol addresses accessing this web site.</p>

<p>Please note that advertisements, chain letters, pyramid schemes, and solicitations are inappropriate on this community.</p>

<p><strong>We reserve the right to terminate any membership for any reason or no reason at all.</strong></p>";
$Context->Dictionary['EmailAddress'] = 'Email address';
$Context->Dictionary['PasswordAgain'] = 'Password again';
$Context->Dictionary['SignedInAsX'] = 'Signed in as //1';
$Context->Dictionary['AccountOptions'] = 'Account Options';
$Context->Dictionary['ChangeYourPersonalInformation'] = 'Personal Information';
$Context->Dictionary['ChangeYourPassword'] = 'Change Password';
$Context->Dictionary['ChangeForumFunctionality'] = 'Forum Preferences';
$Context->Dictionary['YourFirstName'] = 'Your first name';
$Context->Dictionary['YourLastName'] = 'Your last name';
$Context->Dictionary['YourEmailAddress'] = 'Your Email Address';
$Context->Dictionary['AccountPicture'] = 'Account picture';
$Context->Dictionary['Icon'] = 'Icon';
$Context->Dictionary['MakeRealNameVisible'] = 'Check here to make your real name visible to other members';
$Context->Dictionary['YourOldPassword'] = 'Your old password';
$Context->Dictionary['YourNewPassword'] = 'Your new password';
$Context->Dictionary['DiscussionTopic'] = 'discussion topic';
$Context->Dictionary['EmailLower'] = 'email';
$Context->Dictionary['UsernameLower'] = 'username';
$Context->Dictionary['PasswordLower'] = 'password';
$Context->Dictionary['NewPasswordLower'] = 'new password';
$Context->Dictionary['RoleNameLower'] = 'role name';
$Context->Dictionary['DiscussionTopicLower'] = 'discussion topic';
$Context->Dictionary['CommentsLower'] = 'comments';
$Context->Dictionary['CategoryNameLower'] = 'category name';
$Context->Dictionary['Options'] = 'Options';
$Context->Dictionary['BlockCategory'] = 'Block category';
$Context->Dictionary['UnblockCategory'] = 'Unblock category';
$Context->Dictionary['BookmarkThisDiscussion'] = 'Bookmark this discussion';
$Context->Dictionary['UnbookmarkThisDiscussion'] = 'Unbookmark this discussion';
$Context->Dictionary['HideConfirm'] = 'Are you sure you wish to delete this comment?';
$Context->Dictionary['ShowConfirm'] = 'Are you sure you wish to undelete this comment?';
$Context->Dictionary['BookmarkText'] = 'Bookmark this discussion';
$Context->Dictionary['ConfirmHideDiscussion'] = 'Are you sure you want to delete this discussion?';
$Context->Dictionary['ConfirmUnhideDiscussion'] = 'Are you sure you want to undelete this discussion?';
$Context->Dictionary['ConfirmCloseDiscussion'] = 'Are you sure you want to close this discussion?';
$Context->Dictionary['ConfirmReopenDiscussion'] = 'Are you sure you want to re-open this discussion?';
$Context->Dictionary['ConfirmSticky'] = 'Are you sure you want to make this discussion sticky?';
$Context->Dictionary['ConfirmUnsticky'] = 'Are you sure you want to make this discussion unsticky?';
$Context->Dictionary['ChangePersonalInformation'] = 'Change personal information';
$Context->Dictionary['ApplicantOptions'] = 'Applicant Options';
$Context->Dictionary['ChangeRole'] = 'Change Role';
$Context->Dictionary['NewApplicantSearch'] = 'New Applicant Search';
$Context->Dictionary['BigInput'] = 'big input';
$Context->Dictionary['SmallInput'] = 'small input';
$Context->Dictionary['EditYourDiscussionTopic'] = 'Edit the discussion topic';
$Context->Dictionary['EditYourComments'] = 'Edit your comments';
$Context->Dictionary['FormatCommentsAs'] = 'Format comments as ';
$Context->Dictionary['SaveYourChanges'] = 'Save Changes';
$Context->Dictionary['Text'] = 'Text';
$Context->Dictionary['EnterYourDiscussionTopic'] = 'Enter your discussion topic';
$Context->Dictionary['EnterYourComments'] = 'Enter your comments';
$Context->Dictionary['StartYourDiscussion'] = 'Start your discussion';
$Context->Dictionary['ShowAll'] = 'Show all';
$Context->Dictionary['DiscussionIndex'] = 'Discussion list options';
$Context->Dictionary['JumpToLastReadComment'] = 'Jump to the last read comment when clicking on discussion topic';
$Context->Dictionary['NoDiscussionsFound'] = 'No discussions found';
$Context->Dictionary['RegistrationManagement'] = 'Registration Settings';
$Context->Dictionary['NewMemberRole'] = 'New member role';
$Context->Dictionary['NewMemberRoleNotes'] = 'When new users apply for membership, this is the role to which they are assigned. If that role has Sign-in ability, they will be granted immediate access to the forum.';
$Context->Dictionary['RegistrationChangesSaved'] = 'Your changes to registration have been saved successfully.';
$Context->Dictionary['ClickHereToContinue'] = 'Click here to continue';
$Context->Dictionary['RegistrationAccepted'] = 'Registration accepted.';
$Context->Dictionary['RegistrationPendingApproval'] = 'Registration pending administrative approval.';
$Context->Dictionary['Applicant'] = 'Applicant';
$Context->Dictionary['ThankYouForInterest'] = 'Thank you for your interest!';
$Context->Dictionary['ApplicationWillBeReviewed'] = 'Your membership application will be reviewed by an administrator. If you are accepted for membership, you will be contacted via email.';
$Context->Dictionary['ApplicationComplete'] = 'Application complete!';
$Context->Dictionary['AccountChangeNotification'] = 'Account Change Notification';
$Context->Dictionary['PasswordResetRequest'] = 'Password Reset Request';
$Context->Dictionary['LanguageManagement'] = 'Languages';
$Context->Dictionary['LanguageChangesSaved'] = 'The language has been changed successfully.';
$Context->Dictionary['ChangeLanguage'] = 'Choose a language';
$Context->Dictionary['ChangeLanguageNotes'] = 'If your language does not appear here, you can <a href="http://lussumo.com/addons/">download the latest languages from Lussumo</a>.';
$Context->Dictionary['CloseThisDiscussion'] = 'Close this discussion';
$Context->Dictionary['ReOpenThisDiscussion'] = 'Re-Open this discussion';
$Context->Dictionary['MakeThisDiscussionUnsticky'] = 'Make this discussion UnSticky';
$Context->Dictionary['MakeThisDiscussionSticky'] = 'Make this discussion sticky';
$Context->Dictionary['HideThisDiscussion'] = 'Delete this discussion';
$Context->Dictionary['UnhideThisDiscussion'] = 'Undelete this discussion';

// Warnings
$Context->Dictionary['ErrOpenDirectoryExtensions'] = 'Failed to open the extensions directory. Please ensure that PHP has read access to the //1 directory.';
$Context->Dictionary['ErrOpenDirectoryThemes'] = 'Failed to open the themes directory. Please ensure that PHP has read access to the //1 directory.';
$Context->Dictionary['ErrOpenDirectoryStyles'] = 'Failed to open the styles directory. Please ensure that PHP has read access to the //1 directory.';
$Context->Dictionary['ErrReadExtensionDefinition'] = 'An error occurred while attempting to read the extension definition from';
$Context->Dictionary['ErrReadFileExtensions'] = 'Failed to read the extensions file:';
$Context->Dictionary['ErrOpenFile'] = 'The file could not be opened. Please make sure that PHP has write access to the //1 file.';
$Context->Dictionary['ErrWriteFile'] = 'The file could not be written.';
$Context->Dictionary['ErrEmailSubject'] = 'You must provide a subject.';
$Context->Dictionary['ErrEmailRecipient'] = 'You must provide at least one recipient.';
$Context->Dictionary['ErrEmailFrom'] = 'You must define the "from" email address.';
$Context->Dictionary['ErrEmailBody'] = 'You must provide the email body.';
$Context->Dictionary['ErrCategoryNotFound'] = 'The requested category could not be found.';
$Context->Dictionary['ErrCategoryReplacement'] = 'You must choose a replacement category.';
$Context->Dictionary['ErrCommentNotFound'] = 'The requested comment could not be found.';
$Context->Dictionary['ErrDiscussionID'] = 'A discussion identifier was not supplied.';
$Context->Dictionary['ErrCommentID'] = 'A comment identifier was not supplied.';
$Context->Dictionary['ErrPermissionComments'] = 'You do not have permission to administer comments.';
$Context->Dictionary['ErrWhisperInvalid'] = 'The username entered as the whisper recipient could not be found.';
$Context->Dictionary['ErrDiscussionNotFound'] = 'The requested discussion could not be found.';
$Context->Dictionary['ErrSelectCategory'] = 'You must select a category for this discussion.';
$Context->Dictionary['ErrPermissionEditComments'] = "You can not edit another member's comments.";
$Context->Dictionary['ErrPermissionDiscussionEdit'] = 'The discussion was unchanged because it either does not exist, or you do not have administrative capabilities in this category.';
$Context->Dictionary['ErrRoleNotFound'] = 'The requested role could not be found.';
$Context->Dictionary['ErrPermissionInsufficient'] = 'You do not have sufficient privileges to perform this request.';
$Context->Dictionary['ErrSearchNotFound'] = 'The requested search could not be found.';
$Context->Dictionary['ErrSearchLabel'] = 'You must supply a label for your search. You will then be able to click on the search label to run that search.';
$Context->Dictionary['ErrRoleNotes'] = 'You must provide notes regarding the role change.';
$Context->Dictionary['ErrOldPasswordBad'] = 'The old password you supplied is incorrect.';
$Context->Dictionary['ErrNewPasswordMatchBad'] = 'Your new password confirmation did not match.';
$Context->Dictionary['ErrPasswordsMatchBad'] = 'The passwords you entered did not match.';
$Context->Dictionary['ErrAgreeTOS'] = 'You must agree to the terms of service.';
$Context->Dictionary['ErrUsernameTaken'] = 'The username you entered is already taken by another user.';
$Context->Dictionary['ErrUserNotFound'] = 'The requested user could not be found.';
$Context->Dictionary['ErrRemoveUserStyle'] = 'The user could not be removed because he/she is the author of a style.';
$Context->Dictionary['ErrRemoveUserComments'] = 'The user could not be removed because s/he has authored discussion comments.';
$Context->Dictionary['ErrRemoveUserDiscussions'] = 'The user could not be removed because s/he has authored discussions.';
$Context->Dictionary['ErrInvalidUsername'] = 'You did not supply a valid username.';
$Context->Dictionary['ErrInvalidPassword'] = 'You did not supply a valid password.';
$Context->Dictionary['ErrAccountNotFound'] = 'Failed to find an account registered with the specified username.';
$Context->Dictionary['ErrPasswordRequired'] = 'You must supply a new password.';
$Context->Dictionary['ErrUserID'] = 'A user identifier was not supplied.';
$Context->Dictionary['ErrPermissionUserSettings'] = 'You do not have permission to manipulate settings for this user.';
$Context->Dictionary['ErrSpamComments'] = 'You have posted //1 comments within //2 seconds. A spam block is now in effect on your account. You must wait at least //3 seconds before attempting to post again.';
$Context->Dictionary['ErrSpamDiscussions'] = 'You have posted //1 discussions within //2 seconds. A spam block is now in effect on your account. You must wait at least //3 seconds before attempting to start another discussion.';
$Context->Dictionary['ErrUserCombination'] = 'The requested username and password combination could not be found.';
$Context->Dictionary['ErrNoLogin'] = 'You do not have permission to sign in to the site.';
$Context->Dictionary['ErrPasswordResetRequest'] = 'Password reset request failed validation. Please be sure to copy the entire url from your email.';
$Context->Dictionary['ErrSignInToDiscuss'] = 'You cannot take part in the discussions because you are not signed in.';
$Context->Dictionary['ErrPermissionCommentEdit'] = 'You do not have sufficient privileges to edit the requested comment.';
$Context->Dictionary['ErrRequiredInput'] = 'You must enter a value for the //1 input.';
$Context->Dictionary['ErrInputLength'] = '//1 is //2 characters too long.';
$Context->Dictionary['ErrImproperFormat'] = 'You did not supply a properly formatted value for ';
$Context->Dictionary['ErrOpenDirectoryLanguages'] = 'Failed to open the languages directory. Please ensure that PHP has read access to the //1 directory.';
$Context->Dictionary['ErrPermissionAddComments'] = 'You do not have permission to add comments to discussions.';
$Context->Dictionary['ErrPermissionStartDiscussions'] = 'You do not have permission to start discussions.';

$Context->Dictionary['Warning'] = 'Warning!';
$Context->Dictionary['ApplicationTitles'] = 'Forum Name';
$Context->Dictionary['ApplicationTitle'] = 'Application title';
$Context->Dictionary['BannerTitle'] = 'Banner title';
$Context->Dictionary['ApplicationTitlesNotes'] = 'The application title appears in the title bar of your web browser. The banner title appears above the menu tabs in the page. Banner title will allow HTML.';
$Context->Dictionary['CountsTitle'] = 'Discussion and Control Panel Listings';
$Context->Dictionary['DiscussionsPerPage'] = 'Discussions per page';
$Context->Dictionary['CommentsPerPage'] = 'Comments per page';
$Context->Dictionary['SearchResultsPerPage'] = 'Search results per page';
$Context->Dictionary['CountsNotes'] = 'The values chosen here limit the maximum number of discussions or comments to display in the discussion list, comments page, and the control panel.';
$Context->Dictionary['SpamProtectionTitle'] = 'Spam Protection';
$Context->Dictionary['MaxCommentLength'] = 'Max characters in comments';
$Context->Dictionary['MaxCommentLengthNotes'] = "Although the database can transfer and save as much data as the server's memory can handle, it is a good idea to keep the max comment length down to a reasonable size.";
$Context->Dictionary['XDiscussionsYSecondsZFreeze'] = 'Members cannot post more than //1 discussions within //2 seconds or their account will be frozen for //3 seconds.';
$Context->Dictionary['XCommentsYSecondsZFreeze'] = 'Members cannot post more than //1 comments within //2 seconds or their account will be frozen for //3 seconds.';
$Context->Dictionary['LogAllIps'] = 'Log &amp; monitor all IP addresses';
$Context->Dictionary['SupportContactTitle'] = 'Forum Support Contact';
$Context->Dictionary['SupportName'] = 'Support name';
$Context->Dictionary['SupportEmail'] = 'Support email address';
$Context->Dictionary['SupportContactNotes'] = 'All emails sent out of the system for any purpose will be addressed from this name and email address.';
$Context->Dictionary['DiscussionLabelsTitle'] = 'Discussion Labels';
$Context->Dictionary['LabelPrefix'] = 'Label prefix';
$Context->Dictionary['LabelSuffix'] = 'Label suffix';
$Context->Dictionary['WhisperLabel'] = 'Private label';
$Context->Dictionary['StickyLabel'] = 'Sticky label';
$Context->Dictionary['SinkLabel'] = 'Sink label';
$Context->Dictionary['ClosedLabel'] = 'Closed label';
$Context->Dictionary['HiddenLabel'] = 'Deleted label';
$Context->Dictionary['BookmarkedLabel'] = 'Bookmarked label';
$Context->Dictionary['WebPathToVanilla'] = 'Web-path to Vanilla';
$Context->Dictionary['CookieDomain'] = 'Cookie domain';
$Context->Dictionary['WebPathNotes'] = 'The web-path to Vanilla should be a complete path to Vanilla just as you would type it into a web browser. Something like this: http://www.yourdomain.com/vanilla/';
$Context->Dictionary['CookieSettingsNotes'] = 'The cookie domain is where you want cookies assigned to for Vanilla. Typically the cookie domain will be something like www.yourdomain.com. Cookies can be further defined to a particular path on your website using the "cookie path" setting. (TIP: If you want your Vanilla cookies to apply to all subdomains of your domain, use ".yourdomain.com" as the cookie domain)';
$Context->Dictionary['AllowNameChange'] = 'Allow members to change their usernames';
$Context->Dictionary['AllowPublicBrowsing'] = 'Allow non-members to browse the forum';
$Context->Dictionary['UseCategories'] = 'Allow discussions to be categorized';
$Context->Dictionary['DiscussionLabelsNotes'] = "The discussion labels will appear in-front of discussion topics on the main discussion page. The discussion label prefix and suffix will be placed on either side of the discussion label. If a discussion label is left blank, the discussion label's prefix and suffix will not appear.";
$Context->Dictionary['ForumOptions'] = 'Forum Options';
$Context->Dictionary['GlobalApplicationChangesSaved'] = 'Your changes have been saved successfully';
$Context->Dictionary['ApprovedMemberRole'] = 'Membership approval role';
$Context->Dictionary['ApprovedMemberRoleNotes'] = 'When a user is approved for membership by an administrator (if membership approval is required), this is the role to which applicants will be assigned.';
$Context->Dictionary['NewMemberWelcomeAboard'] = 'You have been granted membership access. Welcome aboard!';
$Context->Dictionary['RoleCategoryNotes'] = 'Select the categories this role should have access to';
$Context->Dictionary['DebugTitle'] = 'Vanilla Debugging';
$Context->Dictionary['DebugDescription'] = 'If you have sufficient privileges, you can turn on debugging in Vanilla to have all queries run on any given page displayed after the page has finished executing. You will be the only person who can see this debugging data. Use this page to switch debugging on or off.';
$Context->Dictionary['CurrentApplicationMode'] = 'Vanilla is currently in the following mode: ';
$Context->Dictionary['DEBUG'] = 'Debug';
$Context->Dictionary['RELEASE'] = 'Release';
$Context->Dictionary['SwitchApplicationMode'] = 'Click here to switch the application mode';
$Context->Dictionary['BackToApplication'] = 'Click here to go back to Vanilla';
$Context->Dictionary['ErrReadFileSettings'] = 'An error occurred while attempting to read settings from the configuration file: ';
$Context->Dictionary['CookiePath'] = 'Cookie path';
$Context->Dictionary['Wait'] = 'Wait';
$Context->Dictionary['OldPostDateFormatCode'] = 'M jS Y';
$Context->Dictionary['XDayAgo'] = '//1 day ago';
$Context->Dictionary['XDaysAgo'] = '//1 days ago';
$Context->Dictionary['XHourAgo'] = '//1 hour ago';
$Context->Dictionary['XHoursAgo'] = '//1 hours ago';
$Context->Dictionary['XMinuteAgo'] = '//1 minute ago';
$Context->Dictionary['XMinutesAgo'] = '//1 minutes ago';
$Context->Dictionary['XSecondAgo'] = '//1 second ago';
$Context->Dictionary['XSecondsAgo'] = '//1 seconds ago';
$Context->Dictionary['nothing'] = 'nothing';
$Context->Dictionary['EnableWhispers'] = 'Enable Whispers';
$Context->Dictionary['ExtensionFormNotes'] = 'Extensions are used to add new functionality into Vanilla. Listed below are all of the extensions you currently have installed. To enable an extension, check the box next to the extension name. <a href="http://lussumo.com/addons/">Click here for more extensions from Lussumo</a>.';
$Context->Dictionary['EnabledExtensions'] = 'Enabled Extensions';
$Context->Dictionary['DisabledExtensions'] = 'Disabled Extensions';
$Context->Dictionary['ErrExtensionNotFound'] = 'The specified extension could not be found.';
$Context->Dictionary['UpdatesAndReminders'] = 'Updates &amp; Reminders';
$Context->Dictionary['UpdateCheck'] = 'Check for Updates';
$Context->Dictionary['UpdateCheckNotes'] = 'Vanilla is constantly being updated and upgraded as issues are discovered and features are added (or removed) by the community. In order to make sure that your installation is up to date and secure, it is important that you check for updates to the codebase regularly.';
$Context->Dictionary['CheckForUpdates'] = 'Check for updates now';
$Context->Dictionary['ErrUpdateCheckFailure'] = 'Failed to retrieve information from Lussumo about the latest version of Vanilla. Please try again later.';
$Context->Dictionary['PleaseUpdateYourInstallation'] = '<strong>WARNING:</strong> Your installation of Vanilla is //1, but <span class="Highlight">the most recent version of Vanilla available is //2</span>. Please upgrade your installation immediately by downloading the latest version of Vanilla from <a href="http://getvanilla.com">http://getvanilla.com</a>.';
$Context->Dictionary['YourInstallationIsUpToDate'] = 'Your installation of Vanilla is up to date. Please check again soon!';
$Context->Dictionary['ErrPermissionHideDiscussions'] = 'You do not have permission to delete discussions.';
$Context->Dictionary['ErrPermissionCloseDiscussions'] = 'You do not have permission to close discussions.';
$Context->Dictionary['ErrPermissionStickDiscussions'] = 'You do not have permission to make discussions sticky.';
$Context->Dictionary['CategoryReorderNotes'] = 'Drag and drop the categories below to reorder them. Their new order will be saved automatically. If a category appears greyed out, it means that the category has been blocked for your role.';
$Context->Dictionary['RoleReorderNotes'] = 'Drag and drop the roles below to reorder them. Their new order will be saved automatically. The <i>Unauthenticated</i> role is a special role that is applied to users who are browsing Vanilla without an account, and it cannot be deleted';
$Context->Dictionary['PERMISSION_CHECK_FOR_UPDATES'] = 'Check for updates';
$Context->Dictionary['PERMISSION_SIGN_IN'] = 'Can sign-in';
$Context->Dictionary['PERMISSION_ADD_COMMENTS'] = 'Add comments';
$Context->Dictionary['PERMISSION_ADD_COMMENTS_TO_CLOSED_DISCUSSION'] = 'Add comments to closed discussions';
$Context->Dictionary['PERMISSION_START_DISCUSSION'] = 'Start discussions';
$Context->Dictionary['PERMISSION_HTML_ALLOWED'] = 'HTML &amp; images allowed';
$Context->Dictionary['PERMISSION_IP_ADDRESSES_VISIBLE'] = 'IP addresses visible';
$Context->Dictionary['PERMISSION_APPROVE_APPLICANTS'] = 'Approve applicants';
$Context->Dictionary['PERMISSION_MANAGE_REGISTRATION'] = 'Registration configuration';
$Context->Dictionary['PERMISSION_EDIT_USERS'] = 'Edit any user';
$Context->Dictionary['PERMISSION_CHANGE_USER_ROLE'] = 'Change user roles';
$Context->Dictionary['PERMISSION_SORT_ROLES'] = 'Sort roles';
$Context->Dictionary['PERMISSION_ADD_ROLES'] = 'Add new roles';
$Context->Dictionary['PERMISSION_EDIT_ROLES'] = 'Edit existing roles';
$Context->Dictionary['PERMISSION_REMOVE_ROLES'] = 'Remove existing roles';
$Context->Dictionary['PERMISSION_STICK_DISCUSSIONS'] = 'Make discussions sticky';
$Context->Dictionary['PERMISSION_HIDE_DISCUSSIONS'] = 'Delete discussions';
$Context->Dictionary['PERMISSION_CLOSE_DISCUSSIONS'] = 'Close discussions';
$Context->Dictionary['PERMISSION_EDIT_DISCUSSIONS'] = 'Edit any discussions';
$Context->Dictionary['PERMISSION_HIDE_COMMENTS'] = 'Delete comments';
$Context->Dictionary['PERMISSION_EDIT_COMMENTS'] = 'Edit any comments';
$Context->Dictionary['PERMISSION_ADD_CATEGORIES'] = 'Add categories';
$Context->Dictionary['PERMISSION_EDIT_CATEGORIES'] = 'Edit categories';
$Context->Dictionary['PERMISSION_REMOVE_CATEGORIES'] = 'Remove categories';
$Context->Dictionary['PERMISSION_SORT_CATEGORIES'] = 'Sort categories';
$Context->Dictionary['PERMISSION_VIEW_HIDDEN_DISCUSSIONS'] = 'Deleted discussions visible';
$Context->Dictionary['PERMISSION_VIEW_HIDDEN_COMMENTS'] = 'Deleted comments visible';
$Context->Dictionary['PERMISSION_VIEW_ALL_WHISPERS'] = 'All whispers visible';
$Context->Dictionary['PERMISSION_CHANGE_APPLICATION_SETTINGS'] = 'Change application settings';
$Context->Dictionary['PERMISSION_MANAGE_EXTENSIONS'] = 'Extensions';
$Context->Dictionary['PERMISSION_MANAGE_LANGUAGE'] = 'Change language';
$Context->Dictionary['PERMISSION_MANAGE_STYLES'] = 'Manage styles';
$Context->Dictionary['PERMISSION_MANAGE_THEMES'] = 'Manage themes';
$Context->Dictionary['PERMISSION_RECEIVE_APPLICATION_NOTIFICATION'] = 'Notify by email of new applicants';
$Context->Dictionary['PERMISSION_ALLOW_DEBUG_INFO'] = 'Can view debug info';
$Context->Dictionary['PERMISSION_DATABASE_CLEANUP'] = 'Allow use of the cleanup extension';
$Context->Dictionary['PERMISSION_ADD_ADDONS'] = 'Can add add-ons';
$Context->Dictionary['NoEnabledExtensions'] = 'There are currently no enabled extensions.';
$Context->Dictionary['NoDisabledExtensions'] = 'There are currently no disabled extensions.';
$Context->Dictionary['NA'] = 'n/a';
$Context->Dictionary['AboutExtensionPage'] = '<strong>The Extension Page</strong><br />This page can be used by extension authors to program custom pages in Vanilla. You are looking at the default view and probably reached this page by accident or because of a bug in an extension.';
$Context->Dictionary['NewApplicant'] = 'New Forum Applicant';
$Context->Dictionary['PERMISSION_SINK_DISCUSSIONS'] = 'Sink discussions';
$Context->Dictionary['MakeThisDiscussionSink'] = 'Sink this discussion';
$Context->Dictionary['MakeThisDiscussionUnSink'] = 'Unsink this discussion';
$Context->Dictionary['ConfirmUnSink'] = 'Are you sure you want to unsink this discussion?';
$Context->Dictionary['ConfirmSink'] = 'Are you sure you want to sink this discussion?';
$Context->Dictionary['ErrPermissionSinkDiscussions'] = 'You do not have permission to sink discussions';
$Context->Dictionary['YourCommentsWillBeWhisperedToX'] = 'Your comments will be whispered to //1';
$Context->Dictionary['SMTPHost'] = 'SMTP host';
$Context->Dictionary['SMTPUser'] = 'SMTP user';
$Context->Dictionary['SMTPPassword'] = 'SMTP password';
$Context->Dictionary['SMTPSettingsNotes'] = 'Typically Vanilla will use the mail server that is set up on the server where Vanilla resides. If, for some reason, you want to use a separate SMTP mail server to send outgoing e-mails, you can configure it with these three options. If you do not want to use an SMTP server, leave these fields blank.';
$Context->Dictionary['PagelistNextText'] = 'Next';
$Context->Dictionary['PagelistPreviousText'] = 'Prev';
$Context->Dictionary['EmailSettings'] = 'Email Settings';
$Context->Dictionary['UpdateReminders'] = 'Update Reminders';
$Context->Dictionary['UpdateReminderNotes'] = 'We are all forgetful, so Vanilla can be configured to remind you to check for updates. Anyone who has permission to check for updates will see this reminder, which will appear above the discussion list.';
$Context->Dictionary['ReminderLabel'] = 'Check for updates';
$Context->Dictionary['Never'] = 'Never';
$Context->Dictionary['Weekly'] = 'Weekly';
$Context->Dictionary['Monthly'] = 'Monthly';
$Context->Dictionary['Quarterly'] = 'Quarterly (3 months)';
$Context->Dictionary['ReminderChangesSaved'] = 'Your reminder settings were saved successfully.';
$Context->Dictionary['NeverCheckedForUpdates'] = "You haven't checked for Vanilla updates yet.";
$Context->Dictionary['XDaysSinceUpdateCheck'] = 'It has been //1 days since you checked for Vanilla updates.';
$Context->Dictionary['CheckForUpdatesNow'] = 'Click here to check for updates now';
$Context->Dictionary['ManageThemeAndStyle'] = 'Themes &amp; Styles';
$Context->Dictionary['ThemeChangesSaved'] = 'Your changes have been saved successfully';
$Context->Dictionary['ThemeAndStyleNotes'] =  "Themes and Styles are used to change Vanilla's structure and appearance respectively. For more themes and styles from Lussumo, or to find out how to create your own, <a href=\"http://lussumo.com/addons/\">check out the Vanilla Add-on Directory</a>.";
$Context->Dictionary['ThemeLabel'] = 'Themes currently available in your installation of Vanilla';
$Context->Dictionary['StyleLabel'] = 'Styles available for the selected theme';
$Context->Dictionary['ApplyStyleToAllUsers'] = 'Apply this style to all users';
$Context->Dictionary['ThemeAndStyleManagement'] = 'Themes and Styles';
$Context->Dictionary['Check'] = 'Check: ';
$Context->Dictionary['All'] = 'All';
$Context->Dictionary['None'] = 'None';
$Context->Dictionary['Simple'] = 'Simple';
$Context->Dictionary['ErrorFopen'] = "An error occurred while attempting to retrieve information from an external data source (\\1).";
$Context->Dictionary['ErrorFromPHP'] = " Here is the message reported by PHP: \\1";
$Context->Dictionary['InvalidHostName'] = 'The supplied host name was invalid: \\1';
$Context->Dictionary['WelcomeToVanillaGetSomeAddons'] = '<strong>Welcome to Vanilla!</strong>
<br />You will quickly notice that it is very ... vanilla. You should definitely spice things up with some <a href="http://lussumo.com/addons/">add-ons</a>.';
$Context->Dictionary['RemoveThisNotice'] = 'Remove this message';
$Context->Dictionary['OtherSettings'] = 'Other settings';
$Context->Dictionary['ChangesSaved'] = 'Your changes were saved successfully';
$Context->Dictionary['DiscussionType'] = 'Discussion Type';
// Added for Vanilla 1.1 on 2007-02-20
$Context->Dictionary['ErrPostBackKeyInvalid'] = 'There was a problem authenticating your post information.';
$Context->Dictionary['ErrPostBackActionInvalid'] = 'Your post information was not be defined properly.';
// Moved from settings.php
$Context->Dictionary['TextWhispered'] = 'Private'; 
$Context->Dictionary['TextSticky'] = 'Sticky'; 
$Context->Dictionary['TextClosed'] = 'Closed'; 
$Context->Dictionary['TextHidden'] = 'Deleted';
$Context->Dictionary['TextSink'] = 'Sink';
$Context->Dictionary['TextBookmarked'] = 'Bookmarked'; 
$Context->Dictionary['TextPrefix'] = '['; 
$Context->Dictionary['TextSuffix'] = ']';
// Added for new update checker
$Context->Dictionary['CheckingForUpdates'] = 'Checking for updates...';
$Context->Dictionary['ApplicationStatusGood'] = 'Vanilla is up to date.';
$Context->Dictionary['ExtensionStatusGood'] = 'This extension is up to date.';
$Context->Dictionary['ExtensionStatusUnknown'] = 'Extension not found. <a href="http://lussumo.com/docs/doku.php?id=vanilla:administrators:updatecheck">Find out why</a>';
$Context->Dictionary['NewVersionAvailable'] = 'Version \\1 is available. <a href="\\2">Download</a>';
// Altered for new applicant management screen
$Context->Dictionary['ApproveForMembership'] = 'Approve';
$Context->Dictionary['DeclineForMembership'] = 'Decline';
$Context->Dictionary['ApplicantsNotes'] = 'Use this form to approve or decline new membership applicants.';
$Context->Dictionary['NoApplicants'] = 'There are currently no applicants to review...';

/* Please do not remove or alter this definition */
$Context->Dictionary['PanelFooter'] = '<p id="AboutVanilla"><a href="http://getvanilla.com">Vanilla '.APPLICATION_VERSION.'</a> is a product of <a href="http://lussumo.com">Lussumo</a>. More Information: <a href="http://lussumo.com/docs">Documentation</a>, <a href="http://lussumo.com/community">Community Support</a>.</p>';

?>