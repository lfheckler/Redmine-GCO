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

class GcoLog < ActiveRecord::Base

  belongs_to :project

  acts_as_event :title => :title,
                :datetime => :created_on,
                :description => :msg_log,
                :url => Proc.new {|o| {:controller => 'gco', :action => 'index', :project_id => o.project_id}}

  acts_as_activity_provider :timestamp => '`gco_logs`.created_on',
                            :find_options => { :include => :project }


end