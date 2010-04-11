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

class SvnUtil < Redmine::Scm::Adapters::SubversionAdapter

  require "uri"
  require "logger"
  require 'systemu'

  def initialize
  end



  def copy(log, svn_user, svn_pwd, src, dst,rev)
    l = Logger.new(STDOUT)

    cmd = "svn copy -m \"#{log}\" \"#{src+"@"+rev}\" \"#{dst}\""
    cmd << " --username #{svn_user} --password #{svn_pwd}"
    cmd << " --parents --non-interactive "

    status, stdout, stderr = systemu cmd

    l.debug "***** cmd= "+cmd
    l.debug "**** status=" + status.to_s
    l.debug "**** stdout=" + stdout
    l.debug "**** stderr=" + stderr
    
    unless stderr.nil? || stderr==""
      err_msg = "Erro ao processar o comando no repositório. Erro: #{stderr}"
      l.info "Redmine GCO: "+err_msg+"Retorno: #{status.to_s} Comando: #{strip_credential(cmd)}"
      raise StandardError.new(err_msg)
    end

  end


  
end
