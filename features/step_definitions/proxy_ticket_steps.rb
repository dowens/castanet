Given /^(?:has )?a valid service ticket for "([^"]*)"$/ do |service|
  When %Q{a user requests a service ticket for "#{service}"}

  @st.present!

  @st.should be_ok
end

When /^(?:that user )?requests a proxy ticket for "([^"]*)"$/ do |service|
  # The request is deferred because some steps expect exceptions to be raised.
  @deferred_request = lambda do
    @st.retrieve_pgt!

    @pt = proxy_ticket(@st.pgt, service)
  end
end

When /^that user requests a proxy ticket for "([^"]*)" with a bad PGT$/ do |service|
  @deferred_request = lambda do
    @pt = proxy_ticket('PGT-1bad', service)
  end
end

When /^that proxy ticket is checked for "([^"]*)"$/ do |service|
  @deferred_request.call

  @valid = proxy_ticket_ok?(@pt, service)
end

When /^that proxy ticket is checked again for "([^"]*)"$/ do |service|
  @valid = proxy_ticket_ok?(@pt, service)
end

When /^the proxy ticket "([^"]*)" is checked for "([^"]*)"$/ do |pt, service|
  @valid = proxy_ticket_ok?(pt, service)
end

Then /^that user should receive a proxy ticket$/ do
  @deferred_request.should_not raise_error

  @pt.ticket.should_not be_nil
end

Then /^that proxy ticket should be valid$/ do
  @valid.should be_true
end

Then /^that proxy ticket should not be valid$/ do
  @valid.should be_false
end

Then /^the proxy ticket request should fail with "([^"]*)"$/ do |message|
  @deferred_request.should raise_error(Castanet::ProxyTicketError, /#{message}/)
end
