require "spec_helper"
require "instagram_user"

RSpec.describe InstagramUser do
  before do
    @user_name = 'yuzuru_dev'
    @password = 'gkK9.izwZGBysV82uowpE+JqYzztgVA9'
    @cli = InstagramUser.new(
      user_name: @user_name,
      password: @password,
      selenium: false
    )
  end

  it "has a version number" do
    expect(InstagramUser::VERSION).not_to be nil
  end

  it "get follows" do
    follows = @cli.get_follows(@user_name)
    expect(follows.include?('instagram')).to eq true
  end

  it "get followers 1" do
    follows = @cli.get_followers(@user_name)
    expect(follows.include?('instagram')).to eq false
  end

  it "get followers 2" do
    follows = @cli.get_followers(@user_name)
    expect(follows.include?('yudsuzuk')).to eq true
  end
end

