# frozen_string_literal: true

require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class Krystal < OmniAuth::Strategies::OAuth2
      BASE_URL = ENV.fetch('KRYSTAL_IDENTITY_URL', 'https://identity.k.io')

      option :name, 'krystal'

      option :client_options,
             site: ENV.fetch('KRYSTAL_IDENTITY_API_URL', "#{BASE_URL}/api/v1"),
             authorize_url: ENV.fetch('KRYSTAL_IDENTITY_OAUTH_AUTHORIZE_URL', "#{BASE_URL}/oauth2/auth"),
             token_url: ENV.fetch('KRYSTAL_IDENTITY_OAUTH_TOKEN_URL', "#{BASE_URL}/oauth2/token")

      option :authorize_params,
             scope: 'user.profile'

      uid { raw_info['user']['id'] }

      info do
        {
          name: "#{raw_info['user']['first_name']} #{raw_info['user']['last_name']}",
          email: raw_info['user']['email_address']
        }
      end

      extra do
        {
          raw_info: raw_info,
          scope: scope,
          session_id: raw_info['session_id'],
          first_name: raw_info['user']['first_name'],
          last_name: raw_info['user']['last_name'],
          email_addresses: raw_info['user']['email_addresses'],
          roles: raw_info['user']['roles'],
          two_factor_auth_enabled: raw_info['user']['two_factor_auth_enabled']
        }
      end

      def scope
        access_token['scope']
      end

      def callback_url
        full_host + script_name + callback_path
      end

      def raw_info
        @raw_info ||= access_token.get('user').parsed
      end
    end
  end
end
