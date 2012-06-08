require_relative '../../lib/quacky/quacky'
require_relative '../../lib/quacky/rspec_setup'

  class Classroom
    def dismiss break_time; end
  end
  module Dismissable
    def dismiss break_time; end
  end

  module Cleanable
    def clean! time; end
  end

  describe Classroom do
    it { should quack_like Dismissable, Cleanable }
  end