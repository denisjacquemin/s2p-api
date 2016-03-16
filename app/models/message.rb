class Message < ApplicationRecord

  scope :by_group_ids, ->(group_ids) { where("groups && ARRAY[?]::integer[]", group_ids) }
  scope :since, ->(date) { where("updated_at > ?", date) }
end
