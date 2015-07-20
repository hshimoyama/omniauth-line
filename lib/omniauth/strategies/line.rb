require 'omniauth-oauth2'
require 'httpauth'

module OmniAuth
  module Strategies
    class Line < OmniAuth::Strategies::OAuth2

      option :name, 'line'
      option :client_options, {
               :site => 'https://api.line.me',
               :authorize_url => 'https://access.line.me/dialog/oauth/weblogin',
               :token_url => '/v1/oauth/accessToken'
             }

      def request_phase
        super
      end

      uid { raw_info['mid'] }

      info do
        prune!(
          { :display_name   => raw_info['displayName'],
            :picture_url    => raw_info['pictureUrl'],
            :status_message => raw_info['statusMessage'],
          }
        )
      end

      extra do
        hash = {}
        hash[:raw_info] = raw_info unless skip_info?
        prune! hash
      end

      def raw_info
        @raw_info ||= access_token.get('https://api.line.me/v1/profile').parsed
      end

      def prune!(hash)
        hash.delete_if do |_, value|
          prune!(value) if value.is_a?(Hash)
          value.nil? || (value.respond_to?(:empty?) && value.empty?)
        end
      end

      def build_access_token
        token_params = {
          :grant_type    => 'authorization_code',
          :client_id     => client.id,
          :client_secret => client.secret,
          :code          => request.params['code'],
          :redirect_uri  => callback_url,
        }

        client.get_token(token_params);
      end

    end
  end
end
