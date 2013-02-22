#!/usr/bin/env ruby
require 'mechanize'

agent = Mechanize.new
agent.get('http://localhost:8111') do |page|
  form = page.form_with(:action => "/showAgreement.html") do |form|
    form.input.with(:class => "_accept").check
  end

  page = form.click_button(form.button_with(:name => 'Continue'))

  form = page.form_with(:action => "/createAdminSubmit.html") do |form|
    form['username1'] = 'pivotal'
    form['password1'] = 'password'
    form['retypedPassword'] = 'password'
  end

  page = form.click_button(form.button_with(:value => 'Create Account'))
end
