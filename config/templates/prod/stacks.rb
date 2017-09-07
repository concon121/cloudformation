template 'stacks/pipeline/production-sad-pipeline' do
  source 'stacks/pipeline/production-sad-pipeline-stack'
  variables(
    'enableDNS' => true
  )
end
