module VagrantPlugins
  module Vundler
    module Logging
      def vundler_debug(msg)
        @logger.debug "[VUNDLER] #{msg}"
      end
    end
  end
end
