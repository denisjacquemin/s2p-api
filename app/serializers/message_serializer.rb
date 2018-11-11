class MessageSerializer < ActiveModel::Serializer
  attributes :id, :title, :publish_date, :content, :student_names, :muuid, :forms, :formdata, :signature, :photos

  def photos
    photos = object.photos.map do |photo|
      {
        id: photo.id,
        format: photo.format,
        resource_type: photo.resource_type,
        public_id: photo.public_id,
        width: photo.width,
        height: photo.height
      }
    end
  end

  def signature
    signature = {
      fullname: object.custom_author || object.author.fullname,
      function: object.author.function,
      schoolname: object.school.name,
      address: object.school.address,
      url: object.school.url,
      phone: object.school.phone,
      logo_url: object.school.file_url
    }
    signature.merge!(email: object.author.reply_to) if object.author.display_email_address

    return signature
  end
end
