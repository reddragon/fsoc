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

require "prawn/core"
  
  Prawn::Document.generate("certificate.pdf", \
    :page_layout => :landscape) do |pdf|
    
    logo = "#{RAILS_ROOT}/public/images/certificate/complete_logo.png" 
    #Callibrate the pixel positions according to the image
    pdf.image logo, :at => [90,550]
    
    #The following line breaks the PDF layout
    #pdf.image logo, :align => :center
    
    watermark = "#{RAILS_ROOT}/public/images/certificate/watermark.png"
    #Callibrate the pixel positions according to the image
    pdf.image watermark, :at => [250,350] 
    
    pdf.move_down 190
    pdf.text "This certificate is awarded to,", :align => :center, :size => 20
    pdf.move_down 40
    pdf.text "#{@proposal.student.name}", :align => :center, :size => 40, :style => :bold
    pdf.move_down 40
    pdf.text "For successfully completing the project\n\
      #{@proposal.project.name}", \
      :align => :center, :size => 20
    pdf.text "in the #{APP_CONFIG['program']['name']} #{APP_CONFIG['program']['edition']} program.", \
      :align => :center, :size => 20
      
    #pdf.move_down 80
    pdf.draw_text "#{@proposal.project.mentor.name}", :size => 15, :at => [20, 20]
    pdf.draw_text "#{APP_CONFIG['admin']['name']}", :size => 15, :at => [550,20]
    #pdf.move_down 5
    pdf.draw_text "Mentor", :at => [20, 10]
    pdf.draw_text "#{APP_CONFIG['admin']['designation']}", :at => [550, 10] 
    
  end
