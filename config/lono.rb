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

dev_tags = [{
  'key' => 'Environment',
  'value' => '!FindInMap [EnvironmentConfiguration, dev, EnvironmentLongName]'
}, {
  'key' => 'Criticality',
  'value' => '!FindInMap [EnvironmentConfiguration, dev, Criticality]'
}, {
  'key' => 'DataClassification',
  'value' => '!FindInMap [EnvironmentConfiguration, dev, DataClassification]'
}]

test_tags = [{
  'key' => 'Environment',
  'value' => '!FindInMap [EnvironmentConfiguration, test, EnvironmentLongName]'
}, {
  'key' => 'Criticality',
  'value' => '!FindInMap [EnvironmentConfiguration, test, Criticality]'
}, {
  'key' => 'DataClassification',
  'value' => '!FindInMap [EnvironmentConfiguration, test, DataClassification]'
}]

prod_tags = [{
  'key' => 'Environment',
  'value' => '!FindInMap [EnvironmentConfiguration, prod, EnvironmentLongName]'
}, {
  'key' => 'Criticality',
  'value' => '!FindInMap [EnvironmentConfiguration, prod, Criticality]'
}, {
  'key' => 'DataClassification',
  'value' => '!FindInMap [EnvironmentConfiguration, prod, DataClassification]'
}]

root_domain = {
  'key' => 'RootDomain',
  'value' => '!Join [., [calculators, !Ref RootDomain]]'
}
root_zone = {
  'key' => 'RootDomainZoneID',
  'value' => '!Ref RootDomainZoneID'
}
user_role = {
  'key' => 'UserRole',
  'value' => '!Ref UserRole'
}
common_repo = {
  'key' => 'CommonRepo',
  'value' => 'calculators-shared'
}

ip_white_list = [{
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
  'tags' => tags + prod_tags,
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
    }, root_zone, user_role
  ]
}

suf = {
  'id' => 'SUF',
  'key' => 'stacks/small-apps-project-stack.yaml',
  'tags' => tags,
  'params' => [root_domain, root_zone, user_role, common_repo, {
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
    'dev_tags' => dev_tags,
    'test_tags' => test_tags,
    'prod_tags' => prod_tags
  )
end

template 'stacks/pipeline/development-sad-pipeline.yaml' do
  source 'stacks/pipeline/development-sad-pipeline-stack.yaml.erb'
  variables(
    'ip_white_list' => ip_white_list,
    'tag' => 'dev'
  )
end

template 'stacks/pipeline/test-sad-pipeline.yaml' do
  source 'stacks/pipeline/test-sad-pipeline-stack.yaml.erb'
  variables(
    'ip_white_list' => ip_white_list,
    'tag' => 'test'
  )
end

template 'stacks/pipeline/production-sad-pipeline.yaml' do
  source 'stacks/pipeline/production-sad-pipeline-stack.yaml.erb'
  variables(
    'ip_white_list' => ip_white_list,
    'tag' => 'prod',
    'enableDNS' => true
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
