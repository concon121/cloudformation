template 'prod/stacks/pipeline/core-stack' do
  source 'stacks/pipeline/core-stack'
end

template 'prod/stacks/small-apps-project-stack' do
  source 'stacks/small-apps-project-stack'
end

root_domain = {
  'key' => 'RootDomain',
  'value' => '!Join [., [calculators, !Ref RootDomain]]'
}
root_zone = {
  'key' => 'RootDomainZoneID',
  'value' => '!Ref RootDomainZoneID'
}
common_repo = {
  'key' => 'CommonRepo',
  'value' => 'calculators-shared'
}

shared = {
  'id' => 'SharedResources',
  'key' => 'stacks/pipeline/core-stack',
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
    }, root_zone
  ]
}

suf = {
  'id' => 'SUF',
  'key' => 'stacks/small-apps-project-stack',
  'params' => [root_domain, root_zone, common_repo, {
    'key' => 'ProjectName',
    'value' => 'suf'
  }]
}

# ============================================================================
# Main Stack
# ============================================================================

template 'small-apps-domain' do
  source 'small-apps-domain'
  variables(
    'stacks' => [shared, suf],
    'pipeline' => {
      testing: true,
      codecommitPolicy: true
    }
  )
end
