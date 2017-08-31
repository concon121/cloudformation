template 'development-sad-pipeline.yaml' do
  source 'sad-pipeline.yaml.erb'
  variables(
    'environment' => 'dev',
    'pipeline' => {
      'enabled' => true,
      'testing' => false,
      'codecommitPolicy' => true
    }
  )
end

template 'test-sad-pipeline.yaml' do
  source 'sad-pipeline.yaml.erb'
  variables(
    'environment' => 'test',
    'pipeline' => {
      'enabled' => true,
      'testing' => true,
      'codecommitPolicy' => false
    }
  )
end

template 'production-sad-pipeline.yaml' do
  source 'sad-pipeline.yaml.erb'
  variables(
    'environment' => 'prod',
    'pipeline' => {
      'enabled' => false,
      'testing' => false,
      'codecommitPolicy' => false
    }
  )
end
