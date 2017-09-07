template "sqk-accounting" do
  source "root-stack"
  variables(
    'stacks' => [{
      'id' => 'ProductionStack',
      'url' => 'stacks/sqk-accounting/production.yml'
    }]
  )
end
