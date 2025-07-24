require 'spec_helper'
require 'middleman-blog/alias_pages'
require 'middleman-blog/uri_templates'

describe 'Middleman::Blog::AliasPages' do
  include Middleman::Blog::UriTemplates

  let(:mock_app) { double('app') }
  let(:mock_sitemap) { double('sitemap') }
  let(:mock_blog_controller) { double('blog_controller') }
  let(:mock_blog_data) { double('blog_data') }
  let(:mock_article) { double('article') }
  let(:mock_options) { double('options') }

  before do
    allow(mock_app).to receive(:sitemap).and_return(mock_sitemap)
    allow(mock_blog_controller).to receive(:data).and_return(mock_blog_data)
    allow(mock_blog_controller).to receive(:options).and_return(mock_options)
    allow(mock_article).to receive(:destination_path).and_return('2024/03/14/pi-day.html')
    allow(mock_article).to receive(:date).and_return(Date.new(2024, 3, 14))
    allow(mock_article).to receive(:slug).and_return('pi-day')
    allow(mock_article).to receive(:lang).and_return(:en)
    allow(mock_article).to receive(:locale).and_return(:en)
    allow(mock_article).to receive(:metadata).and_return({ page: {} })
  end

  describe 'alias URL generation' do
    let(:alias_patterns) { [':year-:month-:day-:title.html', ':year/:month-:day-:title'] }

    before do
      allow(mock_options).to receive(:aliases).and_return(alias_patterns)
      allow(mock_blog_data).to receive(:articles).and_return([mock_article])
    end

    context 'when testing alias path generation' do
      let(:alias_pages) { Middleman::Blog::AliasPages.new(mock_app, mock_blog_controller) }

      it 'generates correct alias paths from patterns' do
        template1 = uri_template(':year-:month-:day-:title.html')
        template2 = uri_template(':year/:month-:day-:title')
        
        # Test path generation directly
        alias_path1 = alias_pages.send(:generate_alias_path, template1, mock_article)
        alias_path2 = alias_pages.send(:generate_alias_path, template2, mock_article)
        
        expect(alias_path1).to eq('2024-03-14-pi-day.html')
        expect(alias_path2).to eq('2024/03-14-pi-day')
      end

      it 'filters out aliases that match main permalink' do
        # Test with an alias pattern that would match the main permalink
        template = uri_template(':year/:month/:day/:title.html')
        
        alias_path = alias_pages.send(:generate_alias_path, template, mock_article)
        expect(alias_path).to eq('2024/03/14/pi-day.html')
        
        # This would be filtered out in manipulate_resource_list because it matches destination_path
        expect(alias_path).to eq(mock_article.destination_path)
      end
    end

    context 'when testing permalink options generation' do
      let(:alias_pages) { Middleman::Blog::AliasPages.new(mock_app, mock_blog_controller) }

      it 'generates correct permalink options from article data' do
        params = alias_pages.send(:permalink_options, mock_article)
        
        expect(params[:year]).to eq('2024')
        expect(params[:month]).to eq('03')
        expect(params[:day]).to eq('14')
        expect(params[:title]).to eq('pi-day')
        expect(params[:lang]).to eq('en')
        expect(params[:locale]).to eq('en')
      end
    end
  end

  describe 'empty aliases configuration' do
    before do
      allow(mock_options).to receive(:aliases).and_return([])
      allow(mock_blog_data).to receive(:articles).and_return([mock_article])
    end

    it 'returns original resources when aliases array is empty' do
      alias_pages = Middleman::Blog::AliasPages.new(mock_app, mock_blog_controller)
      resources = ['existing_resource']
      result = alias_pages.manipulate_resource_list(resources)
      
      # Should return the same resources since no aliases are configured
      expect(result).to eq(resources)
    end
  end

  describe 'alias pattern handling' do
    before do
      allow(mock_blog_data).to receive(:articles).and_return([mock_article])
    end

    it 'handles multiple alias patterns' do
      patterns = [':year-:month-:day-:title.html', ':year/:month-:day-:title', 'archive/:title']
      allow(mock_options).to receive(:aliases).and_return(patterns)
      
      alias_pages = Middleman::Blog::AliasPages.new(mock_app, mock_blog_controller)
      
      # Test that all patterns are converted to templates
      expect(alias_pages.instance_variable_get(:@alias_templates).length).to eq(3)
    end

    it 'handles nil alias patterns gracefully' do
      allow(mock_options).to receive(:aliases).and_return(nil)
      
      expect {
        Middleman::Blog::AliasPages.new(mock_app, mock_blog_controller)
      }.not_to raise_error
    end
  end
end