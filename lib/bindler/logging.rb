module VagrantPlugins
  module Bindler
    module Logging
      def bindler_debug(msg)
        @logger.debug "[BINDLER] #{msg}"
      end
    end
  end
end
