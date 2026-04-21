require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Rack driver: no browser required (reliable on GitHub Actions). Use Selenium locally if you add JS-heavy flows.
  driven_by :rack_test
end
