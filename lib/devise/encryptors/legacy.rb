module Devise
  module Encryptable
    module Encryptors
      class Legacy < Base

        def self.digest(password, stretches, salt, pepper)
          digest = pepper
          stretches.times do
            digest = secure_digest(digest, salt, password, pepper)
          end
          digest
        end

        private

        def self.secure_digest(*args)
          Digest::SHA1.hexdigest(args.flatten.join('--'))
        end

      end
    end
  end
end
