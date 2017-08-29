s3 = [{
  'logicalId' => 'StagingBucket',
  'name' => '!Ref \'StagingBucketName\''
}]

dev = {
  'id' => 'Development',
  'tag' => 'dev',
  'pipeline' => {
    'branch' => 'develop'
  }
}

# prod = {
#  'id' => 'Production',
#  'tag' => 'prod',
#  'pipeline' => {
#    'branch' => 'master',
#    'isManual' => true
#  }
# }

template 'cloud.yaml' do
  source 'cloud.yaml.erb'
  variables(
    'buckets' => s3,
    'environments' => [dev]
  )
end
