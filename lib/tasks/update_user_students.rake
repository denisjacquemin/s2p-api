# each time a student is created or students.groups is updated_at
# take car of all users to updates their user.students
desc "Update User.students"
task :update_user_students => :environment do
  ActiveRecord::Base.logger = Logger.new(STDOUT)

  # # find all student that have been updated since 2 days
  # # gets their groups
  # groups = Student.where("updated_at > ?", 1.days.ago).collect do |student|
  #   student.groups
  # end
  #
  # list_of_groups_to_update = groups.flatten.compact.uniq
  #
  # users_to_update = User.all.select do |u|
  #   u.groups.pluck(:id).any? { |group_ids| list_of_groups_to_update.include?(group_ids) }
  # end
  #
  # users_to_update.each do |user_to_update|
  #   students_ids = Group.where(id: user.groups).collect {|g| g.students.pluck(:id)}.flatten.compact.uniq
  #   puts "User to update: " + user_to_update.fullname + " students_ids #{students_ids
  #   }"
  # end

  # for all users rebuild students list
  User.all.each do |user|
    students_ids = Group.where(id: user.group_ids).collect {|g| g.students}.flatten.compact.uniq
    user.students = students_ids
  end

end
