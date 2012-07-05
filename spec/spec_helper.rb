$LOAD_PATH.unshift '.'
require 'quacky/quacky'
require 'quacky/stub'
require 'quacky/double'
require 'quacky/expectations'
require 'quacky/duck_type_verifier'

module Duck
  def duck! arg; end
end

RSpec.configure do |c|
  c.before do
    Quacky.clear_expectations!
  end
end
