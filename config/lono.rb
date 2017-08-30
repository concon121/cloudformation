template 'development-sad-pipeline.yaml' do
  source 'sad-pipeline.yaml.erb'
  variables(
    'environment' => 'dev',
    'pipeline' => {
      'testing' => 'false'
    }
  )
end

template 'test-sad-pipeline.yaml' do
  source 'sad-pipeline.yaml.erb'
  variables(
    'environment' => 'test',
    'pipeline' => {
      'testing' => 'true'
    }
  )
end

template 'production-sad-pipeline.yaml' do
  source 'sad-pipeline.yaml.erb'
  variables(
    'environment' => 'prod',
    'pipeline' => {
      'testing' => 'false'
    }
  )
end
