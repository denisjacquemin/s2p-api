class UpdateFollowersJob < ApplicationJob
  queue_as :default

  def perform(old_device_codes, new_device_codes)
    logger.debug "$UpdateFollowersJob$ execute UpdateFollowersJob.perform(#{old_device_codes}, #{new_device_codes})"
    # collect all codes on which followers counter should be refreshed
    codes_to_refresh = (old_device_codes + new_device_codes).uniq
    logger.debug "$UpdateFollowersJob$ codes_to_refresh: #{codes_to_refresh}"
    students_to_refresh = Student.by_codes(codes_to_refresh)
    logger.debug "$UpdateFollowersJob$ students_to_refresh: #{students_to_refresh.inspect()}"
    logger.debug "$UpdateFollowersJob$ students_to_refresh.size: #{students_to_refresh.size}"
    students_to_refresh.each do |student|
      logger.debug "$UpdateFollowersJob$ finding number of followers for student #{student.code}"
      # check the number of device dollowing the student
      followers_count = Device.by_codes(student.code).count
      logger.debug "$UpdateFollowersJob$student #{student.code} followers is #{followers_count}"

      student.update(followers: followers_count)
    end
    logger.debug "$UpdateFollowersJob$ Job done"
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
