class Form < ApplicationRecord
  scope :by_muuid, ->(muuid) { where("muuid=?", muuid) }
  scope :by_duuid, ->(duuid) { where("duuid=?", duuid) }
end
