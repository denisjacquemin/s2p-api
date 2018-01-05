class Message < ApplicationRecord
  # has_many :mfiles
  belongs_to :school
  belongs_to :author, class_name: "User"
  belongs_to :account

  has_attachments :photos, maximum: 10

  monetize :amount_to_pay_cents

  # http://stackoverflow.com/questions/6892044/add-virtual-attribute-to-json-output
  attr_accessor :student_names, :signature, :forms, :publish_date
  def attributes
    super.merge('student_names' => self.student_names, 'signature' => self.signature, 'forms' => self.forms, 'publish_date' => self.publish_date)
  end

  def publish_date
    publish_date = nil
    publish_date = self.updated_at if self.published?
    return publish_date
  end

  enum status: [:draft, :published, :waiting_for_approval, :approval_refused, :approval_accepted ]

  scope :published, -> { where(status: :published) }
  scope :by_group_ids, ->(group_ids) { where("groups && ARRAY[?]::integer[]", group_ids) }
  scope :by_student_ids, ->(student_ids) { where("students && ARRAY[?]::integer[]", student_ids) }
  scope :by_group_and_student_ids, ->(group_ids, student_ids) { where("groups && ARRAY[?]::integer[] or students && ARRAY[?]::integer[]", group_ids, student_ids) }
  scope :since, ->(date) { where("updated_at > ?", date) }
  scope :for_app, -> { where(send_to_app: true) }
end
