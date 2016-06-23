class User < ApplicationRecord
  def fullname
    "#{self.firstname} #{self.lastname}"
  end
end
