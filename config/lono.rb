s3 = [{
  'logicalId' => 'StagingBucket',
  'name' => '!Ref \'StagingBucketName\''
}]

dev = {
  'tag' => 'dev'
}

tester = {
  'tag' => 'test'
}

prod = {
  'tag' => 'prod'
}

template 'development-sad-pipeline.yaml' do
  source 'sad-pipeline.yaml.erb'
  variables(
    'buckets' => s3,
    'environments' => [dev]
  )
end

template 'test-sad-pipeline.yaml' do
  source 'sad-pipeline.yaml.erb'
  variables(
    'buckets' => s3,
    'environments' => [tester]
  )
end

template 'production-sad-pipeline.yaml' do
  source 'sad-pipeline.yaml.erb'
  variables(
    'buckets' => s3,
    'environments' => [prod]
  )
end
