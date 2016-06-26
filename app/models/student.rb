class Student < ApplicationRecord

  scope :by_codes, ->(codes) { where(code: codes) }

  def fullname
    "#{self.firstname} #{self.lastname}"
  end

  def code
    self.code.downcase
  end
end
