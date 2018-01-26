# frozen_string_literal: true

module EnterpriseScriptService
  class Engine
    attr_accessor :timeout, :instruction_quota, :instruction_quota_start, :memory_quota, :instructions

    def initialize(bin_path = EnterpriseScriptService::DEFAULT_BIN_PATH, executable_name: "enterprise_script_service",
                   instructions_name: "enterprise_script_service.mrb")
      raise Errno::ENOENT, "No such directory - #{bin_path}" unless File.directory?(bin_path)
      @bin_path = bin_path

      @executable = EnterpriseScriptService::Executable.new(@bin_path.join(executable_name))
      @timeout = 1
      @instruction_quota = 100_000
      @instruction_quota_start = 0
      @memory_quota = 8 << 20

      preload_instructions_path = @bin_path.join(instructions_name)
      @instructions = File.exist?(preload_instructions_path) ? File.binread(preload_instructions_path) : nil
    end

    def eval(sources, payload: nil)
      @executable.run(
        input: payload || {},
        sources: sources || [],
        instructions: @instructions,
        timeout: @timeout,
        instruction_quota: @instruction_quota,
        instruction_quota_start: @instruction_quota_start,
        memory_quota: @memory_quota
      )
    end
  end
end
