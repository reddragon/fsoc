#!/usr/bin/env ruby

# checkpassword.rb -- Checks whether a username-password pair exists in FAS
# https://admin.fedoraproject.org/accounts/

# Usage: $ ./checkpassword.rb <fas_username> <fas_password>

# Dependencies: 

# rubygems
# libcurl-devel (required to gem install curb)
# curb - gem install curb

# Copyright (C) 2010 Shreyank Gupta <sgupta@REDHAT.COM>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA



require 'rubygems'
require 'curb'

username = ARGV[0]
password = ARGV[1]

fas_url = "https://admin.fedoraproject.org/accounts/home"

curlobj = Curl::Easy.new(fas_url)

pf_login = Curl::PostField.content('login', 'Login')
pf_username = Curl::PostField.content('user_name', username)
pf_password = Curl::PostField.content('password', password)

curlobj.http_post(pf_login, pf_username, pf_password)

#If the script terminates properly, authentication is assumed to be successful.
if curlobj.response_code == 200
  puts "Authenticated"
else
  puts "Failed to Authenticate"
  return 1
end
