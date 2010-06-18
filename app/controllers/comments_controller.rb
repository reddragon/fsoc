#--
#   Copyright (C) 2010 Gaurav Menghani <gaurav.menghani@gmail.com>
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#++

class CommentsController < ApplicationController
  include ApplicationHelper
  before_filter :login_required, :except => 'index'
  
  def index  
    @project = Project.find(params[:project_id])
    @comments = @project.comments
  end
  
  def inpage_new
    @comment = Comment.new
    project = Project.find(params[:id])
    if params[:reply_to_id] != nil
      original_comment = Comment.find(params[:reply_to_id])
      original_comment.content = enquote(original_comment.content)
      @comment.content = "(In reply to Comment # #{original_comment.id})" + original_comment.content
    end
    @comment.project = project
    render :partial => "new", :task_id => :id
  end

  def edit
    @comment = Comment.find(params[:id])  
    if !can_edit_comment?(@comment)
      flash[:notice] = 'You are not authorised to edit this comment.'
      redirect_to project_comments_url
      end
    #Remove the br tags so that it can be displayed in a natural fashion
    @comment.content = CGI.unescape(@comment.content).gsub(/<br>/,"\n")
  end
  
  def update
    task = Comment.find(params[:id])
    if task.update_attributes(params[:comment])
      flash[:notice] = 'Comment was successfully edited.'
      redirect_to project_comments_url
    else
      flash[:notice] = 'Could not edit comment'        
      render :action => "edit"
    end
  end

  def create
    comment = Comment.new(params[:comment])
    #Convert endlines to <br/>
    comment.content = CGI.unescape(comment.content).gsub(/\n/,"<br>")
    #TODO: Santize tags here, excluding the br tag
    comment.user = current_user
    if comment.save
      flash[:notice] = 'Comment was successfully created.'
      redirect_to project_comments_url
    else
      flash[:notice] = 'Could not create new comment.'    
      redirect_to project_comments_url
    end
  end
  
  def destroy
    comment = Comment.find(params[:id])
    if !can_delete_comment?(comment)
      flash[:notice] = 'You are not authorised to delete this comment.'
      redirect_to project_comments_url
    end
    comment.destroy
    flash[:notice] = 'Comment was successfully deleted.'
    redirect_to project_comments_url
  end
end
