# frozen_string_literal: true

module Flags
  class << self
    def cflags
      debug_flags + optimization_flags
    end

    def debug_flags
      %w[-g3]
    end

    def optimization_flags
      if ENV["MRUBY_ENGINE_ENABLE_DEBUG"]
        %w[-O0]
      else
        %w[-O3]
      end
    end

    def library_paths
      # Necessary because of https://github.com/mruby/mruby/issues/4537
      %w[/usr/local/lib /usr/lib]
    end

    def io_safe_defines
      %w[
        _GNU_SOURCE
        MRB_USE_DEBUG_HOOK
        MRB_INT64
        MRB_UTF8_STRING
        MRB_WORD_BOXING
        YYDEBUG
      ]
    end

    def defines
      io_safe_defines + %w[MRB_NO_STDIO MRB_WORDBOX_NO_FLOAT_TRUNCATE MRB_USE_RO_DATA_P_ETEXT]
    end
  end
end
