@tag = 'prod'
@lambda_version = ENV['LAMBDA_VERSION']

@projects = [{
  'id' => 'Shared',
  'name' => 'shared'
}, {
  'id' => 'SUF',
  'name' => 'suf'
}]
