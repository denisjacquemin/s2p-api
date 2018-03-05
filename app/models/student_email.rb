class StudentEmail < ApplicationRecord
  belongs_to :student, inverse_of: :student_emails
end
