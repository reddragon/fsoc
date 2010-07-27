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

class ProposalTest < ActiveSupport::TestCase

  test "requires proposal text" do
    proposal = Factory(:proposal)
    proposal.proposal_text = ""
    assert !proposal.save, "Requires proposal text"
  end
  
  test "repository link format is valid" do
    proposal = Factory(:proposal)
    proposal.repository_link = "somethingthatisnotavalidurl"
    assert !proposal.save, "Repository link format should be valid"
  end
end
