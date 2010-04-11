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

class GcoController < ApplicationController
  unloadable

  before_filter :find_project, :authorize

  require 'logger'

  def index
    case params[:tab]
      when "baseline"
        find_baselines_path
        find_trunk_path
        find_baseline_svn_entries
        find_next_baselines

        # trata o post do formulário para criar nova baseline
        if request.post?
            create_new_baseline(params[:user],params[:password],params[:baseline_id],params[:baseline_items])
          redirect_to :action => 'index', :project_id => @project.identifier, :tab => params[:tab]
        end

      when "config_plan"
        find_baseline_plan

      when "report"
        show_report

      when "issues"
        review_issues_revisions
    end
    
  end

  def new_baseline_plan
    project_id = params[:project_id]
    tab = params[:tab]
    baseline_ident = params[:baseline_ident]

    if request.post?

      if baseline_ident.nil? || baseline_ident == "" || baseline_ident.gsub(/ /,"")==""
        flash[:error] = 'É preciso preencher o identificador da nova baseline.'
        redirect_to :action => "index", :tab => tab, :project_id => project_id
        return
      end

      @baseline = Baseline.new
      @baseline.identifier = baseline_ident
      @baseline.project_id = project_id
      @baseline.position = 0
      @baseline.move_higher

      if @baseline.save
        flash[:notice] = "Nova baseline planejada com sucesso."
        gcolog = GcoLog.new
        gcolog.created_on = Time.now
        gcolog.author = User.current.name
        gcolog.title = "Planejamento de baseline"
        gcolog.msg_log = "Baseline #{baseline_ident} incluída no plano de configuração."
        gcolog.project_id = project_id
        gcolog.save
      else
        flash[:error] = "Falha ao planejar nova baseline."
      end

    end

    redirect_to :action => "index", :tab => tab, :project_id => project_id

  end

  def move_baseline_plan
    baseline = Baseline.find(params[:baseline_id])
    unless baseline.nil?
      case params[:position]
        when 'highest'
          baseline.move_to_top
        when "lower"
          baseline.move_higher
        when "higher"
          baseline.move_lower
        when 'lowest'
          baseline.move_to_bottom
      end
      baseline.save

      gcolog = GcoLog.new
      gcolog.created_on = Time.now
      gcolog.author = User.current.name
      gcolog.title = "Planejamento de baseline"
      gcolog.msg_log = "Ordem da baseline #{baseline.identifier} alterada."
      gcolog.project_id = @project.id
      gcolog.save

      redirect_to :action => "index", :tab => "config_plan", :project_id => @project.identifier
    end
  end


  def delete_baseline_plan
    baseline = Baseline.find(params[:baseline_id])
    if baseline.creation_date.nil?
      #remove da lista para atualizar os demais
      baseline.remove_from_list
      #remove o registro
      Baseline.delete(baseline.id)

      gcolog = GcoLog.new
      gcolog.created_on = Time.now
      gcolog.author = User.current.name
      gcolog.title = "Planejamento de baseline"
      gcolog.msg_log = "Baseline #{baseline.identifier} excluída do plano de configuração."
      gcolog.project_id = @project.id
      gcolog.save

    else
      flash[:error] = 'Não é possível excluir o planejamento de uma baseline que já foi criada.'
    end
    redirect_to :action => "index", :tab => "config_plan", :project_id => @project.identifier
  end


  def associate_issue

    if params[:changeset_id].nil? || params[:changeset_id]==""
      flash[:error] = "A revisão não foi informada."
      redirect_to :action => "index", :tab => params[:tab], :project_id => params[:project_id]
      return
    end

    if params[:issue_id].nil? || params[:issue_id]==""
      flash[:error] = "É preciso selecionar um ticket para associá-lo à revisão."
      redirect_to :action => "index", :tab => params[:tab], :project_id => params[:project_id]
      return
    end

    changeset = Changeset.find(params[:changeset_id])
    issue = Issue.find(params[:issue_id])

    changeset.issues.push(issue)

    changeset.save

    gcolog = GcoLog.new
    gcolog.created_on = Time.now
    gcolog.author = User.current.name
    gcolog.title = "Associação entre tickets e revisões"
    gcolog.msg_log = "Revisão #{changeset.revision} associado ao ticket #{issue.id}."
    gcolog.project_id = @project.id
    gcolog.save


    flash[:notice] = 'Ticket associado com sucesso à revisão.'

    redirect_to :action => "index", :tab => params[:tab], :project_id => params[:project_id]
  end


