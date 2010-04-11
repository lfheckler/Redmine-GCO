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

class GcoIssueController < ApplicationController
  unloadable

  require 'logger'

  def add
    baseline_item = Baseline_item.new
    baseline_item.baseline_id = params[:baseline_id]
    baseline_item.issue_id = params[:issue_id]

    baseline_item.save if request.post?

    baseline = Baseline.find(params[:baseline_id])
    gcolog = GcoLog.new
    gcolog.created_on = Time.now
    gcolog.author = User.current.name
    gcolog.title = "Associação entre tickets e baselines"
    gcolog.msg_log = "Ticket #{params[:issue_id]} incluído na baseline #{baseline.identifier}."
    gcolog.project_id = params[:project_id]
    gcolog.save

    respond_to do |format|
      format.html { redirect_to :back }
    end
  rescue ::ActionController::RedirectBackError
    render :text => 'Ticket associado à baseline.', :layout => true
  end


  def del
    Baseline_item.delete_all "baseline_id=#{params[:baseline_id]} and issue_id=#{params[:issue_id]}" if request.post?

    baseline = Baseline.find(params[:baseline_id])
    gcolog = GcoLog.new
    gcolog.created_on = Time.now
    gcolog.author = User.current.name
    gcolog.title = "Associação entre tickets e baselines"
    gcolog.msg_log = "Ticket #{params[:issue_id]} excluído da baseline #{baseline.identifier}."
    gcolog.project_id = params[:project_id]
    gcolog.save

    respond_to do |format|
      format.html { redirect_to :back }
    end
  rescue ::ActionController::RedirectBackError
    render :text => 'Ticket retirado da baseline.', :layout => true
  end
  
end
