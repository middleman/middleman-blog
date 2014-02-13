# -*- coding: utf-8 -*-

require 'middleman-blog/uri_templates'

describe 'Middleman::Blog::UriTemplates' do
  include Middleman::Blog::UriTemplates

  describe 'safe_parameterize' do
    it 'can parameterize normal strings' do
      safe_parameterize('Some FUN stuff!').should == 'some-fun-stuff'
    end

    it "doesn't mangle unicode strings" do
      safe_parameterize('☆☆☆').should == '☆☆☆'
      safe_parameterize('明日がある').should == '明日がある'
    end

    it "still transliterates when it's safe" do
      safe_parameterize('Schlagwörter').should == 'schlagworter'
    end

    it "can handle mixed strings" do
      safe_parameterize('What ☆☆☆!').should == 'what-☆☆☆'
    end

    it "can handle numbers" do
      safe_parameterize(1).should == '1'
    end
  end

  describe 'extract_params' do
    it 'matches correctly' do
      template = uri_template('{year}/{month}/{day}/{title}/{+path}')
      params = extract_params(template, '2013/12/13/foo-bar/foo/bar.html')

      params['year'].should == '2013'
      params['month'].should == '12'
      params['day'].should == '13'
      params['title'].should == 'foo-bar'
      params['path'].should == 'foo/bar.html'
    end

    it 'returns nil if there is no match' do
      template = uri_template('{year}/{month}/{day}/{title}/{+path}')
      extract_params(template, 'foo/bar.html').should == nil
    end

    it 'returns nil if there is no match in the date bits' do
      template = uri_template('{year}/{month}/{day}/{title}/{+path}')
      params = extract_params(template, '2a13/1a2/1s3/foo-bar/foo/bar.html')
    end

    it 'matches even when the path contains spaces' do
      template = uri_template('{year}/{month}/{day}/{title}/{+path}')
      params = extract_params(template, '2013/12/13/foo - bar/foo/bar.html')

      params['year'].should == '2013'
      params['month'].should == '12'
      params['day'].should == '13'
      params['title'].should == 'foo - bar'
      params['path'].should == 'foo/bar.html'
    end
  end
end
