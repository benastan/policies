require 'spec_helper'

describe 'Policies', js: true do
  include Capybara::DSL

  specify do
    visit '/'

    click_on 'Projects'
    click_on 'New Project'
    fill_in 'Title', with: 'My Startup'
    click_on 'Create Project'
    click_on 'view'
    click_on 'New Policy'
    fill_in 'Title', with: 'Socialize schema changes'
    fill_in 'Description', with: 'Schema changes are difficult to reverse.'
    click_on 'Create Policy'
    expect(page).to have_content('Socialize schema changes')
    expect(page).to have_content('Proposal')

    click_on 'view'
    expect(page).to have_content('Socialize schema changes')
    expect(page).to have_content('Schema changes are difficult to reverse.')
    expect(page.html).to match('Proposal')

    click_on 'Edit'
    expect(page).to have_content('Edit "Socialize schema changes"')
    fill_in 'Title', with: 'Blargle Snargle'
    click_on 'cancel'
    expect(page).to_not have_content('Blargle Snargle')
    expect(page).to_not have_content('Edit "Socialize schema changes"')

    Timecop.travel(Date.new(2014, 01, 23)) do
      click_on 'Edit'
      expect(page).to have_content('Edit "Socialize schema changes"')
      fill_in 'Title', with: 'Socialize all schema changes'
      fill_in 'Description', with: 'Schema changes are difficult to reverse. Before making schema changes, discuss them with other members of the team.'
      select 'Experiment', from: 'Status'
      click_on 'Update Policy'
      expect(page).to have_content('Socialize all schema changes')
      expect(page).to have_content('Schema changes are difficult to reverse. Before making schema changes, discuss them with other members of the team.')
      click_on 'Edit'
    expect(find_field('Status').value).to eq 'experiment'
      click_on 'cancel'
    end

    Timecop.travel(Date.new(2014, 01, 24)) do
      click_on 'Edit'
      expect(page).to have_content('Edit "Socialize all schema changes"')
      select 'Policy', from: 'Status'
      click_on 'Update Policy'

      expect(page).to have_content('Socialize all schema changes')
      expect(page.html).to match('Experiment')
      within '.list-group', text: 'January 23, 2014' do
        policy_state_change_dates = page.all('.list-group-item .row .col-sm-2').map(&:text)
        expect(policy_state_change_dates).to eq [ 'January 23, 2014', 'January 24, 2014' ]
      end
    end

    click_on 'My Startup'
    click_on 'New Policy'
    fill_in 'Title', with: 'Pair full time'
    fill_in 'Description', with: 'Pairing prevents siloing and speeds up the feedback loop.'
    click_on 'Create Policy'
    expect(page).to have_content 'Pair full time'

    click_on 'New Policy'
    fill_in 'Title', with: 'Daily stand up at 9:11am'
    fill_in 'Description', with: 'To establish a daily feedback loop, stand up occurs at 9:11am. Each team member briefly discusses what they accomplished on the previous work day.'
    click_on 'Create Policy'

    within '.list-group-item', text: 'Daily stand up at 9:11am' do
      click_on 'view'
    end

    click_on 'Edit'
    select 'Experiment', from: 'Status'
    click_on 'Update Policy'
    click_on 'My Startup'
    click_on 'Proposal'
    expect(page).to_not have_content('Socialize all schema changes')
    expect(page).to_not have_content('Daily stand up at 9:11am')
    expect(page).to have_content('Pair full time')

    click_on 'Experiment'
    expect(page).to_not have_content('Socialize all schema changes')
    expect(page).to have_content('Daily stand up at 9:11am')
    expect(page).to_not have_content('Pair full time')
    
    click_on 'Policy'
    expect(page).to have_content('Socialize all schema changes')
    expect(page).to_not have_content('Daily stand up at 9:11am')
    expect(page).to_not have_content('Pair full time')
    
    click_on 'All'
    expect(page).to have_content('Socialize all schema changes')
    expect(page).to have_content('Daily stand up at 9:11am')
    expect(page).to have_content('Pair full time')

    within('.breadcrumb') { click_on 'Projects'}
    click_on 'New Project'
    fill_in 'Title', with: 'My Other Startup'
    click_on 'Create Project'
    within '.list-group-item', text: 'My Other Startup' do
      click_on 'view'
    end
    
    click_on 'New Policy'
    fill_in 'Title', with: 'Discuss pain points in a weekly retro'
    fill_in 'Description', with: 'Discussing pain points as they arise can be noisy and ineffective. Pain points should be discussed weekly during a dedicated meeting.'
    click_on 'Create Policy'
    
    expect(page).to have_content('Discuss pain points in a weekly retro')
    expect(page).to_not have_content('Socialize all schema changes')
    expect(page).to_not have_content('Daily stand up at 9:11am')
    expect(page).to_not have_content('Pair full time')
  end
end
