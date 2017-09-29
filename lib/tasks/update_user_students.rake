# each time a student is created or students.groups is updated_at
# take car of all users to updates their user.students
desc "Update User.students"
task :update_user_students => :environment do
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  groups = Student.where("updated_at > ?", 2.days.ago).collect do |student|
    student.groups
  end

  list_of_groups_to_update = groups.flatten.compact.uniq

  users_to_update = User.all.select do |u|
    u.groups.pluck(:id).any? { |group_ids| list_of_groups_to_update.include?(group_ids) }
  end

  users_to_update.each do |user_to_update|
    puts "User to update: " + user_to_update.fullname
  end
end
