# =============================================================================
# Variables
# =============================================================================

tags = [
  {
    'key' => 'Owner',
    'value' => 'Michael Last'
  },
  {
    'key' => 'Contact',
    'value' => 'Andover2@prudential.co.uk'
  },
  {
    'key' => 'ApplicationName',
    'value' => 'Small Apps Domain'
  },
  {
    'key' => 'BusinessUnit',
    'value' => 'PUK'
  },
  {
    'key' => 'CostCentrePGDS',
    'value' => 'ITBUEXP'
  },
  {
    'key' => 'CostCentreBU',
    'value' => 'UKPSRPT'
  },
  {
    'key' => 'ProjectCodePGDS',
    'value' => 'TODO'
  },
  {
    'key' => 'ProjectCodeBU',
    'value' => 'TODO'
  }
]

devTags = [{
  'key' => 'Environment',
  'value' => '!FindInMap [EnvironmentConfigurationMap, dev, EnvironmentLongName]'
}, {
  'key' => 'Criticality',
  'value' => '!FindInMap [EnvironmentConfigurationMap, dev, Criticality]'
}, {
  'key' => 'DataClassification',
  'value' => '!FindInMap [EnvironmentConfigurationMap, dev, DataClassification]'
}]

testTags = [{
  'key' => 'Environment',
  'value' => '!FindInMap [EnvironmentConfigurationMap, test, EnvironmentLongName]'
}, {
  'key' => 'Criticality',
  'value' => '!FindInMap [EnvironmentConfigurationMap, test, Criticality]'
}, {
  'key' => 'DataClassification',
  'value' => '!FindInMap [EnvironmentConfigurationMap, test, DataClassification]'
}]

prodTags = [{
  'key' => 'Environment',
  'value' => '!FindInMap [EnvironmentConfigurationMap, prod, EnvironmentLongName]'
}, {
  'key' => 'Criticality',
  'value' => '!FindInMap [EnvironmentConfigurationMap, prod, Criticality]'
}, {
  'key' => 'DataClassification',
  'value' => '!FindInMap [EnvironmentConfigurationMap, prod, DataClassification]'
}]

rootDomain = {
  'key' => 'RootDomain',
  'value' => '!Join [., [calculators, !Ref RootDomain]]'
}
rootZone = {
  'key' => 'RootDomainZoneID',
  'value' => '!Ref RootDomainZoneID'
}
userRole = {
  'key' => 'UserRole',
  'value' => '!Ref UserRole'
}
commonRepo = {
  'key' => 'CommonRepo',
  'value' => 'calculators-shared'
}

ipWhiteList = [{
  'type' => 'IPV4',
  'value' => '80.247.48.23/32'
}, {
  'type' => 'IPV4',
  'value' => '80.247.53.96/32'
}, {
  'type' => 'IPV4',
  'value' => '80.247.48.25/32'
}, {
  'type' => 'IPV4',
  'value' => '80.247.48.26/32'
}, {
  'type' => 'IPV4',
  'value' => '80.247.53.97/32'
}, {
  'type' => 'IPV4',
  'value' => '80.247.48.24/32'
}, {
  'type' => 'IPV4',
  'value' => '80.247.53.37/32'
}]

shared = {
  'id' => 'SharedResources',
  'key' => 'stacks/pipeline/core-stack.yaml',
  'tags' => tags + prodTags,
  'params' => [
    {
      'key' => 'ProjectName',
      'value' => 'calculators-shared'
    }, {
      'key' => 'RootDomain',
      'value' => '!Ref RootDomain'
    }, {
      'key' => 'SubDomain',
      'value' => 'calculators'
    }, rootZone, userRole
  ]
}

suf = {
  'id' => 'SUF',
  'key' => 'stacks/small-apps-project-stack.yaml',
  'tags' => tags,
  'params' => [rootDomain, rootZone, userRole, commonRepo, {
    'key' => 'ProjectName',
    'value' => 'suf'
  }]
}

# =============================================================================
# Nested Stacks
# =============================================================================

template 'stacks/pipeline/core-stack.yaml' do
  source 'stacks/pipeline/core-stack.yaml.erb'
end

template 'stacks/small-apps-project-stack.yaml' do
  source 'stacks/small-apps-project-stack.yaml.erb'
  variables(
    'devTags' => devTags,
    'testTags' => testTags,
    'prodTags' => prodTags
  )
end

template 'stacks/pipeline/development-sad-pipeline.yaml' do
  source 'stacks/pipeline/development-sad-pipeline-stack.yaml.erb'
  variables(
    'ipWhiteList' => ipWhiteList,
    'tag' => 'dev'
  )
end

template 'stacks/pipeline/test-sad-pipeline.yaml' do
  source 'stacks/pipeline/test-sad-pipeline-stack.yaml.erb'
  variables(
    'ipWhiteList' => ipWhiteList,
    'tag' => 'test'
  )
end

template 'stacks/pipeline/production-sad-pipeline.yaml' do
  source 'stacks/pipeline/production-sad-pipeline-stack.yaml.erb'
  variables(
    'ipWhiteList' => ipWhiteList,
    'tag' => 'prod',
    'enableDNS' => false
  )
end

# ============================================================================
# Main Stack
# ============================================================================

template 'small-apps-domain.yaml' do
  source 'small-apps-domain.yaml.erb'
  variables(
    'stacks' => [shared, suf],
    'pipeline' => {
      testing: true,
      codecommitPolicy: true
    }
  )
end
