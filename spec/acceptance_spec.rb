require 'spec_helper'

describe 'Policies', js: true do
  include Capybara::DSL

  specify do
    visit '/'
    click_on 'New Policy'
    fill_in 'Title', with: 'Socialize schema changes'
    fill_in 'Description', with: 'Schema changes are difficult to reverse. Before making schema changes, discuss them with other members of the team.'
    click_on 'Create Policy'
    expect(page).to have_content('Socialize schema changes')
    expect(page).to have_content('Proposal')

    click_on 'view'
    expect(page).to have_content('Socialize schema changes')
    expect(page).to have_content('Schema changes are difficult to reverse. Before making schema changes, discuss them with other members of the team.')
    expect(page.html).to match('Proposal')

    click_on 'Edit'
    expect(page).to have_content('Edit "Socialize schema changes"')
    select 'Experiment', from: 'Status'
    click_on 'Update Policy'
    expect(page).to have_content('Socialize schema changes')
    expect(page.html).to match('Experiment')

    click_on 'New Policy'
    fill_in 'Title', with: 'Pair full time'
    fill_in 'Description', with: 'Pairing prevents siloing and speeds up the feedback loop.'
    click_on 'Create Policy'
    expect(page).to have_content 'Pair full time'

    click_on 'Experiment'
    expect(page).to have_content('Socialize schema changes')
    expect(page).to_not have_content('Pair full time')
  end
end
