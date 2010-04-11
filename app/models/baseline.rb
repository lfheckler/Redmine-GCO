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

class Baseline < ActiveRecord::Base
  belongs_to :project

  has_many :baseline_item

  validates_presence_of :project_id
  
  validates_uniqueness_of :identifier => :project_id

  acts_as_list :scope => 'project_id = #{project_id} AND creation_date is null and cancellation_date is null'

  def baseline_items
    Baseline_item.find(:all,:conditions=>"baseline_id=#{id}")
  end

  def entries
    Change.find_by_sql " SELECT distinct c.path,  max(cs.revision ) as revision "+
                       " FROM changesets cs, "+
                       "      changes c, "+
                       "      changesets_issues ci, "+
                       "      baseline_items bi " +
                       " WHERE "+
                       " cs.id = c.changeset_id AND "+
                       " ci.changeset_id = c.changeset_id AND "+
                       " ci.issue_id = bi.issue_id AND "+
                       " bi.baseline_id = #{id} AND " + 
                       " c.action <> 'D' "+
                       " GROUP BY c.path "+
                       " ORDER BY c.path "

  end
end
