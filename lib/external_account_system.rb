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

module ExternalAccountSystem
  #Contains methods that links FSoC with an external account system
  
  #This method is called to validate the username/password pair
  def authenticated_externally?(username, password)
    fas_url = "https://admin.fedoraproject.org/accounts/home"

    curlobj = Curl::Easy.new(fas_url)

    pf_login = Curl::PostField.content('login', 'Login')
    pf_username = Curl::PostField.content('user_name', username)
    pf_password = Curl::PostField.content('password', password)

    curlobj.http_post(pf_login, pf_username, pf_password)

    if curlobj.response_code == 200
      return true
    else
      return false
    end
  end
  
  def self.included(base)
      if base.respond_to? :helper_method
        base.send :helper_method, :authenticated_externally?
      end
  end
end
