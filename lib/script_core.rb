# frozen_string_literal: true

require("forwardable")
require("msgpack")
require("open3")
require("pathname")

require("script_core/engine_error")
require("script_core/message_processor")
require("script_core/protocol")
require("script_core/result")
require("script_core/runner")
require("script_core/service_channel")
require("script_core/service_process")
require("script_core/spawner")
require("script_core/stat")
require("script_core/executable")
require("script_core/engine")

module ScriptCore
  DEFAULT_BIN_PATH = Pathname.new(__dir__).parent.join("bin")
  DEFAULT_EXECUTABLE_PATH = DEFAULT_BIN_PATH.join("enterprise_script_service")

  class << self
    extend Forwardable

    def default_executable
      @default_executable ||= ScriptCore::Executable.new DEFAULT_EXECUTABLE_PATH
    end

    def_delegator :default_executable, :run
  end
end
