# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'

describe PokerArena::Infrastructure::Persistence::JsonStore do
  let(:temp_file) { Tempfile.new(['test_store', '.json']) }
  let(:store) { described_class.new(temp_file.path) }

  after do
    temp_file.close
    temp_file.unlink
  end

  describe '#initialize' do
    it 'creates a new store with an empty data hash' do
      expect(store.instance_variable_get(:@data)).to eq({})
    end

    it 'loads data from file if it exists' do
      File.write(temp_file.path, '{"1": {"name": "Test"}}')

      new_store = described_class.new(temp_file.path)

      expect(new_store.instance_variable_get(:@data)).to eq({ '1' => { 'name' => 'Test' } })
    end
  end

  describe '#find' do
    before do
      store.save('1', { 'name' => 'Test' })
    end

    it 'returns the entity with the given id' do
      expect(store.find('1')).to eq({ 'name' => 'Test' })
    end

    it 'returns nil if the entity is not found' do
      expect(store.find('2')).to be_nil
    end
  end

  describe '#all' do
    before do
      store.save('1', { 'name' => 'Test 1' })
      store.save('2', { 'name' => 'Test 2' })
    end

    it 'returns all entities' do
      expect(store.all).to match_array([{ 'name' => 'Test 1' }, { 'name' => 'Test 2' }])
    end
  end

  describe '#save' do
    it 'saves the entity with the given id' do
      store.save('1', { 'name' => 'Test' })
      expect(store.find('1')).to eq({ 'name' => 'Test' })
    end

    it 'overwrites an existing entity with the same id' do
      store.save('1', { 'name' => 'Test' })
      store.save('1', { 'name' => 'Updated' })
      expect(store.find('1')).to eq({ 'name' => 'Updated' })
    end

    it 'persists the data to the file' do
      store.save('1', { 'name' => 'Test' })

      new_store = described_class.new(temp_file.path)

      expect(new_store.find('1')).to eq({ 'name' => 'Test' })
    end
  end

  describe '#delete' do
    before do
      store.save('1', { 'name' => 'Test' })
    end

    it 'removes the entity with the given id' do
      store.delete('1')
      expect(store.find('1')).to be_nil
    end

    it 'returns the deleted entity' do
      expect(store.delete('1')).to eq({ 'name' => 'Test' })
    end

    it 'returns nil if the entity is not found' do
      expect(store.delete('2')).to be_nil
    end

    it 'persists the deletion to the file' do
      store.delete('1')

      new_store = described_class.new(temp_file.path)

      expect(new_store.find('1')).to be_nil
    end
  end

  describe '#clear' do
    before do
      store.save('1', { 'name' => 'Test 1' })
      store.save('2', { 'name' => 'Test 2' })
    end

    it 'removes all entities' do
      store.clear
      expect(store.all).to be_empty
    end

    it 'persists the clearing to the file' do
      store.clear
      
      new_store = described_class.new(temp_file.path)

      expect(new_store.all).to be_empty
    end
  end
end
