class Student < ApplicationRecord
  before_save     :downcase_code

  scope :by_codes, ->(codes) { where(code: codes) }
  scope :by_code, ->(code) { where(code: code) }

  def fullname
    "#{self.firstname} #{self.lastname}"
  end

  def follow
    self.increment(:followers)
    self.save
  end

  def unfollow
    self.decrement(:followers)
    self.save
  end

  private
      def downcase_code
        self.code.downcase!
      end
end
