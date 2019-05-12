# frozen_string_literal: true

RSpec.describe(ScriptCore::Stat) do
  let(:null_stat) { ScriptCore::Stat::Null }

  it "supports all stats" do
    options = { instructions: 1, memory: 2, bytes_in: 3, time: 4, total_instructions: 5 }
    stat = ScriptCore::Stat.new(options)
    expect(stat).to have_attributes(options)
  end

  it "nullStats are all zero" do
    default_values = { instructions: 0, memory: 0, bytes_in: 0, time: 0, total_instructions: 0 }
    expect(null_stat).to have_attributes(default_values)
  end
end
