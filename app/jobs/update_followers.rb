class UpdateFollowersJob < ApplicationJob
  queue_as :default

  def perform(old_device_codes, new_device_codes)
    logger.debug "execute UpdateFollowersJob.perform(#{old_device_codes}, #{new_device_codes})"
    # collect all codes on which followers counter should be refreshed
    codes_to_refresh = (old_device_codes + new_device_codes).uniq
    logger.debug "codes_to_refresh: #{codes_to_refresh}"
    students_to_refresh = Student.by_codes(codes_to_refresh)
    logger.debug "students_to_refresh: #{students_to_refresh.inspect()}"

    students_to_refresh.each do |student|
      # check the number of device dollowing the student
      followers_count = Device.by_code(student.code)
      logger.debug "student #{student.code} followers is #{followers_count}"
      student.update(followers: followers_count)
    end

    # students_ids_to_decrement = old_device_codes - new_device_codes
    # students_ids_to_increment = new_device_codes - old_device_codes
    #
    # #logger.debug "students_ids_to_decrement: #{students_ids_to_decrement}"
    # #logger.debug "students_ids_to_increment: #{students_ids_to_increment}"
    # Student.by_code(students_ids_to_decrement).each do |student|
    #   logger.debug "decrement #{student.followers} for student #{student.inspect}"
    #   if (student.followers > 0)
    #     student.decrement(:followers)
    #     student.save
    #   end
    # end
    #
    # Student.by_code(students_ids_to_increment).each do |student|
    #   logger.debug "increment #{student.followers} for student #{student.inspect}"
    #   student.increment(:followers)
    #   student.save
    # end

  end
end
