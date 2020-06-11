ScriptCore
====

ScriptCore is a fork of [Shopify's enterprise script service](https://github.com/Shopify/ess).

The enterprise script service (aka ESS) is a thin Ruby API layer that spawns a process, the `enterprise_script_engine`, to execute an untrusted Ruby script.

The `enterprise_script_engine` executable ingests the input from `stdin` as a msgpack encoded payload; then spawns an mruby-engine; uses seccomp to sandbox itself; feeds `library`, `input` and finally the Ruby scripts into the engine; returns the output as a msgpack encoded payload to `stdout` and finally exits.

## Why fork?

I want to make these changes:

- Toolchain
    - [x] Expose mruby build config to allow developer modify mruby-engine executable, e.g: add some gems
    - [x] Expose `mrbc` to allow developer precompile mruby library that would inject to sandbox
    - [x] Rake tasks for compiling mruby-engine & mruby library
    - [ ] Watching and auto compiling mruby library when it change
    - [ ] Capistrano recipe
- Practice
    - [x] Rails generator for mruby library
    - [x] Find a good place for engines
    - [ ] Find a good way to working with timezone on mruby side
    - [ ] Find a good way to working with `BigDecimal` & `Date` (mruby doesn't have these) on mruby side

## limitation

- We enable `MRB_DISABLE_STDIO` flag when compiling mruby,
  which means the sandbox will not support gems which dependent `mruby-io` or `stdio.h`,
  the result is you can not do any HTTP request, read and write files in the sandbox,
  you may consider preparing data on Ruby side and pass them to the sandbox.

## Help wanted

I'm not familiar with C/CPP, so I can't improve ESS (in `ext/enterprise_script_service`),

Currently there're too much warnings on compiling, hope some one could help to resolve them.

## Demo

Clone the repository.

```sh
$ git clone https://github.com/rails-engine/script_core
```

Change directory

```sh
$ cd script_core
```

Fetch submodules

```sh
$ git submodule update --init --recursive
```

Run bundler

```sh
$ bundle install
```

Preparing database

```sh
$ bin/rails db:migrate
```

Build mruby engine & engine lib

```sh
$ bin/rails app:script_core:engine:build
$ bin/rails app:script_core:engine:compile_lib 
```

Start the Rails server

```sh
$ bin/rails s
```

Open your browser, and visit `http://localhost:3000`

## Installation

Add this line to your Gemfile:

```ruby
gem 'script_core'
```

Or you may want to include the gem directly from GitHub:

```ruby
gem 'script_core', github: 'rails-engine/script_core'
```

Then execute:

```sh
$ bundle
```

## Build your executable

ScriptCore already has a default executable, because of mruby's gem is compiled in binary, or you may want to build a mruby library, build your own engine is necessary.

You can check `spec/dummy/mruby` as reference.

### Create a new engine

Run the task in your app directory:

```sh
$ rails script_core:engine:new [engine_name]
```

`engine_name` is optional, by default it would be `mruby` that will generate `mruby` directory in your app root folder.

Then execute:

```sh
$ rails script_core:engine:build [engine_name]
```

It will build mruby executables.

#### customizing `gembox`

Remove `.example` extension for `engine.gembox.example`, customize it, then rebuild the engine.

**Warning: because of `seccomp`, you may meet compatibility problems, especially for IO relates gems.**

### Build lib for the engine

Write your own lib for mruby environment in `mruby/lib` directory.

### Compile lib for the engine

Run the task in your app directory:

```sh
$ rails script_core:engine:compile_lib [engine_name]
```

### Ignoring engine binaries

Because of engine binaries are platform dependent, it's good to compile in every deployment.

Simply add `mruby/bin` to `.gitignore`.

### Integrate to your app

You can wrap it for example:

```ruby
module ScriptEngine
  class << self
    def engine
      @engine ||= ScriptCore::Engine.new Rails.root.join("mruby/bin")
    end

    def eval(string, input: nil, instruction_quota_start: nil, environment_variables: {})
      sources = [
        ["user", string],
      ]

      engine.eval sources, input: input,
                  instruction_quota_start: instruction_quota_start,
                  environment_variables: environment_variables
    end
  end
end
```

Then use it:

```ruby
ScriptEngine.eval "@output = 'hello world'"
```

## Tips

- Add `/mruby/bin` into `.gitignore`
- Don't do any IO in mruby side
- Because of `seccomp`, it may have compatible issues with some mruby gems
- mruby doesn't have `Date`, use `Time` instead
- mruby doesn't have `BigDecimal`, you can use Shopify's `Decimal` instead
- mruby is poor support timezone, you'd better handle it by yourself
- mruby engine is fast, usually it only costs 3 - 5ms depends on complexity, but it consume a lot of memory (~300k at least per process)

# More information about ESS

## Data format

### Input

The input is expected to be a msgpack `MAP` with three keys (Symbol): `library`, `sources`, `input`:

 - `library`: a msgpack `BIN` set of MRuby instructions that will be fed directly to the `mruby-engine`
 - `input`: a msgpack formated payload for the `sources` to digest
 - `sources`: a msgpack `ARRAY` of `ARRAY` with two elements each (tuples): `path`, `source`; the actual code to be executed by the mruby-engine

### Output

The output is msgpack encoded as well; it is streamed to the consuming end though. Streamed items can be of different types.
Each element streamed is in the format of an `ARRAY` of two elements, where the first is a `Symbol` describing the element type:

 * `measurement`: a msgpack `ARRAY` of two elements: a `Symbol` describing the measurement, and an `INT64` with the value in µs.
 * `output`: a msgpack `MAP` with two entries (keys are symbols):
 ** `extracted` with whatever the script put in `@output`, msgpack encoded; and
 ** `stdout` with a `STRING` containing whatever the script printed to "stdout".
 * `stat`: a `MAP` keyed with symbols mapping to their `INT64` values

## Errors

When the ESS fails to serve a request, it communicates the error back to the caller by returning a non-zero status code.
It can also report data about the error, in certain cases, over the pipe. In does so in returning a tuple, as an `ARRAY` with the type being the symbol `error` and the payload being a `MAP`. The content of the map will vary, but it always will have a `__type` symbol key that defines the other keys.

## Build

Run `./bin/rake` to build the project. This effectively runs the `spec` target, which builds all libraries, the ESS and native tests; then runs all tests (native and Ruby).

To rebuild the entire project (which is useful when switching from one OS to another), use `./bin/rake mrproper`.

## Using it

The sample script `bin/sandbox` reads Ruby input from a file or stdin, executes it, and displays the results.

You can invoke ESS from your own Ruby code as follows:

```ruby
result = ScriptCore.run(
  input: {result: [26803196617, 0.475]}, # <1>
  sources: [
    ["stdout", "@stdout_buffer = 'hello'"],
    ["foo", "@output = @input[:result]"], # <2>
  ],
  instructions: nil, # <3>
  timeout: 10.0, # <4>
  instruction_quota: 100000, # <5>
  instruction_quota_start: 1, # <6>
  memory_quota: 8 << 20  # <7>
)
expect(result.success?).to be(true)
expect(result.output).to eq([26803196617, 0.475])
expect(result.stdout).to eq("hello")
```

- <1> invokes the ESS, with a map as the `input` (available as `@input` in the sources)
- <2> two "scripts" to be executed, one sets the `@stdout_buffer` to a value, the second returns the value associated with the key `:result` of the map passed in in <1>
- <3> some raw instructions that will be fed directly into MRuby; defaults to nil
- <4> a 10 second time quota to spawn, init, inject, eval and finally output the result back; defaults to 1 second
- <5> a 100k instruction limit that that the engine will execute; defaults to 100k
- <6> starts counting the instructions at index 1 of the `sources` array
- <7> creates an 8 megabyte memory pool in which the script will run

## Where are things?

### C++ sources

Consists of our code base, plus `seccomp` and `msgpack` libraries, as well as the `mruby` stuff. All in `ext/enterprise_script_service`

Note: lib `seccomp` is omitted on Darwin.

### Ruby layer

Ruby code is in `lib/`

### Tests

- GoogleTest tests are in `tests/`, which also includes the Google Test library.
- RSpec tests are in `spec/`

## Other useful things

- There is a `CMakeLists.txt` that's mainly there for CLion support; we don't use cmake to build any of this.
- You can use vagrant to bootstrap a VM to test under Linux while on Darwin; this is useful when testing `seccomp`.

### Clone git submodules

`git submodule update --init --recursive`

### Vagrant

```
$ vagrant up
$ vagrant ssh
vagrant@vagrant-ubuntu-bionic-64:~$ cd /vagrant
vagrant@vagrant-ubuntu-bionic-64:/vagrant$ bundle install
vagrant@vagrant-ubuntu-bionic-64:/vagrant$ git submodule init
vagrant@vagrant-ubuntu-bionic-64:/vagrant$ git submodule update
vagrant@vagrant-ubuntu-bionic-64:/vagrant$ bin/rake
```

## Contributing

Bug report or pull request are welcome.

### Make a pull request

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Please write unit test with your code if necessary.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
