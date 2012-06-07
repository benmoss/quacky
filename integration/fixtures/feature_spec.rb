require_relative '../../lib/quacky/quacky'
require_relative '../../lib/quacky/rspec_setup'

  class Classroom
    def dismiss
    end
  end
  module Dismissable
    def dismiss break_time; end
  end

  describe Classroom do
    specify { described_class.should quack_like Dismissable }
  end