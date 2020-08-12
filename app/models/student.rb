class Student < ApplicationRecord
  before_save     :downcase_code
  belongs_to :school
  has_many :phones, inverse_of: :student
  has_and_belongs_to_many :users
  has_many :student_emails, inverse_of: :student, dependent: :delete_all
  accepts_nested_attributes_for :student_emails,
    :allow_destroy => true,
    :reject_if => proc { |att| att[:email].blank? }


  scope :by_codes, ->(codes) { where(code: codes) }
  scope :by_code, ->(code) { where(code: code) }
  scope :by_group, ->(id) { where("? = ANY(groups)", id) }


  include AlgoliaSearch

  algoliasearch synchronous: false do
    attribute :firstname, :lastname, :school_id, :classroom, :level, :code, :followers, :message_sent_by_email, :phones_count, :groups_to_index, :groups_to_index_ids
    attributesToIndex [:firstname, :lastname, :school_id, :classroom, :level, :code, :groups_to_index]
    attributesForFaceting ['searchable(classroom)', 'searchable(level)', 'searchable(groups_to_index)', 'filterOnly(groups_to_index_ids)']
    customRanking ['asc(level)', 'asc(lastname)']
    typoTolerance :false
  end


  def groups_to_index
    Group.where("id IN (?)", self.groups).pluck(:name)
  end

  def groups_to_index_ids
    Group.where("id IN (?)", self.groups).pluck(:id)
  end


  def message_sent_by_email
    self.sent_message_by_email and self.student_emails.count > 0
  end

  def phones_count
    self.phones.count
  end


  def fullname
    "#{self.firstname} #{self.lastname}"
  end

  private
      def downcase_code
        self.code.downcase! unless self.code.nil?
      end
end
