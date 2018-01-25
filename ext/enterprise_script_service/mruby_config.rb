# frozen_string_literal: true

require_relative("./flags")

mruby_engine_gembox_path =
  if ENV["MRUBY_ENGINE_GEMBOX_PATH"] && File.exist?(ENV["MRUBY_ENGINE_GEMBOX_PATH"])
    unless ENV["MRUBY_ENGINE_GEMBOX_PATH"].end_with?(".gembox")
      raise "`#{ENV["MRUBY_ENGINE_GEMBOX_PATH"]}` require `.gembox` extension"
    end
    Pathname.new ENV["MRUBY_ENGINE_GEMBOX_PATH"][0..-8]
  else
    Pathname.new(__FILE__).dirname.join("mruby_engine")
  end

MRuby::Build.new do |conf|
  toolchain(:gcc)

  enable_debug

  conf.gembox(mruby_engine_gembox_path)
  conf.gem(core: "mruby-bin-mirb")
  conf.gem(core: "mruby-bin-mruby")

  conf.bins = %w[mrbc mruby]

  conf.cc do |cc|
    cc.flags += %w[-fPIC]
    cc.flags += Flags.cflags
    cc.defines += Flags.io_safe_defines
  end
end

MRuby::CrossBuild.new("sandbox") do |conf|
  toolchain(:gcc)

  enable_debug

  conf.gembox(mruby_engine_gembox_path)

  conf.bins = []

  conf.cc do |cc|
    cc.flags += %w[-fPIC]
    cc.flags += Flags.cflags
    cc.defines += Flags.defines
  end
end
