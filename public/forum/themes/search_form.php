<?php
// Note: This file is included from the library/Vanilla/Vanilla.Control.SearchForm.php class.

$this->PostBackParams->Add("PostBackAction", "Search");

echo '<div id="Form" class="Account Search">
	<fieldset id="SearchSimpleFields">
      <legend>'.$this->Context->GetDefinition('Search').'</legend>
		<a href="./" onclick="ShowAdvancedSearch(); return false;" class="SearchSwitch">'.$this->Context->GetDefinition('Advanced').'</a>';
      $this->Render_PostBackForm('SearchSimple', 'get');
		$this->TypeRadio->CssClass = 'SearchRadio';
			echo '<ul>
				<li id="MainSearchInput">
					<label for="txtKeywords">'.$this->Context->GetDefinition('SearchTerms').'</label>
					<input id="txtKeywords" type="text" name="Keywords" value="'.$this->Search->Keywords.'" class="SearchInput" />
				</li>
				<li id="SimpleSearchRadios">'
					.$this->Context->GetDefinition('ChooseSearchType')
					.$this->TypeRadio->Get()
				.'</li>
				<li>
					<input type="submit" name="btnSubmit" value="'.$this->Context->GetDefinition('Search').'" class="Button SearchButton" />
				</li>
			</ul>
		</form>
	</fieldset>';
   
   // Begin Advanced Topic Search Form
   echo '<fieldset id="SearchDiscussionFields">
		<legend>'.$this->Context->GetDefinition('DiscussionTopicSearch').'</legend>
		<a href="./" onclick="ShowSimpleSearch(); return false;" class="SearchSwitch">'.$this->Context->GetDefinition('Simple').'</a>';
		$this->PostBackParams->Add('Type', 'Discussions');
		$this->PostBackParams->Add('Advanced', '1');
		$this->Render_PostBackForm('SearchDiscussions', 'get');
			echo '<ul>
				<li>
					<label for="txtDiscussionKeywords">'.$this->Context->GetDefinition('FindDiscussionsContaining').'</label>
					<input id="txtDiscussionKeywords" type="text" name="Keywords" value="'.($this->Search->Type == 'Topics'?$this->Search->Query:'').'" class="SearchInput AdvancedSearchInput" />
				</li>';
				if ($this->Context->Configuration['USE_CATEGORIES']) {
					$this->CategorySelect->Attributes = ' id="ddDiscussionCategories"';
					$this->CategorySelect->CssClass = 'SearchSelect';
					$this->CategorySelect->SelectedValue = ($this->Search->Type == 'Topics' ? $this->Search->Categories : '');
					echo '<li>
						<label for="ddDiscussionCategories">'.$this->Context->GetDefinition('InTheCategory').'</label>'
						.$this->CategorySelect->Get().'
					</li>';
				}
				echo '<li>
					<label for="DiscussionAuthUsername">'.$this->Context->GetDefinition('WhereTheAuthorWas').'</label>
					<input id="DiscussionAuthUsername" name="AuthUsername" type="text" value="'.($this->Search->Type == 'Topics'?$this->Search->AuthUsername:'').'" class="SearchInput AdvancedUserInput" />
					<script type="text/javascript">
						var DiscussionAutoComplete = new AutoComplete("DiscussionAuthUsername", false);
						DiscussionAutoComplete.TableID = "DiscussionAutoCompleteResults";
						DiscussionAutoComplete.KeywordSourceUrl = "'.$this->Context->Configuration['WEB_ROOT'].'ajax/getusers.php?Search=";
					</script>
				</li>
				<li>
					<input type="submit" name="btnSubmit" value="'.$this->Context->GetDefinition('Search').'" class="Button SearchButton" />
				</li>
			</ul>
		</form>
	</fieldset>';
   
   // Begin Advanced Comment Search Form
   echo '<fieldset id="SearchCommentFields">
		<legend>'.$this->Context->GetDefinition('DiscussionCommentSearch').'</legend>';
		$this->PostBackParams->Set('Type', 'Comments');
		$this->Render_PostBackForm('SearchComments', 'get');
			echo '<ul>
				<li>
					<label for="txtCommentKeywords">'.$this->Context->GetDefinition('FindCommentsContaining').'</label>
					<input id="txtCommentKeywords" type="text" name="Keywords" value="'.($this->Search->Type == 'Comments'?$this->Search->Query:'').'" class="SearchInput AdvancedSearchInput" />
				</li>';
				if ($this->Context->Configuration['USE_CATEGORIES']) {
					$this->CategorySelect->Attributes = ' id="ddCommentCategories"';
					$this->CategorySelect->CssClass = 'SearchSelect';
					$this->CategorySelect->SelectedValue = ($this->Search->Type == 'Comments' ? $this->Search->Categories : '');
					echo '<li>
						<label for="ddCommentCategories">'.$this->Context->GetDefinition('InTheCategory').'</label>'
						.$this->CategorySelect->Get().'
					</li>';
				}
				echo '<li>
					<label for="CommentAuthUsername">'.$this->Context->GetDefinition('WhereTheAuthorWas').'</label>
					<input id="CommentAuthUsername" name="AuthUsername" type="text" value="'.($this->Search->Type == 'Comments'?$this->Search->AuthUsername:'').'" class="SearchInput AdvancedUserInput" />
					<script type="text/javascript">
						var CommentAutoComplete = new AutoComplete("CommentAuthUsername", false);
						CommentAutoComplete.TableID = "CommentAutoCompleteResults";
						CommentAutoComplete.KeywordSourceUrl = "'.$this->Context->Configuration['WEB_ROOT'].'ajax/getusers.php?Search=";
					</script>
				</li>
				<li>
					<input type="submit" name="btnSubmit" value="'.$this->Context->GetDefinition('Search').'" class="Button SearchButton" />
				</li>
			</ul>
		</form>
	</fieldset>';
   
   // Begin Advanced User Search Form
   
	echo '<fieldset id="SearchUserFields">
		<legend>'.$this->Context->GetDefinition('UserAccountSearch').'</legend>';
		$this->RoleSelect->Attributes = ' id="ddRoles"';
		$this->RoleSelect->CssClass = 'SearchSelect';
		$this->OrderSelect->Attributes = ' id="ddOrder"';
		$this->OrderSelect->CssClass = 'SearchSelect';
		$this->PostBackParams->Set('Type', 'Users');
		$this->Render_PostBackForm('SearchUsers', 'get');
			echo '<ul>
				<li>
					<label for="txtUserKeywords">'.$this->Context->GetDefinition('FindUserAccountsContaining').'</label>
					<input id="txtUserKeywords" type="text" name="Keywords" value="'.($this->Search->Type == 'Users'?$this->Search->Query:'').'" class="SearchInput AdvancedSearchInput" />
				</li>
				<li>
					<label for="ddRoles">'.$this->Context->GetDefinition('InTheRole').'</label>
					'.$this->RoleSelect->Get().'
				</li>
				<li>
					<label for="ddOrder">'.$this->Context->GetDefinition('SortResultsBy').'</label>
					'.$this->OrderSelect->Get().'
				</li>
				<li>
					<input type="submit" name="btnSubmit" value="'.$this->Context->GetDefinition('Search').'" class="Button SearchButton" />
				</li>
			</ul>
		</form>
	</fieldset>
</div>';
?>