class UpdateFollowersJob < ApplicationJob
  queue_as :default

  def perform(old_device_codes, new_device_codes)
    logger.debug "execute UpdateFollowersJob.perform(#{old_device_codes}, #{new_device_codes})"
    students_ids_to_decrement = old_device_codes - new_device_codes
    students_ids_to_increment = new_device_codes - old_device_codes

    Student.by_code(students_ids_to_decrement).select(:id).each do |student|
      student.decrement(:followers)
      student.save
    end

    Student.by_code(students_ids_to_increment).select(:id).each do |student|
      student.increment(:followers)
      student.save
    end

  end
end
