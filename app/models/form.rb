class Form < ApplicationRecord
  scope :by_muuid, ->(muuid) { where("muuid=?", muuid) }
  scope :by_duuid, ->(duuid) { where("duuid=?", duuid) }

  belongs_to :message, foreign_key: :muuid
  belongs_to :device, foreign_key: :duuid
end
