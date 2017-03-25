# -*- coding: utf-8 -*-

require 'middleman-blog/uri_templates'

describe 'Middleman::Blog::UriTemplates' do
  include Middleman::Blog::UriTemplates

  describe 'safe_parameterize' do
    it 'can parameterize normal strings' do
      expect(safe_parameterize('Some FUN stuff!')) == 'some-fun-stuff'
    end

    it "doesn't mangle unicode strings" do
      expect(safe_parameterize('☆☆☆')) == '☆☆☆'
      expect(safe_parameterize('明日がある')) == '明日がある'
    end

    it "still transliterates when it's safe" do
      expect(safe_parameterize('Schlagwörter')) == 'schlagworter'
    end

    it "can handle mixed strings" do
      expect(safe_parameterize('What ☆☆☆!')) == 'what-☆☆☆'
    end

    it "can handle numbers" do
      expect(safe_parameterize(1)) == '1'
    end
  end

  describe 'extract_params' do
    it 'matches correctly' do
      template = uri_template('{year}/{month}/{day}/{title}/{+path}')
      params = extract_params(template, '2013/12/13/foo-bar/foo/bar.html')

      expect(params['year'])  == '2013'
      expect(params['month']) == '12'
      expect(params['day'])   == '13'
      expect(params['title']) == 'foo-bar'
      expect(params['path'])  == 'foo/bar.html'
    end

    it 'returns nil if there is no match' do
      template = uri_template('{year}/{month}/{day}/{title}/{+path}')
      expect(extract_params(template, 'foo/bar.html')) == nil
    end

    it 'returns nil if there is no match in the date bits' do
      template = uri_template('{year}/{month}/{day}/{title}/{+path}')
      params = extract_params(template, '2a13/1a2/1s3/foo-bar/foo/bar.html')
    end

    it 'matches even when the path contains spaces' do
      template = uri_template('{year}/{month}/{day}/{title}/{+path}')
      params = extract_params(template, '2013/12/13/foo - bar/foo/bar.html')

      expect(params['year'])  == '2013'
      expect(params['month']) == '12'
      expect(params['day'])   == '13'
      expect(params['title']) == 'foo - bar'
      expect(params['path'])  == 'foo/bar.html'
    end
  end

  describe 'extract_directory_path' do

    it 'can extract a directory path' do

      template     = uri_template( '{year}/{month}/{day}/{title}/{+path}' )
      params       = extract_params( template, '2013/12/13/foo-bar/foo/bar.html' )
      article_path = apply_uri_template template, params

      expect( extract_directory_path( article_path ) ) == '2013-12-13-foo-bar-foo-bar'

    end

  end

end
