class Message < ApplicationRecord
  has_many :mfiles
  belongs_to :school
  belongs_to :author, class_name: "User"

  # http://stackoverflow.com/questions/6892044/add-virtual-attribute-to-json-output
  attr_accessor :students, :signature
  def attributes
    super.merge('students' => self.students, 'signature' => self.signature)
  end


  scope :published, -> { where.not(publish_date: nil) }
  scope :by_group_ids, ->(group_ids) { where("groups && ARRAY[?]::integer[]", group_ids) }
  scope :since, ->(date) { where("updated_at > ?", date) }
  scope :for_app, -> { where(send_to_app: true) }
end
