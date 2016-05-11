class Device < ApplicationRecord


# http://stackoverflow.com/questions/24236871/in-rails-how-to-add-an-element-to-an-array-type-attribute-for-all-records
# http://www.postgresql.org/docs/current/static/arrays.html
# http://www.postgresql.org/docs/current/static/functions-array.html
def add_code(code)
  #self.update_all(['codes = array_append(codes, ?)', code])
  Device.where(token: self.token).update_all(['codes = array_append(codes, ?)', code])
end

def remove_code(code)
  Device.where(token: self.token).update_all['codes = array_remove(codes, ?)', code])
end

# def self.remove_group(student_ids, group_ids)
#   Student.by_ids(student_ids).update_all(['groups = array_remove(groups, ?)', group_ids])
# end
end
