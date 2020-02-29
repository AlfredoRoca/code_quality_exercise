RSpec.describe 'Reading environment configuration' do

  it 'reads env vars', :aggregate_failures do
    expect(ENV['REDIS_LOCAL_PORT']).not_to be_empty
    expect(ENV['REDIS_PORTS']).not_to be_empty
    expect(ENV['REDIS_URL']).not_to be_empty
  end

end
