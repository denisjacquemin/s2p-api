class Group < ApplicationRecord

  scope :by_codes, ->(codes) { where(code: codes) }

end