private

  #localiza o projeto, por meio do parâmetro de ID recebido
  def find_project
    @project = GcoUtil.find_project(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end


  #localiza o caminho onde estão as baselines, indicado em atributo do projeto
  def find_baselines_path
    @baselines_path = GcoUtil.find_custom_field_value(@project,l(:baseline_custom_field))

    if @baselines_path == ""
      field_name = l(:baseline_custom_field)
      @error_msg = l(:msg_baseline_path, field_name )
    end
  end

  def find_trunk_path
    @trunk_path = GcoUtil.find_custom_field_value(@project,l(:trunk_custom_field))

    if @trunk_path == ""
      field_name = l(:trunk_custom_field)
      @error_msg = l(:msg_trunk_path, field_name )
    end

  end

  def find_baseline_svn_entries
    # busca as entradas do repositório no diretório de baselines
    project_repository = @project.repository

    if !project_repository.nil? && project_repository.scm_name == "Subversion"
      find_baselines_path if @baselines_path.nil?
      #logger.info("*** @baselines_path = "+@baselines_path)
      @entries ||= []
      @entries = project_repository.entries(@baselines_path)
      @entries = @entries.sort_by { |e| e.lastrev.identifier.to_i } unless @entries.nil? || @entries.empty?
    else
      @error_msg = l(:msg_no_project_repository)
    end
  
  end

  def find_baseline_plan
    @entries = Baseline.find(:all,:conditions=>"project_id="+@project.id.to_s,:order=>"position, COALESCE(creation_date, cancellation_date) ")
  end

  def find_next_baselines
    @baseline_options = Baseline.find(:all,:conditions=>"project_id="+@project.id.to_s+" and creation_date is null and cancellation_date is null",:order=>"position")
  end

  #cria nova baseline no repositório
  def create_new_baseline (user, passwd, baseline_id, baseline_items)

    if user=="" || user.nil?
      flash[:error] = l(:js_formBaseline_userNotFound)
      return
    end

    if passwd=="" || passwd.nil?
      flash[:error] = l(:js_formBaseline_passwdNotFound)
      return
    end

    if baseline_id=="" || baseline_id.nil?
      flash[:error] = l(:js_formBaseline_baselineIdNotFound)
      return
    end

    selected_baseline = Baseline.find(baseline_id)

    if selected_baseline.nil?
      flash[:error] = "Não foi localizada a baseline."
      return
    end

    svn_util = SvnUtil.new

    l = Logger.new(STDOUT)

    msg_log = "Baseline #{selected_baseline.identifier} criada automaticamente."

    dst = @project.repository.url+"/"+@baselines_path+"/"+selected_baseline.identifier

    i = 0

    baseline_items.each do |item|
      i += 1
      path,revision = item.split('|')

      if path.index(@trunk_path).nil?
        flash[:error] = "Não é previsto incluir na baseline itens que não pertencem ao ramo principal do projeto."
        return
      else
        index = path.index(@trunk_path)+@trunk_path.length-1
      end

      path.slice!(path.slice(0..index))

      src_item = @project.repository.url+"/"+@trunk_path+path

      dst_item = dst+path

      begin
        svn_util.copy(msg_log,user, passwd,src_item, dst_item,revision)
      rescue StandardError => e
        err_msg = "Ocorreu um erro ao criar a baseline #{selected_baseline.identifier}."
          err_msg << " Verifique o repositório pois alguns dos arquivos devem ter sido copiados para a baseline." unless i <= 1
          l.error "Redmine_GCO: gco_controller: "+err_msg + " Usuário: #{User.current.name}. Erro: "+e.to_s
        err_msg << " #{e.to_s}"
        flash[:error] = err_msg
        return
      end
   end
    

    # cancelar as baselines inferiores a esta
    if !selected_baseline.first?
      lower_baselines = Baseline.find(:all,:conditions=>["project_id=:project_id and position < :position and creation_date is null",{:project_id=> @project.id,:position => selected_baseline.position}],:order=>"position")
      lower_baselines.each do |bs|
        bs.cancellation_date = Time.now
        bs.position = nil
        bs.save
      end
    end

    selected_baseline.creation_date = Time.now
    selected_baseline.position = nil
    selected_baseline.save

    # reordenar as baselines restantes
    i = 0
    Baseline.find(:all,:conditions=>["project_id=:project_id and position is not null",{:project_id=> @project.id}],:order=>"position").each do |bs|
      bs.position = i+= 1
      bs.save
    end


    @project.repository.fetch_changesets

    l.info

    flash[:notice] = l(:notice_baseline_created)

  end


  #relatório de possíveis não-conformidades
  def show_report
    @project.repository.fetch_changesets
    
    @missed_baselines ||= []
    @missed_future_baselines ||=[]
    @changes ||=[]

    #busca as baselines no repositório
    find_baseline_svn_entries
    unless @entries.nil? || @entries.empty?
      @entries.each do |entry|
        if entry.is_dir?
          #verifica se existe baseline planejada correspondente
          if Baseline.find(:first,:conditions=>["identifier=:identifier and project_id=:project_id",{:identifier=> entry.name, :project_id=> @project.id}],:order=>"creation_date").nil?
            @missed_baselines.push(entry)
          end

          #verifica se existe baseline planejada e com a data de criação nula
          unless Baseline.find(:first,:conditions=>["identifier=:identifier and project_id=:project_id and creation_date is null",{:identifier=> entry.name, :project_id=> @project.id}],:order=>"creation_date").nil?
            @missed_future_baselines.push(entry)
          end

        end
      end
    end

    #verifica os commits não associados a tickets
    find_trunk_path if @trunk_path.nil?
    @changesets = @project.repository.latest_changesets(@trunk_path,@rev)
    @changesets.collect! {|changeset| changeset if changeset.issues.empty?   }.compact!
    @changesets.uniq!

    #localiza os tickets do projeto
    @issues = @project.issues
  end


  def review_issues_revisions
    @issues = @project.issues
  end
end
