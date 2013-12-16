describe Dockerize do
  subject(:dockerize) { described_class }

  it 'has a valid version string' do
    dockerize::VERSION.should match(/\d+\.\d+\.\d+/)
  end
end
