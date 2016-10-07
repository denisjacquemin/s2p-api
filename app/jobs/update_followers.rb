class UpdateFollowersJob < ApplicationJob
  queue_as :default

  def perform(old_device_codes, new_device_codes)
    logger.debug "execute UpdateFollowersJob.perform(#{old_device_codes}, #{new_device_codes})"
    students_ids_to_decrement = old_device_codes - new_device_codes
    students_ids_to_increment = new_device_codes - old_device_codes

    logger.debug "students_ids_to_decrement: #{students_ids_to_decrement}"
    logger.debug "students_ids_to_increment: #{students_ids_to_increment}"
    Student.by_code(students_ids_to_decrement).select(:id).each do |student|
      logger.debug "decrement #{student.followers} for student #{student.inspect}"
      student.decrement(:followers)
      student.save
    end

    Student.by_code(students_ids_to_increment).select(:id).each do |student|
      logger.debug "increment #{student.followers} for student #{student.inspect}"
      student.increment(:followers)
      student.save
    end

  end
end
