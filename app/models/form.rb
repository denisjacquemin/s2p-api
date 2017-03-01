class Form < ApplicationRecord
  scope :by_muuid, ->(muuid) { where("muuid=?", muuid) } 
end
