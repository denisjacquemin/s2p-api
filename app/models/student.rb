class Student < ApplicationRecord
  before_save     :downcase_code
  belongs_to :school
  has_many :phones, inverse_of: :student
  scope :by_codes, ->(codes) { where(code: codes) }
  scope :by_code, ->(code) { where(code: code) }

  include AlgoliaSearch

  algoliasearch synchronous: false do
    attribute :firstname, :lastname, :school_id, :classroom, :level, :code, :followers, :message_sent_by_email, :phones_count
    attributesToIndex [:firstname, :lastname, :school_id, :classroom, :level, :code]
    attributesForFaceting ['searchable(classroom)', 'searchable(level)']
    customRanking ['asc(level)', 'asc(lastname)']
    typoTolerance :false
  end

  def message_sent_by_email
    self.sent_message_by_email and self.emails.present?
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
