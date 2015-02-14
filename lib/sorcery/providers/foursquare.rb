module Sorcery
  module Providers
    # This class adds support for OAuth with foursquare.com.
    #
    #   config.foursquare.key = <key>
    #   config.foursquare.secret = <secret>
    #   ...
    #
    class Foursquare < Base

      include Protocols::Oauth2

      attr_accessor :auth_url, :token_url, :user_info_path, :mode, :param_name

      def initialize
        super

        @site           = 'https://foursquare.com'
        @user_info_path = 'https://api.foursquare.com/v2/users/self?v=20150214'
        @auth_url       = '/oauth2/authenticate'
        @token_url      = '/oauth2/access_token'
        @mode           = :query
        @param_name     = 'oauth_token'
      end

      def get_user_hash(access_token)
        response = access_token.get(user_info_path)

        auth_hash(access_token).tap do |h|
          h[:user_info] = JSON.parse(response.body)['response']['user']
          h[:uid] = h[:user_info]['id']
          h[:email] = h[:user_info]['contact']['email']
        end
      end

      # calculates and returns the url to which the user should be redirected,
      # to get authenticated at the external provider's site.
      def login_url(params, session)
        authorize_url({ authorize_url: auth_url })
      end

      # tries to login the user from access token
      def process_callback(params, session)
        args = {}.tap do |a|
          a[:code] = params[:code] if params[:code]
        end

        get_access_token(args, token_url: token_url, mode: mode, param_name: param_name)
      end

    end

  end
end
