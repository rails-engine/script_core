# frozen_string_literal: true

SCRIPT_CORE_ROOT = Pathname.new(__dir__).join("../..")
TEMPLATE_ROOT = File.expand_path("mruby", __dir__)
DEFAULT_ENGINE_NAME = "mruby"

namespace :script_core do
  namespace :engine do
    desc "Create a skeletal engine that can be customize at the path you specify"
    task :new do
      ARGV.each { |a| task(a.to_sym) {} }

      name = ARGV[1] || DEFAULT_ENGINE_NAME
      unless /\A[a-z_]+\Z/.match?(name)
        puts "Engine name can only be `a` to `z` and `_`."
        exit 1
      end

      dest_dir = Rails.root.join(name)
      if File.exist?(dest_dir)
        puts "#{dest_dir} exists, you need to remove it first."
        exit 1
      end

      FileUtils.cp_r TEMPLATE_ROOT, dest_dir
    end

    desc "Build engine executables"
    task :build do
      ARGV.each { |a| task(a.to_sym) {} }

      name = ARGV[1] || DEFAULT_ENGINE_NAME
      unless /\A[a-z_]+\Z/.match?(name)
        puts "Must provide a valid engine name."
        exit 1
      end

      engine_root = Rails.root.join(name)
      unless Dir.exist?(engine_root)
        puts "Engine home `#{engine_root}` doesn't exists."
        puts "You should run `rake script_core:engine:new #{name}` to create it first."
        exit 1
      end

      env_vars = "TARGET_DIR=#{engine_root}"

      gembox_file = engine_root.join("engine.gembox")
      if File.exist?(gembox_file)
        puts "Found customized gembox."
        env_vars += " MRUBY_ENGINE_GEMBOX_PATH=#{gembox_file}"
      end

      Dir.chdir(SCRIPT_CORE_ROOT.join("ext/enterprise_script_service")) do
        sh("#{env_vars} #{Rails.root.join('bin/bundle')} exec rake")
      end
    end

    desc "Compile engine lib"
    task :compile_lib do
      ARGV.each { |a| task(a.to_sym) {} }

      name = ARGV[1] || DEFAULT_ENGINE_NAME
      unless /\A[a-z_]+\Z/.match?(name)
        puts "Must provide a valid engine name."
        exit 1
      end

      engine_root = Rails.root.join(name)
      unless Dir.exist?(engine_root)
        puts "Engine home `#{engine_root}` doesn't exists."
        puts "You should run `rake script_core:engine:new #{name}` to create it first."
        exit 1
      end

      unless File.exist?(engine_root.join("bin/mrbc"))
        puts "Engine haven't built yet."
        puts "You should run `rake script_core:engine:build #{name}` first."
        exit 1
      end

      lib_files = Dir["#{engine_root.join('lib')}/**/*.rb"]
      if lib_files.empty?
        puts "Empty lib, no need to compile"
        exit 0
      end

      Dir.chdir(engine_root.join("bin")) do
        sh("./mrbc --remove-lv -o enterprise_script_service.mrb #{lib_files.join(' ')}")
      end
    end

    desc "Clean engine compiled files"
    task :clean do
      ARGV.each { |a| task(a.to_sym) {} }

      name = ARGV[1] || DEFAULT_ENGINE_NAME
      unless /\A[a-z_]+\Z/.match?(name)
        puts "Must provide a valid engine name."
        exit 1
      end

      engine_root = Rails.root.join(name)
      unless Dir.exist?(engine_root)
        puts "Engine home `#{engine_root}` doesn't exists."
        exit 1
      end

      bin_path = engine_root.join("bin")
      if Dir.exist?(bin_path)
        FileUtils.remove_dir engine_root.join("bin")
      end
    end
  end
end
