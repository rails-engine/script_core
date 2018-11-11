def prepare_input
  Input.load @input
  remove_instance_variable "@input"
end

def prepare_output
  instance_variable_set :@output, Output.dump
end

def set_output(value)
  Output.value = value
end
