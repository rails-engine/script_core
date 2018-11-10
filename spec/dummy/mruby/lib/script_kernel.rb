def prepare_input
  Input.load @input
  remove_instance_variable "@input"
end

def prepare_output
  @output = Output.dump
end

module ScriptKernel; end
