Facebooker2.load_facebooker_yaml


module Facebooker2
  module Rails
    module Controller
      def fb_cookie_signature_correct?(hash,secret)
        puts "hash: #{hash}, secret: #{secret}, generate_sig: #{generate_signature(hash,secret)}, hash[sig]: #{hash['sig']}"
        generate_signature(hash,secret) == hash["sig"]
      end
    end
  end
end