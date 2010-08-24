#--
#   Copyright (C) 2010 Shreyank Gupta <sgupta@REDHAT.COM>
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#++

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def highlighted
    return 'class="current_page_item"'
  end
  
  def devide_link(links)
    if !(links.nil? || links == '')
      out = []
      links.split(',').each do |link|
        out << link_to(link, link, :popup=> true)
      end
      out
    else
      '-'
    end
  end
  
  def dash(obj, replacement='-')
    if obj.nil? or obj == ""
      replacement
    elsif obj.respond_to?("each")
      sum = ""
      obj.each do |o|
        if o.nil? or o == ""
          return replacement
        else
          sum += o
        end
      end
      sum
    else
      obj
    end
  end
  
  def all_projects
    return Project.all.reverse
  end
  
  def verb(proposal)
    if proposal.status == 'accepted'
      'Allocate more tasks'
    else
      'Accept and allocate tasks'
    end
  end
  
  def enquote(str)
    lines = str.split(/<br \/>/)
    res = ""
    lines.each do |line|
      res = res + "\n> " + line
    end
    res
  end
  
  def wrap(txt, col = 75)
    txt.gsub(/(.{1,#{col}})( +|$\n?)|(.{1,#{col}})/,
     "\\1\\3\n") 
  end
  
  def display_message_content(txt)
    lines = txt.split(/<br \/>/)
    res = ""
    lines.each do |line|
      if line[0] == 62
        res = res + "<font color = 'blue'>" + line + "</font>" + '<br />'
      else
        res = res + line + '<br />'
      end 
    end
    res
  end
  
  def colored_task_status(task)
    color_map = { "new" => "gray", "open" => "orange", "resolved" => "green", "signed_off" => "blue" } 
    if task.due_date != nil
      color = color_map[task.status]
      if (task.status != "resolved" && task.status != "signed_off") && task.due_date < Date.today
        color = "red"
      end
      status = task.status
    else
      color = "black"
      status = "Unallocated"  
    end
    
    
    res = "<font color = '#{color}'>" + status.humanize + "</font>"
  end
  
end
