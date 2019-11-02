# frozen_string_literal: true

module FieldsHelper
  def options_for_field_types(selected: nil)
    options_for_select(Field.descendants.map { |klass| [klass.model_name.human, klass.to_s] }, selected)
  end

  def field_label(form, field_name:)
    field_name = field_name.to_s.split(".").first.to_sym

    form.fields.find do |field|
      field.name == field_name
    end&.label
  end

  def fields_path
    form = @field.form

    case form
    when Form
      form_fields_path(form)
    when NestedForm
      nested_form_fields_path(form)
    else
      raise "Unknown form: #{form.class}"
    end
  end
end
