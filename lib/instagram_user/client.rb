require 'mechanize'
require 'json'
require 'instagram_user/version'

module InstagramUser
  class Client

    BASE_URL              = 'https://www.instagram.com/graphql/query/?query_hash=%s&variables=%s'.freeze
    LOGIN_URL             = 'https://www.instagram.com/accounts/login/ajax/'.freeze
    USER_INFO_URL         = 'https://www.instagram.com/%s/?__a=1'.freeze
    DEFAULT_USER_AGENT    = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.84 Safari/537.36'.freeze
    DEFAULT_MAX_NUM_USERS = 3000
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
      @num_users     = (ENV['INSTAGRAM_NUM_USERS']  || options[:num_users]  || DEFAULT_MAX_NUM_USERS)
      @session       = Mechanize.new
      @user_ids      = {}
      logined_session
    end

    def get_follows(user_name)
      user_id = @user_ids[user_name].nil? ? get_user_id(user_name) : @user_ids[user_name]
      fetch_all_user_names(user_id, USER_MAP[:follow])
    end

    def get_followers(user_name)
      user_id = @user_ids[user_name].nil? ? get_user_id(user_name) : @user_ids[user_name]
      fetch_all_user_names(user_id, USER_MAP[:follower])
    end

    private

    def get_user_id(user_name)
      url = USER_INFO_URL % [user_name]
      page = @session.get(url)
      json = JSON.parse(page.body)
      @user_ids[user_name] = json["user"]["id"]
      @user_ids[user_name]
    end

    def logined_session
      @session.request_headers = login_http_headers
      @session.post(LOGIN_URL, user_info)
    end

    def login_http_headers
      {
        "user-agent"  => @user_agent,
        "referer"     => @referer,
        "x-csrftoken" => "null",
        "cookie"      => "sessionid=null; csrftoken=null"
      }
    end

    def username_http_headers
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

    def fetch_all_user_names(user_id, request_params)
      after      = nil
      user_names = []

      loop do
        res = fetch_user_names(user_id, request_params, after)
        user_names += res[:user_names]
        break unless res[:has_next]
        after = res[:after]
      end
      user_names
    end

    def fetch_user_names(user_id, request_params, after = nil)
      variables = {
        id:    user_id,
        first: @num_users
      }
      variables[:after] = after unless after.nil?
      url = BASE_URL % [request_params[:query_hash], JSON.generate(variables)]
      @session.request_headers = username_http_headers
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