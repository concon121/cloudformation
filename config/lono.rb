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
    'key' => 'Environment',
    'value' => '!FindInMap [EnvironmentConfigurationMap, !Ref Environment, EnvironmentLongName]'
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
  },
  {
    'key' => 'Criticality',
    'value' => '!FindInMap [EnvironmentConfigurationMap, prod, Criticality]'
  },
  {
    'key' => 'DataClassification',
    'value' => '!FindInMap [EnvironmentConfigurationMap, prod, DataClassification]'
  }
]

shared = {
  'id' => 'SharedResources',
  'key' => 'stacks/pipeline/core-stack.yaml',
  'tags' => tags,
  'params' => [
    {
      'key' => 'ProjectName',
      'value' => '!Ref ProjectName'
    }, {
      'key' => 'RootDomain',
      'value' => '!Ref RootDomain'
    }, {
      'key' => 'RootDomainZoneID',
      'value' => '!Ref RootDomainZoneID'
    }, {
      'key' => 'SubDomain',
      'value' => 'calculators'
    }, {
      'key' => 'UserRole',
      'value' => '!Ref UserRole'
    }
  ]
}

ipRange = {
  'key' => 'AllowedIPRange',
  'value' => '0.0.0.0/0'
}
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

suf = {
  'id' => 'SUF',
  'key' => 'stacks/pipeline/small-apps-project-stack.yaml',
  'tags' => tags,
  'params' => [ipRange, rootDomain, rootZone, userRole, {
    'key' => 'ProjectName',
    'value' => 'SUF'
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
end

template 'stacks/pipeline/development-sad-pipeline.yaml' do
  source 'stacks/pipeline/development-sad-pipeline-stack.yaml.erb'
end

template 'stacks/pipeline/test-sad-pipeline.yaml' do
  source 'stacks/pipeline/test-sad-pipeline-stack.yaml.erb'
end

template 'stacks/pipeline/production-sad-pipeline.yaml' do
  source 'stacks/pipeline/production-sad-pipeline-stack.yaml.erb'
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
