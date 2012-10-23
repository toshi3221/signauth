module Signauth
  module Signature
    module Version1

      def add_authorization!(credentials)
        params['access_key_id']     = credentials.access_key_id
        params['signature_version'] = '1'
        params['signature_method']  = 'HmacSHA256'

        params.delete('signature')
        params['signature'] = signature(credentials)
      end

      def authenticate(credentials)
        given    = params.delete('signature')
        computed = signature(credentials)
        unless given == computed
          raise Errors::SignatureDoesNotMatch,
            "Invalid signature: should have sent Base64(HmacSHA256(secret, #{string_to_sign.inspect}))"\
            ", but given #{given}"
        end
        true
      ensure
        params['signature'] = given
      end

      protected

      def signature(credentials)
        Signer.sign(credentials.secret_access_key, string_to_sign)
      end
      
      def string_to_sign
        [
          method.to_s.upcase,
          host.to_s.downcase,
          path.to_s,
          params.sort.collect { |n, v| encoded(n, v) }.join('&'),
        ].join("\n")
      end

      def encoded(name, value)
        "#{URI.escape(name)}=#{URI.escape(value)}"
      end

    end
  end
end
