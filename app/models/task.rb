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

class Task < ActiveRecord::Base
  validates_presence_of :title, :description, :eta
  validates_numericality_of :eta, :greater_than => 0
  
  belongs_to :author, :class_name => "User", :foreign_key => "author_id"

  belongs_to :project
  belongs_to :proposal
  has_one :student, :through => :proposal
  has_one :mentor, :through => :project
  has_many :journals
end
