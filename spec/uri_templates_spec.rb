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
  end
end
