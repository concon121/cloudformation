template 'development-sad-pipeline.yaml' do
  source 'sad-pipeline.yaml.erb'
  variables(
    'environment' => 'dev',
    'pipeline' => {
      'enabled' => true,
      'testing' => false
    }
  )
end

template 'test-sad-pipeline.yaml' do
  source 'sad-pipeline.yaml.erb'
  variables(
    'environment' => 'test',
    'pipeline' => {
      'enabled' => true,
      'testing' => true
    }
  )
end

template 'production-sad-pipeline.yaml' do
  source 'sad-pipeline.yaml.erb'
  variables(
    'environment' => 'prod',
    'pipeline' => {
      'enabled' => false,
      'testing' => false
    }
  )
end
