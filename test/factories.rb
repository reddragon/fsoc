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

Factory.define :project do |f|
  f.name        "blah"
  f.definition  "blah blah"
  f.eta         10
end

Factory.define :proposal do |f|
  f.proposal_text   "blah"
  f.repository_link "http://www.blah.com" 
end

Factory.define :task do |f|
  f.title          "blah"
  f.description    "blah blah"
  f.eta            10
end
