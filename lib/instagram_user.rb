require "instagram_user/client"

module InstagramUser
  def self.new(options = {})
    InstagramUser::Client.new(options)
  end
end
