# frozen_string_literal: true

module Fields
  %w[
    text boolean decimal integer
    date datetime
    select multiple_select
    nested_form multiple_nested_form
  ].each do |type|
    require_dependency "fields/#{type}_field"
  end

  MAP = Hash[*Field.descendants.map { |f| [f.type_key, f] }.flatten]
end
