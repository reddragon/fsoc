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

class TaskTest < ActiveSupport::TestCase
  test "requires title" do 
    task = Factory(:task)
    task.title = ""
    assert !task.save, "Task requires title"
  end
  
  test "requires description" do
    task = Factory(:task)
    task.description = ""
    assert !task.save, "Task requires description"
  end
  
  test "requires eta" do
    task = Factory(:task)
    task.eta = ""
    assert !task.save, "Task requires eta"
  end
  
  test "numericality of eta" do
    task = Factory(:task)
    task.eta = -1
    assert !task.save, "eta should be greater than zero"
    
    task.eta = 0
    assert !task.save, "eta should be greater than zero"
  end

end
