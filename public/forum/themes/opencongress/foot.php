<?php
// Note: This file is included from the library/Vanilla/Vanilla.Control.Foot.php class.

echo '</div>
<a id="pgbottom" name="pgbottom">&nbsp;</a>
</div>';

$AllowDebugInfo = 0;
if ($this->Context->Session->User) {
   if ($this->Context->Session->User->Permission('PERMISSION_ALLOW_DEBUG_INFO')) $AllowDebugInfo = 1;
}
if ($this->Context->Mode == MODE_DEBUG && $AllowDebugInfo) {
   echo '<div class="DebugBar" id="DebugBar">
   <b>Debug Options</b> | Resize: <a href="javascript:window.resizeTo(800,600);">800x600</a>, <a href="javascript:window.resizeTo(1024, 768);">1024x768</a> | <a href="'
   ."javascript:HideElement('DebugBar');"
   .'">Hide This</a>';
   echo $this->Context->SqlCollector->GetMessages();
   echo '</div>';
}
?>
</div>
<div id="footer-wrapper">
				<div class="left">
					<div class="right">
      		<div id="footer" class="clearfix">

					<h5><b>Find Your Way:</b></h5>
        		<div class="footlist first">
        			<b>OpenCongress</b>
        				<ul>
          				<li><a href="/">Home</a></li>
          				<li><a href="/search">Search</a></li>
			            <li><a href="/about" title="Find out more about who and what is Open Congress">About Open Congress</a></li>

                  <li><a href="/about" title="">Help FAQ</a></li>
									<li><a href="/about/rss">RSS Feeds</a></li>																			
									<a href="/contact/">Contact Us</a>
        				</ul>
        		</div>
      			<div class="footlist">
      				<b>Go to</b>

      					<ul>
							 		<li><a href="/bill/all">Bills</a></li>
									<li><a href="/person/senators">Senators</a></li>
									<li><a href="/person/representatives">Representatives</a></li>
									<li><a href="/roll_call">Votes</a></li>		
									<li><a href="/issues">Issues</a></li>
									<li><a href="/industry">The Money Trail</a></li>

      					</ul>
      			</div>
      			<div class="footlist">
      				<b>Go to</b>
      				<ul>

								<li><a href="/wiki">CongressWiki</a></li>		
								<li><a href="/blog">Blog</a></li>

								<li><a href="/resources">Resources</a></li>
								<li><a href="/forum/categories.php">Discussion</a></li>
								<li><a href="/battle_royale">Bill Battle</a></li>
								<li><a href="/video">Video</a></li>

					</ul>
      			</div>		
      			
      			<div class="footlist last">

      				<b>My OpenCongress</b>
      					<ul>

									
									<li><a href="/login">Login</a></li>
									
						</ul>
					</div>
					</div>
				 	</div>

      </div> <!-- // footer  -->
    </div>	<!-- // footer-wrapper -->


    	<div id="subfoot">
			  
			<p style="text-align:center;">
			
			OpenCongress is a joint project of the <a target="_blank" href="http://participatorypolitics.org/">Participatory Politics Foundation</a> and the <a target="_blank" href="http://www.sunlightfoundation.com/">Sunlight Foundation</a>. Questions? Comments? <a href="/contact/">Contact Us</a></p>

		</div> <!-- // end subfoot -->

	
</div>
</div>
