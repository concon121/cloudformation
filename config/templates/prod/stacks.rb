template "stacks/sqk-accounting/production" do
  source "stacks/sqk-accounting"
  variables(
    instance_type: "t2.small",
    port: "80",
    volume_size: "20",
    availability_zone: "us-east-1e"
  )
end
