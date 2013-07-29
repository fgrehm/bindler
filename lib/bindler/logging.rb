module VagrantPlugins
  module Bindler
    module Logging
      def bindler_debug(msg)
        @logger.debug "[BINDLER] #{msg}"
      end

      def bindler_info(msg)
        @logger.info "[BINDLER] #{msg}"
      end
    end
  end
end
