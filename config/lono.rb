s3 = [{
  'id' => 'Development',
  'type' => 'www',
  'environment' => 'dev'
},
      # {
      #  'id' => 'Production',
      #  'type' => 'www',
      #  'environment' => 'prod'
      # },
      {
        'logicalId' => 'StagingBucket',
        'name' => '!Ref \'StagingBucketName\''
      }]

dev = {
  'id' => 'Development',
  'tag' => 'dev'
  'pipeline' => {
    'dependencies' => %w[
      DevSecurityRole
      DevBuild
      DevAppBucket
      StagingBucket
    ],
    'branch' => 'develop'
  }
}

prod = {
  'id' => 'Production',
  'tag' => 'prod'
  'pipeline' => {
    'dependencies' => %w[
      ProdSecurityRole
      ProdBuild
      ProdAppBucket
      StagingBucket
    ],
    'branch' => 'master',
    'isManual' => true
  }
}

template 'cloud.yaml' do
  source 'cloud.yaml.erb'
  variables(
    'buckets' => s3,
    'environments' => [dev]
  )
end
