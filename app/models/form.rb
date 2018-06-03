class Form < ApplicationRecord
  scope :by_muuid, ->(muuid) { where("muuid=?", muuid) }
  scope :by_duuid, ->(duuid) { where("duuid=?", duuid) }

  belongs_to :message, foreign_key: :muuid, primary_key: :muuid
  belongs_to :device, foreign_key: :duuid, primary_key: :duuid

  def to_json(options)
    I18n.l(self.created_at.in_time_zone, format: :long)
  end
end
