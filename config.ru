# frozen_string_literal: true

require 'rack/cors'
require_relative './lib/poker_arena'

use Rack::Cors do
  allow do
    origins '*'
    resource '*',
             headers: :any,
             methods: %i[get post options delete put patch],
             expose: ['Content-Type']
  end
end

run PokerArena::Launcher
