# frozen_string_literal: true

require("forwardable")
require("msgpack")
require("open3")
require("pathname")

require("enterprise_script_service/engine_error")
require("enterprise_script_service/message_processor")
require("enterprise_script_service/protocol")
require("enterprise_script_service/result")
require("enterprise_script_service/runner")
require("enterprise_script_service/service_channel")
require("enterprise_script_service/service_process")
require("enterprise_script_service/spawner")
require("enterprise_script_service/stat")
require("enterprise_script_service/executable")
require("enterprise_script_service/engine")

module EnterpriseScriptService
  DEFAULT_BIN_PATH = Pathname.new(__dir__).parent.join("bin")
  DEFAULT_EXECUTABLE_PATH = DEFAULT_BIN_PATH.join("enterprise_script_service")

  class << self
    extend Forwardable

    def default_executable
      @default_executable ||= EnterpriseScriptService::Executable.new DEFAULT_EXECUTABLE_PATH
    end

    def_delegator :default_executable, :run
  end
end
