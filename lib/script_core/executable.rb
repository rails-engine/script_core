# frozen_string_literal: true

module ScriptCore
  class Executable
    attr_reader :executable_path

    def initialize(executable_path)
      unless File.exist? executable_path
        raise ScriptCore::ExecutableNotFound.new(executable_path),
              "Executable not found, make sure you've compiled the engine and give an exists path"
      end
      @executable_path = executable_path.to_s
    end

    def run(input:, sources:, instructions: nil,
            timeout: 1, instruction_quota: 100_000, instruction_quota_start: 0, memory_quota: 8 << 20,
            environment_variables: {})
      packer = ScriptCore::Protocol.packer_factory.packer

      payload = {input: input, sources: sources}
      payload[:library] = instructions if instructions
      encoded = packer.pack(payload)

      packer = ScriptCore::Protocol.packer_factory.packer
      size = packer.pack(encoded.size)

      spawner = ScriptCore::Spawner.new
      service_process = ScriptCore::ServiceProcess.new(
        executable_path,
        spawner,
        instruction_quota,
        instruction_quota_start,
        memory_quota,
        environment_variables
      )
      runner = ScriptCore::Runner.new(
        timeout: timeout,
        service_process: service_process,
        message_processor_factory: ScriptCore::MessageProcessor
      )
      runner.run(size, encoded)
    end
  end
end
