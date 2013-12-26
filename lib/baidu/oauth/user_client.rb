# encoding: UTF-8

module Baidu
  module OAuth
    class UserClient
      include Baidu::Support::Request

      def initialize(access_token_or_session)
        @access_token = case access_token_or_session
                        when String then access_token_or_session
                        when Baidu::Session then access_token_or_session.access_token
                        else
                          raise ArgumentError, 'need a String or Baidu::Session'
                        end
        @site = Baidu::OAuth::SITE
      end

      def get_logged_in_user
        post "#{BASE_PATH}/passport/users/getLoggedInUser", nil, base_query
      end

      def get_info(options={})
        body          = base_query
        body[:uid]    = options[:uid]
        body[:fields] = options[:fields]

        post "#{BASE_PATH}/passport/users/getInfo", nil, body
      end

      def app_user?(options={})
        body         = base_query
        body[:uid]   = options[:uid]
        body[:appid] = options[:appid]

        rest = post "#{BASE_PATH}/passport/users/isAppUser", nil, body
        rest[:result] == '1'
      end

      def has_app_permission?(ext_perm, uid=nil)
        body            = base_query
        body[:ext_perm] = ext_perm
        body[:uid]      = uid

        rest = post "#{BASE_PATH}/passport/users/hasAppPermission", nil, body
        rest[:result] == '1'
      end

      def has_app_permissions(ext_perms, uid=nil)
        body             = base_query
        body[:ext_perms] = ext_perms
        if ext_perms.is_a? Array
          body[:ext_perms] = ext_perms.join ','
        end
        body[:uid]       = uid

        rest = post "#{BASE_PATH}/passport/users/hasAppPermissions", nil, body
        rest.each { |k, v| rest[k] = v == '1' }
      end

      # TODO: check return value
      def get_friends(options={})
        post "#{BASE_PATH}/friends/getFriends", nil, base_query.update(options)
      end

      def are_friends(uids1, uids2)
        body = base_query
        case
        when uids1.is_a?(String) && uids2.is_a?(String)
          body[:uids1], body[:uids2] = uids1, uids2
        when uids1.is_a?(Array)  && uids2.is_a?(Array)
          raise ArgumentError, 'not the same size of array' unless uids1.size == uids2.size
          body[:uids1], body[:uids2] = uids1.join(','), uids2.join(',')
        else
          raise ArgumentError, 'not the same types'
        end

        rest = post "#{BASE_PATH}/friends/areFriends", nil, body
        rest.each do |h|
          h[:are_friends] = h[:are_friends] == '1'
          h[:are_friends_reverse] = h[:are_friends_reverse] == '1'
        end
      end

      def expire_session
        body = base_query
        rest = post "#{BASE_PATH}/passport/auth/expireSession", nil, body
        rest[:result] == '1'
      end

      def revoke_authorization(uid=nil)
        body = base_query.update(uid: uid)
        rest = post "#{BASE_PATH}/passport/auth/revokeAuthorization", nil, body
        rest[:result] == '1'
      end

      private

      def base_query
        { access_token: @access_token }
      end
    end
  end
end
