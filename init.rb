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

require 'redmine'

require_dependency 'baseline_item_hook'


Redmine::Plugin.register :redmine_gco do
  name 'Redmine GCO plugin'
  author 'Luís Fernando Heckler'
  description 'Plugin para apoio à Gerência de Configuração'
  version '1.0.1'

  #project_module encapsula as permissões de forma a compor um módulo, que pode
  #então ser selecionado ou não para exibição por projeto
  project_module :gco do
    #declara as permissões de cada action do controller
    permission :gerenciar_configuracao , {:gco => [:index, :new_baseline_plan, :move_baseline_plan, :delete_baseline_plan, :associate_issue]}
    permission :consultar_configuracao , {:gco => [:index]}
    permission :criar_baseline, {:gco => [:index]}
    permission :editar_configuracao, {:gco => [:index]}

    # precisa liberar a permissão para aparecer no menu lateral das atividades
    permission :view_gco_logs, {:project => [:activity]}
  end


  #estende o menu do projeto, indicando qual o controller, action, além de título e parâmetros esperados
  #adicionalmente pode-se forçar a posição com a opção :after
  menu :project_menu, :gco, { :controller => 'gco', :action => 'index' }, :caption => 'GCO', :param => :project_id

  # registrar o provedor de logs de atividade do projeto
  # (a classe do model deve estar setada para tal)
  activity_provider :gco_logs

end
