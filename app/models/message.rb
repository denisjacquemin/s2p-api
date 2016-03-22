class Message < ApplicationRecord

  scope :published, -> { where.not(publish_date: nil) }
  scope :by_group_ids, ->(group_ids) { where("groups && ARRAY[?]::integer[]", group_ids) }
  scope :since, ->(date) { where("updated_at > ?", date) }
end
