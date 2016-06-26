class Student < ApplicationRecord
  before_save     :downcase_code

  scope :by_codes, ->(codes) { where(code: codes) }

  def fullname
    "#{self.firstname} #{self.lastname}"
  end

  private
      def downcase_code
        self.code.downcase!
      end
end
