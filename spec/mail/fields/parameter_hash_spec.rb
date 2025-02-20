# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'
require 'mail/fields/parameter_hash'

RSpec.describe Mail::ParameterHash do
  it "should return the values in the hash" do
    hash = Mail::ParameterHash.new
    hash.merge!({'value1' => 'one', 'value2' => 'two'})
    expect(hash.keys).to include("value1")
    expect(hash.keys).to include("value2")
    expect(hash.values).to include('one')
    expect(hash.values).to include('two')
  end

  it "should return the values in the hash regardless of symbol or string" do
    hash = Mail::ParameterHash.new
    hash.merge!({'value1' => 'one', 'value2' => 'two'})
    expect(hash['value1']).to eq 'one'
    expect(hash['value2']).to eq 'two'
    expect(hash[:value1]).to eq 'one'
    expect(hash[:value2]).to eq 'two'
  end

  it "should return the values in the hash using case-insensitive key matching" do
    hash = Mail::ParameterHash.new
    hash.merge!({'value1' => 'one', 'VALUE2' => 'two'})
    expect(hash['VALUE1']).to eq 'one'
    expect(hash['vAlUe2']).to eq 'two'
    expect(hash[:VaLuE1]).to eq 'one'
    expect(hash[:value2]).to eq 'two'
  end

  it "should return the correct value if they are not encoded" do
    hash = Mail::ParameterHash.new
    hash.merge!({'value1' => 'one', 'value2' => 'two'})
    expect(hash['value1']).to eq 'one'
    expect(hash['value2']).to eq 'two'
  end

  it "should return a name list concatenated" do
    hash = Mail::ParameterHash.new
    hash.merge!({'value*1' => 'one', 'value*2' => 'two'})
    expect(hash['value']).to eq 'onetwo'
  end

  it "should return a name list concatenated and unencoded" do
    hash = Mail::ParameterHash.new
    hash.merge!({'value*0*' => "us-ascii'en'This%20is%20even%20more%20",
                 'value*1*' => "%2A%2A%2Afun%2A%2A%2A%20",
                 'value*2'  => "isn't it"})
    expect(hash['value']).to eq "This is even more ***fun*** isn't it"
  end

  it "allows for blank language" do
    hash = Mail::ParameterHash.new
    hash.merge!({'value*' => "us-ascii''Hello%20there"})
    expect(hash['value']).to eq "Hello there"
  end

  it "allows for blank charset" do
    hash = Mail::ParameterHash.new
    hash.merge!({'value*' => "'en'Hello%20there"})
    expect(hash['value']).to eq "Hello there"
  end

  it "allows for blank charset and language" do
    hash = Mail::ParameterHash.new
    hash.merge!({'value*' => "''Hello%20there"})
    expect(hash['value']).to eq "Hello there"
  end

  it "converts from specified encoding to utf-8" do
    hash = Mail::ParameterHash.new
    hash.merge!({'value*' => "iso-8859-1'en'H%EBll%F3%20there"})
    expect(hash['value']).to eq "Hëlló there"
  end

  it "should allow us to add a value" do
    hash = Mail::ParameterHash.new
    hash['value'] = 'bob'
    expect(hash['value']).to eq 'bob'
  end

  it "should return an encoded value" do
    hash = Mail::ParameterHash.new
    hash.merge!({'value*0*' => "us-ascii'en'This%20is%20even%20more%20",
                 'value*1*' => "%2A%2A%2Afun%2A%2A%2A%20",
                 'value*2'  => "isn't it"})
    expect(hash.encoded).to eq %Q{value*0*=us-ascii'en'This%20is%20even%20more%20;\r\n\svalue*1*=%2A%2A%2Afun%2A%2A%2A%20;\r\n\svalue*2="isn't it"}
  end

end
