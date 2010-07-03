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
    pdf.text "in the #{APP_CONFIG['programname']} program.", \
      :align => :center, :size => 20
      
    #pdf.move_down 80
    pdf.draw_text "#{@proposal.project.mentor.name}", :size => 15, :at => [20, 20]
    pdf.draw_text "#{APP_CONFIG['adminname']}", :size => 15, :at => [550,20]
    #pdf.move_down 5
    pdf.draw_text "Mentor", :at => [20, 10]
    pdf.draw_text "#{APP_CONFIG['admindesignation']}", :at => [550, 10] 
    
  end
