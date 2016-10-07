class Device < ApplicationRecord

  validates :uuid, uniqueness: true

  after_save :update_followers, if: "codes_changed?"

  enum notification_platform: [:ios, :android]

  # http://stackoverflow.com/questions/24236871/in-rails-how-to-add-an-element-to-an-array-type-attribute-for-all-records
  # http://www.postgresql.org/docs/current/static/arrays.html
  # http://www.postgresql.org/docs/current/static/functions-array.html
  def add_code(code)
    #self.update_all(['codes = array_append(codes, ?)', code])
    codes_will_change!
    Device.where(uuid: self.uuid).update_all(['codes = array_append(codes, ?)', code])
  end

  def remove_code(code)
    codes_will_change!
    Device.where(uuid: self.uuid).update_all(['codes = array_remove(codes, ?)', code])
  end

  def disable
    self.update(active: false)
  end

  def enable
    self.update(active: true)
  end

  def update_followers
    logger.debug "update_followers"
    UpdateFollowersJob.perform_later(self.codes_was, self.codes)
  end

  # def self.remove_group(student_ids, group_ids)
  #   Student.by_ids(student_ids).update_all(['groups = array_remove(groups, ?)', group_ids])
  # end
end
