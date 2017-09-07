template 'prod/stacks/pipeline/development-sad-pipeline' do
  source 'stacks/pipeline/development-sad-pipeline-stack'
  variables(
    'tag' => 'dev'
  )
end

template 'prod/stacks/pipeline/test-sad-pipeline' do
  source 'stacks/pipeline/test-sad-pipeline-stack'
  variables(
    'tag' => 'test'
  )
end

template 'prod/stacks/pipeline/production-sad-pipeline' do
  source 'stacks/pipeline/production-sad-pipeline-stack'
  variables(
    'enableDNS' => true,
    'tag' => 'prod'
  )
end
