@projectName = 'calculators'
@appBucketName = "pr52-s3-#{@projectName}-hosting-${AWS::AccountId}-"
@stagingBucket = "pr52-s3-#{@projectName}${ProjectName}-pipelinestaging-${AWS::AccountId}-"

@tags = [
  {
    'key' => 'Owner',
    'value' => 'Connor Bray'
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
    'value' => 'PRJ0021389'
  },
  {
    'key' => 'ProjectCodeBU',
    'value' => 'TODO'
  }
]

@ip_white_list = [{
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

@dev_tags = [{
  'key' => 'Environment',
  'value' => '!FindInMap [EnvironmentConfiguration, dev, EnvironmentLongName]'
}, {
  'key' => 'Criticality',
  'value' => '!FindInMap [EnvironmentConfiguration, dev, Criticality]'
}, {
  'key' => 'DataClassification',
  'value' => '!FindInMap [EnvironmentConfiguration, dev, DataClassification]'
}]

@test_tags = [{
  'key' => 'Environment',
  'value' => '!FindInMap [EnvironmentConfiguration, test, EnvironmentLongName]'
}, {
  'key' => 'Criticality',
  'value' => '!FindInMap [EnvironmentConfiguration, test, Criticality]'
}, {
  'key' => 'DataClassification',
  'value' => '!FindInMap [EnvironmentConfiguration, test, DataClassification]'
}]

@prod_tags = [{
  'key' => 'Environment',
  'value' => '!FindInMap [EnvironmentConfiguration, prod, EnvironmentLongName]'
}, {
  'key' => 'Criticality',
  'value' => '!FindInMap [EnvironmentConfiguration, prod, Criticality]'
}, {
  'key' => 'DataClassification',
  'value' => '!FindInMap [EnvironmentConfiguration, prod, DataClassification]'
}]

@core_tags = @tags + @prod_tags
