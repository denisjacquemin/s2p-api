class User < ApplicationRecord

  scope :by_codes, ->(codes) { where(code: codes) }
  scope :active, -> { where(deleted_at: nil) }


  def fullname
    "#{self.firstname} #{self.lastname}"
  end
end
