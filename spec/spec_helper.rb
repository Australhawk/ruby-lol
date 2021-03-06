require "rspec"
require "simplecov"
require "coveralls"
require "codeclimate-test-reporter"
require "vcr"

Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  Coveralls::SimpleCov::Formatter,
  SimpleCov::Formatter::HTMLFormatter,
]

SimpleCov.start

VCR.configure do |c|
  c.cassette_library_dir = __dir__ + '/../fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.ignore_hosts 'codeclimate.com'
  c.configure_rspec_metadata!
end

def underscore s
  s.to_s.scan(/[A-Z][a-z]*/).join("_").downcase
end

def camelize s
  s[0] + s.to_s.split("_").each {|s| s.capitalize! }.join("")[1..-1]
end

def load_fixture subject, version, method
  JSON.parse(File.read(__dir__ + "/fixtures/#{version}/#{method}-#{subject}.json", :encoding => "utf-8"))
end

def expect_init_attribute subject, attribute
  expect(subject.new(camelize(attribute) => "foo").send(attribute)).to eq("foo")
end

def expect_read_only_attribute subject, attribute
  expect { subject.new.send("#{attribute}=".to_sym, "bar") }.to raise_error(NoMethodError)
end

def error_401
  response = {"status" => {"message" => "Foo", "status_code" => 401}}
  response.send :instance_eval do
    def code; 401; end
    def not_found?; false; end
  end
  response
end

def summoners
  {
    "euw" => "30743211",
    "na" => "5908",
    "eune" => "35778105"
  }
end

RSpec.configure do |c|
#  c.fail_fast = true
  c.filter_run_excluding :remote => true
end
