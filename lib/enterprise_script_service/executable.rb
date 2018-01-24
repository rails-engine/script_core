# frozen_string_literal: true

module EnterpriseScriptService
  class Executable
    attr_reader :executable_path

    def initialize(executable_path)
      unless File.exist? executable_path
        raise EnterpriseScriptService::ExecutableNotFound.new(executable_path),
              "Executable not found, make sure you've compiled the engine and give an exists path"
      end
      @executable_path = executable_path.to_s
    end

    def run(input:, sources:, instructions: nil, timeout: 1, instruction_quota: 100_000, instruction_quota_start: 0, memory_quota: 8 << 20)
      packer = EnterpriseScriptService::Protocol.packer_factory.packer

      payload = {input: input, sources: sources}
      payload[:library] = instructions if instructions
      encoded = packer.pack(payload)

      packer = EnterpriseScriptService::Protocol.packer_factory.packer
      size = packer.pack(encoded.size)

      spawner = EnterpriseScriptService::Spawner.new
      service_process = EnterpriseScriptService::ServiceProcess.new(
        executable_path,
        spawner,
        instruction_quota,
        instruction_quota_start,
        memory_quota
      )
      runner = EnterpriseScriptService::Runner.new(
        timeout: timeout,
        service_process: service_process,
        message_processor_factory: EnterpriseScriptService::MessageProcessor
      )
      runner.run(size, encoded)
    end
  end
end
