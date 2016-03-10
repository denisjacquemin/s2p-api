class Student < ApplicationRecord

  scope :by_codes, ->(codes) { where(code: codes) }

  def fullname
    "#{self.firstname} #{self.lastname}"
  end
end
