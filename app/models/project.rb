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

class Project < ActiveRecord::Base
  validates_presence_of     :name, :definition, :eta
  validates_numericality_of :eta, :greater_than => 0
  
  belongs_to :proposer, :class_name => "User", :foreign_key => "proposer_id"
  belongs_to :mentor, :class_name => "User", :foreign_key => "mentor_id"
  belongs_to :student, :class_name => "User", :foreign_key => "student_id"
  has_many :proposals
end