# frozen_string_literal: true

module ScriptCore
  class Spawner
    def spawn(*)
      super
    end

    def wait(pid, flags = 0)
      _pid, status = Process.wait2(pid, flags)

      return unless status

      if status.signaled?
        255 + status.termsig
      else
        status.exitstatus
      end
    end

    def kill(signal, pid)
      Process.kill(signal, pid)
    end
  end
end
