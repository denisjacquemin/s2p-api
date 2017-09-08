desc "Sync students followers from devices"
task :sync_students_followers => :environment do
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  Student.all.each do |student|
    followers_count = Device.by_codes(student.code).count
    student.update(followers: followers_count)
  end
end
