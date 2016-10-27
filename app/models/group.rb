class Group < ApplicationRecord
  belongs_to :school

  scope :by_codes, ->(codes) { where(code: codes) }

end
