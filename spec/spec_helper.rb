$LOAD_PATH.unshift '.'
require 'quacky/quacky'
require 'quacky/stub'
require 'quacky/double'
require 'quacky/expectations'
require 'quacky/duck_type_verifier'
require 'devtools/spec_helper'

if ENV["CI"]
  require 'coveralls'
  Coveralls.wear!
end

module Duck
  def duck! arg; end
end

RSpec.configure do |c|
  c.before do
    Quacky.clear_expectations!
  end
end
