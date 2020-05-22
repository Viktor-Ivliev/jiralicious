# frozen_string_literal: true

require 'spec_helper'

describe Jiralicious::ParamsEncoder, 'encode' do
  {
    { 'foo' => 'bar', 'baz' => 'bat' } => 'foo=bar&baz=bat',
    { 'foo' => %w[bar baz] } => 'foo[]=bar&foo[]=baz',
    { 'foo' => [{ 'bar' => '1' }, { 'bar' => 2 }] } => 'foo[][bar]=1&foo[][bar]=2',
    { 'foo' => { 'bar' => [{ 'baz' => 1 }, { 'baz' => '2' }] } } => 'foo[bar][][baz]=1&foo[bar][][baz]=2',
    { 'foo' => { '1' => 'bar', '2' => 'baz' } } => 'foo[1]=bar&foo[2]=baz'
  }.each do |hash, params|
    it "coverts hash: #{hash.inspect} to params: #{params.inspect}" do
      expect(Jiralicious::ParamsEncoder.encode(hash).split('&').sort).to eq params.split('&').sort
    end
  end

  it 'not leave a trailing &' do
    expect(
      Jiralicious::ParamsEncoder.encode(
        name: 'Bob',
        address: {
          street: '111 Ruby Ave.',
          city: 'Ruby Central',
          phones: %w[111-111-1111 222-222-2222]
        }
      )
    ).not_to match /&$/
  end

  it 'URL encode unsafe characters' do
    expect(Jiralicious::ParamsEncoder.encode(q: '?&" +')).to eq 'q=%3F%26%22%20%2B'
  end
end
