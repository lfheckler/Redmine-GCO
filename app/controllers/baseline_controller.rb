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

class BaselineController < ApplicationController
  unloadable

  def baseline_items
    baseline_id = params[:baseline_id]

    @project = GcoUtil.find_project(params[:project_id])

    @entries ||=[]

    unless baseline_id.nil? || baseline_id==""
      @entries = GcoUtil.find_baseline_items(baseline_id)
    end

    respond_to do |format|
        format.js { render(:update) {|page| page.replace_html "baselineItems", :partial => 'baseline/baseline_items'} }
    end
  end

end
