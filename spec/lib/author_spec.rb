require 'spec_helper'
require 'lib/author'

describe Author, '.find_by_name' do
  before do
    authors = [{'name' => 'Ron Burgundy'}]
    Author.set_authors(authors)
  end

  it 'returns an author with matching name' do
    name = 'Ron Burgundy'

    result = Author.find_by_name(name)

    expect(result).to be_an_instance_of Author
    expect(result.name).to eq name
  end
end

describe Author, '#avatar' do
  it 'returns the avatar url for author' do
    name = 'Ron Burgundy'

    result = Author.new(name: name).avatar

    expect(result).to eq '/images/avatars/ron-burgundy.jpg'
  end
end

describe Author, '#first_name' do
  it 'returns the first name of the author' do
    name = 'Ron Burgundy'

    result = Author.new(name: name).first_name

    expect(result).to eq 'Ron'
  end
end

describe Author, '#google_plus_url' do
  it 'returns the authors google plus url' do
    google_plus_id = 'fake_id'

    result = Author.new(google_plus_id: google_plus_id).google_plus_url

    expect(result).to eq "https://plus.google.com/#{google_plus_id}"
  end
end

describe Author, '#twitter_url' do
  it 'returns the authors twitter url' do
    twitter_handle = 'fake_handle'

    result = Author.new(twitter_handle: twitter_handle).twitter_url

    expect(result).to eq "https://twitter.com/#{twitter_handle}"
  end
end
