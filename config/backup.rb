tags = [
  {
    key: 'Owner',
    value: 'Michael Last'
  },
  {
    key: 'Contact',
    value: 'Andover2@prudential.co.uk'
  },
  {
    key: 'ApplicationName',
    value: 'Small Apps Domain'
  },
  {
    key: 'Environment',
    value: '!FindInMap [EnvironmentConfigurationMap, !Ref Environment, EnvironmentLongName]'
  },
  {
    key: 'BusinessUnit',
    value: 'PUK'
  },
  {
    key: 'CostCentrePGDS',
    value: 'ITBUEXP'
  },
  {
    key: 'CostCentreBU',
    value: 'UKPSRPT'
  },
  {
    key: 'ProjectCodePGDS',
    value: 'TODO'
  },
  {
    key: 'ProjectCodeBU',
    value: 'TODO'
  },
  {
    key: 'Criticality',
    value: '!FindInMap [EnvironmentConfigurationMap, !Ref Environment, Criticality]'
  },
  {
    key: 'DataClassification',
    value: '!FindInMap [EnvironmentConfigurationMap, !Ref Environment, DataClassification]'
  }
]

shared = {
  'id' => 'SharedResources',
  'key' => 'stacks/pipeline/core-stack.yaml',
  'tags' => tags,
  'params' => [
    {
      key: 'ProjectName',
      value: '!Ref ProjectName'
    }, {
      key: 'RootDomain',
      value: '!Ref RootDomain'
    }, {
      key: 'RootDomainZoneID',
      value: '!Ref RootDomainZoneID'
    }, {
      key: 'SubDomain',
      value: 'calculators'
    }, {
      key: 'UserRole',
      value: '!Ref UserRole'
    }
  ]
}

template 'sad-pipeline.yaml' do
  source 'sad-pipeline.yaml.erb'
  variables(
    'stacks' => [shared],
    'pipeline' => {
      testing: true,
      codecommitPolicy: true
    }
  )
end

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

template 'stacks/pipeline/core-stack.yaml' do
  source 'stacks/pipeline/core-stack.yaml.erb'
end
