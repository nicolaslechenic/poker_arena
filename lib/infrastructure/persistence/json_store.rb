# frozen_string_literal: true

require 'json'
require 'fileutils'

module PokerArena
  module Infrastructure
    module Persistence
      class JsonStore

        attr_reader :data
        
        def initialize(file_path)
          @file_path = file_path
          @data = {}
          ensure_directory_exists
          load_data if File.exist?(@file_path)
        end

        def find(id)
          @data[id.to_s]
        end

        def all
          @data.values
        end

        def save(id, entity)
          @data[id.to_s] = entity
          persist
          entity
        end

        def delete(id)
          entity = @data.delete(id.to_s)
          persist
          entity
        end

        def clear
          @data = {}
          persist
        end

        private

        def ensure_directory_exists
          dir = File.dirname(@file_path)
          FileUtils.mkdir_p(dir) unless File.directory?(dir)
        end

        def load_data
          file_content = File.read(@file_path)
          return if file_content.empty?

          json_data = JSON.parse(file_content)
          @data = json_data
        rescue JSON::ParserError => e
          puts "Error parsing JSON from #{@file_path}: #{e.message}"
          @data = {}
        end

        def persist
          File.open(@file_path, 'w') do |file|
            file.write(JSON.pretty_generate(@data))
          end
        end
      end
    end
  end
end
