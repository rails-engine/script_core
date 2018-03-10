# frozen_string_literal: true

module ScriptCore
  class MessageProcessor
    def initialize
      @measurements = {}
      @stat = ScriptCore::Stat::Null
      @errors = []
      @output = nil
      @stdout = ""
    end

    def process_all(channel)
      unpacker = ScriptCore::Protocol.packer_factory.unpacker(channel)
      begin
        unpacker.each do |raw_message|
          read(raw_message)
        end
      rescue EOFError
        signal_truncation
      end
    end

    def signal_error(error)
      @errors << error
    end

    def signal_truncation
      signal_error(ScriptCore::EngineTruncationError.new)
    end

    def signal_signaled(signal)
      error = case signal
              when 31
                ScriptCore::EngineIllegalSyscallError.new
              else
                ScriptCore::EngineSignaledError.new(signal: signal)
      end

      signal_error(error)
    end

    def signal_abnormal_exit(code)
      error = case code
              when 8
                ScriptCore::ArithmeticOverflowError.new
              when 9
                ScriptCore::UnknownTypeError.new
              when 16
                ScriptCore::EngineMemoryQuotaError.new
              when 17
                ScriptCore::EngineInstructionQuotaError.new
              when 19
                ScriptCore::EngineTypeError.new
              else
                ScriptCore::EngineAbnormalExitError.new(code: code)
      end

      signal_error(error)
    end

    def to_result
      ScriptCore::Result.new(
        output: @output,
        stdout: @stdout,
        stat: @stat,
        errors: @errors,
        measurements: @measurements
      )
    end

    private

    def read(raw_message)
      type, data = raw_message
      case type
      when :output then read_output(data)
      when :error then read_error(data)
      when :measurement then read_measurement(data)
      when :stat then read_stat(data)
      end
    end

    def read_output(data)
      @output = data[:extracted]
      @stdout = data[:stdout]
    end

    def read_error(data)
      @errors <<
        case data[:__type]
        when :runtime
          EngineRuntimeError.new(
            data[:message],
            guest_backtrace: data[:backtrace]
          )
        when :syntax
          EngineSyntaxError.new(
            data[:message],
            filename: data[:filename],
            line_number: data[:line_number],
            column: data[:column]
          )
        when :unknown_type
          EngineUnknownTypeError.new(type: data[:type])
        when :unknown_ext
          EngineUnknownExtError.new(type: data[:type])
        else
          EngineInternalError.new("unknown error: #{data}")
        end
    end

    def read_measurement(data)
      name, microseconds = *data
      if @measurements.key?(name)
        @measurements[name] += microseconds
      else
        @measurements[name] = microseconds
      end
    end

    def read_stat(data)
      unless @stat == ScriptCore::Stat::Null
        @errors << ScriptCore::DuplicateMessageError.new(
          "duplicate stat message"
        )
      end
      @stat = ScriptCore::Stat.new(data)
    end
  end
end
