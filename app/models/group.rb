class Group < ApplicationRecord
  belongs_to :school

  scope :by_codes, ->(codes) { where(code: codes) }

  def students
    Student.by_group(self.id)
  end

end
