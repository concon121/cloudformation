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

origin_access_identity = {
  'key' => 'CloudFrontOriginAccessIdentityResource',
  'value' => '!Ref CloudFrontOriginAccessIdentityResource'
}

template 'prod/stacks/pipeline/core-stack' do
  source 'stacks/pipeline/core-stack'
end

template 'prod/stacks/small-apps-project-stack' do
  source 'stacks/small-apps-project-stack'
end

template 'prod/stacks/hosting/development-hosting-stack' do
  source 'stacks/hosting/development-hosting-stack'
end

template 'prod/stacks/hosting/test-hosting-stack' do
  source 'stacks/hosting/test-hosting-stack'
end

template 'prod/stacks/hosting/production-hosting-stack' do
  source 'stacks/hosting/production-hosting-stack'
  variables(
    'enableDNS' => true
  )
end

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

dev_hosting = {
  'id' => 'DevelopmentHosting',
  'key' => 'stacks/hosting/development-hosting-stack'
}

test_hosting = {
  'id' => 'TestHosting',
  'key' => 'stacks/hosting/test-hosting-stack'
}

prod_hosting = {
  'id' => 'ProductionHosting',
  'key' => 'stacks/hosting/production-hosting-stack',
  'params' => [{
    'key' => 'RootDomain',
    'value' => '!Ref RootDomain'
  }, root_zone, origin_access_identity]
}

small_apps = {
  'id' => 'SmallApps',
  'key' => 'stacks/small-apps-project-stack',
  'params' => [{
    'key' => 'CloudFrontId',
    'value' => '!GetAtt [ProductionHosting, Outputs.CloudFrontId]'
  }]
}

# ============================================================================
# Main Stack
# ============================================================================

template 'small-apps-domain' do
  source 'small-apps-domain'
  variables(
    'stacks' => [dev_hosting, test_hosting, prod_hosting, small_apps]

  )
end

template 'origin-access-identity' do
  source 'origin-access-identity'
end
