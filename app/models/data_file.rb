class DataFile < ActiveRecord::Base
  def self.save(upload, directory, name, operand)
    # create the file path
    path = File.join(directory, name)
    # write the file
    File.open(path, "wb") { |f| f.write(upload[operand].read) }
  end
end
