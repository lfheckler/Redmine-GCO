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

class GcoUtil

  def self.find_baseline_items(baseline_id)
    baseline = Baseline.find(baseline_id)
    entries = baseline.entries
    return entries
  end


  def self.find_project(id)
    return Project.find(id)
  end


  def self.find_custom_field_value(project, field_name)
    #itera sobre os valores de campos customizados do projeto
    project.custom_field_values.each do |field|
      #se encontrou, sai do laço
      if CustomField.find(field.custom_field_id).name == field_name
        return field.value
      end
    end

  end

end