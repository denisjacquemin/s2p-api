class Student < ApplicationRecord

  scope :by_codes, ->(codes) { where(code: codes) }

end
