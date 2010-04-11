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

module GcoHelper

  def gco_tabs
    tabs = [{:name => 'baseline', :permission=> :consultar_configuracao, :partial=> 'baseline/show', :label => 'Baselines'},
            {:name => 'config_plan', :permission=> :consultar_configuracao,:partial=> 'config_plan/plan', :label => 'Plano de Configuração'},
            {:name => 'issues', :permission=> :editar_configuracao,  :partial=> 'issues/index', :label => 'Tickets x Revisões'},
            {:name => 'report', :permission=> :consultar_configuracao, :partial=> 'report/report', :label => 'Não-conformidades'}
            ]
    tabs.select {|tab| User.current.allowed_to?(tab[:permission], @project)}
  end

  def baseline_options_for_select(entries)
      opt_array = entries.collect { |entry| [entry.identifier,entry.id] }
      options_for_select(opt_array)

  end

  def issues_options_for_select(entries)
      opt_array ||= []
      opt_array = entries.collect { |entry| [entry.id.to_s+" - "+entry.subject,entry.id] }
      options_for_select([""]+opt_array,"")
  end

end
