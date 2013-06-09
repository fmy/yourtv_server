class User < ActiveRecord::Base
  attr_accessible :provider, :uid, :name, :image_url

  def self.login(auth)
    where(auth.slice(:uid)).first_or_initialize.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.image_url = auth.info.image
      user.save!
    end
  end

end
