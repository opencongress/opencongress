<?php
// Note: This file is included from the library/Framework/Framework.Control.Head.php class.

$HeadString = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="'.$this->Context->GetDefinition('XMLLang').'">
<head>
  <title>'.$this->Context->Configuration['APPLICATION_TITLE'].' - '.$this->Context->PageTitle.'</title>
  <link rel="shortcut icon" href="/favicon.ico" />
  <link rel="icon" type="image/png" href="/favicon.png" />
  <script type="text/javascript" src="/javascripts/prototype.js"></script>
  <!--[if IE 7]><style type="text/css">@import url("/stylesheets/ie7.css");</style><![endif]-->

  <!--[if lt IE 8]>
  <script src="http://ie7-js.googlecode.com/svn/version/2.0(beta3)/IE8.js" type="text/javascript"></script>
<![endif]-->';

while (list($Name, $Content) = each($this->Meta)) {
  $HeadString .= '
    <meta name="'.$Name.'" content="'.$Content.'" />';
}

if (is_array($this->StyleSheets)) {
  while (list($Key, $StyleSheet) = each($this->StyleSheets)) {
    $HeadString .= '
      <link rel="stylesheet" type="text/css" href="'.$StyleSheet['Sheet'].'"'.($StyleSheet['Media'] == ''?'':' media="'.$StyleSheet['Media'].'"').' />';
  }
}
if (is_array($this->Scripts)) {
  $ScriptCount = count($this->Scripts);
  $i = 0;
  for ($i = 0; $i < $ScriptCount; $i++) {
    $HeadString .= '
      <script type="text/javascript" src="'.$this->Scripts[$i].'"></script>';
  }
}

if (is_array($this->Strings)) {
  $StringCount = count($this->Strings);
  $i = 0;
  for ($i = 0; $i < $StringCount; $i++) {
    $HeadString .= $this->Strings[$i];
  }
}
$BodyId = "";
if ($this->BodyId != "") $BodyId = ' id="'.$this->BodyId.'"';
echo $HeadString . '
  <link type="text/css" rel="stylesheet" media="screen" href="/stylesheets/reset.css" />
  <link type="text/css" rel="stylesheet" media="screen" href="/stylesheets/typo.css" />
  <link type="text/css" rel="stylesheet" media="screen" href="/stylesheets/master.css" />
  </head>
  <body'.$BodyId.' '.$this->Context->BodyAttributes.'>';
?>
<div id="wrapper">
  <div id="header" class="clearfix">
    <h1><a class="logo" href="/" title="link to the home page"> </a></h1>

    <div class="right">

      <div id="user_account">
        <p>
          <?php
        if ($this->Context->Session->UserID > 0) {
          echo str_replace('//1',
          $this->Context->Session->User->Name,
            $this->Context->GetDefinition('SignedInAsX')).' (<a href="'.$this->Context->Configuration['SIGNOUT_URL'].'">'.$this->Context->GetDefinition('SignOut').'</a>)';
        } else {
          echo $this->Context->GetDefinition('NotSignedIn').' (<a href="'.AppendUrlParameters($this->Context->Configuration['SIGNIN_URL'], 'ReturnUrl=http://www.opencongress.org'.$_SERVER['REQUEST_URI']).'">'.$this->Context->GetDefinition('SignIn').'</a>)';
        }
        ?>
      </p>
    </div>
    <div id="search">
    <form action="/forum/search.php" id="SearchSimple" method="get">
        <div class="search">
          <label for="search-field">Search</label>
        <input type="hidden" value="Search" name="PostBackAction"/>
        <input name="Keywords" autocomplete="off" id="txtKeywords" class="search-field" type="text" value="Search Forums" onfocus="this.value = '';" onblur="if (this.value == ''){this.value = 'Search Forums'};"/>
        <input type="image" src="/images//search_submit.gif" name="submit" id="search_submit" value="Search" />
          		
              <ul>
              <li id="SimpleSearchRadios">Search:<input type="radio" class="SearchRadio" checked="checked" value="Topics" id="Radio_Topics" name="Type"/>
      			<label class="Radio" for="Radio_Topics">Topics</label>
      			<input type="radio" class="SearchRadio" value="Comments" id="Radio_Comments" name="Type"/>
      			<label class="Radio" for="Radio_Comments">Comments</label>
      			<input type="radio" class="SearchRadio" value="Users" id="Radio_Users" name="Type"/>
      			<label class="Radio" for="Radio_Users">Users</label>
      			</li>
      			</ul>
        </div>

      </form>
    </div>          
  </div>
  
  <div class="center">
<p><span>Everyone can be an insider</span></p>
<p> <a class="learn_it" href="/#pitch">Learn how to track, comment, and share</a>  </p>                                                                                       
    <p class="project">A project of <a target="_blank" href="http://www.participatorypolitics.org">PPF</a> and the <a target="_blank" href="http://www.sunlightfoundation.com/">Sunlight Foundation</a></p>
  </div>
  
</div> <!-- // header -->
<div id="nav" class="un">
  <div class="left">
    <div class="right">

      <ul id="forum">
        <li id="bill_nav"><a href="/bill/all"><span>Bills</span></a></li>
        <li id="sens_nav"><a href="/person/senators"><span>Senators</span></a></li>
        <li id="reps_nav"><a href="/person/representatives"><span>Representatives</span></a></li>

        <li id="vote_nav"><a href="/roll_call"><span>Votes</span></a></li>
        <li id="ishu_nav"><a href="/issue"><span>Issues</span></a></li>
        <li id="comm_nav"><a href="/committee"><span>Committees</span></a></li>
        <li id="muny_nav"><a href="/money_trail"><span>The Money Trail</span></a></li>
        <li id="wiki_nav" class="sub"><a href="/wiki"><span>Wiki</span></a></li>
        <li id="blog_nav" class="sub"><a href="/blog"><span>Blog</span></a></li>
        <li id="tool_nav" class="sub">
          <a href="/resources"><span>Resources <img src="/images//tool_arrow.png" /></span></a>

          <ul class="sub">
            <li id="compare_nav"><a href="/people/compare" ><span>Vote Comparison</span></a></li> 
            <li id="widget_nav"><a href="#"><span>Site Widgets</span></a></li>
            <li id="states_nav"><a href="/states"><span>States</span></a><li>
              <li id="howitworks_nav"><a href="#"><span>How Congress Works</span></a></li>
              <li id="disc_nav"><a href="/forum/categories.php"><span>Discussion</span></a></li>
              <li id="allresources_nav"><a href="/tools#all"><span>All Resources</span></a></li>
            </ul>
          </li>
          <li id="battle_nav" class="sub"><a href="/battle_royale"><span>Battle Royale</span></a></li> 
        </ul>

      </div>
    </div>
  </div>
