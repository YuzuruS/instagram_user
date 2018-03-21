require 'mechanize'
require 'selenium-webdriver'
require 'json'
require 'instagram_user/version'

module InstagramUser
  class Client

    BASE_URL              = 'https://www.instagram.com/graphql/query/?query_hash=%s&variables=%s'.freeze
    LOGIN_URL             = 'https://www.instagram.com/accounts/login/ajax/'.freeze
    USER_INFO_URL         = 'https://www.instagram.com/%s/?__a=1'.freeze
    MEDIA_JSON_BY_TAG_URL = 'https://www.instagram.com/explore/tags/%s/?__a=1&max_id=%s'.freeze
    DEFAULT_USER_AGENT    = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.84 Safari/537.36'.freeze
    DEFAULT_REFERER       = 'https://www.instagram.com/'.freeze

    USER_MAP = {
      follow: {
        query_hash: '58712303d941c6855d4e888c5f0cd22f',
        edge:       'edge_follow'
      },
      follower: {
        query_hash: '37479f2b8209594dde7facb0d904896a',
        edge:       'edge_followed_by'
      }
    }.freeze

    def initialize(options = {})
      @user_name     = (ENV['INSTAGRAM_USER_NAME']  || options[:user_name])
      @password      = (ENV['INSTAGRAM_PASSWORD']   || options[:password])
      @user_agent    = (ENV['INSTAGRAM_USER_AGENT'] || options[:user_agent] || DEFAULT_USER_AGENT)
      @referer       = (ENV['INSTAGRAM_REFERER']    || options[:referer]    || DEFAULT_REFERER)
      @session       = Mechanize.new
      @user_ids      = {}

      return if @user_name.nil? || @password.nil?
      mechanize_login_setting
      selenium_login_setting unless options[:selenium] == false
    end

    def get_follows(user_name, num_users = 3000)
      user_id = @user_ids[user_name].nil? ? get_user_id(user_name) : @user_ids[user_name]
      fetch_all_user_names(user_id, USER_MAP[:follow], num_users)
    end

    def get_followers(user_name, num_users = 3000)
      user_id = @user_ids[user_name].nil? ? get_user_id(user_name) : @user_ids[user_name]
      fetch_all_user_names(user_id, USER_MAP[:follower], num_users)
    end

    def create_follow(user_name)
      color = get_follow_btn_color(user_name)

      return false if color == false || color != "rgba(255, 255, 255, 1)"

      @driver.find_element(:xpath, '//article//button').click
      sleep(2)

      color = get_follow_btn_color(user_name)
      (color == false || color == "rgba(255, 255, 255, 1)") ? false : true
    end

    def delete_follow(user_name)
      color = get_follow_btn_color(user_name)

      return false if color == false || color == "rgba(255, 255, 255, 1)"

      @driver.find_element(:xpath, '//article//button').click
      sleep(2)

      color = get_follow_btn_color(user_name)
      (color == false || color != "rgba(255, 255, 255, 1)") ? false : true
    end

    def get_medias_by_tag(tag_name, req_num = 1)
      max_id = nil
      tags   = {"recent" => [], "popularity" => []}

      req_num.times do
        url = format MEDIA_JSON_BY_TAG_URL, tag_name, max_id
        page = @session.get(url)
        json = JSON.parse(page.body)
        hastags = json["graphql"]["hashtag"]
        tags["recent"]    += hastags["edge_hashtag_to_media"]["edges"]
        tags["popularity"] = hastags["edge_hashtag_to_top_posts"]["edges"] if max_id.nil?
        break unless hastags["edge_hashtag_to_media"]["page_info"]["has_next_page"]
        max_id = hastags["edge_hashtag_to_media"]["page_info"]["end_cursor"]
      end
      tags
    end

    private

    def get_follow_btn_color(user_name)
      @driver.get "https://www.instagram.com/#{user_name}"
      begin
        @wait.until { !@driver.find_elements(:xpath, '//article//button').empty? }
      rescue => e
        return false
      end
      @driver.find_element(:xpath, '//article//button').css_value("color")
    end

    def selenium_login_setting
      options = Selenium::WebDriver::Chrome::Options.new
      options.add_argument("--user-agent=#{@user_agent}")
      options.add_argument('--headless')
      @driver = Selenium::WebDriver.for :chrome, options: options
      @driver.get 'https://www.instagram.com/'
      @session.cookie_jar.cookies.each do |c|
        cookie_hash = {
          name:       c.name,
          value:      c.value,
          path:       c.path,
          secure:     c.secure,
          expires:    c.expires,
          domain:     c.domain,
          for_domain: c.for_domain,
          httponly:   c.httponly,
          max_age:    c.max_age,
          created_at: c.created_at,
          accessed_at: c.accessed_at,
          origin: c.origin.to_s
        }
        @driver.manage.add_cookie(cookie_hash)
      end
      @wait   = Selenium::WebDriver::Wait.new(timeout: 60)
    end

    def get_user_id(user_name)
      url = format USER_INFO_URL, user_name
      page = @session.get(url)
      json = JSON.parse(page.body)
      @user_ids[user_name] = json["graphql"]["user"]["id"]
      @user_ids[user_name]
    end

    def mechanize_login_setting
      @session.request_headers = login_http_headers
      @session.post(LOGIN_URL, user_info)
    end

    def login_http_headers
      default_http_headers.update(
        "x-csrftoken" => "null",
        "cookie"      => "sessionid=null; csrftoken=null"
      )
    end

    def default_http_headers
      {
          "user-agent" => @user_agent,
          "referer"    => @referer
      }
    end

    def user_info
      {
        username: @user_name,
        password: @password
      }
    end

    def fetch_all_user_names(user_id, request_params, num_users)
      after      = nil
      user_names = []

      loop do
        res = fetch_user_names(user_id, request_params, num_users, after)
        user_names += res[:user_names]
        break unless res[:has_next]
        after = res[:after]
      end
      user_names
    end

    def fetch_user_names(user_id, request_params, num_users, after)
      variables = {
        id:    user_id,
        first: num_users
      }
      variables[:after] = after unless after.nil?
      url = format BASE_URL, request_params[:query_hash], JSON.generate(variables)
      @session.request_headers = default_http_headers
      page = @session.get(url)
      json = JSON.parse(page.body)
      edge = json["data"]["user"][request_params[:edge]]
      {
        after:      edge["page_info"]["end_cursor"],
        has_next:   edge["page_info"]["has_next_page"],
        user_names: edge["edges"].map{ |f| f["node"]["username"] }
      }
    end
  end
end