# Redmine GCO - a Redmine plugin for configuration management
# Copyright (C) 2010  Luis Fernando Heckler
#
# This file is part of Redmine GCO.
# Redmine GCO is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

class IssueRevisionController < ApplicationController
  unloadable

  def show_revisions
    issue_id = params[:issue_id]
    @issue = Issue.find(issue_id)

    @project = GcoUtil.find_project(params[:project_id])

    trunk_path = GcoUtil.find_custom_field_value(@project, l(:trunk_custom_field))

    @entries ||=[]


    changesets = @project.repository.latest_changesets(trunk_path,@rev)
    @entries = changesets.uniq.sort_by {|e| e.revision.to_i} unless changesets.nil?||changesets.empty?


    respond_to do |format|
        format.js { render(:update) {|page| page.replace_html "revisions", :partial => 'issues/revisions'} }
    end
  end


  def add

    issue_id = params[:issue_id]
    issue = Issue.find(issue_id)

    changeset_id = params[:changeset_id]
    changeset = Changeset.find(changeset_id)

    changeset.issues.push(issue)
    changeset.save

    gcolog = GcoLog.new
    gcolog.author = User.current.name
    gcolog.title = "Associação entre tickets e revisões"
    gcolog.msg_log = "Revisão #{changeset.revision} associada ao ticket #{issue.id}."
    gcolog.project_id = params[:project_id]
    gcolog.save


    respond_to do |format|
      format.html { redirect_to :back }
    end
  end


  def del
    issue_id = params[:issue_id]
    issue = Issue.find(issue_id)

    changeset_id = params[:changeset_id]
    changeset = Changeset.find(changeset_id)

    changeset.issues.delete(issue)
    changeset.save

    gcolog = GcoLog.new
    gcolog.created_on = Time.now
    gcolog.author = User.current.name
    gcolog.title = "Associação entre tickets e revisões"
    gcolog.msg_log = "Revisão #{changeset.revision} desassociada do ticket #{issue.id}."
    gcolog.project_id = params[:project_id]
    gcolog.save

    respond_to do |format|
      format.html { redirect_to :back }
    end
  end


end
