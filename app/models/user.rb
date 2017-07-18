class User < ApplicationRecord

  scope :by_codes, ->(codes) { where(code: codes) }
  scope :active, -> { where(deleted_at: nil) }

  def reply_to
    if self.email_reply_to.blank?
      return self.email
    else
      return self.email_reply_to
    end
  end

  def fullname
    "#{self.firstname} #{self.lastname}"
  end
end
