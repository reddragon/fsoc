#--
#   Copyright (C) 2010 Gaurav Menghani <gaurav.menghani@gmail.com>
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

require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../factories'

class ProjectTest < ActiveSupport::TestCase
  
  test "requires name" do 
    project = Factory(:project)
    project.name = ""
    assert !project.save, "Project requires name"
  end
  
  test "requires definition" do
    project = Factory(:project)
    project.definition = ""
    assert !project.save, "Project requires definition"
  end
  
  test "requires eta" do
    project = Factory(:project)
    project.eta = ""
    assert !project.save, "Project requires eta"
  end
  
  test "numericality of eta" do
    project = Factory(:project)
    project.eta = -1
    assert !project.save, "eta should be greater than zero"
    
    project.eta = 0
    assert !project.save, "eta should be greater than zero"
  end
  
end
