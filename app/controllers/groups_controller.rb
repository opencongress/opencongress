class GroupsController < ApplicationController
  def new
    @group = Group.new
  end
end
