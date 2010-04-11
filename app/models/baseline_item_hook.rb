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

class BaselineItemHook < Redmine::Hook::ViewListener
  def view_issues_show_details_bottom(context)


    entries = Baseline.find(:all,:conditions=>"project_id="+context[:project].id.to_s,:order=>"position, COALESCE(creation_date, cancellation_date) ")

    content = "<hr />"+
              "<input type=\"hidden\" id=\"issue_id\" value=\"#{context[:issue].id}\" />"+
              "<script src=\"/plugin_assets/redmine_gco/javascripts/gco.js\" type=\"text/javascript\"></script>"+
              "<script type=\"text/javascript\">addCss();</script>"+
              "<p><span class=\"expand\" id=\"spanGco\" onclick=\"alternaDiv('spanGco','divGco');\" >&nbsp;</span>"+
              "<strong> Gerência de Configuração</strong></p>"+
              "<div id=\"divGco\" class=\"closed\" >"+
              "<p style=\"font-style:italic\">Baselines que deverão incluir os itens do repositório relacionados a este ticket.</p>"+
              "<p>"+
              "<table class=\"tbBaselineOptions\">"
    i=1
    entries.each do |e|
      
      content += "<tr>" if i==1

      relation = Baseline_item.find(:all,:conditions=>"issue_id="+context[:issue].id.to_s+" and baseline_id="+e.id.to_s)

      selected = " checked=\"checked\"" unless relation.empty?

      active = " disabled=\"true\" " unless e.cancellation_date.nil? && e.creation_date.nil? && User.current.allowed_to?(:gerenciar_configuracao, context[:project])

      content += "<td><input type=\"checkbox\" name=\"issueBaselines\" id=\"issueBaselines#{i}\" value=\"#{e.id}\" #{selected} #{active} onclick=\"issueBaselineRelation(this.id,#{context[:project].id})\" />"+
                 e.identifier+"</td>"
      
      content += "</tr><tr>" if i%6==0

      i+=1
    end
    
    content +="</tr></table>"+
              "</p>"

    unless User.current.allowed_to?(:gerenciar_configuracao, context[:project])
      content += "<p><i>** Suas permissões de acesso não permitem alterar a configuração das baselines.</i></p>"
    end

    content +="</div>"+
              "<hr />"
    
    return "<tr><td colspan=\"4\">#{content}</td></tr>"
  end


  def view_layouts_base_html_head(context)
    return '<link href="/plugin_assets/redmine_gco/stylesheets/gco.css" media="screen" rel="stylesheet" type="text/css" />'
  end

end
