template 'cloud.yaml' do
  source 'cloud.yaml.erb'
  variables(
    buckets: [{
      'name' => 'DevAppBucket',
      'param' => 'DevBucketName',
      'type' => 'www',
      'environment' => 'dev'
    }, {
      'name' => 'ProdAppBucket',
      'param' => 'ProdBucketName',
      'type' => 'www',
      'environment' => 'prod'
    }, {
      'name' => 'StagingBucket',
      'param' => 'StagingBucketName',
      'type' => 'default'
    }],
    environments: [{
      'tag' => 'dev',
      'appBucket' => '!Ref \'DevBucketName\'',
      'stagingBucket' => '!Ref \'StagingBucketName\'',
      'role' => {
        'name' => 'DevSecurityRole'
      },
      'build' => {
        'name' => 'DevBuild',
        'dependencies' => [
          'DevSecurityRole'
        ]
      },
      'pipeline' => {
        'name' => 'DevelopmentPipeline',
        'dependencies' => %w[
          DevSecurityRole
          DevBuild
          DevAppBucket
          StagingBucket
        ],
        'branch' => 'develop'
      }
    }, {
      'tag' => 'prod',
      'appBucket' => '!Ref \'ProdBucketName\'',
      'stagingBucket' => '!Ref \'StagingBucketName\'',
      'role' => {
        'name' => 'ProdSecurityRole'
      },
      'build' => {
        'name' => 'ProdBuild',
        'dependencies' => [
          'ProdSecurityRole'
        ]
      },
      'pipeline' => {
        'name' => 'ProductionPipeline',
        'dependencies' => %w[
          ProdSecurityRole
          ProdBuild
          ProdAppBucket
          StagingBucket
        ],
        'branch' => 'master',
        'isManual' => true
      }
    }]
  )
end
